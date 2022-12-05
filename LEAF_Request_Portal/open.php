<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

include '../libs/php-commons/Db.php';
include 'sources/DbConfig.php';
include 'sources/Config.php';
require 'sources/Shortener.php';

$db_config = new Portal\DbConfig();
$config = new Portal\Config();

$db = new Leaf\Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$short = new Portal\Shortener($db, null);

unset($db_config);

// Include XSSHelpers
if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$report = isset($_GET['report']) ? XSSHelpers::xscrub($_GET['report']) : '';
if($report != '') {
    $short->getReport($report);
}
