<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$dir = '/var/www/scripts/updateNationalOrgchart.php';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$sql = 'SELECT `cacheID`, LEFT(`data`, 5) AS `data`
        FROM `cache`
        WHERE LEFT(`data`, 3) = "DN,"';

$VISNS = $db->query($sql);

passthru("cat /dev/null > /var/www/tmp/nationalUpdate.txt");

echo "Beginning National Update ...\r\n";

$national = fopen('/var/www/tmp/nationalUpdate.txt', 'w');

foreach ($VISNS as $visn) {
    if (str_starts_with($visn['data'], 'DN,')) {
        fwrite($national, "{$dir} {$visn['cacheID']}\r\n");
    }
}

fclose($national);

echo "Updating National Orgcharts\r\n";
passthru("cat /var/www/tmp/national.txt | parallel -j 100 -d '\r\n' php {}");

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "National Update took {$timeInMinutes} minutes and ended at ";
echo date('Y-m-d g:i:s a'). "\r\n";
