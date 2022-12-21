<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$version = 'PUBLIC';

require_once '../globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

$vars = array(':version' => $version);
$res = $oc_db->prepared_query("UPDATE settings SET data=:version WHERE setting='version'", $vars);
