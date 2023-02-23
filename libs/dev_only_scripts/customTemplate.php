<?php

$dir = '/var/www/html';
$items = scandir('/var/www/html');

$myfile = fopen("CustomEvent.html", "a") or die("Unable to open file!");
$numPortals = 0;
$files = 0;
//echo '<ul>';
foreach ($items as $visn) {
    if ($visn != '.' && $visn != '..' && is_dir($dir . '/' . $visn)) {
        if (is_dir($dir . '/' . $visn . '/scripts/events')) {
            $events = scandir($dir . '/' . $visn . '/scripts/events');

            $i = 0;
            foreach ($events as $event) {
                if (
                    $event != '.'
                    && $event != '..'
                    && $event != 'CustomEvent_LeafSecure_Certified.php'
                    && $event != 'CustomEvent_LeafSecure_DeveloperConsole.php'
                    && $event != 'TEMPLATE_CustomEvent_YOUR_ID.php'
                    && strpos($event, 'CustomEvent') !== false
                ) {
                    if ($i == 0) {
                        $numPortals++;
                        $i++;
                    }
                    $files++;
                    cleanFile($visn . '/scripts/events' . '/' . $event, str_replace('.php', '', $event));
                    $txt = $visn . '/scripts/events' . '/' . $event . '<br />';
                    fwrite($myfile, $txt);
                    $txt = getLineWithString($visn . '/scripts/events' . '/' . $event);
                    fwrite($myfile, $txt);
                }
            }
        } else {
            $sections = scandir($dir . '/' . $visn);

            foreach ($sections as $section) {
                if ($section != '.' && $section != '..' && is_dir($dir . '/' . $visn . '/' . $section)) {
                    if (is_dir($dir . '/' . $visn . '/' . $section . '/scripts/events')) {
                        $events = scandir($dir . '/' . $visn . '/' . $section . '/scripts/events');

                        $j = 0;
                        foreach ($events as $event) {
                            if (
                                $event != '.'
                                && $event != '..'
                                && $event != 'CustomEvent_LeafSecure_Certified.php'
                                && $event != 'CustomEvent_LeafSecure_DeveloperConsole.php'
                                && $event != 'TEMPLATE_CustomEvent_YOUR_ID.php'
                                && strpos($event, 'CustomEvent') !== false
                            ) {
                                if ($j == 0) {
                                    $numPortals++;
                                    $j++;
                                }
                                $files++;
                                cleanFile($visn . '/' . $section . '/scripts/events' . '/' . $event, str_replace('.php', '', $event));
                                $txt = $visn . '/' . $section . '/scripts/events' . '/' . $event . '<br />';
                                fwrite($myfile, $txt);
                                $txt = getLineWithString($visn . '/' . $section . '/scripts/events' . '/' . $event);
                                fwrite($myfile, $txt);
                            }
                        }
                    } else {
                        $portals = scandir($dir . '/' . $visn . '/' . $section);

                        foreach($portals as $portal) {
                            if ($portal != '.' && $portal != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal)) {
                                if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/scripts/events')) {
                                    $events = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/scripts/events');

                                    $k = 0;
                                    foreach ($events as $event) {
                                        if (
                                            $event != '.'
                                            && $event != '..'
                                            && $event != 'CustomEvent_LeafSecure_Certified.php'
                                            && $event != 'CustomEvent_LeafSecure_DeveloperConsole.php'
                                            && $event != 'TEMPLATE_CustomEvent_YOUR_ID.php'
                                            && strpos($event, 'CustomEvent') !== false
                                        ) {
                                            if ($k == 0) {
                                                $numPortals++;
                                                $k++;
                                            }
                                            $files++;

                                            cleanFile($visn . '/' . $section . '/' . $portal . '/scripts/events' . '/' . $event, str_replace('.php', '', $event));
                                            $txt = $visn . '/' . $section . '/' . $portal . '/scripts/events' . '/' . $event . '<br />';
                                            fwrite($myfile, $txt);
                                            $txt = getLineWithString($visn . '/' . $section . '/' . $portal . '/scripts/events' . '/' . $event);
                                            fwrite($myfile, $txt);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

$text = 'There are ' . $numPortals . ' Portals with a total of ' . $files . ' custom files.';
fwrite($myfile, $text);
fclose($myfile);

function cleanFile($fileName, $className) {
    $dir = '/var/www/html/';

    $myline = getLine($dir . $fileName, 'class ' . $className);
    $commentEnd = getLine($dir . $fileName, '*/') + 1;
    $contents = file($dir . $fileName);
    $keep2 = array_slice($contents, $myline);

    $a = array_splice($contents, 0, $commentEnd);

    $keep = array_merge($a, $keep2);

    file_put_contents($dir . $fileName, $keep);

    $file_contents = file_get_contents($dir . $fileName);
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
    $lines = file('/var/www/html/' . $fileName);
    $result = '<ul>';

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, 'include') !== false || strpos($line, 'require') !== false || strpos($line, 'new ') !== false) {
            $result .= '<li>Line # ' . $lineNumber . '-' . $line . '</li>';
        }
    }

    $result .= '</ul>';
    return $result;
}