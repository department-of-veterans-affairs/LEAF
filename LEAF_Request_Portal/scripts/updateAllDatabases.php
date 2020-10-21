<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
include_once $currDir . '/../../routing/routing_config.php';
    
$routingDB = new DB(Routing_Config::$dbHost, Routing_Config::$dbUser, Routing_Config::$dbPass, Routing_Config::$dbName);
$result = $routingDB->prepared_query('SELECT path FROM portal_configs;', array());

foreach( $result as $row )
{
    $script = __DIR__ . "/updateDatabase.php";
    $result = shell_exec('PHP ' . $script . ' ' . $row['path']);
    print_r($result);
}