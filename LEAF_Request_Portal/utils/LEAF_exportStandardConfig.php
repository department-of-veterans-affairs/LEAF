<?php
ini_set('display_errors', 0); // Set to 1 to display errors

$tempFolder = str_replace('\\', '/', dirname(__FILE__)) . '/../files/temp/';

define("LF", "\n");

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$debug = false;

if(LEAF_SETTINGS['siteType'] != 'national_primary') {
    exit();
}

if ($debug) {
    DB->enableDebug();
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

exportTable(DB, $tempFolder, 'actions');
exportTable(DB, $tempFolder, 'categories');
exportTable(DB, $tempFolder, 'category_staples');
exportTable(DB, $tempFolder, 'dependencies');
exportTable(DB, $tempFolder, 'indicators');
exportTable(DB, $tempFolder, 'route_events');
exportTable(DB, $tempFolder, 'workflows');
exportTable(DB, $tempFolder, 'workflow_steps');
exportTable(DB, $tempFolder, 'step_dependencies');
exportTable(DB, $tempFolder, 'workflow_routes');
exportTable(DB, $tempFolder, 'step_modules');
