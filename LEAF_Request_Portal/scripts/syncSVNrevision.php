<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

$currDir = dirname(__FILE__);
include_once $currDir . '/../globals.php';
include_once $currDir . '/../../libs/php-commons/Db.php';
include_once $currDir . '/../sources/DbConfig.php';

$config = new Portal\DbConfig();
$db = new Leaf\Db($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$vars = array(':version' => $version);
$res = $db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
