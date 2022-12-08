<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

include '../libs/loaders/Leaf_autoloader.php';

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

$controllerMap->register('formEditor', function () use ($db, $login, $action) {
    require_once 'controllers/FormEditorController.php';
    $controller = new Portal\FormEditorController($db, $login);
    $controller->handler($action);
});

$controllerMap->register('form', function () use ($db, $login, $action) {
    require 'controllers/FormController.php';
    $formController = new Portal\FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
