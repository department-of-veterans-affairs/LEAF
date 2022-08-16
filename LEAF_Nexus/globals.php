<?php
if (!defined('PRODUCT_NAME')) define('PRODUCT_NAME', getenv('PRODUCT_NAME'));
if (!defined('NEXUS_VERSION_NUMBER')) define('NEXUS_VERSION_NUMBER', getenv('NEXUS_VERSION_NUMBER'));

if (!defined('DATABASE_DB_ADMIN')) define('DATABASE_DB_ADMIN', getenv('DATABASE_DB_ADMIN'));

if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('DATABASE_DB_DIRECTORY'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));

if (!defined('HTTP_HOST')) define('HTTP_HOST', getenv('APP_HTTP_HOST'));
if (!defined('AUTH_URL')) define('AUTH_URL', getenv('APP_URL_AUTH'));
if (!defined('AUTH_TYPE')) define('AUTH_TYPE', getenv('APP_AUTH_TYPE'));
if (!defined('CIPHER_KEY')) define('CIPHER_KEY', getenv('APP_CIPHER_KEY'));
