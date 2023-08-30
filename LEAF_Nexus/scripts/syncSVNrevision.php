<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

require_once '../globals.php';
require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$db = $oc_db;

$vars = array(':version' => $version);
$res = $db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
