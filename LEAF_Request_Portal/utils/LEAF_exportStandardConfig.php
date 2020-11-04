<?php
ini_set('display_errors', 0); // Set to 1 to display errors

$tempFolder = __DIR__ . '/temp/'; // utils/temp/

define("LF", "\n");
include __DIR__ . '/../db_mysql.php';

$debug = false;

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$res = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

if($res['siteType'] != 'national_primary') {
    exit();
}

if ($debug) {
    $db->enableDebug();
}
echo "Running Package Builder...<br />\n";
array_map('unlink', glob($tempFolder . '*.sql'));

function exportTable($db, $tempFolder, $table) {
    switch($table) {
        case 'actions':
        case 'categories':
        case 'category_staples':
        case 'dependencies':
        case 'indicators':
        case 'route_events':
        case 'workflows':
        case 'workflow_steps':
        case 'step_dependencies':
        case 'workflow_routes':
        case 'step_modules':
            break;
        default:
            exit();
            break;
    }

    $res = $db->query("SELECT * FROM {$table}");

    $cleanPortalPath = str_replace("/", "_", $config->portalPath);

    file_put_contents("{$tempFolder}/${cleanPortalPath}_{$table}.sql", serialize($res));
}

exportTable($db, $tempFolder, 'actions');
exportTable($db, $tempFolder, 'categories');
exportTable($db, $tempFolder, 'category_staples');
exportTable($db, $tempFolder, 'dependencies');
exportTable($db, $tempFolder, 'indicators');
exportTable($db, $tempFolder, 'route_events');
exportTable($db, $tempFolder, 'workflows');
exportTable($db, $tempFolder, 'workflow_steps');
exportTable($db, $tempFolder, 'step_dependencies');
exportTable($db, $tempFolder, 'workflow_routes');
exportTable($db, $tempFolder, 'step_modules');

echo "Package Built <br />\n";
