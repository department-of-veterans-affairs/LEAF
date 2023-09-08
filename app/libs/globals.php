<?php
if (!defined('PRODUCT_NAME')) define('PRODUCT_NAME', getenv('PRODUCT_NAME'));
if (!defined('VERSION_NUMBER')) define('VERSION_NUMBER', getenv('NEXUS_VERSION_NUMBER'));

if (!defined('DATABASE_DB_ADMIN')) define('DATABASE_DB_ADMIN', getenv('DATABASE_DB_ADMIN'));

if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));

if (!defined('LEAF_NEXUS_URL')) define('LEAF_NEXUS_URL', getenv('APP_URL_NEXUS'));
if (!defined('HTTP_HOST')) define('HTTP_HOST', getenv('APP_HTTP_HOST'));
if (!defined('AUTH_URL')) define('AUTH_URL', getenv('APP_URL_AUTH'));
if (!defined('AUTH_TYPE')) define('AUTH_TYPE', getenv('APP_AUTH_TYPE'));
if (!defined('CIPHER_KEY')) define('CIPHER_KEY', getenv('APP_CIPHER_KEY'));
// if (!defined('LIB_PATH')) define('LIB_PATH', rtrim('/', getenv('APP_LIB_PATH')));
if (!defined('LIB_PATH')) define('LIB_PATH', '/var/www/html/libs');
if (!defined('APP_PATH')) define('APP_PATH', '/var/www/html/app');
if (!defined('APP_LIBS_PATH')) define('APP_LIBS_PATH', '/var/www/html/app/libs');
if (!defined('APP_CSS_PATH')) define('APP_CSS_PATH', 'https://' . HTTP_HOST . '/app/libs/css');
if (!defined('APP_JS_PATH')) define('APP_JS_PATH', 'https://' . HTTP_HOST . '/app/libs/js');
//if (!defined('PORTAL_PATH')) define('PORTAL_PATH', str_replace('/var/www/html/', '', __DIR__));
preg_match('(\/.+\/)', $_SERVER['SCRIPT_FILENAME'], $match);

$path = str_replace('/var/www/html', '', $match[0]);
$path = str_replace('admin', '', $path);
$path = str_replace('api', '', $path);
$path = str_replace('auth_domain', '', $path);
$path = str_replace('dynicons', '', $path);
$path = str_replace('qrcode', '', $path);
$path = str_replace('scripts', '', $path);
$path = str_replace('utils', '', $path);
$path = rtrim($path, '/');

if (!defined('PORTAL_PATH')) define('PORTAL_PATH', $path);
