<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '/var/www/html/libs/loaders/Leaf_autoloader.php';

$db_config = new Orgchart\Config();
$config = new Orgchart\Config();

$db = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
unset($db_config);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

$emp = new Orgchart\Employee($db, $login);

print_r($emp->search('gao'));
