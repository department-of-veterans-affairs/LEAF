<?php

$dir = '/var/www/html';
$items = scandir('/var/www/html');

function checkTemplate($folder) {
    if (is_dir($folder . '/.svn')) {
        if (is_dir($folder . '/templates/custom_override') || is_dir($folder . '/templates/reports')) {
            $events = scandir($folder . '/templates/custom_override');
            $events2 = scandir($folder . '/templates/reports');

            $i = 0;
            foreach ($events as $event) {
                if ($event != '.' && $event != '..') {
                    if (is_file($dir . '/' . $visn . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                        cleanFile($folder . '/templates/custom_override' . '/' . $event);
                    }
                }
            }
            foreach ($events2 as $event) {
                if ($event != '.' && $event != '..') {
                    if (is_file($folder . '/templates/reports' . '/' . $event) && substr($event, -4) == '.tpl') {
                        cleanFile($folder . '/templates/reports' . '/' . $event);
                    }
                }
            }
        }
    } else {
        $items = scandir($folder);
        foreach ($items as $item) {
            echo 'Location: ' . $folder . '/' . $item . "\r\n";
            if (is_dir($folder.'/'.$item) && ($item != '.' && $item != '..')) {
                checkTemplate($folder.'/'.$item);
            }
        }
    }
}


function cleanFile($fileName) {
    //echo $fileName . '<br />';
    $dir = '/var/www/html/';

    $file_contents = file_get_contents($dir . $fileName);
    $file_contents = str_replace("../libs/dynicons", "dynicons", $file_contents);
    $file_contents = str_replace("../libs/qrcode", '{$abs_portal_path}/qrcode', $file_contents);
    $file_contents = str_replace("https://leaf.va.gov/", "/", $file_contents);
    file_put_contents($dir . $fileName, $file_contents);
}

function getLine($fileName, $str) {
    $lines = file($fileName);

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, $str) !== false) {
            return (int) $lineNumber;
        }
    }
    return -1;
}

function getLineWithString($fileName) {
    $lines = file($fileName);
    $result = '<ul>';

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, 'include') !== false || strpos($line, 'require') !== false || strpos($line, 'new ') !== false) {
            $result .= '<li>Line # ' . $lineNumber . '-' . $line . '</li>';
        } else if (strpos($line, '../libs/dynicons')) {
            $result .= '<li>Line # ' . $lineNumber . '- dynicons line</li>';
        }
    }

    $result .= '</ul>';
    return $result;
}
