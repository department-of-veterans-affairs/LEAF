<?php

use App\Api\v1\ApiMap;
use App\Api\v1\Routes\NationalEmployeeRouter;
use App\Nexus\Controllers\NationalEmployeeController;
use App\Nexus\Model\Employee;
use App\Nexus\Model\EmployeeData;
use App\Nexus\Model\Indicators;
use Orgchart\Employee as OrgchartEmployee;

/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$org_db = $oc_db;

$oc_login->loginUser();

if (!$oc_login->isLogin() || !$oc_login->isInDB()) {
    throw new Exception('Sorry, your login is not recognized');
}

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
$keyIndex = strpos($action, '/');

if ($keyIndex === false) {
    $key = $action;
} else {
    $key = substr($action, 0, $keyIndex);
}

$MapApi = new ApiMap();
$router_map = new ApiMap();

switch ($key) {
    case 'group':
    case 'position':
    case 'employee':
    case 'indicator':
    case 'tag':
    case 'system':
        break;
    case 'national':
        $MapApi->register($key, function () use ($action, $key, $org_db, $oc_login, $router_map) {
            $employee = new Employee($org_db);
            $empolyee_data = new EmployeeData($org_db);
            $indicators = new Indicators($org_db);
            $oc_employee = new OrgchartEmployee($org_db, $oc_login);

            $national_employee_controller = new NationalEmployeeController($indicators, $employee, $empolyee_data);
            $national_employee_router = new NationalEmployeeRouter($national_employee_controller, $router_map, $oc_employee);
            $national_employee_router->handler($action);
        });

        break;
    case 'x':
        break;
    default:
        echo 'Primary Object not supported.';

        break;
}

$MapApi->runControl($key);
