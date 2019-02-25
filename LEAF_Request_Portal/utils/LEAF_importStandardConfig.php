<?php
ini_set('display_errors', 1); // Set to 1 to display errors

include '../globals.php';
include '../db_mysql.php';
include '../db_config.php';

$db_config = new DB_Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$res = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

$protocol = isset($_SERVER['HTTPS']) ? 'https://' : 'http://';
$siteRootURL = $protocol . HTTP_HOST;
$relativePath = trim(str_replace($siteRootURL, '', $res['national_linkedPrimary']));
$tempFolder = $_SERVER['DOCUMENT_ROOT'] . $relativePath . 'files/temp/';

if($res['siteType'] != 'national_subordinate') {
    echo "ERROR: This is not a national subordinate site.";
    exit();
}

if(!file_exists($tempFolder . 'actions.sql')) {
    echo "ERROR: Primary site files missing.";
    exit();
}

echo "Running Importer on {$db_config->dbName}...<br />\n";
$db->enableDebug();
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



$db->query("LOAD DATA INFILE '{$tempFolder}actions.sql' INTO TABLE actions");
$db->query("LOAD DATA INFILE '{$tempFolder}categories.sql' INTO TABLE categories");
$db->query("LOAD DATA INFILE '{$tempFolder}category_staples.sql' INTO TABLE category_staples");
$db->query("LOAD DATA INFILE '{$tempFolder}dependencies.sql' INTO TABLE dependencies");
$db->query("LOAD DATA INFILE '{$tempFolder}indicators.sql' INTO TABLE indicators");
$db->query("LOAD DATA INFILE '{$tempFolder}route_events.sql' INTO TABLE route_events");
$db->query("LOAD DATA INFILE '{$tempFolder}workflows.sql' INTO TABLE workflows");
$db->query("LOAD DATA INFILE '{$tempFolder}workflow_steps.sql' INTO TABLE workflow_steps");
$db->query("LOAD DATA INFILE '{$tempFolder}step_dependencies.sql' INTO TABLE step_dependencies");
$db->query("LOAD DATA INFILE '{$tempFolder}workflow_routes.sql' INTO TABLE workflow_routes");
$db->query("LOAD DATA INFILE '{$tempFolder}step_modules.sql' INTO TABLE step_modules");



$db->query("ALTER TABLE `records_dependencies` ADD CONSTRAINT `fk_records_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `dependency_privs` ADD CONSTRAINT `fk_privs_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `category_count` ADD CONSTRAINT `category_count_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories`(`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
$db->query("ALTER TABLE `category_privs` ADD CONSTRAINT `category_privs_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories`(`categoryID`) ON DELETE RESTRICT ON UPDATE RESTRICT;");
