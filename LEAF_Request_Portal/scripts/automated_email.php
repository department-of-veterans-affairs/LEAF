<?php

$currDir = dirname(__FILE__);

include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../db_config.php';

require_once $currDir . '/../Email.php';
require_once $currDir . '/../VAMC_Directory.php';

// copied from FormWorkflow.php just to get us moved along.
$protocol = 'https';


$request_uri = str_replace(['/var/www/html/','/scripts'],'',$_SERVER['PWD']);

$siteRoot = "{$protocol}://" . HTTP_HOST . '/' . $request_uri . '/';

// this was what the random function I found used.
$comment = '';

$db_config = new DB_Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$getWorkflowStepsSQL = 'SELECT workflowID, stepID,stepTitle,stepData
FROM workflow_steps WHERE stepData LIKE \'%"AutomateEmailGroup":"true"%\';';
$getWorkflowStepsRes = $db->prepared_query($getWorkflowStepsSQL, []);

// do we have automated notification setup here
if (empty($getWorkflowStepsRes)) {
    // @todo: need to look at how other scripts output
    echo "No automated emails setup! \r\n";
    exit();
}
// go over the selected events
foreach ($getWorkflowStepsRes as $workflowStep) {

    // get our data, we need to see how many days back we need to look.
    $eventDataArray = json_decode($workflowStep['stepData'], true, 3);

    // DateSelected * DaysSelected * what is a day anyway= how many days to bug this person.
    $daysago = $eventDataArray['AutomatedEmailReminders']['DaysSelected'];

    // pass ?current=asdasd to get the present time for testing purposes
    if (!empty($_GET['current'])) {
        $daysagotimestamp = time();
        echo "Present day, Present time \r\n";
    } else{
        $daysagotimestamp = time() - ($daysago * 60 * 60 * 24);

        echo "Working on step: {$workflowStep['stepID']}, time calculation: ".time()." - $daysago = $daysagotimestamp / ".date('Y-m-d H:i:s',$daysagotimestamp)."\r\n";
    }


    // step id, I think workflow id is also needed here
    $getRecordVar = [':stepID' => $workflowStep['stepID'], ':lastNotified' => date('Y-m-d H:i:s',$daysagotimestamp)];

    // get the records that have not been responded to, had actions taken on, in x amount of time
    $getRecordSql = 'SELECT records.recordID, records.title, records.userID, service 
        FROM records_workflow_state
        JOIN records ON records.recordID = records_workflow_state.recordID
        JOIN services USING(serviceID) 
        WHERE records_workflow_state.stepID = :stepID
        AND lastNotified <= :lastNotified
        AND deleted = 0;';

    $getRecordRes = $db->prepared_query($getRecordSql, $getRecordVar);

    // make sure we have records to work with
    if (empty($getRecordRes)) {
        // @todo: need to look at how other scripts output errors
        echo "There are no records to be notified for this step! \r\n";
        continue;
    }

    // go through each and send an email
    foreach ($getRecordRes as $record) {

        // send the email
        $email = new Email();

        // ive seen examples using the attachApproversAndEmail method and some had smarty vars and some did not.
        $title = strlen($record['title']) > 45 ? substr($record['title'], 0, 42) . '...' : $record['title'];

        // add in variables for the smarty template
        $email->addSmartyVariables(array(
            "daysSince" => $daysago,
            "truncatedTitle" => $title,
            "fullTitle" => $record['title'],
            "recordID" => $record['recordID'],
            "service" => $record['service'],
            "stepTitle" => $workflowStep['stepTitle'],
            "comment" => $comment,
            "siteRoot" => $siteRoot
        ));

        // need to get the emails sending to make sure this actually works!
        $email->attachApproversAndEmail($record['recordID'],\Email::AUTOMATED_EMAIL_REMINDER,$record['userID']);

        // update the notification timestamp, this could be moved to batch, just trying to get a prototype working
        $updateRecordsWorkflowStateVars = [
            ':recordID' => $record['recordID'],
            ':lastNotified' => date('Y-m-d H:i:s')
        ];
        $updateRecordsWorkflowStateSql = 'UPDATE records_workflow_state
                                            SET lastNotified=:lastNotified
                                            WHERE recordID=:recordID';
        $db->prepared_query($updateRecordsWorkflowStateSql, $updateRecordsWorkflowStateVars);

        echo "Email sent for {$record['recordID']} \r\n";
    }
}
