<?php

// copy db_config.php from portal root to portal/sources as DbConfig.php
// copy db_config.php from portal root to portal/sources as Config.php

// open portal/sources/DbConfig.php and remove ini_set('display_errors', 0); // Set to 1 to display errors
// remove require_once(dirname(__FILE__) . 'globals.php');
// replace class DB_Config with namespace Portal; \n\n class DbConfig
// remove all lines beginging with class Config and after

// open portal/sources/Config.php and remove ini_set('display_errors', 0); // Set to 1 to display errors
// remove require_once(dirname(__FILE__) . 'globals.php');
// remove all lines from class DB_Config to one line before class Config
// replace class Config with  namespace Portal; \n\n class Config

// remove portal/db_config.php

if (!file_exists('../db_config.php')) {
    exit;
}

if (is_file('../sources/DbConfig.php')) {
    // remove the file
    unlink('../sources/DbConfig.php');
}

if (is_file('../sources/Config.php')) {
    // remove the file
    unlink('../sources/Config.php');
}

copy('../db_config.php', '../sources/aaaDbConfig.php');
copy('../db_config.php', '../sources/bbbConfig.php');

$path_to_file = '../sources/aaaDbConfig.php';
$file_contents = file_get_contents($path_to_file);
$file_contents = str_replace("ini_set('display_errors', 0); // Set to 1 to display errors", "", $file_contents);
$file_contents = str_replace("require_once(dirname(__FILE__) . 'globals.php');", "", $file_contents);
$file_contents = str_replace("class DB_Config", "namespace Portal; \n\n class DbConfig", $file_contents);
file_put_contents($path_to_file, $file_contents);

$myline = getLineWithString('../sources/aaaDbConfig.php', 'class Config');
$contents = file('../sources/aaaDbConfig.php');
$keep1 = array_slice($contents, 0, $myline);
$keep2 = array_slice($contents, 0, $myline);

$a = array_splice($keep1, 0, 9);
$b = array_splice($keep2, 13, -1);

$keep = array_merge($a, $b);

if (is_file('../sources/DbConfig.php')) {
    // remove the file
    unlink('../sources/DbConfig.php');
}

file_put_contents('../sources/DbConfig.php', $keep);
unlink('../sources/aaaDbConfig.php');

// take care of Config
$path_to_file = '../sources/bbbConfig.php';

$myline = getLineWithString('../sources/bbbConfig.php', 'class Config');
$contents = file('../sources/bbbConfig.php');
$keep2 = array_slice($contents, $myline);

$a = array_splice($contents, 0, 9);

$keep = array_merge($a, $keep2);

if (is_file('../sources/Config.php')) {
    // remove the file
    unlink('../sources/Config.php');
}

file_put_contents('../sources/Config.php', $keep);
unlink('../sources/bbbConfig.php');
//unlink('../db_config.php');

$file_contents = file_get_contents('../sources/Config.php');
$file_contents = str_replace("class Config", "namespace Portal; \n\n class Config", $file_contents);
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
