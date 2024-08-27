<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';
require_once APP_PATH . '/Leaf/ErrorNotify.php';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
$errorNotify = new App\Leaf\ErrorNotify();
$siteList = $db->query("SELECT `site_path` FROM `sites` WHERE `site_type` = 'portal' AND `isVAPO` = 'true'");
$dir = '/var/www/html';

$failedArray = [];

foreach ($siteList as $site) {
    echo "Portal: " . $dir . $site['site_path'] . '/scripts/automated_email.php' . "\r\n";
    if (is_file($dir . $site['site_path'] . '/scripts/automated_email.php')) {
        $response =  exec('php ' . $dir . $site['site_path'] . '/scripts/automated_email.php');
        if($response == '0'){
            $failedArray[] = $site['site_path'].' (Failed)';
        }
    } else {
        echo "File was not found\r\n";
    }
}

$errorNotify->logEmailErrors($failedArray);


$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Emails processing took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
