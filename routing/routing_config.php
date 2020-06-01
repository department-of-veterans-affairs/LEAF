<?php
    ini_set('display_errors', 0); // Set to 1 to display errors
    $_SERVER['REMOTE_USER'] = '\\tester';
    $_SESSION['userID'] = '\\tester';
    class Routing_Config
    {
        public static $dbHost = 'mysql';
        public static $dbName = 'leaf_config';
        public static $dbUser = 'tester';
        public static $dbPass = 'tester';
    }