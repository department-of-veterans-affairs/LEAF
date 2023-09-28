<?php
ini_set('display_errors', 0); // Set to 1 to display errors

$tempFolder = str_replace('\\', '/', dirname(__FILE__)) . '/../files/temp/';

define("LF", "\n");

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$debug = false;

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
    }

    $res = $db->query("SELECT * FROM {$table}");
    file_put_contents("{$tempFolder}{$table}.sql", serialize($res));
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
