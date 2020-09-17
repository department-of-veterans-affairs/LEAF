<?php
if(!isset($argv[1])){
    echo "First parameter must be portal path (e.g., /leaf/portal/path/).\n";
    exit();
}
$portalPath = $argv[1];
$portalPath = "/" . ltrim(rtrim($portalPath,"/"), "/") . "/";

if(!isset($argv[2]) || (strcasecmp($argv[2], 'stateless') !== 0 && strcasecmp($argv[2], 'nonstateless') !== 0)){
    echo "Second parameter must be either 'stateless' or 'nonstateless'.\n";
    exit();
}

if(strcasecmp($argv[2], 'stateless') === 0){
    include_once '/var/www/html/routing/routing_config.php';
    $routingDB = new mysqli(Routing_Config::$dbHost, Routing_Config::$dbUser, Routing_Config::$dbPass, Routing_Config::$dbName);
    $res = $routingDB->query('SELECT database_name FROM portal_configs WHERE path="'.$portalPath.'";');
    if($res->num_rows == 0)
    {
        echo "Portal Path does not exist.\n";
        die;
    }
    $res->data_seek(0);
    $row = $res->fetch_row();

    $mysqli = new mysqli(Routing_Config::$dbHost, Routing_Config::$dbUser, Routing_Config::$dbPass);
    $dbHost = Routing_Config::$dbHost;
    $dbUser = Routing_Config::$dbUser;
    $dbPass = Routing_Config::$dbPass;
    $portalToExport = $row[0];
    $routingDB->close();

}elseif(strcasecmp($argv[2], 'nonstateless') === 0){
    if(!is_dir("/var/www/html/" . $portalPath)){
        echo "Portal path does not exist.\n";
        exit();
    }
    include_once "/var/www/html" . $portalPath . 'db_config.php';
    $db_config = new DB_Config();

    $mysqli = new mysqli($db_config->dbHost,$db_config->dbUser,$db_config->dbPass);
    $dbHost = $db_config->dbHost;
    $dbUser = $db_config->dbUser;
    $dbPass = $db_config->dbPass;
    $portalToExport = $db_config->dbName;
}





$tempDBName = "data_transfer_temp_" . $portalToExport;

// Check connection
if ($mysqli -> connect_errno) {
    echo "Failed to connect to MySQL: " . $mysqli -> connect_error . "\n";
    exit();
}

if (!$mysqli->query("DROP DATABASE IF EXISTS " . $tempDBName . ";")) {
    echo("Error description 1: " . $mysqli -> error) . "\n";
    exit();
}

if (!$mysqli->query("CREATE DATABASE " . $tempDBName . ";")) {
    echo("Error description 2: " . $mysqli -> error) . "\n";
    exit();
}

if (!$mysqli->select_db($tempDBName)) {
    echo("Error description 3: " . $mysqli -> error) . "\n";
    exit();
}

if (!$mysqli->query("CREATE TABLE form_data
                        (
                        recordID int(10)  NOT NULL DEFAULT 0,
                        record_date int(10)  NOT NULL,
                        submitter_userID varchar(50)  NOT NULL,
                        record_title text  DEFAULT NULL,
                        indicatorID int(10),
                        data_entered text ,
                        data_entry_date int(10)  DEFAULT 0,
                        formID varchar(20) ,
                        form_name varchar(50) ,
                        form_description varchar(255) 
                        )
                        SELECT 
                        records.recordID, 
                        records.date as record_date,
                        records.userID as submitter_userID,
                        records.title as record_title,
                        data.indicatorID,
                        data.data as data_entered,
                        data.timestamp as data_entry_date,
                        categories.categoryID as formID,
                        categories.categoryName as form_name,
                        categories.categoryDescription as form_description

                        FROM $portalToExport.records
                        LEFT JOIN $portalToExport.data on records.recordID = data.recordID
                        LEFT JOIN $portalToExport.category_count on records.recordID = category_count.recordID
                        LEFT JOIN $portalToExport.categories on category_count.categoryID = categories.categoryID;")) {
    echo("Error description 4: " . $mysqli -> error) . "\n";
    exit();
}

if (!$mysqli->query("CREATE TABLE indicators
                        (
                        indicatorID int(10) NOT NULL DEFAULT 0,
                        name text  NOT NULL,
                        format text  NOT NULL,
                        description varchar(50)  DEFAULT NULL,
                        default_data text  DEFAULT NULL,
                        parentID int(10) DEFAULT NULL,
                        categoryID varchar(20)  DEFAULT NULL,
                        html text  DEFAULT NULL,
                        htmlPrint text  DEFAULT NULL,
                        jsSort varchar(255)  DEFAULT NULL,
                        required int(10) NOT NULL DEFAULT 0,
                        sort int(10) NOT NULL DEFAULT 1,
                        timeAdded datetime NOT NULL,
                        disabled int(10)  NOT NULL DEFAULT 0,
                        is_sensitive int(10) NOT NULL DEFAULT 0
                        )
                        SELECT indicatorID,
                        name,
                        format,
                        description,
                        indicators.default as default_data,
                        parentID,
                        categoryID,
                        html,
                        htmlPrint,
                        jsSort,
                        required,
                        sort,
                        timeAdded,
                        disabled,
                        is_sensitive 
                        FROM $portalToExport.indicators;")) {
    echo("Error description 5: " . $mysqli -> error) . "\n";
    exit();
}

if (!$mysqli->query("CREATE TABLE action_history
                        (
                        actionID int(10)  NOT NULL DEFAULT 0,
                        recordID int(10)  NOT NULL,
                        action_taken_by varchar(50)  NOT NULL,
                        actionType varchar(50)  NOT NULL,
                        action_time int(10)  NOT NULL,
                        stepID int(10) DEFAULT 0,
                        stepTitle varchar(64) 
                        )
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
    echo("Error description 6: " . $mysqli -> error) . "\n";
    exit();
}
$filename = $tempDBName . ".sql";
$directory = "/var/www/html/sqlserver_dumps/";
$filenameFullPath = $directory . $filename;

shell_exec("mkdir -p " . $directory);
shell_exec("rm -f " . $filenameFullPath);
shell_exec("mysqldump --compact --skip-quote-names --skip-opt --add-drop-table -h $dbHost -u $dbUser -p$dbPass $tempDBName > $filenameFullPath");
shell_exec("sed -i 's/`//g' " . $filenameFullPath);
shell_exec("sed -i  s/\"\\\\\\'\"/\"''\"/g " . $filenameFullPath);//replace \' with ''
shell_exec("sed -i 's/DEFAULT current_timestamp()//g' " . $filenameFullPath);
shell_exec("sed -i 's/int(10)/int/g' " . $filenameFullPath);

if (!$mysqli->query("DROP DATABASE IF EXISTS " . $tempDBName . ";")) {
    echo("Error description 1: " . $mysqli -> error) . "\n";
    exit();
}

echo $filename . " created.\n"; 