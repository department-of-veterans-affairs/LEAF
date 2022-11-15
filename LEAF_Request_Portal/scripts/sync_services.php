<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '/var/www/html/libs/loaders/Leaf_autoloader.php';

$db_config = new DB_Config();
$config = new Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');
$login->loginUser();

$employee = new Orgchart\Employee($db_phonebook, $login);
$group = new Orgchart\Group($db_phonebook, $login);
$position = new Orgchart\Position($db_phonebook, $login);
$tag = new Orgchart\Tag($db_phonebook, $login);

$group_portal = new Group($db, $login);
$service_portal = new Service($db, $login);
$system_portal = new System($db, $login);
$syncing = $system_portal->syncSystem($group_portal, $service_portal, $group, $employee, $tag, $position);

echo $syncing;