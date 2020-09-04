<?php

if (!defined('DATABASE_HOST'))      define('DATABASE_HOST',         getenv('DATABASE_HOST', true) ?:     getenv('DATABASE_HOST'));
if (!defined('DATABASE_USERNAME'))  define('DATABASE_USERNAME',     getenv('DATABASE_USERNAME', true) ?: getenv('DATABASE_USERNAME'));
if (!defined('DATABASE_PASSWORD'))  define('DATABASE_PASSWORD',     getenv('DATABASE_PASSWORD', true) ?: getenv('DATABASE_PASSWORD'));
if (!defined('DATABASE_DB_TEST_PORTAL')) define('DATABASE_DB_TEST_PORTAL',    getenv('DATABASE_DB_TEST_PORTAL', true) ?:     getenv('DATABASE_DB_TEST_PORTAL'));
if (!defined('DATABASE_DB_TEST_NEXUS')) define('DATABASE_DB_TEST_NEXUS',    getenv('DATABASE_DB_TEST_NEXUS', true) ?:     getenv('DATABASE_DB_TEST_NEXUS'));

class Test_Config
{
    public static $dbHost = DATABASE_HOST;
    public static $dbNamePortal = DATABASE_DB_TEST_PORTAL;
    public static $dbNameNexus = DATABASE_DB_TEST_NEXUS;
    public static $dbUser = DATABASE_USERNAME;
    public static $dbPass = DATABASE_PASSWORD;
}

