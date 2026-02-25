<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

set_time_limit(240);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$oc_login->setBaseDir('../');
$oc_login->loginUser();

$memberships = $oc_login->getMembership();

$position = new Orgchart\Position($oc_db, $oc_login);
$employee = new Orgchart\Employee($oc_db, $oc_login);
$tag = new Orgchart\Tag($oc_db, $oc_login);

// check for cached result
/* if(!isset($_GET['cache'])
    && $_GET['cache'] == 0) {
    $cache = $oc_db->query_kv('SELECT * FROM cache WHERE cacheID="jsonExport_PDL.php" OR cacheID="lastModified"', 'cacheID', array('data', 'cacheTime'));
    if (isset($cache['jsonExport_PDL.php'])
        && isset($cache['lastModified'])
        && $cache['jsonExport_PDL.php']['cacheTime'] > $cache['lastModified']['data']
        ) {
        header('Content-type: application/json');

        $scrubCache = json_decode($cache['jsonExport_PDL.php']['data']);
        if(json_last_error() == JSON_ERROR_NONE) { // validate JSON object
            $scrubCache = XSSHelpers::scrubObjectOrArray($scrubCache);
            echo json_encode($scrubCache);
        }
        exit();
    }
} */

header('Content-type: application/json');

$res = $oc_db->prepared_query('SELECT * FROM positions', array());

$jsonOut = array();
$iteration = 0;
foreach ($res as $pos)
{
    $data = $position->getAllData($pos['positionID']);
    $output = array();
    $output[$pos['positionID']]['employeees'] = $position->getEmployees($pos['positionID']);

    $serviceChief = $position->findRootPositionByGroupTag($pos['positionID'], 'service');

    $output[$pos['positionID']]['positionTitle'] = $pos['positionTitle'];
    $positionService = $position->getService($pos['positionID']);
    $output[$pos['positionID']]['service'] = isset($positionService[0]) ? $positionService[0]['groupTitle'] : '';
    // If the position is a service chief, show the ELT's Service
    if (isset($serviceChief[0])
        && $serviceChief[0]['positionID'] == $pos['positionID'])
    {
        $elt = $position->findRootPositionByGroupTag($pos['positionID'], $tag->getParent('service'));
        /* error_log($iteration);
        error_log(print_r($elt, true)); */

        if (!empty($elt)) {
            $output[$pos['positionID']]['service'] = $elt[0]['groupTitle'];
            // If position is an ELT member, show their supervisor's service (director)
            if ($serviceChief[0]['groupID'] == $elt[0]['groupID'])
            {
                $super = $position->getSupervisor($pos['positionID']);
                if (isset($super[0]))
                {
                    $superService = $position->getService($super[0]['positionID']);
                    if(isset($superService[0]))
                    {
                        $output[$pos['positionID']]['service'] = $superService[0]['groupTitle'];
                    }
                }
            }
        }
    }

    $output[$pos['positionID']]['data']['Pay Plan'] = $data[2]['data'];
    $output[$pos['positionID']]['data']['Series'] = $data[13]['data'];
    $output[$pos['positionID']]['data']['Pay Grade'] = $data[14]['data'];
    //	$output[$pos['positionID']]['data']['FTE Ceiling'] = ($data[11]['data'] / count($output[$pos['positionID']]['employeees']));
    //	$output[$pos['positionID']]['data']['Current FTE'] = ($data[17]['data'] / count($output[$pos['positionID']]['employeees']));
    $output[$pos['positionID']]['data']['FTE Ceiling'] = 0;
    $output[$pos['positionID']]['data']['Current FTE'] = 0;
    $output[$pos['positionID']]['data']['HR Smart Position #'] = $data[26]['data'];

    // calculate FTE Ceiling. Includes support for one-to-many position-employee
    if (is_numeric($data[11]['data']) // fte ceiling
        && is_numeric($data[19]['data']))
    { // total headcount
        $output[$pos['positionID']]['data']['FTE Ceiling'] = $data[19]['data'] == 0 ? 0 : round($data[11]['data'] / $data[19]['data'], 5);
    }

    // calculate current FTE. Includes support for one-to-many position-employee
    if (is_numeric($data[17]['data']) // current fte
        && is_numeric($data[19]['data']))
    { // total headcount
        $output[$pos['positionID']]['data']['Current FTE'] = $data[19]['data'] == 0 ? 0 : round($data[17]['data'] / $data[19]['data'], 5);
    }

    $output[$pos['positionID']]['data']['PD Number'] = $data[9]['data'];

    foreach ($output[$pos['positionID']]['employeees'] as $key => $emp)
    {
        if ($emp['isActing'] == 0)
        {
            // find supervisor
            $supervisor = $position->getSupervisor($pos['positionID']);
            $supervisorName = '';
            $supervisorEmail = '';
            if (isset($supervisor[0]['lastName'])
                && $supervisor[0]['isActing'] == 0)
            {
                $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
                $supervisorData = $employee->lookupEmpUID($supervisor[0]['empUID']);
                $supervisorEmail = $supervisorData[0]['email'];
            }

            $packet = array();
            $packet['positionID'] = (int)$pos['positionID'];
            $packet['positionTitle'] = XSSHelpers::xscrub($pos['positionTitle']);

            $employeeEmail = '';
            if ($emp['lastName'] != ''
                && $emp['isActing'] == 0)
            {
                $packet['employee'] = XSSHelpers::xscrub("{$emp['lastName']}, {$emp['firstName']}");
                $packet['employeeUserName'] = XSSHelpers::xscrub($emp['userName']);
                $packet['employeeUID'] = (int)$emp['empUID'];
                $empData = $employee->lookupEmpUID($emp['empUID']);
                $employeeEmail = $empData[0]['email'];
                $packet['employeeEmail'] = XSSHelpers::xscrub($employeeEmail);
            }
            else
            {
                $packet['employee'] = '';
                $packet['employeeUserName'] = '';
                $packet['employeeUID'] = '';
            }

            $packet['supervisor'] = XSSHelpers::xscrub($supervisorName);
            $packet['supervisorEmail'] = XSSHelpers::xscrub($supervisorEmail);
            $packet['service'] = XSSHelpers::xscrub($output[$pos['positionID']]['service']);
            $packet['payPlan'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Pay Plan']);
            $packet['series'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Series']);
            $packet['payGrade'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Pay Grade']);
            $packet['fteCeiling'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['FTE Ceiling']);
            $packet['currentFte'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Current FTE']);
            $packet['pdNumber'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['PD Number']);
            $packet['hrSmartPosition'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['HR Smart Position #']);
            $jsonOut[] = $packet;
        }
        else
        {
            unset($output[$pos['positionID']]['employeees'][$key]);
        }
    }

    // use total headcount field to generate rows for vacant positions
    if (count($output[$pos['positionID']]['employeees']) < $data[19]['data'])
    {
        $vacancies = $data[19]['data'] - count($output[$pos['positionID']]['employeees']);
        for ($i = 0; $i < $vacancies; $i++)
        {
            // find supervisor
            $supervisor = $position->getSupervisor($pos['positionID']);
            $supervisorName = '';
            $supervisorEmail = '';
            if (isset($supervisor[0]['lastName'])
                && $supervisor[0]['isActing'] == 0)
            {
                $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
                $supervisorData = $employee->lookupEmpUID($supervisor[0]['empUID']);
                $supervisorEmail = $supervisorData[0]['email'];
            }

            $packet = array();
            $packet['positionID'] = (int)$pos['positionID'];
            $packet['positionTitle'] = XSSHelpers::xscrub($output[$pos['positionID']]['positionTitle']);
            $packet['employee'] = '';
            $packet['employeeUserName'] = '';
            $packet['employeeUID'] = '';
            $packet['employeeEmail'] = '';
            $packet['supervisor'] = XSSHelpers::xscrub($supervisorName);
            $packet['supervisorEmail'] = XSSHelpers::xscrub($supervisorEmail);
            $packet['service'] = XSSHelpers::xscrub($output[$pos['positionID']]['service']);
            $packet['payPlan'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Pay Plan']);
            $packet['series'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Series']);
            $packet['payGrade'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Pay Grade']);
            $packet['fteCeiling'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['FTE Ceiling']);
            $packet['currentFte'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['Current FTE']);
            $packet['pdNumber'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['PD Number']);
            $packet['hrSmartPosition'] = XSSHelpers::xscrub($output[$pos['positionID']]['data']['HR Smart Position #']);
            $jsonOut[] = $packet;
        }
    }
    $iteration++;
}

// add email addresses
$uniqueEmps = [];
foreach($jsonOut as $item) {
    if($item['employeeUID'] != '') {
        $uniqueEmps[$item['employeeUID']] = $item['employeeUID'];
    }
}
$empUID_list = implode(',', $uniqueEmps);
$vars = [];
$empEmails = $oc_db->query_kv("SELECT * FROM employee_data
            WHERE indicatorID = 6 AND empUID IN ({$empUID_list})", 'empUID', 'data', $vars);
foreach($jsonOut as $key => $item) {
    if($item['employeeUID'] != '') {
        $jsonOut[$key]['employeeEmail'] = htmlspecialchars($empEmails[$item['employeeUID']], ENT_QUOTES, 'UTF-8');
    }
    else {
        $jsonOut[$key]['employeeEmail'] = '';
    }
}

// the data here that is getting encoded for json is being scrubed before now.
// Look at lines 169-184 and line 203 above, that should be sufficient for fortify
$result = json_encode($jsonOut);

// cache the result
$vars = array(':cacheID' => 'jsonExport_PDL.php',
              ':data' => $result,
              ':cacheTime' => time(), );
$res = $oc_db->prepared_query('INSERT INTO cache (cacheID, data, cacheTime)
   								VALUES (:cacheID, :data, :cacheTime)
   								ON DUPLICATE KEY UPDATE data=:data, cacheTime=:cacheTime', $vars);

echo $result;
