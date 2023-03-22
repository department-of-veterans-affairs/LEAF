<?php

require_once '/var/www/html/libs/php-commons/Db.php';
require_once '/var/www/html/Academy/Demo1/globals.php';

$dir = '/var/www/html/Academy';

checkTemplate($dir);

function checkTemplate($folder) {
    if (is_dir($folder . '/.svn')) {
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
            $args[] = $portal;
            $args[] = $site_paths['portal_database'];
            $config = readPortalConfig($args);
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

            $args[] = $orgchart;
            $args[] = $site_paths['orgchart_database'];
            $config = readNexusConfig($args);
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
        $arg = '\'' . serialize($portalDirectory) . '\'';
        $phpPath = 'php';
        $script = '/var/www/scripts/leaf-scripts/src/orgchart_config_to_db.php';
        return unserialize(shell_exec($phpPath . ' ' . $script . ' ' . $arg));
}

function readPortalConfig($portalDirectory)
{
        $arg = '\'' . serialize($portalDirectory) . '\'';
        $phpPath = 'php';
        $script = '/var/www/scripts/leaf-scripts/src/portal_config_to_db.php';
        return unserialize(shell_exec($phpPath . ' ' . $script . ' '. $arg));
}
