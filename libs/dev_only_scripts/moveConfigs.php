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
        if (file_exists($dir . '/' . $visn . '/db_config.php')) {
            // this covers all portals
            if (file_exists($dir . '/' . $visn . '/sources/DbConfig.php')) {
                // remove the file
                unlink($dir . '/' . $visn . '/sources/DbConfig.php');
            }

            if (file_exists($dir . '/' . $visn . '/sources/Config.php')) {
                // remove the file
                unlink($dir . '/' . $visn . '/sources/Config.php');
            }

            copy($dir . '/' . $visn . '/db_config.php', $dir . '/' . $visn . '/sources/aaaDbConfig.php');
            copy($dir . '/' . $visn . '/db_config.php', $dir . '/' . $visn . '/sources/bbbConfig.php');

            $path_to_file = $dir . '/' . $visn . '/sources/aaaDbConfig.php';
            $path_to_new = $dir . '/' . $visn . '/sources/DbConfig.php';

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

            $path_to_file = $dir . '/' . $visn . '/sources/bbbConfig.php';
            $path_to_new = $dir . '/' . $visn . '/sources/Config.php';

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
            unlink($dir . '/' . $visn . '/db_config.php');
        } else if (file_exists($dir . '/' . $visn . '/config.php')) {
            // this is nexus config
            if (file_exists($dir . '/' . $visn . '/sources/Config.php')) {
                // remove the file
                unlink($dir . '/' . $visn . '/sources/Config.php');
            }

            copy($dir . '/' . $visn . '/config.php', $dir . '/' . $visn . '/sources/bbbConfig.php');

            $path_to_file = $dir . '/' . $visn . '/sources/bbbConfig.php';
            $path_to_new = $dir . '/' . $visn . '/sources/Config.php';

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
            unlink($dir . '/' . $visn . '/config.php');
        } else {
            $sections = scandir($dir . '/' . $visn);

            foreach ($sections as $section) {
                if ($section != '.' && $section != '..' && is_dir($dir . '/' . $visn . '/' . $section)) {
                    if (file_exists($dir . '/' . $visn . '/' . $section . '/db_config.php')) {
                        // this covers all portals
                        if (file_exists($dir . '/' . $visn . '/' . $section . '/sources/DbConfig.php')) {
                            // remove the file
                            unlink($dir . '/' . $visn . '/' . $section . '/sources/DbConfig.php');
                        }

                        if (file_exists($dir . '/' . $visn . '/' . $section . '/sources/Config.php')) {
                            // remove the file
                            unlink($dir . '/' . $visn . '/' . $section . '/sources/Config.php');
                        }

                        copy($dir . '/' . $visn . '/' . $section . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/sources/aaaDbConfig.php');
                        copy($dir . '/' . $visn . '/' . $section . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/sources/bbbConfig.php');

                        $path_to_file = $dir . '/' . $visn . '/' . $section . '/sources/aaaDbConfig.php';
                        $path_to_new = $dir . '/' . $visn . '/' . $section . '/sources/DbConfig.php';

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

                        $path_to_file = $dir . '/' . $visn . '/' . $section . '/sources/bbbConfig.php';
                        $path_to_new = $dir . '/' . $visn . '/' . $section . '/sources/Config.php';

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
                        unlink($dir . '/' . $visn . '/' . $section . '/db_config.php');
                    } else if (file_exists($dir . '/' . $visn . '/' . $section . '/config.php')) {
                        // this is nexus config
                        if (file_exists($dir . '/' . $visn . '/' . $section . '/sources/Config.php')) {
                            // remove the file
                            unlink($dir . '/' . $visn . '/' . $section . '/sources/Config.php');
                        }

                        copy($dir . '/' . $visn . '/' . $section . '/config.php', $dir . '/' . $visn . '/' . $section . '/sources/bbbConfig.php');

                        $path_to_file = $dir . '/' . $visn . '/' . $section . '/sources/bbbConfig.php';
                        $path_to_new = $dir . '/' . $visn . '/' . $section . '/sources/Config.php';

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
                        unlink($dir . '/' . $visn . '/' . $section . '/config.php');
                    } else {
                        $portals = scandir($dir . '/' . $visn . '/' . $section);

                        foreach($portals as $portal) {
                            if ($portal != '.' && $portal != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal)) {
                                if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/db_config.php')) {
                                    // this covers all portals
                                    if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/DbConfig.php')) {
                                        // remove the file
                                        unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/DbConfig.php');
                                    }

                                    if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php')) {
                                        // remove the file
                                        unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php');
                                    }

                                    copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/aaaDbConfig.php');
                                    copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/bbbConfig.php');

                                    $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/aaaDbConfig.php';
                                    $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/DbConfig.php';

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

                                    $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/bbbConfig.php';
                                    $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php';

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
                                    unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/db_config.php');
                                } else if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/config.php')) {
                                    // this is nexus config
                                    if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php')) {
                                        // remove the file
                                        unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php');
                                    }

                                    copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/bbbConfig.php');

                                    $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/bbbConfig.php';
                                    $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/sources/Config.php';

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
                                    unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/config.php');
                                } else {
                                    $fourth = scandir($dir . '/' . $visn . '/' . $section);

                                    foreach($fourth as $four) {
                                        if ($four != '.' && $four != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four)) {
                                            if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/db_config.php')) {
                                                // this covers all portals
                                                if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/DbConfig.php')) {
                                                    // remove the file
                                                    unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/DbConfig.php');
                                                }

                                                if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php')) {
                                                    // remove the file
                                                    unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php');
                                                }

                                                copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/aaaDbConfig.php');
                                                copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/bbbConfig.php');

                                                $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/aaaDbConfig.php';
                                                $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/DbConfig.php';

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

                                                $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/bbbConfig.php';
                                                $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php';

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
                                                unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/db_config.php');
                                            } else if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/config.php')) {
                                                // this is nexus config
                                                if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php')) {
                                                    // remove the file
                                                    unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php');
                                                }

                                                copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/bbbConfig.php');

                                                $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/bbbConfig.php';
                                                $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/sources/Config.php';

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
                                                unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/config.php');
                                            } else {
                                                $fifth = scandir($dir . '/' . $visn . '/' . $section);

                                                foreach($fifth as $five) {
                                                    if ($five != '.' && $five != '..' && is_dir($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five)) {
                                                        if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/db_config.php')) {
                                                            // this covers all portals
                                                            if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/DbConfig.php')) {
                                                                // remove the file
                                                                unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/DbConfig.php');
                                                            }

                                                            if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php')) {
                                                                // remove the file
                                                                unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php');
                                                            }

                                                            copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/aaaDbConfig.php');
                                                            copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/db_config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/bbbConfig.php');

                                                            $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/aaaDbConfig.php';
                                                            $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/DbConfig.php';

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

                                                            $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/bbbConfig.php';
                                                            $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php';

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
                                                            unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/db_config.php');
                                                        } else if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/config.php')) {
                                                            // this is nexus config
                                                            if (file_exists($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php')) {
                                                                // remove the file
                                                                unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php');
                                                            }

                                                            copy($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/config.php', $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/bbbConfig.php');

                                                            $path_to_file = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/bbbConfig.php';
                                                            $path_to_new = $dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/sources/Config.php';

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
                                                            unlink($dir . '/' . $visn . '/' . $section . '/' . $portal . '/' . $four . '/' . $five . '/config.php');
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

function getLineWithString($fileName, $str) {
    $lines = file($fileName);

    foreach ($lines as $lineNumber => $line) {
        if (strpos($line, $str) !== false) {
            return $lineNumber;
        }
    }
    return -1;
}