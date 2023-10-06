<?php
if (!defined('PRODUCT_NAME')) define('PRODUCT_NAME', getenv('PRODUCT_NAME'));
if (!defined('VERSION_NUMBER')) define('VERSION_NUMBER', getenv('NEXUS_VERSION_NUMBER'));

if (!defined('DATABASE_DB_ADMIN')) define('DATABASE_DB_ADMIN', getenv('DATABASE_DB_ADMIN'));

if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));

if (!defined('HTTP_HOST')) define('HTTP_HOST', getenv('APP_HTTP_HOST'));
if (!defined('AUTH_URL')) define('AUTH_URL', getenv('APP_URL_AUTH'));
if (!defined('AUTH_TYPE')) define('AUTH_TYPE', getenv('APP_AUTH_TYPE'));
if (!defined('CIPHER_KEY')) define('CIPHER_KEY', getenv('APP_CIPHER_KEY'));
if (!defined('LIB_PATH')) define('LIB_PATH', '/var/www/html/libs');
if (!defined('APP_PATH')) define('APP_PATH', getenv('APP_PATH'));
if (!defined('APP_LIBS_PATH')) define('APP_LIBS_PATH', getenv('APP_LIBS_PATH'));
if (!defined('APP_CSS_PATH')) define('APP_CSS_PATH', getenv('APP_CSS_PATH'));
if (!defined('APP_JS_PATH')) define('APP_JS_PATH', getenv('APP_JS_PATH'));
if (!defined('LEAF_DOMAIN')) define('LEAF_DOMAIN', getenv('APP_URL_NEXUS'));

/*
    We need to extract the portal url from the SCRIPT_FILENAME so we can get the data from the sites table.
    There are times where there is another folder tacked on to the end of the url, in those cases that folder
    needs to be striped from the url

    i.e. /Academy/Demo1/admin
    I decided it best to put this into a class and have the class deal with it to keep this file clean
*/

require_once getenv('APP_PATH') . '/Leaf/Db.php';
require_once getenv('APP_PATH') . '/Leaf/Site.php';

$file_paths_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$site = new App\Leaf\Site($file_paths_db, $_SERVER['SCRIPT_FILENAME']);

if ($site->error) {
    // redirect to 404 not found
} else {
    $my_path = $site->getPortalPath();
    if (!defined('PORTAL_PATH')) define('PORTAL_PATH', $my_path);
    if (!defined('LEAF_NEXUS_URL')) define('LEAF_NEXUS_URL', getenv('APP_URL_NEXUS') . trim($my_path) . '/');
    $site_paths = $site->getSitePath();
}