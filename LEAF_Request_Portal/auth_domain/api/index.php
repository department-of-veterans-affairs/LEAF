<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/
header('Access-Control-Allow-Origin: *');
error_reporting(E_ERROR);

include '../../globals.php';
include '../../sources/Login.php';
include '../../sources/Session.php';
include '../../../libs/php-commons/Db.php';
include '../../sources/DbConfig.php';
include '../../sources/Config.php';
require '../../api/RESTfulResponse.php';
require '../../sources/Exception.php';
require '../../api/ControllerMap.php';

$db_config = new Portal\DbConfig();
$config = new Portal\Config();

$db = new Leaf\Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Portal\Login($db_phonebook, $db);
$login->setBaseDir('../');

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

$login->loginUser();

$controllerMap = new Portal\ControllerMap();

$controllerMap->register('form', function () use ($db, $login, $action) {
    require '../../api/controllers/FormController.php';
    $formController = new Portal\FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action) {
    require '../../api/controllers/OpenController.php';
    $SignatureController = new Portal\OpenController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
