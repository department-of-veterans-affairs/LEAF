<?php

$dir = '/var/www/html';
$items = scandir($dir);

$depth = 0;

check($dir);

function check($folder) {
    if (is_dir($folder . '/.svn')) {
        if (file_exists($folder . '/db_config.php')) {
            // this covers all portals
            if (file_exists($folder . '/sources/DbConfig.php')) {
                // remove the file
                unlink($folder . '/sources/DbConfig.php');
            }

            if (file_exists($folder . '/sources/Config.php')) {
                // remove the file
                unlink($folder . '/sources/Config.php');
            }

            copy($folder . '/db_config.php', $folder . '/sources/aaaDbConfig.php');
            copy($folder . '/db_config.php', $folder . '/sources/bbbConfig.php');

            $path_to_file = $folder . '/sources/aaaDbConfig.php';
            $path_to_new = $folder . '/sources/DbConfig.php';

            $ConfigStart = getLineWithString($path_to_file, 'class Config');
            $commentEnd = getLineWithString($path_to_file, '*/') + 1;
            $DbConfigStart = getLineWithString($path_to_file, 'class DB_Config');
            $contents = file($path_to_file);

            $keep1 = array_slice($contents, 0, $commentEnd);
            $keep2 = array_slice($contents, $DbConfigStart, $ConfigStart - $DbConfigStart);

            $keep = array_merge($keep1, $keep2);

            file_put_contents($path_to_new, $keep);

            $file_contents = file_get_contents($path_to_new);
            $file_contents = str_replace("class DB_Config", "\nnamespace Portal;\n\nclass DbConfig", $file_contents);
            file_put_contents($path_to_new, $file_contents);
            unlink($path_to_file);

            $path_to_file = $folder . '/sources/bbbConfig.php';
            $path_to_new = $folder . '/sources/Config.php';

            $ConfigStart = getLineWithString($path_to_file, 'class Config');
            $commentEnd = getLineWithString($path_to_file, '*/') + 1;
            $contents = file($path_to_file);

            $keep1 = array_slice($contents, 0, $commentEnd);
            $keep2 = array_slice($contents, $ConfigStart);

            $keep = array_merge($keep1, $keep2);

            file_put_contents($path_to_new, $keep);

            $file_contents = file_get_contents($path_to_new);
            $file_contents = str_replace("class Config", "\nnamespace Portal;\n\nclass Config", $file_contents);
            file_put_contents($path_to_new, $file_contents);
            unlink($path_to_file);
            unlink($folder . '/db_config.php');
        } else if (file_exists($folder . '/config.php')) {
            // this is nexus config
            if (file_exists($folder . '/sources/Config.php')) {
                // remove the file
                unlink($folder . '/sources/Config.php');
            }

            copy($folder . '/config.php', $folder . '/sources/bbbConfig.php');

            $path_to_file = $folder . '/sources/bbbConfig.php';
            $path_to_new = $folder . '/sources/Config.php';

            $ConfigStart = getLineWithString($path_to_file, 'class Config');
            $commentEnd = getLineWithString($path_to_file, '*/') + 1;
            $contents = file($path_to_file);

            $keep1 = array_slice($contents, 0, $commentEnd);
            $keep2 = array_slice($contents, $ConfigStart);

            $keep = array_merge($keep1, $keep2);

            file_put_contents($path_to_new, $keep);

            $file_contents = file_get_contents($path_to_new);
            $file_contents = str_replace("class Config", "\nnamespace Orgchart;\n\nclass Config", $file_contents);
            file_put_contents($path_to_new, $file_contents);
            unlink($path_to_file);
            unlink($folder . '/config.php');
        }
    } else {
        $items = scandir($folder);
        $depth++;
        foreach ($items as $item) {
            echo 'Location: ' . $folder . '/' . $item . "\r\n";
            if (is_dir($folder.'/'.$item) && ($item != '.' && $item != '..')) {
                check($folder.'/'.$item);
            }
        }
    }
}

function getLineWithString($fileName, $str) {
    $lines = file($fileName);

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, $str) !== false) {
            return $lineNumber;
        }
    }
    return -1;
}
