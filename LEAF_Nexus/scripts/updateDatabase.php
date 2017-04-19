<?php

define('PREFIX', 'Update_OC_DB_');
if(php_sapi_name() == 'cli') {
	define('BR', "\r\n");
}
else {
	define('BR', '<br />');
}
$currDir = dirname(__FILE__);

include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../config.php';
include_once $currDir . '/../sources/Login.php';

$config = new Orgchart\Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');
$login->loginUser();

$res = $db->query('SELECT * FROM settings WHERE setting="dbversion"');
if(!isset($res[0]) || !is_numeric($res[0]['data'])) {
    exit();
}
$currentVersion = $res[0]['data'];
echo "Current Database Version: $currentVersion" . BR . BR;

clearstatcache();

$folder = $currDir . '/../db_upgrade/';

$updates = scandir($folder);

$updateList = [];

foreach($updates as $item) {
	$versionRaw = substr($item, strlen(PREFIX . $currentVersion) - strlen($currentVersion));
	$tIdx = strpos($versionRaw, '-');
	$oldVer = substr($versionRaw, 0, $tIdx);
	$newVer = str_replace('.sql', '', substr($versionRaw, $tIdx + 1));
	if(is_numeric($oldVer)) {
		$updateList[$oldVer] = $item;
	}
}

updateDB($currentVersion, $updateList, $folder, $db);

echo BR . BR . "Complete.";

function updateDB($thisVer, $updateList, $folder, $db) {
	if(isset($updateList[$thisVer])) {
		echo "Update found: " . $updateList[$thisVer] . BR;
		$update = file_get_contents($folder . $updateList[$thisVer]);
		echo "Processing update... ";
		$db->query($update);
		echo " ... Complete." . BR;
		$res = $db->query('SELECT * FROM settings WHERE setting="dbversion"');
		if($res[0]['data'] == $thisVer) {
			echo "Update failed." . BR;
		}
		else {
			echo "Database updated to: {$res[0]['data']}" . BR;
			updateDB($res[0]['data'], $updateList, $folder, $db);
		}
	}
}
