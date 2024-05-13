<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';

$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$siteList = $db->query("SELECT `site_path` FROM `sites` WHERE `site_type` = 'portal'");
$dir = '/var/www/html';
foreach ($siteList as $site) {
    echo "Portal: " . $dir . $site['site_path'] . '/scripts/automated_email.php' . "\r\n";
    if (is_file($dir . $site['site_path'] . '/scripts/automated_email.php')) {
        echo exec('php ' . $dir . $site['site_path'] . '/scripts/automated_email.php') . "\r\n";
    } else {
        echo "File was not found\r\n";
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Emails processing took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
