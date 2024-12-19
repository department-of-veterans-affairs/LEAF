<?php

// copy db_config.php from portal root to portal/sources as Config.php

// open portal/sources/Config.php and remove ini_set('display_errors', 0); // Set to 1 to display errors
// remove require_once(dirname(__FILE__) . 'globals.php');
// remove all lines from class DB_Config to one line before class Config
// replace class Config with  namespace Portal; \n\n class Config

// remove portal/db_config.php
if (!file_exists('../config.php')) {
    exit;
}

if (is_file('../sources/Config.php')) {
    // remove the file
    unlink('../sources/Config.php');
}

copy('../config.php', '../sources/bbbConfig.php');

$path_to_file = '../sources/bbbConfig.php';

$myline = getLineWithString('../sources/bbbConfig.php', 'class Config');
$contents = file('../sources/bbbConfig.php');
$keep2 = array_slice($contents, $myline);

$a = array_splice($contents, 0, 9);

$keep = array_merge($a, $keep2);
error_log(print_r($keep, true));

if (is_file('../sources/Config.php')) {
    // remove the file
    unlink('../sources/Config.php');
}

file_put_contents('../sources/Config.php', $keep);
unlink('../sources/bbbConfig.php');
//unlink('../config.php');

$file_contents = file_get_contents('../sources/Config.php');
$file_contents = str_replace("namespace Orgchart;\nclass Config", "\nnamespace Orgchart; \n\n class Config", $file_contents);
file_put_contents('../sources/Config.php', $file_contents);

function getLineWithString($fileName, $str) {
    $lines = file($fileName);

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, $str) !== false) {
            return $lineNumber;
        }
    }
    return -1;
}