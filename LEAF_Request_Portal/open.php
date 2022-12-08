<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

include '../libs/loaders/Leaf_autoloader.php';

$report = isset($_GET['report']) ? Leaf\XSSHelpers::xscrub($_GET['report']) : '';
if($report != '') {
    $short->getReport($report);
}
