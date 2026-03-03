<?php
use App\Leaf\Db;
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$orgchart_db = $oc_db;
$launchpad_db = $file_paths_db;
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
        $controllerMap->register('group', function () use ($orgchart_db, $oc_login, $action) {
            $groupController = new Orgchart\GroupController($orgchart_db, $oc_login);
            $groupController->handler($action);
        });

        break;
    case 'position':
        $controllerMap->register('position', function () use ($orgchart_db, $oc_login, $action) {
            $positionController = new Orgchart\PositionController($orgchart_db, $oc_login);
            $positionController->handler($action);
        });

        break;
    case 'employee':
        $controllerMap->register('employee', function () use ($orgchart_db, $oc_login, $national_db, $action) {
            $employeeController = new Orgchart\EmployeeController($orgchart_db, $oc_login, $national_db);
            $employeeController->handler($action);
        });

        break;
    case 'indicator':
        $controllerMap->register('indicator', function () use ($orgchart_db, $oc_login, $action) {
            $indicatorController = new Orgchart\IndicatorController($orgchart_db, $oc_login);
            $indicatorController->handler($action);
        });

        break;
    case 'tag':
         $controllerMap->register('tag', function () use ($orgchart_db, $oc_login, $action) {
            $tagController = new Orgchart\TagController($orgchart_db, $oc_login);
            $tagController->handler($action);
         });

           break;
    case 'system':
        $controllerMap->register('system', function () use ($orgchart_db, $oc_login, $action) {
            $systemController = new Orgchart\SystemController($orgchart_db, $oc_login);
            $systemController->handler($action);
        });

        break;
    case 'platform':
        $controllerMap->register('platform', function () use ($orgchart_db, $oc_login, $launchpad_db, $action) {
            $platform = new Orgchart\Platform($orgchart_db, $oc_login, $launchpad_db);
            $platformController = new Orgchart\PlatformController($orgchart_db, $oc_login, $platform);
            $platformController->handler($action);
        });

        break;
    case 'national':
        $controllerMap->register('national', function () use ($action) {
            $orgchart_db_nat = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
            $oc_login_nat = new Orgchart\Login($orgchart_db_nat, $orgchart_db_nat);

            $nationalEmployeeController = new Orgchart\NationalEmployeeController($orgchart_db_nat, $oc_login_nat);
            $nationalEmployeeController->handler($action);
        });

        break;
    case 'export':
        $controllerMap->register('export', function () use ($orgchart_db, $oc_login, $action) {
            $exportController = new Orgchart\ExportController($orgchart_db, $oc_login);
            $exportController->handler($action);
        });

    case 'x':
        $controllerMap->register('x', function () use ($orgchart_db, $oc_login, $action) {
            $experimentalController = new Orgchart\ExperimentalController($orgchart_db, $oc_login);
            $experimentalController->handler($action);
        });

        break;
    default:
        echo 'Primary Object not supported.';

        break;
}

$controllerMap->runControl($key);
