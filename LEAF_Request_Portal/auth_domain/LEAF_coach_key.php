<?php
// give coaches admin access
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

ini_set('display_errors', 1);

$db_national = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);

$login->setBaseDir('../');
$login->loginUser();

$userID = $login->getUserID();

$vars = array(':userName' => $userID);
$resEmpID = $db_national->prepared_query('SELECT * FROM employee WHERE userName=:userName', $vars);

$vars = array(':groupID' => 17,
              ':empUID' => $resEmpID[0]['empUID']);
$res = $db_national->prepared_query('SELECT * FROM relation_group_employee WHERE groupID=:groupID AND empUID=:empUID', $vars);

if(count($res) > 0) {
    $vars = array(':groupID' => 1,
                  ':userID' => $userID);
    DB->prepared_query('INSERT INTO users (userID, groupID, backupID) VALUES (:userID, :groupID, "")', $vars);

    $vars = array(':groupID' => 1,
                  ':empUID' => $login->getEmpUID());
    OC_DB->prepared_query('INSERT INTO relation_group_employee (empUID, groupID) VALUES (:empUID, :groupID)', $vars);

    echo "Added {$userID} to Portal and Nexus admin lists";
}
else {
    echo 'No action taken';
}
