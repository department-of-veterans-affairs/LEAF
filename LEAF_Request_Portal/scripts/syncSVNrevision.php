<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

$currDir = dirname(__FILE__);
include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../db_config.php';

$config = new DB_Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$vars = array(':version' => $version);
$res = $db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
