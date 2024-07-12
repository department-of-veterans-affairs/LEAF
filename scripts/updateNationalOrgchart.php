<?php
require_once 'scheduled-task-commands/globals.php';
require_once APP_PATH . '/Leaf/Db.php';
require_once APP_PATH . '/Leaf/VAMCActiveDirectory.php';

$startTime = microtime(true);

if (count($argv) < 1) {
    // no argument supplied
    exit();
}

$file = $argv[1];

$national_db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');
$dir = new Leaf\VAMCActiveDirectory($national_db);

$dir->importADData($file);

$endTime = microtime(true);
$totalTime = round(($endTime - $startTime)/60, 2);

error_log(print_r($file . " took " . $totalTime . " minutes to complete.", true));