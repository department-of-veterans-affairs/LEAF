<?php

include './sources/Login.php';
include 'db_mysql.php';
include 'config.php';

$db_config = new Orgchart\Config();
$config = new Orgchart\Config();

// Enforce HTTPS
if(isset($config->enforceHTTPS) && $config->enforceHTTPS == true) {
	if(!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] != 'on') {
		header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
		exit();
	}
}

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
unset($db_config);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

include './sources/Employee.php';


$emp = new OrgChart\Employee($db, $login);

print_r($emp->search('gao'));

?>