<?php

$dir = '/var/www/html';
$items = scandir('/var/www/html');

$myfile = fopen("CustomTemplate.html", "a") or die("Unable to open file!");
$numPortals = 0;
$files = 0;
//echo '<ul>';
foreach ($items as $visn) {
    //echo $dir . '/' . $visn.'<br />';
    if ($visn != '.' && $visn != '..' && is_dir($dir . '/' . $visn)) {
        if (is_dir($dir . '/' . $visn . '/templates_c')) {
            exec("rm {$dir}/{$visn}/templates_c/*.tpl.php");
        } else {
            $sections = scandir($dir . '/' . $visn);

            foreach ($sections as $section) {
                if ($section != '.' && $section != '..' && is_dir($dir . '/' . $visn . '/' . $section)) {
                    if (is_dir($dir . '/' . $visn . '/' . $section . '/templates_c')) {
                        exec("rm {$dir}/{$visn}/{$section}/templates_c/*.tpl.php");
                    } else {
                        $portals = scandir($dir . '/' . $visn . '/' . $section);

                        foreach($portals as $portal) {
                            if ($portal != '.' && $portal != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal)) {
                                if (is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/templates_c')) {
                                    exec("rm {$dir}/{$visn}/{$section}/{$portal}/templates_c/*.tpl.php");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}