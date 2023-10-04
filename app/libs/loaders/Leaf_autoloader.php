<?php
use App\Leaf\Db;
use App\Leaf\Psr4AutoloaderClass;
use App\Leaf\Setting;
use App\Leaf\Logger\DataActionLogger;

$curr_dir = '/var/www/html';
$app_dir = '/var/www/html/app';

require_once $app_dir . '/libs/globals.php';
require_once $app_dir . '/Leaf/Psr4AutoloaderClass.php';
require_once $app_dir . '/libs/smarty/bootstrap.php';

$loader = new Psr4AutoloaderClass;
$loader->register();

$loader->addNamespace('App\Leaf', $app_dir . '/Leaf');
$loader->addNamespace('App\Leaf\Logger', $app_dir . '/Leaf/Logger');
$loader->addNamespace('App\Leaf\Logger\Formatters', $app_dir . '/Leaf/Logger/Formatters');

$file_paths_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

if (substr(PORTAL_PATH, 0, 1) !== '/') {
    $my_path = '/' . PORTAL_PATH;
} else {
    $my_path = PORTAL_PATH;
}
$vars = array(':site_path' => $my_path);
$sql = 'SELECT `site_path`, `site_uploads`, `portal_database`, `orgchart_path`,
            `orgchart_database`
        FROM `sites`
        WHERE `site_path` = BINARY :site_path';
//error_log(print_r($vars, true));
$site_paths = $file_paths_db->pdo_select_query($sql, $vars);
//error_log(print_r($site_paths, true));
$site_paths = $site_paths['data'][0];

/** Here down is old loader stuff, will be deprecated as we go along getting everything into a single source of code. */
$working_dir = $curr_dir;

$loader->addNamespace('Leaf', $curr_dir . '/libs/logger');
$loader->addNamespace('Leaf', $curr_dir . '/libs/php-commons');
$loader->addNamespace('Leaf', $curr_dir . '/libs/logger/formatters');

$working_dir = $curr_dir;

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

if (!empty($site_paths['portal_database'])){
    $db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['portal_database']);
} else {
    $db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['orgchart_database']);
}

$oc_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $site_paths['orgchart_database']);

// get the settings for this portal
$setting_up = new Setting($db);
$settings = $setting_up->getSettings();

if (class_exists('Portal\Config')) {
    $config = new Portal\Config($site_paths, $settings);
    if (!defined('PORTAL_CONFIG')) define('PORTAL_CONFIG', $config);
}

$vars = array(':site_path' => $site_paths['orgchart_path']);
$sql = 'SELECT site_uploads
        FROM sites
        WHERE site_path= BINARY :site_path';

$oc_site_paths = $file_paths_db->prepared_query($sql, $vars)[0];

$oc_setting_up = new Setting($oc_db);
$oc_settings = $oc_setting_up->getSettings();

$oc_config = new Orgchart\Config($site_paths, $oc_settings);
if (!defined('ORGCHART_CONFIG')) define('ORGCHART_CONFIG', $oc_config);

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
    $session_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB, true);

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
$data_action_logger = new DataActionLogger($db, $login);

if (!defined('S_LIB_PATH')) define('S_LIB_PATH', 'https://' . getenv('APP_HTTP_HOST') . '/libs');
if (!defined('ABSOLUTE_ORG_PATH')) define('ABSOLUTE_ORG_PATH', 'https://' . getenv('APP_HTTP_HOST') . $site_paths['orgchart_path']);
if (!defined('ABSOLUTE_PORT_PATH')) define('ABSOLUTE_PORT_PATH', 'https://' . getenv('APP_HTTP_HOST') . $site_paths['site_path']);
if (!defined('DOMAIN_PATH')) define('DOMAIN_PATH', 'https://' . getenv('APP_HTTP_HOST'));
if (!defined('ORGCHART_DB')) define('ORGCHART_DB', $site_paths['orgchart_database']);
if (!defined('OC_DB')) define('OC_DB', $oc_db);

if (!empty($site_paths['portal_database'])) {
    if (!defined('PORTAL_DB')) define('PORTAL_DB', $site_paths['portal_database']);
} else {
    if (!defined('PORTAL_DB')) define('PORTAL_DB', $site_paths['orgchart_database']);
}
