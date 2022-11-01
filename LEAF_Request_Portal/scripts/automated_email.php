<?php


$currDir = dirname(__FILE__);

include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../db_config.php';

require_once $currDir . '/../Email.php';
require_once $currDir . '/../VAMC_Directory.php';
ini_set('display_errors',1);
error_reporting(E_ALL);

// copied from FormWorkflow.php just to get us moved along.
$protocol = 'https';
$siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';

// this was what the random function I found used.
$comment = '';

$db_config = new DB_Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$getWorkflowStepsRes = $db->prepared_query('SELECT workflowID, stepID,stepTitle,stepData
FROM workflow_steps WHERE stepData LIKE \'%"AutomateEmailGroup":"true"%\';', []);

// do we have automated notification setup here
if (empty($getWorkflowStepsRes)) {
    // @todo: need to look at how other scripts output
    echo 'No automated emails setup!';
    exit();
}
// go over the selected events
foreach ($getWorkflowStepsRes as $workflowStep) {

    // get our data, we need to see how many days back we need to look.
    $eventDataArray = json_decode($workflowStep['stepData'], true, 2);
    // DateSelected * DaysSelected = how many days to bug this person.
    var_dump($eventDataArray);
    var_dump($workflowStep);exit();
    // step id, i think workflow id is also needed here
    $getRecordVar = [':stepID' => $workflowStep['stepID']];

    // get the records that have not been responded to, had actions taken on, in x amount of time
    // currently this does not get based on that time FYI
    $getRecordSql = 'SELECT fulfillmentTime, records.recordID, records.title, records.userID, service 
        FROM records_step_fulfillment 
        JOIN records_workflow_state ON records_step_fulfillment.stepID = records_workflow_state.stepID
        JOIN records ON records.recordID = records_workflow_state.recordID AND records.recordID = records_step_fulfillment.recordID
        JOIN services USING(serviceID) 
        WHERE records_step_fulfillment.stepID = :stepID
        AND deleted = 0;';

    $getRecordRes = $db->prepared_query($getRecordSql, $getRecordVar);

    // make sure we have records to work with
    if (empty($getRecordRes)) {
        // @todo: need to look at how other scripts output errors
        echo 'There are no records to be notified';
        exit();
    }

    // go through each and send an email
    foreach ($getRecordRes as $record) {
var_dump($record);
        // send the email
        $email = new Email();

        $title = strlen($record['title']) > 45 ? substr($record['title'], 0, 42) . '...' : $record['title'];

        // add in variables for the smarty template
        $email->addSmartyVariables(array(
            "truncatedTitle" => $title,
            "fullTitle" => $record['title'],
            "recordID" => $record['recordID'],
            "service" => $record['service'],
            "stepTitle" => $workflowStep['stepTitle'],
            "comment" => $comment,
            "siteRoot" => $siteRoot
        ));

        // we will use an existing one for just a scoatch
        $email->setTemplateByID(\Email::SEND_BACK);

        // get who we need to send this to!
        $dir = new VAMC_Directory;

        // this will be the from person
        $requester = $dir->lookupLogin($record['userID']);

        // folks that will need to be notified of this!
//        $author = $dir->lookupLogin($this->login->getUserID());
//        $email->addRecipient($requester[0]['Email']);
//        $email->addRecipient($author[0]['Email']);
//
//        // Get backups to requester so they can be notified as well
//        $nexusDB = $this->login->getNexusDB();
//        $vars = array(
//            ':reqEmpUID' => $requester[0]['empUiD'],
//            ':authEmpUID' => $author[0]['empUID']
//        );
//        $strSQL = "SELECT DISTINCT backupEmpUID FROM relation_employee_backup " .
//            "WHERE empUID IN (:reqEmpUID, :authEmpUID)";
//        $backupIds = $nexusDB->prepared_query($strSQL, $vars);
//
//        // Add backups to email recepients
//        foreach ($backupIds as $backup) {
//            // Don't re-email requestor or author if they are backups of each other
//            if (($backup['backupEmpUID'] != $author[0]['empUID']) &&
//                ($backup['backupEmpUID'] != $requester[0]['empID'])) {
//                $theirBackup = $dir->lookupEmpUID($backup['backupEmpUID']);
//                $email->addRecipient($theirBackup[0]['Email']);
//            }
//        }

        $email->setSender($requester[0]['Email']);

        $email->sendMail();
        echo "email sent <br>";
    }
}
