<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

require_once __DIR__ . '/../../../LEAF_Request_Portal/globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';
require_once __DIR__ . '/../../../LEAF_Request_Portal/api/RESTfulResponse.php';
require_once __DIR__ . '/../../../LEAF_Request_Portal/sources/Exception.php';
require_once __DIR__ . '/../../../LEAF_Request_Portal/api/ControllerMap.php';

$db_config = new DB_Config();
$config = new Config();

$db = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $db_config->dbName);
$db_phonebook = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $config->phonedbName);
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

$controllerMap->register('formEditor', function () use ($db, $login, $action) {
    require_once 'controllers/FormEditorController.php';
    $controller = new FormEditorController($db, $login);
    $controller->handler($action);
});

$controllerMap->register('form', function () use ($db, $login, $action) {
    require 'controllers/FormController.php';
    $formController = new FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
