<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

require_once '../../libs/loaders/Leaf_autoloader.php';

$config = new Orgchart\Config();
$db = new Leaf\Db($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$vars = array(':version' => $version);
$res = $db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
