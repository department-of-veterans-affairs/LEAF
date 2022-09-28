<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

require_once '/var/www/html/libs/loaders/Leaf_autoloader.php';

$db_config = new DB_Config();
$config = new Config();

$db = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$short = new Shortener($db, null);

unset($db_config);

$report = isset($_GET['report']) ? XSSHelpers::xscrub($_GET['report']) : '';
if($report != '') {
    $short->getReport($report);
}
