<?php
// give coaches admin access
$currDir = dirname(__FILE__);
include_once $currDir . '/../globals.php';
include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../Login.php';
include_once $currDir . '/../form.php';

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
$db_national = new DB(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');
$login->loginUser();
ini_set('display_errors', 1);

$userID = $login->getUserID();

$vars = array(':userName' => $userID);
$resEmpID = $db_national->prepared_query('SELECT * FROM employee WHERE userName=:userName', $vars);

$vars = array(':groupID' => 17,
              ':empUID' => $resEmpID[0]['empUID']);
$res = $db_national->prepared_query('SELECT * FROM relation_group_employee WHERE groupID=:groupID AND empUID=:empUID', $vars);

if(count($res) > 0) {
    $vars = array(':groupID' => 1,
                  ':userID' => $userID);
    $db->prepared_query('INSERT INTO users (userID, groupID) VALUES (:userID, :groupID)', $vars);

    $vars = array(':groupID' => 1,
                  ':empUID' => $login->getEmpUID());
    $db_phonebook->prepared_query('INSERT INTO relation_group_employee (empUID, groupID) VALUES (:empUID, :groupID)', $vars);

    echo "Added {$userID} to Portal and Nexus admin lists";
}
else {
    echo 'No action taken';
}
