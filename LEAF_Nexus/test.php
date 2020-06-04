<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/./sources/Login.php';
include __DIR__ . '/db_mysql.php';

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

include __DIR__ . '/./sources/Employee.php';

$emp = new OrgChart\Employee($db, $login);

print_r($emp->search('gao'));
