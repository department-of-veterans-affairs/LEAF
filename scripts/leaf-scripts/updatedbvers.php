<?php

require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';
ini_set('display_errors', 1);
error_reporting(E_ALL);
$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$portals = $db->query("SELECT `portal_database` FROM `sites` WHERE `site_type` = 'portal'");

foreach ($portals as $portal) {
    try {
        // Switch to portal in list
        $db->query("USE `{$portal['portal_database']}`");

        $results = $db->query("SELECT `data` from `settings` where setting = 'dbversion'");

        if ((int)$results[0]['data'] <= 2024062001) {
            $res = $db->query("SHOW INDEX FROM `sites` where Key_name = 'isVAPO'");
            if (!empty($res)) {

                var_dump($portal['portal_database'], $results[0]['data']);

                echo "\r\n";
                $db->query("UPDATE `settings` SET `data` = '2024071100' WHERE `settings`.`setting` = 'dbversion'");
            } else {

                var_dump($portal['portal_database'], $results[0]['data'], 'did not update');
                echo "\r\n";
            }
        }
    } catch (Exception $e) {
        echo $e->getMessage();
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Process took {$timeInMinutes} minutes\r\n";
echo date('Y-m-d g:i:s a') . "\r\n";
