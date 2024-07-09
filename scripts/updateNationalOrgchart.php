<?php
if (count($argv) < 1) {
    // no argument supplied
    exit();
}

$file = $argv[1];

echo $file;
/*
$national_db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');
$dir = new Leaf\VAMCActiveDirectory($national_db);

$sql = 'SELECT `data`
        FROM `cache`
        WHERE `cacheID` = ' . $file;

$data = $db->query($sql);

$dir->importADData($data['data']);

$sql = 'DELETE
        FROM `cache`
        WHERE `cacheID` = ' . $file;

$db->query($sql);
*/