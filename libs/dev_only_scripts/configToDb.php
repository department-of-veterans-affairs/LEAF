<?php

require_once '/var/www/html/libs/php-commons/Db.php';
require_once '/var/www/html/Academy/Demo1/globals.php';

$dir = '/var/www/html/Academy';

checkTemplate($dir);

function checkTemplate($folder) {
    if (is_dir($folder . '/.svn')) {
    //if (is_dir($folder . '/sources')) {
        if (file_exists($folder . '/sources/DbConfig.php')) {
            // we are in a portal
            $portal = str_replace('/var/www/html', '', $folder);

            // instantiate a national_leaf_launchpad db
            $launchpad_db = new \Leaf\Db(getenv('DATABASE_HOST'), getenv('DATABASE_USERNAME'), getenv('DATABASE_PASSWORD'), 'national_leaf_launchpad');

            // get the db name for this portal
            $vars = array(':site_path' => $portal);
            $sql = 'SELECT portal_database
                    FROM sites
                    WHERE site_path= BINARY :site_path';

            $site_paths = $launchpad_db->prepared_query($sql, $vars)[0];

            // instantiate a portal db
            $db =  new \Leaf\Db(getenv('DATABASE_HOST'), getenv('DATABASE_USERNAME'), getenv('DATABASE_PASSWORD'), $site_paths['portal_database']);

            $config = readPortalConfig($portal);

            // populate db with config data
            $sql = 'INSERT INTO `settings` (`setting`, `data`)
                    VALUES (:setting, :data)
                    ON DUPLICATE KEY UPDATE `setting`=:setting';

            $vars = array(':setting' => 'heading',
                    ':data' => $config['title']);
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'subHeading',
                    ':data' => $config['city']);
            $db->prepared_query($sql, $vars);

            $data = json_encode($config->adPath, JSON_FORCE_OBJECT);
            error_log(print_r($data, true));
            $vars = array(':setting' => 'adPath',
                    ':data' => json_encode($config['adPath'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'orgchartImportTags',
                    ':data' => json_encode($config['orgchartImportTags'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'descriptionID',
                    ':data' => $config['descriptionID']);
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'emailCC',
                    ':data' => json_encode($config['emailCC'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'emailBCC',
                    ':data' => json_encode($config['emailBCC'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);
        } elseif (file_exists($folder . '/sources/Config.php')) {
            // we are in an orgchart
            $orgchart = str_replace('/var/www/html', '', $folder);

            // instantiate a national_leaf_launchpad db
            $launchpad_db = new \Leaf\Db(getenv('DATABASE_HOST'), getenv('DATABASE_USERNAME'), getenv('DATABASE_PASSWORD'), 'national_leaf_launchpad');

            // get the db name for this portal
            $vars = array(':site_path' => $orgchart);
            $sql = 'SELECT orgchart_database
                    FROM sites
                    WHERE site_path= BINARY :site_path';

            $site_paths = $launchpad_db->prepared_query($sql, $vars)[0];

            // instantiate a portal db
            $db =  new \Leaf\Db(getenv('DATABASE_HOST'), getenv('DATABASE_USERNAME'), getenv('DATABASE_PASSWORD'), $site_paths['orgchart_database']);

            // instantiate a Config.php
            $config = readNexusConfig($orgchart);

            // populate db with config data
            $sql = 'INSERT INTO `settings` (`setting`, `data`)
                    VALUES (:setting, :data)
                    ON DUPLICATE KEY UPDATE `setting`=:setting';

            $vars = array(':setting' => 'heading',
                    ':data' => $config['title']);
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'subheading',
                    ':data' => $config['city']);
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'adPath',
                    ':data' => json_encode($config['adPath'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);

            $vars = array(':setting' => 'ERM_Sites',
                    ':data' => json_encode($config['ERM_Sites'], JSON_FORCE_OBJECT));
            $db->prepared_query($sql, $vars);
        }
    } else {
        $items = scandir($folder);
        foreach ($items as $item) {
            echo 'Location: ' . $folder . '/' . $item . "<br />";
            if (is_dir($folder.'/'.$item) && ($item != '.' && $item != '..')) {
                checkTemplate($folder.'/'.$item);
            }
        }


    }
}

function readNexusConfig($portalDirectory)
{
        $phpPath = 'php';
        $script = '/var/www/scripts/leaf-scripts/src/read_orgchart_config.php';
        return unserialize(shell_exec($phpPath . ' ' . $script . ' ' . $portalDirectory));
}

function readPortalConfig($portalDirectory)
{
        $phpPath = 'php';
        $script = '/var/www/scripts/leaf-scripts/src/read_portal_config.php';
        return unserialize(shell_exec($phpPath . ' ' . $script . ' '. $portalDirectory));
}