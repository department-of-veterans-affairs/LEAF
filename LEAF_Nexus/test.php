<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/./sources/Login.php';
include __DIR__ . '/db_mysql.php';
include __DIR__ . '/config.php';

$db_config = new Orgchart\Config();
$config = new Orgchart\Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
unset($db_config);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

include __DIR__ . '/./sources/Employee.php';

$emp = new OrgChart\Employee($db, $login);

print_r($emp->search('gao'));
