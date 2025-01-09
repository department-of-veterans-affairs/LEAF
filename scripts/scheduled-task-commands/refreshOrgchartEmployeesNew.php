<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once APP_PATH . '/Leaf/ErrorNotify.php';

$startTime = microtime(true);

if (count($argv) < 1) {
    // no argument supplied
    exit();
}

$file = $argv[1];
$errorNotify = new App\Leaf\ErrorNotify();

$dir = '/var/www/html';

$failedArray = [];

echo "Orgchart: " . $dir . $file . '/scripts/refreshOrgchartEmployees.php' . "\r\n";
if (is_file($dir . $file . '/scripts/refreshOrgchartEmployees.php')) {

    $response = exec('php ' . $dir . $file . '/scripts/refreshOrgchartEmployees.php',$output) . "\r\n";

    if ($response == '0') {
        $failedArray[] = $file.' (Failed)';
    }
} else {
    $failedArray[] = $file.' (File Not Found)';
    echo "File was not found\r\n";
}

// send email this could be brought into the class to allow for reuse

$errorNotify->sendNotification('Orgchart Refresh Error',$failedArray);

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "refresh took {$timeInMinutes} minutes ";
echo date('Y-m-d g:i:s a') . "\r\n";
