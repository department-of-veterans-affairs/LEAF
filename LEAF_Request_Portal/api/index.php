<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

require_once '../globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

$login->setBaseDir('../');

$dal = new Leaf\DataActionLogger($db, $login);
$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

$upload_dir = $site_paths['site_uploads'];

$emailPrefix = $settings['emailPrefix'];

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
$keyIndex = strpos($action, '/');
$key = null;

if ($keyIndex === false) {
    $key = $action;
} else {
    $key = substr($action, 0, $keyIndex);
}

// exclude some controllers from login requirement
switch($key) {
    case 'classicphonebook':
    case 'telemetry':
    case 'userActivity':
        break;
    default:
        $login->loginUser();
        break;
}

// Used for the 15min session timeout period UX
if ($key != 'userActivity') {
    $_SESSION['lastAction'] = time();
    $_SESSION['expireTime'] = null;
}

$controllerMap = new Portal\ControllerMap();

$controllerMap->register('classicphonebook', function () use ($vamc, $action) {
    $controller = new Portal\ClassicPhonebookController($vamc);
    $controller->handler($action);
});

// admin only
if ($login->checkGroup(1))
{
    $controllerMap->register('simpledata', function () use ($db, $login, $action, $form) {
        $controller = new Portal\SimpleDataController($db, $login, $form);
        $controller->handler($action);
    });

    $controllerMap->register('formEditor', function () use ($db, $login, $action, $form) {
        $formEditorController = new Portal\FormEditorController($db, $login, $form);
        $formEditorController->handler($action);
    });

    $controllerMap->register('service', function () use ($db, $login, $dal, $oc_employee, $vamc, $action) {
        $service = new Portal\Service($db, $login, $dal, $oc_employee, $vamc);
        $serviceController = new Portal\ServiceController($db, $login, $service);
        $serviceController->handler($action);
    });

    $controllerMap->register('group', function () use ($db, $login, $dal, $oc_employee, $vamc, $action) {
        $groupController = new Portal\GroupController($db, $login, $dal, $oc_employee, $vamc);
        $groupController->handler($action);
    });

    $controllerMap->register('import', function () use ($db, $login, $action) {
        $importController = new Portal\ImportController($db, $login);
        $importController->handler($action);
    });

    $controllerMap->register('site', function () use ($db, $login, $action) {
        $siteController = new Portal\SiteController($db, $login);
        $siteController->handler($action);
    });
}

$controllerMap->register('form', function () use ($db, $oc_db, $login, $action, $settings, $form, $vamc) {
    $formController = new Portal\FormController($db, $oc_db, $login, $settings, $form, $vamc);
    $formController->handler($action);
});

$controllerMap->register('formStack', function () use ($db, $login, $action) {
    $formStackController = new Portal\FormStackController($db, $login);
    $formStackController->handler($action);
});

$controllerMap->register('formWorkflow', function () use ($db, $oc_db, $login, $action, $emailPrefix, $settings, $form, $vamc) {
    $email = new Portal\Email($db, $oc_db, $settings, $form, $vamc);
    $form_workflow = new Portal\FormWorkflow($db, $login, 0, $form, $vamc, $email);

    $formWorkflowController = new Portal\FormWorkflowController($db, $login, $emailPrefix, $form_workflow);

    $formWorkflowController->handler($action);
});

$controllerMap->register('workflow', function () use ($db, $login, $action) {
    $workflowController = new Portal\WorkflowController($db, $login);
    $workflowController->handler($action);
});

$controllerMap->register('FTEdata', function () use ($db, $login, $form, $action) {
    $FTEdataController = new Portal\FTEdataController($db, $login, $form);
    $FTEdataController->handler($action);
});

$controllerMap->register('inbox', function () use ($db, $login, $action, $form, $vamc) {
    $InboxController = new Portal\InboxController($db, $login, $form, $vamc);
    $InboxController->handler($action);
});

$controllerMap->register('system', function () use ($db, $oc_db, $login, $oc_login, $vamc, $action) {
    $SystemController = new Portal\SystemController($db, $oc_db, $login, $oc_login, $vamc);
    $SystemController->handler($action);
});

$controllerMap->register('emailTemplates', function () use ($db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('converter', function () use ($db, $login, $action) {
    $ConverterController = new Portal\ConverterController($db, $login);
    $ConverterController->handler($action);
});

$controllerMap->register('telemetry', function () use ($db, $login, $upload_dir, $action) {
    $TelemetryController = new Portal\TelemetryController($db, $login, $upload_dir);
    $TelemetryController->handler($action);
});

$controllerMap->register('signature', function() use ($db, $login, $action) {
    $SignatureController = new Portal\SignatureController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $form, $action) {
    $OpenController = new Portal\OpenController($db, $login, $form);
    $OpenController->handler($action);
});

$controllerMap->register('userActivity', function() use ($db, $login, $action) {
    $UserActivity = new Portal\UserActivity($db, $login);
    $UserActivity->handler($action);
});

$controllerMap->register('note', function() use ($db, $login, $action, $form) {
    $dataActionLogger = new Leaf\DataActionLogger($db, $login);

    $NotesController = new Portal\NotesController($db, $login, $dataActionLogger, $form);
    $NotesController->handler($action);
});

$controllerMap->register('templateEditor', function () use ($db, $login, $action) {
    require 'controllers/TemplateEditorController.php';
    $TemplateEditorController = new Portal\TemplateEditorController($db, $login);
    $TemplateEditorController->handler($action);
});

$controllerMap->register('reportTemplates', function () use ($db, $login, $action) {
    require 'controllers/TemplateReportsController.php';
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
