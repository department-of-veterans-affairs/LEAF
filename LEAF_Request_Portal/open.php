<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$short = new Portal\Shortener($db, null);

$report = isset($_GET['report']) ? Leaf\XSSHelpers::xscrub($_GET['report']) : '';
if($report != '') {
    $short->getReport($report);
}
