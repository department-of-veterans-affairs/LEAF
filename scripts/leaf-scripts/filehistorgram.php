<?php
/**
 * This file gets the amount of storage used for each portal in the ERM uploads directory.
 */

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/../Leaf/Db.php';

$startTime = microtime(true);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$portals = $db->query("SELECT * FROM `sites` WHERE `site_type` = 'portal'");
$directory = '/var/www/html';
$totalfilecount = 0;
$totalfilesize = 0;
$totalmaxfilesize = 0;
$totalminfilesize = 999999999;
$fp = fopen('filehistogram.csv', 'w');
fputcsv($fp, ['path', 'max (KB)', 'min (KB)', 'average (KB)', 'count']);
foreach ($portals as $portal) {

    // setup our initial array
    $filesizes = ['path' => $portal['site_path'], 'max' => 0, 'min' => 999999999, 'average' => 0, 'count' => 0];

    // look at the erm uploads, if looking at multiple dirs, will need to decouple filecounts, since we mainly want to look at erm I will just look at erm.
    $path = $portal['site_uploads'] . '*.*';

    $glob_array = glob($path);
    $filecount = count($glob_array);
    $filesizes['count'] += $filecount;

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

    if ($filesizes['min'] > $filesizes['max']) {
        $filesizes['min'] = 0;
    }

    if (count($glob_array) > 0) {
        $totalfilesize += $filesizes['average'];
        $filesizes['average'] = $filesizes['average'] / $filecount;
        $totalfilecount += $filecount;
        fputcsv($fp, $filesizes);
    }
}

if ($totalminfilesize > $totalmaxfilesize) {
    $totalminfilesize = 0;
}

fputcsv($fp, ['total', $totalmaxfilesize, $totalminfilesize, $totalfilesize / $totalfilecount, $totalfilecount]);
fclose($fp);
$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Processing took {$timeInMinutes} minutes\r\n";
echo date('Y-m-d g:i:s a') . "\r\n";
