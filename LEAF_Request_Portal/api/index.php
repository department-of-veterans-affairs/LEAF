<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

include_once '../globals.php';
include_once '../sources/Login.php';
include_once '../sources/Session.php';
include_once '../../libs/php-commons/Db.php';
include_once '../sources/DbConfig.php';
include_once '../sources/Config.php';
require_once 'RESTfulResponse.php';
require_once '../sources/Exception.php';
require_once '../../libs/logger/dataActionLogger.php';
require_once 'ControllerMap.php';

$db_config = new Portal\DbConfig();
$config = new Portal\Config();

$db = new Leaf\Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Portal\Login($db_phonebook, $db);
$login->setBaseDir('../');

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

$controllerMap->register('classicphonebook', function () use ($db, $login, $action) {
    require 'controllers/ClassicPhonebookController.php';
    $controller = new Portal\ClassicPhonebookController($db, $login);
    $controller->handler($action);
});

// admin only
if ($login->checkGroup(1))
{
    $controllerMap->register('simpledata', function () use ($db, $login, $action) {
        require 'controllers/SimpleDataController.php';
        $controller = new Portal\SimpleDataController($db, $login);
        $controller->handler($action);
    });

    $controllerMap->register('formEditor', function () use ($db, $login, $action) {
        require 'controllers/FormEditorController.php';
        $formEditorController = new Portal\FormEditorController($db, $login);
        $formEditorController->handler($action);
    });

    $controllerMap->register('service', function () use ($db, $login, $action) {
        require 'controllers/ServiceController.php';
        $serviceController = new Portal\ServiceController($db, $login);
        $serviceController->handler($action);
    });

    $controllerMap->register('group', function () use ($db, $login, $action) {
        require 'controllers/GroupController.php';
        $serviceController = new Portal\GroupController($db, $login);
        $serviceController->handler($action);
    });

    $controllerMap->register('import', function () use ($db, $login, $action) {
        require 'controllers/ImportController.php';
        $importController = new Portal\ImportController($db, $login);
        $importController->handler($action);
    });

    $controllerMap->register('site', function () use ($db, $login, $action) {
        require 'controllers/SiteController.php';
        $siteController = new Portal\SiteController($db, $login);
        $siteController->handler($action);
    });
}

$controllerMap->register('form', function () use ($db, $login, $action) {
    require 'controllers/FormController.php';
    $formController = new Portal\FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->register('formStack', function () use ($db, $login, $action) {
    require 'controllers/FormStackController.php';
    $formStackController = new Portal\FormStackController($db, $login);
    $formStackController->handler($action);
});

$controllerMap->register('formWorkflow', function () use ($db, $login, $action) {
    require 'controllers/FormWorkflowController.php';
    $formWorkflowController = new Portal\FormWorkflowController($db, $login);
    $formWorkflowController->handler($action);
});

$controllerMap->register('workflow', function () use ($db, $login, $action) {
    require 'controllers/WorkflowController.php';
    $workflowController = new Portal\WorkflowController($db, $login);
    $workflowController->handler($action);
});

$controllerMap->register('FTEdata', function () use ($db, $login, $action) {
    require 'controllers/FTEdataController.php';
    $FTEdataController = new Portal\FTEdataController($db, $login);
    $FTEdataController->handler($action);
});

$controllerMap->register('inbox', function () use ($db, $login, $action) {
    require 'controllers/InboxController.php';
    $InboxController = new Portal\InboxController($db, $login);
    $InboxController->handler($action);
});

$controllerMap->register('system', function () use ($db, $login, $action) {
    require 'controllers/SystemController.php';
    $SystemController = new Portal\SystemController($db, $login);
    $SystemController->handler($action);
});

$controllerMap->register('emailTemplates', function () use ($db, $login, $action) {
    require 'controllers/EmailTemplateController.php';
    $EmailTemplateController = new Portal\EmailTemplateController($db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('converter', function () use ($db, $login, $action) {
    require 'controllers/ConverterController.php';
    $ConverterController = new Portal\ConverterController($db, $login);
    $ConverterController->handler($action);
});

$controllerMap->register('telemetry', function () use ($db, $login, $action) {
    require 'controllers/TelemetryController.php';
    $TelemetryController = new Portal\TelemetryController($db, $login);
    $TelemetryController->handler($action);
});

$controllerMap->register('signature', function() use ($db, $login, $action) {
    require 'controllers/SignatureController.php';
    $SignatureController = new Portal\SignatureController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action) {
    require 'controllers/OpenController.php';
    $OpenController = new Portal\OpenController($db, $login);
    $OpenController->handler($action);
});

$controllerMap->register('userActivity', function() use ($db, $login, $action) {
    require 'controllers/UserActivity.php';
    $UserActivity = new Portal\UserActivity($db, $login);
    $UserActivity->handler($action);
});

$controllerMap->register('note', function() use ($db, $login, $action) {
    require 'controllers/NotesController.php';

    $dataActionLogger = new Leaf\DataActionLogger($db, $login);

    $NotesController = new Portal\NotesController($db, $login, $dataActionLogger);
    $NotesController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
