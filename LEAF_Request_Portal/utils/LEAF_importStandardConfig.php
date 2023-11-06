<?php
ini_set('display_errors', 0); // Set to 1 to display errors

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$debug = false;

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$protocol = isset($_SERVER['HTTPS']) ? 'https://' : 'http://';
$protocol = 'https://';
$siteRootURL = $protocol . HTTP_HOST;

$relativePath = trim(str_replace($siteRootURL, '', $settings['national_linkedPrimary']));
$tempFolder = $_SERVER['DOCUMENT_ROOT'] . $relativePath . 'files/temp/';
$copy_custom_templates = $_SERVER['DOCUMENT_ROOT'] . $relativePath . 'templates/email/custom_override/';
$paste_custom_templates = getenv('APP_LIB_PATH') . '../' . PORTAL_PATH . '/templates/email/custom_override/';

if($settings['siteType'] != 'national_subordinate') {
    echo "ERROR: This is not a national subordinate site.";
    exit();
}

if(!file_exists($tempFolder . 'actions.sql')) {
    echo "ERROR: Primary site files missing.";
    exit();
}

echo "Running Importer on {$site_paths['portal_database']}...<br />\n";

if ($debug)
{
    $db->enableDebug();
}

$db->query("TRUNCATE TABLE `workflow_routes`;");
$db->query("TRUNCATE TABLE `step_dependencies`;");
$db->query("delete from `workflow_steps`;");
$db->query("delete FROM `workflows`;");
$db->query("TRUNCATE TABLE `route_events`;");
$db->query("TRUNCATE TABLE `indicators`;");
$db->query("ALTER TABLE records_dependencies DROP FOREIGN KEY fk_records_dependencyID;");
$db->query("ALTER TABLE dependency_privs DROP FOREIGN KEY fk_privs_dependencyID;");
$db->query("delete FROM `dependencies`;");
$db->query("ALTER TABLE category_count DROP FOREIGN KEY category_count_ibfk_1;");
$db->query("ALTER TABLE category_privs DROP FOREIGN KEY category_privs_ibfk_2;");
$db->query("TRUNCATE TABLE `category_staples`;");
$db->query("delete FROM `categories`;");
$db->query("delete FROM `actions`;");
$db->query("delete FROM `records_dependencies` WHERE dependencyID=0;"); // delete invalid items -- TODO: figure out how these invalid items got written
$db->query("TRUNCATE TABLE `step_modules`;");
$db->query("TRUNCATE TABLE `email_templates`;");
$db->query("TRUNCATE TABLE `events`;");


function importTable($db, $tempFolder, $table) {
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

    $resFields = $db->query("DESCRIBE {$table}");
    $fields = [];
    foreach($resFields as $t) {
        $fields[] = $t['Field'];
    }

    $fieldSQL = '`'. implode("`, `", $fields) . '`';

    $file = file_get_contents($tempFolder . $table . '.sql');
    $data = unserialize($file);
    foreach($data as $row) {
        $vars = [];
        foreach($fields as $described) {
            $vars[':'.$described] = $row[$described] ?? null;
        }
        $varsSQL = implode(', ', array_keys($vars));
        $db->prepared_query("INSERT INTO {$table} ({$fieldSQL}) VALUES ({$varsSQL})", $vars);
    }
}

importTable($db, $tempFolder, 'actions');
importTable($db, $tempFolder, 'categories');
importTable($db, $tempFolder, 'category_staples');
importTable($db, $tempFolder, 'dependencies');
importTable($db, $tempFolder, 'indicators');
importTable($db, $tempFolder, 'route_events');
importTable($db, $tempFolder, 'workflows');
importTable($db, $tempFolder, 'workflow_steps');
importTable($db, $tempFolder, 'step_dependencies');
importTable($db, $tempFolder, 'workflow_routes');
importTable($db, $tempFolder, 'step_modules');

// remove files from templates/email/custom_override on subordinate
passthru('rm -rf ' . $paste_custom_templates . '*');
// copy templates/email/custom_override from primary to subordinate
passthru('cp -r ' . $copy_custom_templates . '* ' . $paste_custom_templates);

$db->query("ALTER TABLE `records_dependencies` ADD CONSTRAINT `fk_records_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `dependency_privs` ADD CONSTRAINT `fk_privs_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `category_count` ADD CONSTRAINT `category_count_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories`(`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `category_privs` ADD CONSTRAINT `category_privs_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories`(`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
