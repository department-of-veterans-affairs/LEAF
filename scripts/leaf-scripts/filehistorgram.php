<?php

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '../Leaf/Db.php';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$portals = $db->query("SELECT * FROM `sites` WHERE `site_type` = 'portal'");
$directory = '/var/www/html';
$totalfilecount = 0;
$totalfilesize = 0;
$totalmaxfilesize = 0;
$totalminfilesize = 0;
$fp = fopen('filehistogram.csv', 'w');
fputcsv($fp, ['path', 'max (MB)', 'min (MB)', 'average (MB)', 'count']);
foreach ($portals as $portal) {

    $filesizes = ['path' => $portal['site_path'], 'max' => 0, 'min' => 999999999, 'average' => 0, 'count' => 0];
    $header = array_keys($filesizes);

    $glob_array = glob($directory . $portal['site_path'] . '/files/*.*');
    $filecount = count($glob_array);
    $filzesizes['count'] = $filecount;

    foreach ($glob_array as $glob) {
        $filesize = filesize($glob);
        if ($filesize > 0)
            $filesize = $filesize / 1024;

        if ($filesize > $filesizes['max']) {
            $filesizes['max'] = $filesize;
        }

        if ($filesize < $filesizes['min'] && $filesize > 0) {
            $filesizes['min'] = $filesize;
        }

        if ($filesize > $totalmaxfilesize) {
            $totalmaxfilesize = $filesize;
        }

        if ($filesize < $totalminfilesize && $filesize > 0) {
            $totalminfilesize = $filesize;
        }

        $filesizes['average'] += $filesize;
    }

    if (count($glob_array) > 0) {
        $totalfilesize += $filesizes['average'];
        $filesizes['average'] = $filesizes['average'] / $filecount;
        $totalfilecount += $filecount;
        fputcsv($fp, $filesizes);
    }
}
fputcsv($fp, ['total', $totalmaxfilesize, $totalminfilesize, $totalfilesize / $totalfilecount, $totalfilecount]);
fclose($fp);
$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Destruction took {$timeInMinutes} minutes\r\n";
echo date('Y-m-d g:i:s a') . "\r\n";
