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
        if (is_dir($dir . '/' . $visn . '/templates_c')) {
            $scan = scandir($dir . '/' . $visn . '/templates_c');
            $file_to_delete = false;
            foreach ($scan as $file) {
                if (strpos($file, '.tpl.php')) {
                    $file_to_delete = true;
                    continue;
                }
            }
            if ($file_to_delete) {
                exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
            }
        } else {
            $sections = scandir($dir . '/' . $visn);

            foreach ($sections as $section) {
                if ($section != '.' && $section != '..' && is_dir($dir . '/' . $visn . '/' . $section)) {
                    if (is_dir($dir . '/' . $visn . '/' . $section . '/templates_c')) {
                        $scan = scandir($dir . '/' . $visn . '/' . $section . '/templates_c');
                        $file_to_delete = false;
                        foreach ($scan as $file) {
                            if (strpos($file, '.tpl.php')) {
                                $file_to_delete = true;
                                continue;
                            }
                        }
                        if ($file_to_delete) {
                            exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
                        }
                    } else {
                        $portals = scandir($dir . '/' . $visn . '/' . $section);

                        foreach($portals as $portal) {
                            if ($portal != '.' && $portal != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal)) {
                                if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates_c')) {
                                    $scan = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates_c');
                                    $file_to_delete = false;
                                    foreach ($scan as $file) {
                                        if (strpos($file, '.tpl.php')) {
                                            $file_to_delete = true;
                                            continue;
                                        }
                                    }
                                    if ($file_to_delete) {
                                        exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
                                    }
                                }
                            } else {
                                $fourth = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal);

                                foreach($fourth as $four) {
                                    if ($four != '.' && $four != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four)) {
                                        if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates_c')) {
                                            $scan = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/templates_c');
                                            $file_to_delete = false;
                                            foreach ($scan as $file) {
                                                if (strpos($file, '.tpl.php')) {
                                                    $file_to_delete = true;
                                                    continue;
                                                }
                                            }
                                            if ($file_to_delete) {
                                                exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
                                            }
                                        }
                                    } else {
                                        $fifth = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal);

                                        foreach($fifth as $five) {
                                            if ($five != '.' && $five != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five)) {
                                                if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates_c')) {
                                                    $scan = scandir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/templates_c');
                                                    $file_to_delete = false;
                                                    foreach ($scan as $file) {
                                                        if (strpos($file, '.tpl.php')) {
                                                            $file_to_delete = true;
                                                            continue;
                                                        }
                                                    }
                                                    if ($file_to_delete) {
                                                        exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
                                                    }
                                                }
                                            } else {

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