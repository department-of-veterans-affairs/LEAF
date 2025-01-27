<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$dir = '/var/www/html';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$vars = array();

$sql = 'SELECT `site_path`
        FROM `sites`
        WHERE `site_type` = "orgchart"
        AND `site_path` = "/Academy/Demo1"
        ORDER BY `site_path`';

$paths = $db->prepared_query($sql, $vars);

passthru("cat /dev/null > /var/www/tmp/refreshOrgcharts.txt");

echo "Refresh Orgcharts Started ...\r\n";

$forgcharts = fopen('/var/www/tmp/refreshOrgcharts.txt', 'w');

foreach ($paths as $path) {
    $site = rtrim($path['site_path'], '/');
    fwrite($forgcharts, "{$dir}{$site}/\r\n");
}

fclose($forgcharts);

echo "Refreshing Orgcharts\r\n";
passthru("cat /var/www/tmp/refreshOrgcharts.txt | parallel -j 100 -d '\r\n' php {}scripts/refreshOrgchartEmployees.php");

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Refresh took {$timeInMinutes} minutes and ended at ";
echo date('Y-m-d g:i:s a'). "\r\n";
