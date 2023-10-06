<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';

$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$orgcharts = $db->query("SELECT `site_path` FROM `sites` WHERE `site_type` = 'orgchart'");
$dir = '/var/www/html';
foreach ($orgcharts as $orgchart) {
    echo "Orgchart: " . $dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php' . "\r\n";
    if (is_file($dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php')) {
        echo exec('php ' . $dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php') . "\r\n";
    } else {
        echo "File was not found\r\n";
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Update took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
