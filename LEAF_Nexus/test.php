<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include './sources/Login.php';
include 'db_mysql.php';
include 'config.php';

$db_config = new Orgchart\Config();
$config = new Orgchart\Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
unset($db_config);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

include './sources/Employee.php';

$emp = new OrgChart\Employee($db, $login);

print_r($emp->search('gao'));
