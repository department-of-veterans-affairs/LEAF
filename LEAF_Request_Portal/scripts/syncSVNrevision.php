<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

$currDir = dirname(__FILE__);
include_once $currDir . '/../db_mysql.php';

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$vars = array(':version' => $version);
$res = $db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
