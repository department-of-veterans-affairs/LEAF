<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

include '../globals.php';
include '../sources/Login.php';
include '../../libs/php-commons/Db.php';
include '../sources/config.php';
require 'RESTfulResponse.php';
require '../sources/Exception.php';
require 'ControllerMap.php';

$config = new Orgchart\Config();

$db = new Leaf\Db($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
    echo 'Your login is not recognized.';
    exit;
}

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
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

$controllerMap = new Orgchart\ControllerMap();

switch ($key) {
    case 'group':
        $controllerMap->register('group', function () use ($db, $login, $action) {
            require 'controllers/GroupController.php';
            $groupController = new Orgchart\GroupController($db, $login);
            $groupController->handler($action);
        });

        break;
    case 'position':
        $controllerMap->register('position', function () use ($db, $login, $action) {
            require 'controllers/PositionController.php';
            $positionController = new Orgchart\PositionController($db, $login);
            $positionController->handler($action);
        });

        break;
    case 'employee':
        $controllerMap->register('employee', function () use ($db, $login, $action) {
            require 'controllers/EmployeeController.php';
            $employeeController = new Orgchart\EmployeeController($db, $login);
            $employeeController->handler($action);
        });

        break;
    case 'indicator':
        $controllerMap->register('indicator', function () use ($db, $login, $action) {
            require 'controllers/IndicatorController.php';
            $indicatorController = new Orgchart\IndicatorController($db, $login);
            $indicatorController->handler($action);
        });

        break;
    case 'tag':
         $controllerMap->register('tag', function () use ($db, $login, $action) {
             require 'controllers/TagController.php';
             $tagController = new Orgchart\TagController($db, $login);
             $tagController->handler($action);
         });

           break;
    case 'system':
        $controllerMap->register('system', function () use ($db, $login, $action) {
            require 'controllers/SystemController.php';
            $systemController = new Orgchart\SystemController($db, $login);
            $systemController->handler($action);
        });

        break;
    case 'national':
        $controllerMap->register('national', function () use ($action) {
            $db_nat = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
            $login_nat = new Orgchart\Login($db_nat, $db_nat);

            require 'controllers/NationalEmployeeController.php';
            $nationalEmployeeController = new Orgchart\NationalEmployeeController($db_nat, $login_nat);
            $nationalEmployeeController->handler($action);
        });

        break;

    case 'x':
        $controllerMap->register('x', function () use ($db, $login, $action) {
            require 'controllers/ExperimentalController.php';
            $experimentalController = new Orgchart\ExperimentalController($db, $login);
            $experimentalController->handler($action);
        });

        break;
    default:
        echo 'Primary Object not supported.';

        break;
}

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
