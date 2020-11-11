<?php
ini_set('display_errors', 0); // Set to 1 to display errors
define("LF", "\n");

include __DIR__ . '/../db_mysql.php';

$debug = false;
$tempFolder = __DIR__ . '/custom_override/'; // utils/custom_override

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$res = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

if($res['siteType'] != 'national_primary') {
    exit();
}

if ($debug) {
    $db->enableDebug();
}

echo "Running Package Builder...<br />\n";
$cleanPrimaryPrefix = str_replace("/", "_", $config->portalPath); // portal_prefix_

array_map('unlink', glob($tempFolder . $cleanPrimaryPrefix . '*.sql'));

function exportTable($db, $tempFolder, $cleanPrimaryPrefix, $table) {
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

    file_put_contents("{$tempFolder}{$cleanPrimaryPrefix}_{$table}.sql", serialize($res));
}

exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'actions');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'categories');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'category_staples');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'dependencies');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'indicators');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'route_events');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'workflows');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'workflow_steps');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'step_dependencies');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'workflow_routes');
exportTable($db, $tempFolder, $cleanPrimaryPrefix, 'step_modules');

echo "Package Built <br />\n";
