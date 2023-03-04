<?php

$dir = '/var/www/html';
$items = scandir('/var/www/html');

//$myfile = fopen("CustomTemplate.html", "a") or die("Unable to open file!");
$numPortals = 0;
$files = 0;
//echo '<ul>';
foreach ($items as $visn) {
    //echo $dir . '/' . $visn.'<br />';
    if ($visn != '.' && $visn != '..' && is_dir($dir . '/' . $visn)) {
        if (is_dir($dir . '/' . $visn . '/templates/custom_override')) {
            $events = scandir($dir . '/' . $visn . '/templates/custom_override');

            $i = 0;
            foreach ($events as $event) {
                if (
                    $event != '.'
                    && $event != '..'
                ) {
                    if ($i == 0) {
                        $numPortals++;
                        $i++;
                    }
                    //echo $dir . '/' . $visn . '/templates/custom_override' . '/' . $event.'<br />';
                    if (is_file($dir . '/' . $visn . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                        $files++;
                        cleanFile($visn . '/templates/custom_override' . '/' . $event);
                        $txt = '1. ' . $dir . '/' . $visn . '/templates/custom_override' . '/' . $event . '<br />';
                        //fwrite($myfile, $txt);
                        $txt = getLineWithString($dir . '/' . $visn . '/templates/custom_override' . '/' . $event);
                        //fwrite($myfile, $txt);
                    }

                }
            }
        } else {
            $sections = scandir($dir . '/' . $visn);

            foreach ($sections as $section) {
                if ($section != '.' && $section != '..' && is_dir($dir . '/' . $visn . '/' . $section)) {
                    if (is_dir($dir . '/' . $visn . '/' . $section . '/templates/custom_override')) {
                        $events = scandir($dir . '/' . $visn . '/' . $section . '/templates/custom_override');

                        $j = 0;
                        foreach ($events as $event) {
                            if (
                                $event != '.'
                                && $event != '..'
                            ) {
                                if ($j == 0) {
                                    $numPortals++;
                                    $j++;
                                }
                                //echo $dir . '/' . $visn . '/' . $section . '/templates/custom_override' . '/' . $event . '<br />';
                                if (is_file($dir . '/' . $visn . '/' . $section . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                                    $files++;
                                    cleanFile($visn . '/' . $section . '/templates/custom_override' . '/' . $event);
                                    $txt = '2. ' . $dir . '/' . $visn . '/' . $section . '/templates/custom_override' . '/' . $event . '<br />';
                                    //fwrite($myfile, $txt);
                                    $txt = getLineWithString($dir . '/' . $visn . '/' . $section . '/templates/custom_override' . '/' . $event);
                                    //fwrite($myfile, $txt);
                                }
                            }
                        }
                    } else {
                        $portals = scandir($dir . '/' . $visn . '/' . $section);

                        foreach($portals as $portal) {
                            if ($portal != '.' && $portal != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal)) {
                                if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override')) {
                                    $events = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override');

                                    $k = 0;
                                    foreach ($events as $event) {
                                        if (
                                            $event != '.'
                                            && $event != '..'
                                        ) {
                                            if ($k == 0) {
                                                $numPortals++;
                                                $k++;
                                            }
                                            //echo $dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event . '<br />';
                                            if (is_file($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                                                $files++;
                                                cleanFile($visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event);
                                                $txt = '2. ' . $dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event . '<br />';
                                                //fwrite($myfile, $txt);
                                                $txt = getLineWithString($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event);
                                                //fwrite($myfile, $txt);
                                            }
                                        }
                                    }
                                } else {
                                    $fourth = scandir($dir . '/' . $visn . '/' . $section);

                                    foreach($fourth as $four) {
                                        if ($four != '.' && $four != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four)) {
                                            if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override')) {
                                                $events = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override');

                                                $k = 0;
                                                foreach ($events as $event) {
                                                    if (
                                                        $event != '.'
                                                        && $event != '..'
                                                    ) {
                                                        if ($k == 0) {
                                                            $numPortals++;
                                                            $k++;
                                                        }
                                                        //echo $dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event . '<br />';
                                                        if (is_file($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                                                            $files++;
                                                            cleanFile($visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override' . '/' . $event);
                                                            $txt = '2. ' . $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override' . '/' . $event . '<br />';
                                                            //fwrite($myfile, $txt);
                                                            $txt = getLineWithString($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates/custom_override' . '/' . $event);
                                                            //fwrite($myfile, $txt);
                                                        }
                                                    }
                                                }
                                            } else {
                                                $fifth = scandir($dir . '/' . $visn . '/' . $section);

                                                foreach($fifth as $five) {
                                                    if ($five != '.' && $five != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five)) {
                                                        if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override')) {
                                                            $events = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override');

                                                            $k = 0;
                                                            foreach ($events as $event) {
                                                                if (
                                                                    $event != '.'
                                                                    && $event != '..'
                                                                ) {
                                                                    if ($k == 0) {
                                                                        $numPortals++;
                                                                        $k++;
                                                                    }
                                                                    //echo $dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates/custom_override' . '/' . $event . '<br />';
                                                                    if (is_file($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override' . '/' . $event) && substr($event, -4) == '.tpl') {
                                                                        $files++;
                                                                        cleanFile($visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override' . '/' . $event);
                                                                        $txt = '2. ' . $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override' . '/' . $event . '<br />';
                                                                        //fwrite($myfile, $txt);
                                                                        $txt = getLineWithString($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates/custom_override' . '/' . $event);
                                                                        //fwrite($myfile, $txt);
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
                        }
                    }
                }
            }
        }
    }
}

$text = 'There are ' . $numPortals . ' Portals with a total of ' . $files . ' custom files.';
//fwrite($myfile, $text);
//fclose($myfile);

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