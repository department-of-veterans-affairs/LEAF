<?php

$dir = '/var/www/html';

checkTemplate($dir);

function checkTemplate($folder) {
    if (is_dir($folder . '/.svn')) {
        if (is_dir($folder . '/templates/custom_override') || is_dir($folder . '/templates/reports' || is_dir($folder . '/scripts/events'))) {
            $events = scandir($folder . '/templates/custom_override');
            $events2 = scandir($folder . '/templates/reports');

            foreach ($events as $event) {
                if ($event != '.' && $event != '..') {
                    if (is_file($folder . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
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
            foreach ($events3 as $event) {
                if ($event != '.' && $event != '..' 
                    && $event != 'CustomEvent_LeafSecure_Certified.php'
                    && $event != 'CustomEvent_LeafSecure_DeveloperConsole.php'
                    && $event != 'TEMPLATE_CustomEvent_YOUR_ID.php'
                    && strpos($event, 'CustomEvent') !== false
                ) {
                    cleanEvent($folder . '/scripts/events' . '/' . $event, str_replace('.php', '', $event));
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
    $file_contents = file_get_contents($fileName);
    $file_contents = str_replace("../libs/dynicons", "dynicons", $file_contents);
    $file_contents = str_replace("../libs/qrcode", '{$abs_portal_path}/qrcode', $file_contents);
    $file_contents = str_replace("https://leaf.va.gov/", "/", $file_contents);
    file_put_contents($fileName, $file_contents);
}

function cleanEvent($fileName, $className) {
    $myline = getLine($fileName, 'class ' . $className);
    $commentEnd = getLine($fileName, '*/') + 1;
    $contents = file($fileName);
    $keep2 = array_slice($contents, $myline);

    $a = array_splice($contents, 0, $commentEnd);

    $keep = array_merge($a, $keep2);

    file_put_contents($fileName, $keep);

    $file_contents = file_get_contents($fileName);
    $file_contents = str_replace("class " . $className, "\nnamespace Portal;\n\nclass " . $className, $file_contents);
    $file_contents = str_replace("include_once '../form.php';", "", $file_contents);
    $file_contents = str_replace("include_once '../FormWorkflow.php';", "", $file_contents);
    $file_contents = str_replace("new DB", "new \Leaf\Db", $file_contents);
    $file_contents = str_replace("DIRECTORY_HOST", "\DIRECTORY_HOST", $file_contents);
    $file_contents = str_replace("DIRECTORY_USER", "\DIRECTORY_USER", $file_contents);
    $file_contents = str_replace("DIRECTORY_PASS", "\DIRECTORY_PASS", $file_contents);
    $file_contents = str_replace("DIRECTORY_DB", "\DIRECTORY_DB", $file_contents);
    $file_contents = str_replace("new COM", "new \COM", $file_contents);
    $file_contents = str_replace("include_once '../../libs/smarty/Smarty.class.php';", "", $file_contents);
    $file_contents = str_replace("Smarty", "\Smarty", $file_contents);
    $file_contents = str_replace('include_once __DIR__ . "/../../db_config.php";', "", $file_contents);
    $file_contents = str_replace("include_once 'form.php';", "", $file_contents);
    $file_contents = str_replace("https://leaf.va.gov/", "/", $file_contents);
    file_put_contents($fileName, $file_contents);
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
