<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

set_time_limit(240);
include '../globals.php';
include '../config.php';
include '../sources/Login.php';
include '../db_mysql.php';
include '../sources/Position.php';
include '../sources/Tag.php';


if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}

$config = new Orgchart\Config;
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');
$login->loginUser();

$memberships = $login->getMembership();

$position = new Orgchart\Position($db, $login);
$tag = new Orgchart\Tag($db, $login);

// check for cached result
if(!isset($_GET['cache'])
    && $_GET['cache'] == 0) {
    $cache = $db->query_kv('SELECT * FROM cache WHERE cacheID="jsonExport_PDL.php" OR cacheID="lastModified"', 'cacheID', array('data', 'cacheTime'));
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
}

header('Content-type: application/json');

$res = $db->prepared_query('SELECT * FROM positions', array());

//$pos = $res[15]; // for testing

$jsonOut = array();

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
            if (isset($supervisor[0]['lastName'])
                && $supervisor[0]['isActing'] == 0)
            {
                $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
            }

            $packet = array();
            $packet['positionID'] = (int)$pos['positionID'];
            $packet['positionTitle'] = XSSHelpers::xscrub($pos['positionTitle']);

            if ($emp['lastName'] != ''
                && $emp['isActing'] == 0)
            {
                $packet['employee'] = XSSHelpers::xscrub("{$emp['lastName']}, {$emp['firstName']}");
                $packet['employeeUserName'] = XSSHelpers::xscrub($emp['userName']);
                $packet['employeeUID'] = (int)$emp['empUID'];
            }
            else
            {
                $packet['employee'] = '';
                $packet['employeeUserName'] = '';
                $packet['employeeUID'] = '';
            }

            $packet['supervisor'] = XSSHelpers::xscrub($supervisorName);
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
            if (isset($supervisor[0]['lastName'])
                && $supervisor[0]['isActing'] == 0)
            {
                $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
            }

            $packet = array();
            $packet['positionID'] = (int)$pos['positionID'];
            $packet['positionTitle'] = XSSHelpers::xscrub($output[$pos['positionID']]['positionTitle']);
            $packet['employee'] = '';
            $packet['employeeUserName'] = '';
            $packet['employeeUID'] = '';
            $packet['supervisor'] = XSSHelpers::xscrub($supervisorName);
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
$empEmails = $db->query_kv("SELECT * FROM employee_data
            WHERE indicatorID = 6 AND empUID IN ({$empUID_list})", 'empUID', 'data', $vars);
foreach($jsonOut as $key => $item) {
    if($item['employeeUID'] != '') {
        $jsonOut[$key]['employeeEmail'] = $empEmails[$item['employeeUID']];
    }
    else {
        $jsonOut[$key]['employeeEmail'] = '';
    }
}

$result = json_encode($jsonOut);

// cache the result
$vars = array(':cacheID' => 'jsonExport_PDL.php',
              ':data' => $result,
              ':cacheTime' => time(), );
$res = $db->prepared_query('INSERT INTO cache (cacheID, data, cacheTime)
   								VALUES (:cacheID, :data, :cacheTime)
   								ON DUPLICATE KEY UPDATE data=:data, cacheTime=:cacheTime', $vars);

echo $result;
