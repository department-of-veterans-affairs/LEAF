<?php
define('PROD_NAME', getenv('PRODUCT_NAME'));
define('PORTAL_VERSION_NUMBER', getenv('PORTAL_VERSION_NUMBER'));

define('DATABASE_DB_ADMIN', getenv('DATABASE_DB_ADMIN'));

define('DB_HOST', getenv('DATABASE_HOST'));
define('NEXUS_DB', getenv('NEXUS_DB'));
define('PORTAL_DB', getenv('PORTAL_DB'));
define('DB_USER', getenv('DATABASE_USERNAME'));
define('DB_PASS', getenv('DATABASE_PASSWORD'));

define('APP_URL_NEXUS', getenv('APP_URL_NEXUS'));
define('APP_HTTP_HOST', getenv('APP_HTTP_HOST'));
define('APP_PORTAL_URL_AUTH', getenv('APP_PORTAL_URL_AUTH'));
define('APP_AUTH_TYPE', getenv('APP_AUTH_TYPE'));
define('APP_CIPHER_KEY', getenv('APP_CIPHER_KEY'));

const PRODUCT_NAME = PROD_NAME;
const VERSION_NUMBER = PORTAL_VERSION_NUMBER;

const DIRECTORY_HOST = DB_HOST;
const DIRECTORY_DB = NEXUS_DB;
const DIRECTORY_USER = DB_USER;
const DIRECTORY_PASS = DB_PASS;

const LEAF_NEXUS_URL = APP_URL_NEXUS; // trailing slash required
const HTTP_HOST = APP_HTTP_HOST;

const AUTH_URL = APP_PORTAL_URL_AUTH;

const AUTH_TYPE = APP_AUTH_TYPE;

const CIPHER_KEY = APP_CIPHER_KEY;
