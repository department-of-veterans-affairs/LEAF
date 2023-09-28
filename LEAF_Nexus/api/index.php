<?php
use App\Leaf\Db;
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$oc_db = $oc_db;
$oc_login->setBaseDir('../');

if (strtolower($oc_config->dbName) == strtolower(DIRECTORY_DB)) {
    $national_db = true;
} else {
    $national_db = false;
}

$oc_login->loginUser();
if (!$oc_login->isLogin() || !$oc_login->isInDB())
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
        $controllerMap->register('group', function () use ($oc_db, $oc_login, $action) {
            $groupController = new Orgchart\GroupController($oc_db, $oc_login);
            $groupController->handler($action);
        });

        break;
    case 'position':
        $controllerMap->register('position', function () use ($oc_db, $oc_login, $action) {
            $positionController = new Orgchart\PositionController($oc_db, $oc_login);
            $positionController->handler($action);
        });

        break;
    case 'employee':
        $controllerMap->register('employee', function () use ($oc_db, $oc_login, $national_db, $action) {
            $employeeController = new Orgchart\EmployeeController($oc_db, $oc_login, $national_db);
            $employeeController->handler($action);
        });

        break;
    case 'indicator':
        $controllerMap->register('indicator', function () use ($oc_db, $oc_login, $action) {
            $indicatorController = new Orgchart\IndicatorController($oc_db, $oc_login);
            $indicatorController->handler($action);
        });

        break;
    case 'tag':
         $controllerMap->register('tag', function () use ($oc_db, $oc_login, $action) {
            $tagController = new Orgchart\TagController($oc_db, $oc_login);
            $tagController->handler($action);
         });

           break;
    case 'system':
        $controllerMap->register('system', function () use ($oc_db, $oc_login, $action) {
            $systemController = new Orgchart\SystemController($oc_db, $oc_login);
            $systemController->handler($action);
        });

        break;
    case 'national':
        $controllerMap->register('national', function () use ($action) {
            $oc_db_nat = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
            $oc_login_nat = new Orgchart\Login($oc_db_nat, $oc_db_nat);

            $nationalEmployeeController = new Orgchart\NationalEmployeeController($oc_db_nat, $oc_login_nat);
            $nationalEmployeeController->handler($action);
        });

        break;

    case 'x':
        $controllerMap->register('x', function () use ($oc_db, $oc_login, $action) {
            $experimentalController = new Orgchart\ExperimentalController($oc_db, $oc_login);
            $experimentalController->handler($action);
        });

        break;
    default:
        echo 'Primary Object not supported.';

        break;
}

$controllerMap->runControl($key);
