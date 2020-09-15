<?php
$currDir = dirname(__FILE__);

include_once $currDir . '/../db_config.php';

$db_config = new DB_Config();

$mysqli = new mysqli($db_config->dbHost,$db_config->dbUser,$db_config->dbPass);
$portalToExport = $db_config->dbName;
$tempDBName = "data_transfer_temp_" . $portalToExport;

// Check connection
if ($mysqli -> connect_errno) {
    echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
    exit();
}

if (!$mysqli->query("DROP DATABASE IF EXISTS " . $tempDBName . ";")) {
    echo("Error description: " . $mysqli -> error);
    exit();
}

if (!$mysqli->query("CREATE DATABASE " . $tempDBName . ";")) {
    echo("Error description: " . $mysqli -> error);
    exit();
}

if (!$mysqli->select_db($tempDBName)) {
    echo("Error description: " . $mysqli -> error);
    exit();
}

if (!$mysqli->query("CREATE TABLE form_data
                        SELECT 
                        records.recordID, 
                        records.date as record_date,
                        records.userID as submitter_userID,
                        records.title as record_title,
                        data.indicatorID,
                        data.data,
                        data.timestamp as data_entry_date,
                        categories.categoryID as formID,
                        categories.categoryName as form_name,
                        categories.categoryDescription as form_description

                        FROM $portalToExport.records
                        LEFT JOIN $portalToExport.data on records.recordID = data.recordID
                        LEFT JOIN $portalToExport.category_count on records.recordID = category_count.recordID
                        LEFT JOIN $portalToExport.categories on category_count.categoryID = categories.categoryID;")) {
    echo("Error description: " . $mysqli -> error);
    exit();
}

if (!$mysqli->query("CREATE TABLE indicators
                        SELECT * FROM $portalToExport.indicators;")) {
    echo("Error description: " . $mysqli -> error);
    exit();
}

if (!$mysqli->query("CREATE TABLE action_history
                        SELECT 
                        action_history.actionID,
                        action_history.recordID,
                        action_history.userID as action_taken_by,
                        action_history.actionType,
                        action_history.time as action_time,
                        workflow_steps.stepID,
                        workflow_steps.stepTitle
                        FROM $portalToExport.action_history
                        LEFT JOIN $portalToExport.workflow_steps on workflow_steps.stepID = action_history.stepID;")) {
    echo("Error description: " . $mysqli -> error);
    exit();
}
$filename = $tempDBName . ".sql";
$filenameFullPath = "/var/www/html/sqlserver_dumps/" . $filename;

shell_exec("rm " . $filenameFullPath);
shell_exec("mysqldump --compact --skip-quote-names --skip-opt -h mysql -u tester -ptester data_transfer_temp_leaf_portal > /var/www/html/sqlserver_dumps/data_transfer_temp_leaf_portal.sql");
shell_exec("sed -i 's/`//g' " . $filenameFullPath);
shell_exec("sed -i 's/unsigned//g' " . $filenameFullPath);
shell_exec("sed -i 's/CHARACTER SET utf8//g' " . $filenameFullPath);
shell_exec("sed -i 's/CHARACTER SET latin1//g' " . $filenameFullPath);
shell_exec("sed -i -e s/\\\\\\\\'/\'\'/g " . $filenameFullPath);
//remove ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
header("Content-type: application/sql");
header("Content-Disposition: attachment; filename=" . $filename);
readfile($filenameFullPath);