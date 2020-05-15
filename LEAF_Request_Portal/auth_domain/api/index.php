<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/
header('Access-Control-Allow-Origin: *');
error_reporting(E_ALL & ~E_NOTICE);

include __DIR__ . '/../../globals.php';
include __DIR__ . '/../Login.php';
include __DIR__ . '/../../db_mysql.php';
include __DIR__ . '/../../db_config.php';
require __DIR__ . '/../../api/RESTfulResponse.php';
require __DIR__ . '/../../sources/Exception.php';
require __DIR__ . '/../../api/ControllerMap.php';

$db_config = new DB_Config();
$config = new Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
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

$controllerMap = new ControllerMap();

$controllerMap->register('form', function () use ($db, $login, $action) {
    require __DIR__ . '/../../api/controllers/FormController.php';
    $formController = new FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action) {
    require __DIR__ . '/../../api/controllers/OpenController.php';
    $SignatureController = new OpenController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
