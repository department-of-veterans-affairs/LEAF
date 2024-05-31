<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';
require_once LIB_PATH . '/php-commons/ErrorNotify.php';

$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
$errorNotify = new Leaf\ErrorNotify();
$orgcharts = $db->query("SELECT `site_path` FROM `sites` WHERE `site_type` = 'orgchart'");
$dir = '/var/www/html';

$failedArray = [];

foreach ($orgcharts as $orgchart) {
    echo "Orgchart: " . $dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php' . "\r\n";
    if (is_file($dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php')) {
        
        $response = exec('php ' . $dir . $orgchart['site_path'] . '/scripts/refreshOrgchartEmployees.php',$output) . "\r\n";
        
        if($response == '0'){
            $failedArray[] = $orgchart['site_path'].' (Failed)';
        }
    } else {
        $failedArray[] = $orgchart['site_path'].' (File Not Found)';
        echo "File was not found\r\n";
    }
}

// send email this could be brought into the class to allow for reuse

$errorNotify->sendNotification('Orgchart Refresh Error',$failedArray);

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Update took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
