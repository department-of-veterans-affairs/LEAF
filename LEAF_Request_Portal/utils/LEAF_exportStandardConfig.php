<?php
ini_set('display_errors', 1); // Set to 1 to display errors

$tempFolder = str_replace('\\', '/', dirname(__FILE__)) . '/../files/temp/';

include '../db_mysql.php';
include '../db_config.php';

$db_config = new DB_Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$res = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

if($res['siteType'] != 'national_primary') {
    exit();
}

$db->enableDebug();
echo "Running Package Builder...<br />\n";
array_map('unlink', glob($tempFolder . '*.sql'));

$db->query("SELECT * INTO OUTFILE '{$tempFolder}actions.sql' FROM actions");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}categories.sql' FROM categories");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}category_staples.sql' FROM category_staples");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}dependencies.sql' FROM dependencies");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}indicators.sql' FROM indicators");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}route_events.sql' FROM route_events");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}workflows.sql' FROM workflows");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}workflow_steps.sql' FROM workflow_steps");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}step_dependencies.sql' FROM step_dependencies");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}workflow_routes.sql' FROM workflow_routes");
$db->query("SELECT * INTO OUTFILE '{$tempFolder}step_modules.sql' FROM step_modules");
