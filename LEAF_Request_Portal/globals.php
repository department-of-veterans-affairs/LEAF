<?php
if (!defined('PRODUCT_NAME')) define('PRODUCT_NAME', getenv('PRODUCT_NAME'));
if (!defined('PORTAL_VERSION_NUMBER')) define('PORTAL_VERSION_NUMBER', getenv('PORTAL_VERSION_NUMBER'));
if (!defined('DATABASE_DB_ADMIN')) define('DATABASE_DB_ADMIN', getenv('DATABASE_DB_ADMIN'));
if (!defined('DIRECTORY_HOST')) define('DIRECTORY_HOST', getenv('DATABASE_HOST'));
if (!defined('DIRECTORY_DB')) define('DIRECTORY_DB', getenv('NEXUS_DB'));
if (!defined('PORTAL_DB')) define('PORTAL_DB', getenv('PORTAL_DB'));
if (!defined('DIRECTORY_USER')) define('DIRECTORY_USER', getenv('DATABASE_USERNAME'));
if (!defined('DIRECTORY_PASS')) define('DIRECTORY_PASS', getenv('DATABASE_PASSWORD'));
if (!defined('LEAF_NEXUS_URL')) define('LEAF_NEXUS_URL', getenv('APP_URL_NEXUS'));
if (!defined('HTTP_HOST')) define('HTTP_HOST', getenv('APP_HTTP_HOST'));
if (!defined('PORTAL_AUTH_URL')) define('PORTAL_AUTH_URL', getenv('APP_PORTAL_URL_AUTH'));
if (!defined('AUTH_TYPE')) define('AUTH_TYPE', getenv('APP_AUTH_TYPE'));
if (!defined('CIPHER_KEY')) define('CIPHER_KEY', getenv('APP_CIPHER_KEY'));
