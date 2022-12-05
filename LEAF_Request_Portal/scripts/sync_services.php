<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';
include_once $currDir . '/../../libs/php-commons/Db.php';
include_once $currDir . '/../sources/DbConfig.php';
include_once $currDir . '/../sources/Config.php';
include_once $currDir . '/../sources/Login.php';
include_once $currDir . '/../sources/Group.php';
include_once $currDir . '/../sources/Service.php';
include_once $currDir . '/../sources/System.php';

$db_config = new Portal\DbConfig();
$config = new Portal\Config();
$db = new Leaf\Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
$login = new Portal\Login($db_phonebook, $db);
$login->setBaseDir('../');
$login->loginUser();

include_once $currDir . '/../' . Portal\Config::$orgchartPath . '/sources/Config.php';
include_once $currDir . '/../' . Portal\Config::$orgchartPath . '/sources/Employee.php';
include_once $currDir . '/../' . Portal\Config::$orgchartPath . '/sources/Group.php';
include_once $currDir . '/../' . Portal\Config::$orgchartPath . '/sources/Position.php';
include_once $currDir . '/../' . Portal\Config::$orgchartPath . '/sources/Tag.php';

$employee = new Orgchart\Employee($db_phonebook, $login);
$group = new Orgchart\Group($db_phonebook, $login);
$position = new Orgchart\Position($db_phonebook, $login);
$tag = new Orgchart\Tag($db_phonebook, $login);

$group_portal = new Portal\Group($db, $login);
$service_portal = new Portal\Service($db, $login);
$system_portal = new Portal\System($db, $login);
$syncing = $system_portal->syncSystem($group_portal, $service_portal, $group, $employee, $tag, $position);

echo $syncing;