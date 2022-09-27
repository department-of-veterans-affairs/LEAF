<?php

spl_autoload_register("auto_load");

function auto_load($class)
{
    // work in Nexus root first
    $path = './';
    $ext = '.php';
    $fullPath = $path . $class . $ext;
    echo __DIR__.'<br />';
    echo $fullPath.'<br />';
    echo $class.'<br />';

    if (include_once $fullPath) {
        // made it
        echo 'full path route<br />';
    } else if ($class == 'Db') {
        include_once $fullPath;
        echo 'this is a root thing<br />';
    } else if (substr($class, 0, 8) == 'Orgchart') {
        echo 'this is a nexus thing<br />';
        $class_name = substr($class, 9);

        if ($class_name == 'Config') {
            include_once dirname(__FILE__) . '/../../LEAF_Nexus/config.php';
        } else {
            include_once dirname(__FILE__) . '/../../LEAF_Nexus/sources/'.$class_name.'.php';
        }
    } else {
        $path = dirname(__FILE__) . '/../../LEAF_Request_Portal/';
        echo $path . 'admin/' . $class.$ext.'<br />';

        if (include_once $path . 'admin/' . $class.$ext) {
            echo 'portal full path admin<br />';
        } else if (include_once $path . 'sources/' . $class.$ext){
            echo 'portal full path sources<br />';
        }

        $path = dirname(__FILE__) . '/../../libs/';

        if (include_once $path . 'logger/' . $class.$ext) {
            echo 'portal full path logger<br />';
        } else if (include_once $path . 'php-commons/' . $class.$ext){
            echo 'portal full path commons<br />';
        } else if (include_once $path . 'php-commons/spreadsheet/' . $class.$ext){
            echo 'portal full path commons spreadsheet<br />';
        } else if (include_once $path . 'smarty/' . $class . '.class' . $ext){
            echo 'portal full path smarty<br />';
        }
    }

}
