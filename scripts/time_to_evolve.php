<?php
use App\Leaf\Db;

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$site_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$vars = array();
$sql = 'SELECT `site_path`
        FROM `sites`
        WHERE `site_type` = "portal"';

$result = $site_db->pdo_select_query($sql, $vars);

$string = $argv[1];

if ($string == '') {
    exit;
}

$list = array();
$root = str_replace('app/libs', '', getenv('APP_LIBS_PATH'));

// loop through the portal sites
foreach ($result['data'] as $path) {
    // search each file on the site for the specified string
    iterator($root . $path['site_path']);
}

function iterator($filename)
{
    $dir = new DirectoryIterator($filename);

    foreach ($dir as $file) {
        if ($file->isDot()) {
            continue;
        } elseif ($file->isDir()) {
            iterator($file->getRealPath());
        } else {
            getLineWithString($file->getRealPath());
        }
    }
}

function getLineWithString($fileName)
{
    global $string;
    global $list;

    $lines = file($fileName);

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, $string) !== false) {
            $list[] = array('file_name' => $fileName,
                'string' => $string,
                'line' => trim($line),
                'line_number' => $lineNumber,
            );
        }
    }
}

file_put_contents('/var/www/logs/time_to_evolve.txt', json_encode($list));
