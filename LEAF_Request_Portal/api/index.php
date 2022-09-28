<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for services

*/

error_reporting(E_ERROR);

require_once '/var/www/html/libs/loaders/Leaf_autoloader.php';

$db_config = new DB_Config();
$config = new Config();

$db = new Db($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');

$action = isset($_GET['a']) ? $_GET['a'] : $_SERVER['PATH_INFO'];
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

// exclude some controllers from login requirement
if ($key != 'classicphonebook'
    && $key != 'telemetry')
{
    $login->loginUser();
}

// Used for the 15min session timeout period UX
if ($key != 'userActivity') {
    $_SESSION['lastAction'] = time();
}

$controllerMap = new ControllerMap();

$controllerMap->register('classicphonebook', function () use ($db, $login, $action) {
    $controller = new ClassicPhonebookController($db, $login);
    $controller->handler($action);
});

// admin only
if ($login->checkGroup(1))
{
    $controllerMap->register('simpledata', function () use ($db, $login, $action) {
        $controller = new SimpleDataController($db, $login);
        $controller->handler($action);
    });

    $controllerMap->register('formEditor', function () use ($db, $login, $action) {
        $formEditorController = new FormEditorController($db, $login);
        $formEditorController->handler($action);
    });

    $controllerMap->register('service', function () use ($db, $login, $action) {
        $serviceController = new ServiceController($db, $login);
        $serviceController->handler($action);
    });

    $controllerMap->register('group', function () use ($db, $login, $action) {
        $serviceController = new GroupController($db, $login);
        $serviceController->handler($action);
    });

    $controllerMap->register('import', function () use ($db, $login, $action) {
        $importController = new ImportController($db, $login);
        $importController->handler($action);
    });

    $controllerMap->register('site', function () use ($db, $login, $action) {
        $siteController = new SiteController($db, $login);
        $siteController->handler($action);
    });
}

$controllerMap->register('form', function () use ($db, $login, $action) {
    $formController = new FormController($db, $login);
    $formController->handler($action);
});

$controllerMap->register('formStack', function () use ($db, $login, $action) {
    $formStackController = new FormStackController($db, $login);
    $formStackController->handler($action);
});

$controllerMap->register('formWorkflow', function () use ($db, $login, $action) {
    $formWorkflowController = new FormWorkflowController($db, $login);
    $formWorkflowController->handler($action);
});

$controllerMap->register('workflow', function () use ($db, $login, $action) {
    $workflowController = new WorkflowController($db, $login);
    $workflowController->handler($action);
});

$controllerMap->register('FTEdata', function () use ($db, $login, $action) {
    $FTEdataController = new FTEdataController($db, $login);
    $FTEdataController->handler($action);
});

$controllerMap->register('inbox', function () use ($db, $login, $action) {
    $InboxController = new InboxController($db, $login);
    $InboxController->handler($action);
});

$controllerMap->register('system', function () use ($db, $login, $action) {
    $SystemController = new SystemController($db, $login);
    $SystemController->handler($action);
});

$controllerMap->register('emailTemplates', function () use ($db, $login, $action) {
    $EmailTemplateController = new EmailTemplateController($db, $login);
    $EmailTemplateController->handler($action);
});

$controllerMap->register('converter', function () use ($db, $login, $action) {
    $ConverterController = new ConverterController($db, $login);
    $ConverterController->handler($action);
});

$controllerMap->register('telemetry', function () use ($db, $login, $action) {
    $TelemetryController = new TelemetryController($db, $login);
    $TelemetryController->handler($action);
});

$controllerMap->register('signature', function() use ($db, $login, $action) {
    $SignatureController = new SignatureController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->register('open', function() use ($db, $login, $action) {
    $SignatureController = new OpenController($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->register('userActivity', function() use ($db, $login, $action) {
    $SignatureController = new UserActivity($db, $login);
    $SignatureController->handler($action);
});

$controllerMap->runControl($key);

//echo '<br />' . memory_get_peak_usage();
