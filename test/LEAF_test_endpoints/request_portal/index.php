<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

require_once '../libs/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$db;
$oc_db;
$settings;



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

$controllerMap->register('formEditor', function () use ($db, $login, $form, $action) {
    $controller = new Portal\FormEditorController($db, $login, $form);
    $controller->handler($action);
});

$controllerMap->register('form', function () use ($db, $oc_db, $login, $settings, $form, $vamc, $action) {
    $formController = new Portal\FormController($db, $oc_db, $login, $settings, $form, $vamc);
    $formController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
