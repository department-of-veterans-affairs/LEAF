<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
include_once __DIR__ . '/../../routing/routing_config.php';
include_once __DIR__ . '/../db_mysql.php';
    
$routingDB = new DB(Routing_Config::$dbHost, Routing_Config::$dbUser, Routing_Config::$dbPass, Routing_Config::$dbName);
$result = $routingDB->prepared_query('SELECT path FROM portal_configs;', array());
$script = __DIR__ . "/updateDatabase.php";
foreach( $result as $row )
{
    print_r("\n");
    print_r("Updating " . $row['path']);
    print_r("\n");
    $result = shell_exec('php ' . $script . ' ' . $row['path']);
    print_r($result);
    print_r("\n");
    print_r("---------------------");
    print_r("\n");
}