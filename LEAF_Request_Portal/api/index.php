<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');

$p_db = $db;

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
$keyIndex = strpos($action, '/');
$key = null;
$parts = null;

if ($keyIndex === false) {
    $key = $action;
} else {
    $key = substr($action, 0, $keyIndex);
    $parts = explode('/', substr($action, $keyIndex + 1));
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

//Do not scrub as it returns structured directory search results
$controllerMap->register('classicphonebook', function () use ($p_db, $login, $action) {
    $controller = new Portal\ClassicPhonebookController($p_db, $login);
    echo $controller->handler($action);
});

//Should not scrub returns JSON that is all needed
$controllerMap->register('service', function () use ($p_db, $login, $action) {
    $serviceController = new Portal\ServiceController($p_db, $login);
    echo $serviceController->handler($action);
});

//Do not scrub as it contains structured site data needed for proper functionality
$controllerMap->register('site', function () use ($p_db, $login, $action) {
    $siteController = new Portal\SiteController($p_db, $login);
    echo $siteController->handler($action);
});

// Should not be scrubbed as it returns sensitive serialized data
$controllerMap->register('formStack', function () use ($p_db, $login, $action) {
    $formStackController = new Portal\FormStackController($p_db, $login);
    echo $formStackController->handler($action);
});

// admin only do not scrub output returns Json data needed for proper functionality
if ($login->checkGroup(1) || ($key === 'group' && isset($parts[0]) && $parts[0] === '1' && isset($parts[1]) && $parts[1] === 'members')) {
    $controllerMap->register('group', function () use ($p_db, $login, $action) {
        $groupController = new Portal\GroupController($p_db, $login);
        echo $groupController->handler($action);
    });

    $controllerMap->register('simpledata', function () use ($p_db, $login, $action) {
        $controller = new Portal\SimpleDataController($p_db, $login);
        echo $controller->handler($action);
    });

    //Should not be scrubbed since it returns LEAF Programmer code
    $controllerMap->register('formEditor', function () use ($p_db, $login, $action) {
        $formEditorController = new Portal\FormEditorController($p_db, $login);
        echo $formEditorController->handler($action);
    });

    $icons_path = LIB_PATH . '/dynicons/svg/';
    $dynicon_index = ABSOLUTE_PORT_PATH . '/dynicons';
    $domain = DOMAIN_PATH . '/libs/dynicons/svg/';

    $controllerMap->register('iconPicker', function () use ($p_db, $login, $action, $icons_path, $dynicon_index, $domain) {
        $iconPickerController = new Portal\IconPickerController($p_db, $login, $icons_path, $dynicon_index, $domain);
        echo $iconPickerController->handler($action);
    });
}

//Should not be scrubbed as it may contain LEAF Programmer code
$controllerMap->register('form', function () use ($p_db, $login, $action) {
    $formController = new Portal\FormController($p_db, $login);
    echo $formController->handler($action);
});

//Should not be scrubbed since the structure is needed for proper functionality
$controllerMap->register('formWorkflow', function () use ($p_db, $login, $action) {
    $formWorkflowController = new Portal\FormWorkflowController($p_db, $login);
    echo $formWorkflowController->handler($action);
});

//Should not be scrubbed since the structure is needed for proper functionality
$controllerMap->register('workflow', function () use ($p_db, $login, $action) {
    $workflowController = new Portal\WorkflowController($p_db, $login);
    echo $workflowController->handler($action);
});

//Should not be scrubbed since the structure is needed for proper functionality
$controllerMap->register('workflowRoute', function () use ($db, $login, $action) {
    $WorkflowRouteController = new Portal\WorkflowRouteController($db, $login);
    echo $WorkflowRouteController->handler($action);
});

//Do not scrub returns structured data needed for proper functionality
$controllerMap->register('FTEdata', function () use ($p_db, $login, $action) {
    $FTEdataController = new Portal\FTEdataController($p_db, $login);
    echo $FTEdataController->handler($action);
});

//Do not scrub it contains Json needed for proper functionality
$controllerMap->register('inbox', function () use ($p_db, $login, $action) {
    $InboxController = new Portal\InboxController($p_db, $login);
    echo $InboxController->handler($action);
});

//Do not scrub it contains Json needed for proper functionality
$controllerMap->register('system', function () use ($p_db, $login, $action) {
    $SystemController = new Portal\SystemController($p_db, $login);
    echo $SystemController->handler($action);
});

//Do not scrub returns custom email HTML needed to create templates
$controllerMap->register('emailTemplates', function () use ($p_db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($p_db, $login);
    echo $EmailTemplateController->handler($action);
});

//Should not be scrubbed as it may contain LEAF Programmer code
$controllerMap->register('converter', function () use ($p_db, $login, $action) {
    $ConverterController = new Portal\ConverterController($p_db, $login);
    echo $ConverterController->handler($action);
});

//Do not scrub returns JSON data needed for proper functionality
$controllerMap->register('telemetry', function () use ($p_db, $login, $action) {
    $TelemetryController = new Portal\TelemetryController($p_db, $login);
    echo $TelemetryController->handler($action);
});

//Do not scrub returns structured data needed for proper functionality
$controllerMap->register('signature', function() use ($p_db, $login, $action) {
    $SignatureController = new Portal\SignatureController($p_db, $login);
    echo $SignatureController->handler($action);
});

//Do not scrub returns structured data needed for proper functionality
$controllerMap->register('open', function() use ($p_db, $login, $action) {
    $OpenController = new Portal\OpenController($p_db, $login);
    echo $OpenController->handler($action);
});

//Do not scrub returns JSON data needed for proper functionality
$controllerMap->register('userActivity', function() use ($p_db, $login, $action) {
    $UserActivity = new Portal\UserActivity($p_db, $login);
    echo $UserActivity->handler($action);
});

//Should not be scrubbed as it may contain LEAF Programmer code
$controllerMap->register('note', function() use ($p_db, $login, $action) {
    $dataActionLogger = new DataActionLogger($p_db, $login);

    $NotesController = new Portal\NotesController($p_db, $login, $dataActionLogger);
    echo $NotesController->handler($action);
});

$controllerMap->register('templateEditor', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $TemplateController = new Portal\TemplateController($db, $login);
    echo $TemplateController->handler($action);
});

//Should not be scrubbed since the HTML structure is needed for proper functionality
$controllerMap->register('template', function () use ($db, $login, $action) {
    $TemplateController = new Portal\TemplateController($db, $login);
    echo $TemplateController->handler($action);
});

$controllerMap->register('reportTemplates', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('reportTemplates/mergeFileHistory', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

//None of the Applets/Templates should not be scrubbed since the HTML structure is needed for proper functionality
$controllerMap->register('applet', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('applet/mergeFileHistory', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('emailTemplateFileHistory', function () use ($p_db, $login, $action) {
    $EmailTemplateController = new Portal\EmailTemplateController($p_db, $login);
    echo $EmailTemplateController->handler($action);
});

$controllerMap->register('templateFileHistory', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    echo $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateCompareFileHistory', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    echo $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateHistoryMergeFile', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    echo $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('templateEmailHistoryMergeFile', function () use ($db, $login, $action) {
    $TemplateFileHistoryController = new Portal\TemplateFileHistoryController($db, $login);
    echo $TemplateFileHistoryController->handler($action);
});

$controllerMap->register('reportTemplates/fileHistory', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('reportTemplates/getHistoryFiles', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('reportTemplates/saveReportMergeTemplate', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('reportTemplates/deleteHistoryFileReport', function () use ($db, $login, $action) {
    // this is depricated and should be removed once it has not been used in over 30 days
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('applet/fileHistory', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('applet/getHistoryFiles', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('applet/saveReportMergeTemplate', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->register('applet/deleteHistoryFileReport', function () use ($db, $login, $action) {
    $AppletController = new Portal\AppletController($db, $login);
    echo $AppletController->handler($action);
});

$controllerMap->runControl($key);