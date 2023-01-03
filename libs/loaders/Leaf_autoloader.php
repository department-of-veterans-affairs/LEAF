<?php

require_once __DIR__ . '/../php-commons/Psr4AutoloaderClass.php';
require_once __DIR__ . '/../smarty/bootstrap.php';

$loader = new \Leaf\Psr4AutoloaderClass;
$loader->register();
//error_log(print_r($_SERVER, true));
/* $url = $_SERVER['APP_PORTAL_URL_AUTH'];

$uri_array = explode('/', $url);

$uri = trim($_SERVER['REQUEST_URI'], '/');
//error_log(print_r($uri, true));
error_log(print_r($_SERVER, true));
/*for ($i=1; $i < count($uri_array) - 1; $i++) {
    $uri .= $uri_array[$i] . '/';
}

if (is_file(__DIR__ . '/../../' . $uri . 'globals.php')) {
    require_once __DIR__ . '/../../' . $uri . 'globals.php';
} */

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

    $file_paths_db = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

    $vars = array(':site_path' => '/' . PORTAL_PATH);
    $sql = 'SELECT site_path, site_uploads, portal_database, orgchart_path,
                orgchart_database, libs_path
            FROM sites
            WHERE site_path=:site_path';

    $site_paths = $file_paths_db->prepared_query($sql, $vars)[0];

    //error_log(print_r($site_paths, true));

    $working_dir = str_replace('/libs/loaders/Leaf_autoloader.php', '', __FILE__);

    $vars = array(':site_path' => $site_paths['orgchart_path']);
    $sql = 'SELECT site_path, orgchart_path, orgchart_database, site_uploads
            FROM sites
            WHERE site_path=:site_path';

    $oc_paths = $file_paths_db->prepared_query($sql, $vars)[0];

    if (is_dir($working_dir . $site_paths['site_path'])) {
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path']);
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/api');
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/api/controllers');
        $loader->addNamespace('Portal', $working_dir . $site_paths['site_path'] . '/sources');
    }

    if (is_dir($working_dir . $site_paths['orgchart_path'])) {

        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path']);
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/api');
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/api/controllers');
        $loader->addNamespace('Orgchart', $working_dir . $site_paths['orgchart_path'] . '/sources');
    }
}

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['portal_database']);
$oc_db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['orgchart_database']);

$vars = [];
$sql = 'SELECT setting, `data`
        FROM settings';

$all_settings = $db->prepared_query($sql, $vars);
$settings = [];

foreach ($all_settings as $setting) {
    $settings[$setting['setting']] = json_decode($setting['data'], true) ?: Leaf\XSSHelpers::sanitizeHTMLRich($setting['data']);
}

if (isset($settings['timeZone'])) {
    date_default_timezone_set($settings['timeZone']);
}

$sql = 'SELECT setting, `data`
        FROM settings';

$all_settings = $oc_db->prepared_query($sql, $vars);
$oc_settings = [];

foreach ($all_settings as $setting) {
    $oc_settings[$setting['setting']] = json_decode($setting['data'], true) ?: Leaf\XSSHelpers::sanitizeHTMLRich($setting['data']);
}

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
//error_log(print_r($loader, true));
if (session_id() == '') {
    if(defined('DIRECTORY_HOST')) {
        $session_db = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB, true);
    } else {
        $session_db = $oc_db;
    }

    $sessionHandler = new \Portal\Session($session_db);
    session_set_save_handler($sessionHandler, true);
    session_start();
    $cookie = session_get_cookie_params();
    $id = session_id();

    // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//            $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
    $https = true;
    setcookie('PHPSESSID', $id, time() + 2592000, $cookie['path'], $cookie['domain'], $https, true);
}

$login = new Portal\Login($oc_db, $db);
$oc_login = new Orgchart\Login($oc_db, $oc_db);
$data_action_logger = new Leaf\DataActionLogger($db, $login);

if (!defined('S_LIB_PATH')) define('S_LIB_PATH', 'https://' . $_SERVER['HTTP_HOST'] . '/libs/');
