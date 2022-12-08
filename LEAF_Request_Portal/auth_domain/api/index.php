<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/
header('Access-Control-Allow-Origin: *');
error_reporting(E_ERROR);

include '../../../libs/loaders/Leaf_autoloader.php';

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
    $formController = new Portal\FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action) {
    $SignatureController = new Portal\OpenController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
