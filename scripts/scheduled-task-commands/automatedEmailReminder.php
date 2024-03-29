<?php
$dir = '/var/www/html';

// this should probably be in a file
$blacklist = [
    'pre-apr10',
    'piwik',
];

$folder_to_check = 'scripts';
//$folder_to_check = 'LEAF_Nexus';

$startTime = microtime(true);

$items = scandir($dir);

function isBlacklisted($folder)
{
    global $blacklist;
    foreach ($blacklist as $item) {
        if (strpos($folder, $item) !== FALSE) {
            return TRUE;
        }
    }
    return FALSE;
}

function checkForOrgChart($folder, $depth = 0)
{

    global $folder_to_check;

    // make sure the folder exists and that it is not in the root directory of where we are checking, scripts in this case.
    if (is_dir($folder . '/' . $folder_to_check) && $folder . '/' . $folder_to_check !== '/var/www/html/scripts') {
        if ($depth > 4 && strpos($folder, 'libs') > 0) {
            echo "OrgChart: " . $folder . " - depth: {$depth} - IGNORED\r\n";
        } else if (isBlacklisted($folder)) {
            echo "OrgChart: " . $folder . " - depth: {$depth} - BLACKLISTED\r\n";
        } // orgchart found!
        else {
            echo "OrgChart: " . $folder . " - depth: {$depth}\r\n";
            //echo $folder.'/'.$folder_to_check.'/scripts/refreshOrgchartEmployees.php'."\r\n";
            //echo exec('php ' . $folder.'/'.$folder_to_check.'/scripts/refreshOrgchartEmployees.php' . " > /dev/null 2>/dev/null &")."\r\n";
            if(is_file($folder.'/'.$folder_to_check.'/automated_email.php')){
                echo exec('php ' . $folder.'/'.$folder_to_check.'/automated_email.php')."\r\n";
            }

        }
    } else {
        echo "examine: " . $folder . "\r\n";
        $items = scandir($folder);
        $depth++;
        foreach ($items as $item) {
            if (is_dir($folder . '/' . $item)
                && ($item != '.' && $item != '..')) {
                checkForOrgChart($folder . '/' . $item, $depth);
            }
        }
    }
}

checkForOrgChart($dir);

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Update took {$timeInMinutes} minutes";
echo date('Y-m-d g:i:s a') . "\r\n";
