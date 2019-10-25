<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ALL & ~E_NOTICE);

if (false)
{
    echo '<img src="../libs/dynicons/?img=dialog-error.svg&amp;w=96" alt="error" style="float: left" /><div style="font: 36px verdana">Site currently undergoing maintenance, will be back shortly!</div>';
    exit();
}

include '../globals.php';
include '../sources/Login.php';
include '../db_mysql.php';
include '../config.php';
require 'RESTfulResponse.php';
require '../sources/Exception.php';
require 'ControllerMap.php';

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

switch ($key) {
    case 'group':
        $controllerMap->register('group', function () use ($db, $login, $action) {
            require 'controllers/GroupController.php';
            $groupController = new GroupController($db, $login);
            $groupController->handler($action);
        });

        break;
    case 'position':
        $controllerMap->register('position', function () use ($db, $login, $action) {
            require 'controllers/PositionController.php';
            $positionController = new PositionController($db, $login);
            $positionController->handler($action);
        });

        break;
    case 'employee':
        $controllerMap->register('employee', function () use ($db, $login, $action) {
            require 'controllers/EmployeeController.php';
            $employeeController = new EmployeeController($db, $login);
            $employeeController->handler($action);
        });

        break;
    case 'indicator':
        $controllerMap->register('indicator', function () use ($db, $login, $action) {
            require 'controllers/IndicatorController.php';
            $indicatorController = new IndicatorController($db, $login);
            $indicatorController->handler($action);
        });

        break;
    case 'tag':
         $controllerMap->register('tag', function () use ($db, $login, $action) {
             require 'controllers/TagController.php';
             $tagController = new TagController($db, $login);
             $tagController->handler($action);
         });

           break;
    case 'system':
        $controllerMap->register('system', function () use ($db, $login, $action) {
            require 'controllers/SystemController.php';
            $systemController = new SystemController($db, $login);
            $systemController->handler($action);
        });

        break;
    case 'national':
        $controllerMap->register('national', function () use ($action) {
            $db_nat = new DB(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
            $login_nat = new Orgchart\Login($db_nat, $db_nat);

            require 'controllers/NationalEmployeeController.php';
            $nationalEmployeeController = new NationalEmployeeController($db_nat, $login_nat);
            $nationalEmployeeController->handler($action);
        });

        break;

    case 'x':
        $controllerMap->register('x', function () use ($db, $login, $action) {
            require 'controllers/ExperimentalController.php';
            $experimentalController = new ExperimentalController($db, $login);
            $experimentalController->handler($action);
        });

        break;
    default:
        echo 'Primary Object not supported.';

        break;
}

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
