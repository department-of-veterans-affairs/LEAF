<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';
require_once APP_PATH . '/Leaf/VAMCActiveDirectory.php';

$startTime = microtime(true);

$national_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');
$dir = new App\Leaf\VAMCActiveDirectory($national_db);

$dir->disableNationalOrgchartEmployees();

$endTime = microtime(true);
$totalTime = round(($endTime - $startTime)/60, 2);

error_log(print_r("Disable took " . $totalTime . " minutes to complete.", true), 3 , '/var/www/php-logs/ad_processing.log');