<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$short = new Portal\Shortener($db, null);

$report = isset($_GET['report']) ? XSSHelpers::xscrub($_GET['report']) : '';
if($report != '') {
    $short->getReport($report);
}
