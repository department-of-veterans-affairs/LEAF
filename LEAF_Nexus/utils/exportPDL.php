<?php
set_time_limit(90);
include '../config.php';
include '../sources/Login.php';
include '../db_mysql.php';
include '../sources/Position.php';
include '../sources/Tag.php';


$config = new Orgchart\Config;
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');
$login->loginUser();

$position = new Orgchart\Position($db, $login);
$tag = new Orgchart\Tag($db, $login);

header('Content-type: text/csv');
header('Content-Disposition: attachment; filename="Exported_'.time().'.csv"');

echo "LEAF Position ID, HR Smart Position Number, Service, Position Title, Classification Title, Employee Name, Employee Username, Supervisor Name, Pay Plan, Series, Pay Grade, FTE Ceiling / Total Headcount, Current FTE, PD Number, Note\r\n";

$res = $db->query('SELECT * FROM positions');

//$pos = $res[15]; // for testing
foreach($res as $pos) {
	$data = $position->getAllData($pos['positionID']);
	$output = [];
	$output[$pos['positionID']]['employeees'] = $position->getEmployees($pos['positionID']);

	$serviceChief = $position->findRootPositionByGroupTag($pos['positionID'], 'service');
	
	$output[$pos['positionID']]['positionTitle'] = $pos['positionTitle'];
	$positionService = $position->getService($pos['positionID']);
	$output[$pos['positionID']]['service'] = isset($positionService[0]) ? $positionService[0]['groupTitle'] : '';
	// If the position is a service chief, show the ELT's Service
	if(isset($serviceChief[0])
		&& $serviceChief[0]['positionID'] == $pos['positionID']) {
		$elt = $position->findRootPositionByGroupTag($pos['positionID'], $tag->getParent('service'));
		$output[$pos['positionID']]['service'] = $elt[0]['groupTitle'];
		// If position is an ELT member, show their supervisor's service (director)
		if($serviceChief[0]['groupID'] == $elt[0]['groupID']) {
			$super = $position->getSupervisor($pos['positionID']);
			if(isset($super[0])) {
				$superService = $position->getService($super[0]['positionID']);
				$output[$pos['positionID']]['service'] = $superService[0]['groupTitle'];
			}
		}
	}
	
	$output[$pos['positionID']]['data']['Classification Title'] = $data[12]['data'];
	$output[$pos['positionID']]['data']['Pay Plan'] = $data[2]['data'];
	$output[$pos['positionID']]['data']['Series'] = $data[13]['data'];
	$output[$pos['positionID']]['data']['Pay Grade'] = $data[14]['data'];
//	$output[$pos['positionID']]['data']['FTE Ceiling'] = ($data[11]['data'] / count($output[$pos['positionID']]['employeees']));
//	$output[$pos['positionID']]['data']['Current FTE'] = ($data[17]['data'] / count($output[$pos['positionID']]['employeees']));
	$output[$pos['positionID']]['data']['FTE'] = 0;
	if(is_numeric($data[11]['data'])
		&& is_numeric($data[19]['data'])) {
			$output[$pos['positionID']]['data']['FTE'] = $data[19]['data'] == 0 ? 0 : round($data[11]['data'] / $data[19]['data'], 5);
	}
	$output[$pos['positionID']]['data']['Current FTE'] = $data[17]['data'];
	$output[$pos['positionID']]['data']['PD Number'] = $data[9]['data'];
	$output[$pos['positionID']]['data']['HR Smart Position #'] = $data[26]['data'];
	
	foreach($output[$pos['positionID']]['employeees'] as $emp) {
		
		// find supervisor
		$supervisor = $position->getSupervisor($pos['positionID']);
		$supervisorName = '';
		if(isset($supervisor[0]['lastName'])
			&& $supervisor[0]['isActing'] == 0) {
			$supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
		}

		echo "\"{$pos['positionID']}\",";
		echo "\"{$output[$pos['positionID']]['data']['HR Smart Position #']}\",";
		echo "\"{$output[$pos['positionID']]['service']}\",";
		echo "\"{$output[$pos['positionID']]['positionTitle']}\",";
		echo "\"{$output[$pos['positionID']]['data']['Classification Title']}\",";
		if($emp['lastName'] != ''
			&& $emp['isActing'] == 0) {
			echo "\"{$emp['lastName']}, {$emp['firstName']}\",";
		}
		else {
			echo "\"\",";
		}
		echo "\"{$emp['userName']}\",";
		echo "\"{$supervisorName}\",";
		echo "\"{$output[$pos['positionID']]['data']['Pay Plan']}\",";
		echo "=\"{$output[$pos['positionID']]['data']['Series']}\",";
		echo "=\"{$output[$pos['positionID']]['data']['Pay Grade']}\",";
//		echo "\"{$output[$pos['positionID']]['data']['FTE Ceiling']}\",";
//		echo "\"{$output[$pos['positionID']]['data']['Current FTE']}\",";
		echo "\"{$output[$pos['positionID']]['data']['FTE']}\",";
		echo "\"{$output[$pos['positionID']]['data']['Current FTE']}\",";
		echo "\"{$output[$pos['positionID']]['data']['PD Number']}\",";
		if($data[19]['data'] == 0) {
            echo "\"Missing Total Headcount\",";
        }
        else {
            echo "\"\",";
        }
		echo "\r\n";
	}
	if(count($output[$pos['positionID']]['employeees']) < $data[19]['data']) {
		$vacancies = $data[19]['data'] - count($output[$pos['positionID']]['employeees']);
		for($i = 0; $i < $vacancies; $i++) {
    		// find supervisor
    		$supervisor = $position->getSupervisor($pos['positionID']);
    		$supervisorName = '';
    		if(isset($supervisor[0]['lastName'])
    			&& $supervisor[0]['isActing'] == 0) {
    			$supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
    		}

			echo "\"{$pos['positionID']}\",";
			echo "\"{$output[$pos['positionID']]['data']['HR Smart Position #']}\",";
			echo "\"{$output[$pos['positionID']]['service']}\",";
			echo "\"{$output[$pos['positionID']]['positionTitle']}\",";
			echo "\"{$output[$pos['positionID']]['data']['Classification Title']}\",";
			echo "\"\","; // vacant employee
			echo "\"\","; // vacant employee
			echo "\"{$supervisorName}\",";
			echo "\"{$output[$pos['positionID']]['data']['Pay Plan']}\",";
			echo "=\"{$output[$pos['positionID']]['data']['Series']}\",";
			echo "=\"{$output[$pos['positionID']]['data']['Pay Grade']}\",";
			//		echo "\"{$output[$pos['positionID']]['data']['FTE Ceiling']}\",";
			//		echo "\"{$output[$pos['positionID']]['data']['Current FTE']}\",";
			echo "\"{$output[$pos['positionID']]['data']['FTE']}\",";
			echo "\"{$output[$pos['positionID']]['data']['Current FTE']}\",";
			echo "\"{$output[$pos['positionID']]['data']['PD Number']}\",";
			if($data[19]['data'] == 0) {
                echo "\"Missing Total Headcount\",";
            }
            else {
                echo "\"\",";
            }
			echo "\r\n";
		}
	}
}
