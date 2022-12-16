<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/
header('Access-Control-Allow-Origin: *');
error_reporting(E_ERROR);

require_once '../../../libs/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');

$settings;

$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

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

$controllerMap->register('form', function () use ($db, $oc_db, $login, $action, $settings, $form, $vamc) {
    $formController = new Portal\FormController($db, $oc_db, $login, $settings, $form, $vamc);
    $formController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action, $form) {
    $SignatureController = new Portal\OpenController($db, $login, $form);
    $SignatureController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
