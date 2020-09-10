<?php
$portalToExport = $argv[1];


$mysqli = new mysqli("mysql","tester","tester");
// Check connection
if ($mysqli -> connect_errno) {
    echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
    exit();
}

if (!$mysqli->query("DROP DATABASE IF EXISTS data_transfer_temp_" . $portalToExport . ";")) {
    echo("Error description: " . $mysqli -> error);
}

if (!$mysqli->query("CREATE DATABASE data_transfer_temp_" . $portalToExport . ";")) {
    echo("Error description: " . $mysqli -> error);
}

if (!$mysqli->select_db("data_transfer_temp_" . $portalToExport)) {
    echo("Error description: " . $mysqli -> error);
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
}

if (!$mysqli->query("CREATE TABLE indicators
                        SELECT * FROM $portalToExport.indicators;")) {
    echo("Error description: " . $mysqli -> error);
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
}


shell_exec("mysqldump -h mysql -u tester -ptester data_transfer_temp_" . $portalToExport . " > /var/www/html/sqlserver_dumps/data_transfer_temp_" . $portalToExport . ".sql");