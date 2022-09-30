<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';
include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../db_config.php';
include_once $currDir . '/../Login.php';
include_once $currDir . '/../admin/Group.php';
include_once $currDir . '/../sources/Service.php';
include_once $currDir . '/../sources/System.php';

$db_config = new DB_Config();
$config = new Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');
$login->loginUser();

include_once $currDir . '/../' . Config::$orgchartPath . '/config.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Employee.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Group.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Position.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Tag.php';

$employee = new Orgchart\Employee($db_phonebook, $login);
$group = new Orgchart\Group($db_phonebook, $login);
$position = new Orgchart\Position($db_phonebook, $login);
$tag = new Orgchart\Tag($db_phonebook, $login);

$group_portal = new Group($db, $login);
$service_portal = new Service($db, $login);
$system_portal = new System($db, $login);
$system_portal->syncSystem($group_portal, $service_portal, $group, $employee, $tag, $position);
