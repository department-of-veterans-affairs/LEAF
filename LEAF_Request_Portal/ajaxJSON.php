<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    JSON index for legacy API
    Date Created: August 13, 2009

*/

error_reporting(E_ERROR);

require_once 'globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

$login->loginUser();

$action = isset($_GET['a']) ? $_GET['a'] : '';

$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

switch ($action) {
    case 'getform':
        header('Content-type: application/json');
        echo $form->getFormJSON($_GET['recordID']);

        break;
    case 'getprogress': // support legacy customizations
        header('Content-type: application/json');
        // this method does not exist in Form class
        // echo $form->getProgressJSON($_GET['recordID']);
        // but this one does
        echo $form->getProgress($_GET['recordID']);

        break;
    case 'getrecentactions':
        if (!is_numeric($_GET['lastStatusTime']))
        {
            exit();
        }
        $vars = array(':lastStatusTime' => $_GET['lastStatusTime']);
        $res = $db->prepared_query('SELECT recordID FROM action_history
        								WHERE time > :lastStatusTime
        								GROUP BY recordID', $vars);
        echo json_encode($res);

        break;
    case 'getlastaction':
        if (!is_numeric($_GET['recordID']))
        {
            exit();
        }

        $vars = array(':recordID' => $_GET['recordID']);
        $res = $db->prepared_query('SELECT * FROM records_dependencies
    									LEFT JOIN category_count USING (recordID)
    									LEFT JOIN categories USING (categoryID)
    									LEFT JOIN step_dependencies USING (dependencyID)
    									LEFT JOIN workflow_routes USING (workflowID, stepID)
    									LEFT JOIN workflow_steps USING (workflowID, stepID)
    									LEFT JOIN actions USING (actionType)
    									LEFT JOIN dependencies USING (dependencyID)
    									RIGHT JOIN action_history USING (recordID, dependencyID, actionType)
    									WHERE records_dependencies.recordID=:recordID
    										AND actionType IS NOT NULL
    									ORDER BY actionID DESC
                                        LIMIT 1', $vars);

        $record = $res[0];
        foreach (array_keys($record) as $key)
        {
            $record[$key] = Leaf\XSSHelpers::xscrub($record[$key]);
        }

        echo json_encode($record);

        break;
    default:
        break;
}
