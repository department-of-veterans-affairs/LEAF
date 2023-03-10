<?php

require_once __DIR__ . '/../php-commons/Psr4AutoloaderClass.php';
require_once __DIR__ . '/../smarty/bootstrap.php';

$loader = new \Leaf\Psr4AutoloaderClass;
$loader->register();

if (is_dir(__DIR__ . '/../php-commons') || is_dir(__DIR__ . '/../../php-commons')) {
    if (is_dir(__DIR__ . '/../php-commons')) {
        $loader->addNamespace('Leaf', __DIR__ . '/../php-commons');
        $loader->addNamespace('Leaf', __DIR__ . '/../logger');
        $loader->addNamespace('Leaf', __DIR__ . '/../logger/formatters');
    } else {
        $loader->addNamespace('Leaf', __DIR__ . '/../../php-commons');
        $loader->addNamespace('Leaf', __DIR__ . '/../../logger');
        $loader->addNamespace('Leaf', __DIR__ . '/../../logger/formatters');
    }

    $file_paths_db = new \Leaf\Db(getenv('DATABASE_HOST'), getenv('DATABASE_USERNAME'), getenv('DATABASE_PASSWORD'), 'national_leaf_launchpad');

    $vars = array(':site_path' => '/' . PORTAL_PATH);
    $sql = 'SELECT site_path, site_uploads, portal_database, orgchart_path,
                orgchart_database
            FROM sites
            WHERE site_path= BINARY :site_path';

    $site_paths = $file_paths_db->prepared_query($sql, $vars)[0];

    $working_dir = str_replace('/libs/loaders/Leaf_autoloader.php', '', __FILE__);

    if (is_dir($working_dir . $site_paths['site_path'])) {
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path']);
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/api');
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/api/controllers');
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/sources');
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/scripts/events');
    }

    if (is_dir($working_dir . $site_paths['orgchart_path'])) {

        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path']);
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/api');
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/api/controllers');
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/sources');
    }
}

if (class_exists('Portal\DbConfig')) {
    $db_config = new Portal\DbConfig();
    $config = new Portal\Config();
}

$oc_config = new Orgchart\Config();

if (!empty($site_paths['portal_database'])){
    $db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['portal_database']);
} else {
    $db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['orgchart_database']);
}

$oc_db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['orgchart_database']);

unset($db_config);

ini_set('session.gc_maxlifetime', 2592000);

// Sanitize all $_GET input
if (count($_GET) > 0) {
    $keys = array_keys($_GET);
    foreach ($keys as $key) {
        if (is_string($_GET[$key])) {
            $_GET[$key] = htmlentities($_GET[$key], ENT_QUOTES);
        }
    }
}

if (session_id() == '') {
    if(defined('DIRECTORY_HOST')) {
        $session_db = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB, true);
    } else {
        $session_db = $oc_db;
    }

    if (class_exists('Portal\Session')) {
        $sessionHandler = new \Portal\Session($session_db);
    } else {
        $sessionHandler = new \Orgchart\Session($session_db);
    }

    session_set_save_handler($sessionHandler, true);
    session_start();
    $cookie = session_get_cookie_params();
    $id = session_id();

    // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//            $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
    $https = true;
    setcookie('PHPSESSID', $id, time() + 2592000, $cookie['path'], $cookie['domain'], $https, true);
}

if (class_exists('Portal\Login')) {
    $login = new Portal\Login($oc_db, $db);
} else if (class_exists('Orgchart\Login')) {
    $login = new Orgchart\Login($oc_db, $db);
    $oc_login = new Orgchart\Login($oc_db, $oc_db);
} else {
    error_log(print_r($loader, true));
    exit;
}
$data_action_logger = new Leaf\DataActionLogger($db, $login);

if (!defined('S_LIB_PATH')) define('S_LIB_PATH', 'https://' . getenv('APP_HTTP_HOST') . '/libs');
if (!defined('ABSOLUTE_ORG_PATH')) define('ABSOLUTE_ORG_PATH', 'https://' . getenv('APP_HTTP_HOST') . $site_paths['orgchart_path']);
if (!defined('ABSOLUTE_PORT_PATH')) define('ABSOLUTE_PORT_PATH', 'https://' . getenv('APP_HTTP_HOST') . $site_paths['site_path']);
if (!defined('DOMAIN_PATH')) define('DOMAIN_PATH', 'https://' . getenv('APP_HTTP_HOST'));
