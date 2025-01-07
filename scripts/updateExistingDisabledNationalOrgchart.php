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

$national_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$vars = array(':domain' => $file);
$sql = 'SELECT `userName`
        FROM `employee`
        WHERE `deleted` > 0
        AND LEFT(`userName`, 9) <> "disabled_"
        AND `domain` = :domain
        LIMIT 1000';

$VISNS = $db->prepared_query($sql, $vars);
$users = array();

foreach ($VISNS as $user) {
    $users[] = $user['userName'];
}

$dir = new App\Leaf\VAMCActiveDirectory($national_db);

$dir->disableNationalOrgchartEmployees($users);

$endTime = microtime(true);
$totalTime = round(($endTime - $startTime)/60, 2);

error_log(print_r($file . " took " . $totalTime . " minutes to complete.", true), 3 , '/var/www/php-logs/update_existing.log');