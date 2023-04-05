<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

require_once '../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');

$p_db = $db;

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
$keyIndex = strpos($action, '/');
$key = null;

if ($keyIndex === false) {
    $key = $action;
} else {
    $key = substr($action, 0, $keyIndex);
}

// exclude some controllers from login requirement
switch ($key) {
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

$controllerMap->register('classicphonebook', function () use ($p_db, $login, $action) {
    $controller = new Portal\ClassicPhonebookController($p_db, $login);
    $controller->handler($action);
});

// admin only
if ($login->checkGroup(1)) {
    $controllerMap->register('simpledata', function () use ($p_db, $login, $action) {
        $controller = new Portal\SimpleDataController($p_db, $login);
        $controller->handler($action);
    });

    $controllerMap->register('formEditor', function () use ($p_db, $login, $action) {
        $formEditorController = new Portal\FormEditorController($p_db, $login);
        $formEditorController->handler($action);
    });

    $controllerMap->register('service', function () use ($p_db, $login, $action) {
        $serviceController = new Portal\ServiceController($p_db, $login);
        $serviceController->handler($action);
    });

    $controllerMap->register('group', function () use ($p_db, $login, $action) {
        $groupController = new Portal\GroupController($p_db, $login);
        $groupController->handler($action);
    });

    $controllerMap->register('import', function () use ($p_db, $login, $action) {
        $importController = new Portal\ImportController($p_db, $login);
        $importController->handler($action);
    });

    $controllerMap->register('site', function () use ($p_db, $login, $action) {
        $siteController = new Portal\SiteController($p_db, $login);
        $siteController->handler($action);
    });

    $icons_path = LIB_PATH . '/dynicons/svg/';
    $dynicon_index = ABSOLUTE_PORT_PATH . '/dynicons';
    $domain = DOMAIN_PATH . '/libs/dynicons/svg/';

    $controllerMap->register('iconPicker', function () use ($p_db, $login, $action, $icons_path, $dynicon_index, $domain) {
        $iconPickerController = new Portal\IconPickerController($p_db, $login, $icons_path, $dynicon_index, $domain);
        $iconPickerController->handler($action);
    });
}

$controllerMap->register('form', function () use ($p_db, $login, $action) {
    $formController = new Portal\FormController($p_db, $login);
    $formController->handler($action);
});

$controllerMap->register('formStack', function () use ($p_db, $login, $action) {
    $formStackController = new Portal\FormStackController($p_db, $login);
    $formStackController->handler($action);
});

$controllerMap->register('formWorkflow', function () use ($p_db, $login, $action) {
    $formWorkflowController = new Portal\FormWorkflowController($p_db, $login);
    $formWorkflowController->handler($action);
});

$controllerMap->register('workflow', function () use ($p_db, $login, $action) {
    $workflowController = new Portal\WorkflowController($p_db, $login);
    $workflowController->handler($action);
});

$controllerMap->register('FTEdata', function () use ($p_db, $login, $action) {
    $FTEdataController = new Portal\FTEdataController($p_db, $login);
    $FTEdataController->handler($action);
});

$controllerMap->register('inbox', function () use ($p_db, $login, $action) {
    $InboxController = new Portal\InboxController($p_db, $login);
    $InboxController->handler($action);
});

$controllerMap->register('system', function () use ($p_db, $login, $action) {
    $SystemController = new Portal\SystemController($p_db, $login);
    $SystemController->handler($action);
});

$controllerMap->register('emailTemplates', function () use ($p_db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($p_db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('emailTemplateFileHistory', function () use ($p_db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($p_db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('getEmailTemplateFileHistory', function () use ($p_db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($p_db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('converter', function () use ($p_db, $login, $action) {
    $ConverterController = new Portal\ConverterController($p_db, $login);
    $ConverterController->handler($action);
});

$controllerMap->register('telemetry', function () use ($p_db, $login, $action) {
    $TelemetryController = new Portal\TelemetryController($p_db, $login);
    $TelemetryController->handler($action);
});

$controllerMap->register('signature', function () use ($p_db, $login, $action) {
    $SignatureController = new Portal\SignatureController($p_db, $login);
    $SignatureController->handler($action);
});

$controllerMap->register('open', function () use ($p_db, $login, $action) {
    $OpenController = new Portal\OpenController($p_db, $login);
    $OpenController->handler($action);
});

$controllerMap->register('userActivity', function () use ($p_db, $login, $action) {
    $UserActivity = new Portal\UserActivity($p_db, $login);
    $UserActivity->handler($action);
});

$controllerMap->register('note', function () use ($p_db, $login, $action) {
    $dataActionLogger = new Leaf\DataActionLogger($p_db, $login);

    $NotesController = new Portal\NotesController($p_db, $login, $dataActionLogger);
    $NotesController->handler($action);
});

$controllerMap->register('templateEditor', function () use ($db, $login, $action) {
    $TemplateEditorController = new Portal\TemplateEditorController($db, $login);
    $TemplateEditorController->handler($action);
});

$controllerMap->register('templateFileHistory', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateCompareFileHistory', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateHistoryMergeFile', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateEmailHistoryMergeFile', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('reportTemplates', function () use ($db, $login, $action) {
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->register('reportTemplates/fileHistory', function () use ($db, $login, $action) {
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->register('reportTemplates/getHistoryFiles', function () use ($db, $login, $action) {
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->register('reportTemplates/saveReportMergeTemplate', function () use ($db, $login, $action) {
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->register('reportTemplates/deleteHistoryFileReport', function () use ($db, $login, $action) {
    $TemplateReportsController = new Portal\TemplateReportsController($db, $login);
    $TemplateReportsController->handler($action);
});

$controllerMap->runControl($key);
