<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';

$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
$portalsSql = "SELECT `site_path`, `site_large_query`.`id` as largeQueryID FROM `sites` 
JOIN `site_large_query` ON `sites`.id=`site_large_query`.site_id 
WHERE `site_type` = 'portal' AND currently_running < 1";
$portals = $db->query($portalsSql);
$dir = '/var/www/html';

foreach ($portals as $portal) {

    $vars = [
        ':id' => $portal['largeQueryID'],
        ':currently_running' => time()

    ];
    $processQueryUpdateSQL = 'UPDATE site_large_query SET currently_running=:currently_running WHERE `id`=:id';
    $db->prepared_query($processQueryUpdateSQL, $vars);

    echo "Orgchart: " . $dir . $portal['site_path'] . '/scripts/process_queries.php' . "\r\n";
    if (is_file($dir . $portal['site_path'] . '/scripts/process_queries.php')) {
        echo exec('php ' . $dir . $portal['site_path'] . '/scripts/process_queries.php &') . "\r\n";
        $vars = [
            ':largeQueryID' => $portal['largeQueryID']
        ];
        $db->prepared_query("DELETE FROM `site_large_query` WHERE id = :largeQueryID ", $vars);
    } else {
        echo "File was not found\r\n";
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Update took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
