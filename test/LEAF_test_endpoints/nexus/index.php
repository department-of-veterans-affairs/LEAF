<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

include_once __DIR__ . '/../../../LEAF_Nexus/globals.php';
include_once __DIR__ . '/../../../LEAF_Nexus/sources/Login.php';
include_once __DIR__ . '/../../../LEAF_Nexus/db_mysql.php';
include_once __DIR__ . '/../../../LEAF_Nexus/config.php';
require_once __DIR__ . '/../../../LEAF_Nexus/api/RESTfulResponse.php';
require_once __DIR__ . '/../../../LEAF_Nexus/sources/Exception.php';
require_once __DIR__ . '/../../../LEAF_Nexus/api/ControllerMap.php';

$config = new Orgchart\Config();

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
    echo 'Your login is not recognized.';
    exit;
}

$action = isset($_GET['a']) ? $_GET['a'] : '';
$keyIndex = strpos($action, '/');
$key = null;
if ($keyIndex === false)
{
    $key = $action;
}
else
{
    $key = substr($action, 0, $keyIndex);
}

$controllerMap = new ControllerMap();

$controllerMap->register('group', function () use ($db, $login, $action) {
    require 'controllers/GroupController.php';
    $groupController = new GroupController($db, $login);
    $groupController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
