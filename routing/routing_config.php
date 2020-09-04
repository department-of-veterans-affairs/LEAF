<?php

if (!defined('DATABASE_HOST'))      define('DATABASE_HOST',         getenv('DATABASE_HOST', true) ?:     getenv('DATABASE_HOST'));
if (!defined('DATABASE_USERNAME'))  define('DATABASE_USERNAME',     getenv('DATABASE_USERNAME', true) ?: getenv('DATABASE_USERNAME'));
if (!defined('DATABASE_PASSWORD'))  define('DATABASE_PASSWORD',     getenv('DATABASE_PASSWORD', true) ?: getenv('DATABASE_PASSWORD'));
if (!defined('DATABASE_DB_CONFIG')) define('DATABASE_DB_CONFIG',    getenv('DATABASE_DB_CONFIG', true) ?:     getenv('DATABASE_DB_CONFIG'));


    ini_set('display_errors', 0); // Set to 1 to display errors
    class Routing_Config
    {
        public static $dbHost = DATABASE_HOST;
        public static $dbName = DATABASE_DB_CONFIG;
        public static $dbUser = DATABASE_USERNAME;
        public static $dbPass = DATABASE_PASSWORD;
    }

