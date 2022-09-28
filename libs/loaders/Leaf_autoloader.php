<?php

spl_autoload_register("auto_load");

function auto_load($class)
{
    // work in Nexus root first
    $path = './';
    $ext = '.php';
    $fullPath = $path . $class . $ext;
    /*if ($class == 'DataActions') {
        error_log($class);
    }*/

    if (file_exists($fullPath)) {
        // error_log('Full Path');
        include_once $fullPath;
    } else if (substr($class, 0, 8) == 'Orgchart') {
        $class_name = substr($class, 9);

        $path = dirname(__FILE__) . '/../../LEAF_Nexus/';

        if ($class_name == 'Config') {
            // error_log('Nexus Config');
            include_once dirname(__FILE__) . '/../../LEAF_Nexus/config.php';
        } else if (file_exists($path . 'sources/' . $class_name . '.php')) {
            // error_log('Nexus Class');
            include_once $path . 'sources/' . $class_name . '.php';
        } else if (file_exists($path . 'api/' . $class_name . '.php')) {
            // error_log('Nexus Api');
            include_once $path . 'api/' . $class_name . '.php';
        } else if (file_exists($path . 'api/controllers/' . $class_name . '.php')) {
            // error_log('Nexus Api Controllers');
            include_once $path . 'api/controllers/' . $class_name . '.php';
        }
    } else {
        $path = dirname(__FILE__) . '/../../LEAF_Request_Portal/';
        $nexus_path = dirname(__FILE__) . '/../../LEAF_Nexus/';
        $lib_path  = dirname(__FILE__) . '/../../libs/';

        if (file_exists($path . $class.$ext)) {
            // error_log('Portal Full Path');
            include_once $path . $class.$ext;
        } else if (file_exists($path . 'admin/' . $class.$ext)) {
            // error_log('Portal admin');
            include_once $path . 'admin/' . $class.$ext;
        } else if (file_exists($path . 'api/' . $class.$ext)) {
            // error_log('Portal api');
            include_once $path . 'api/' . $class.$ext;
        } else if (file_exists($path . 'api/controllers/' . $class.$ext)) {
            // error_log('Portal api controllers');
            include_once $path . 'api/controllers/' . $class.$ext;
        } else if (file_exists($nexus_path . 'api/' . $class.$ext)) {
            // error_log('Nexus Api');
            include_once $nexus_path . 'api/' . $class.$ext;
        } else if (file_exists($nexus_path . 'api/controllers/' . $class.$ext)) {
            // error_log('Nexus Api Controllers');
            include_once $nexus_path . 'api/controllers/' . $class.$ext;
        } else if (file_exists($path . 'sources/' . $class.$ext)) {
            // error_log('Portal Class');
            include_once $path . 'sources/' . $class.$ext;
        } else if (file_exists($lib_path . 'logger/' . $class.$ext)) {
            // error_log('Portal Logger ' . $class);
            include_once $lib_path . 'logger/' . $class.$ext;
        } else if (file_exists($lib_path . 'logger/formatters/' . $class.$ext)) {
            // error_log('Portal Logger Formatters ' . $class);
            include_once $lib_path . 'logger/formatters/' . $class.$ext;
        } else if (file_exists($lib_path . 'php-commons/' . $class.$ext)) {
            // error_log('Portal Commons');
            include_once $lib_path . 'php-commons/' . $class.$ext;
        } else if (file_exists($lib_path . 'php-commons/spreadsheet/' . $class.$ext)) {
            // error_log('Portal Spreadsheet');
            include_once $lib_path . 'php-commons/spreadsheet/' . $class.$ext;
        } else if (file_exists($lib_path . 'smarty/' . $class . '.class' . $ext)) {
            // error_log('Portal Smarty');
            include_once $lib_path . 'smarty/' . $class . '.class' . $ext;
        } else {
            // error_log('no class added expect an error '. $class);
        }
    }

}
