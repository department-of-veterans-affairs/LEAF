<?php
/**
 * This file is used to get the different db versions after a deploy to verify update. 
 * You will need to update the db version manually in this file to do the search at this time however
 */

require_once '/var/www/html/app/libs/globals.php';
require_once '/var/www/html/app/libs/../Leaf/Db.php';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$portals = $db->query("SELECT `portal_database` FROM `sites` WHERE `site_type` = 'portal'");

foreach ($portals as $portal) {
    // Initialize record destruction counter
    $count = 0;

    // Switch to portal in list
    $db->query("USE `{$portal['portal_database']}`");

    $results = $db->query("SELECT `data` from `settings` where setting = 'dbversion'");

    if( (int)$results[0]['data'] < 2023100500){
        var_dump($portal['portal_database'],$results[0]['data']);
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Processing took {$timeInMinutes} minutes\r\n";
echo date('Y-m-d g:i:s a') . "\r\n";
