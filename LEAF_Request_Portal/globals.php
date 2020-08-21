<?php
const PRODUCT_NAME = 'VA Light Electronic Action Framework';
const VERSION_NUMBER = '4.0.0';

define('DATABASE_HOST',         getenv('DATABASE_HOST', true)         ?:  getenv('DATABASE_HOST'));
define('DATABASE_USERNAME',     getenv('DATABASE_USERNAME', true)     ?:  getenv('DATABASE_USERNAME'));
define('DATABASE_PASSWORD',     getenv('DATABASE_PASSWORD', true)     ?:  getenv('DATABASE_PASSWORD'));
define('DATABASE_DB_DIRECTORY', getenv('DATABASE_DB_DIRECTORY', true) ?:  getenv('DATABASE_DB_DIRECTORY'));

define('APP_URL_NEXUS',     getenv('APP_URL_NEXUS', true)   ?:   getenv('APP_URL_NEXUS'));
define('APP_HTTP_HOST',     getenv('APP_HTTP_HOST', true)   ?:   getenv('APP_HTTP_HOST'));
define('APP_URL_AUTH',      getenv('APP_URL_AUTH', true)    ?:   getenv('APP_URL_AUTH'));
define('APP_AUTH_TYPE',     getenv('APP_AUTH_TYPE', true)   ?:   getenv('APP_AUTH_TYPE'));
define('APP_CIPHER_KEY',    getenv('APP_CIPHER_KEY', true)  ?:   getenv('APP_CIPHER_KEY'));

const DIRECTORY_HOST = DATABASE_HOST;
const DIRECTORY_DB = DATABASE_DB_DIRECTORY;
const DIRECTORY_USER = DATABASE_USERNAME;
const DIRECTORY_PASS = DATABASE_PASSWORD;

const LEAF_NEXUS_URL = APP_URL_NEXUS;  // trailing slash required
const HTTP_HOST = APP_HTTP_HOST;

const AUTH_URL = APP_URL_AUTH;

const AUTH_TYPE = APP_AUTH_TYPE;

const CIPHER_KEY = APP_CIPHER_KEY;

