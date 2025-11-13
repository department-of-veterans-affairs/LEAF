<?php
// give coaches admin access
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

ini_set('display_errors', 1);

// Restrict platform sites
if(strpos(ABSOLUTE_PORT_PATH, DOMAIN_PATH.'/platform') !== false) {
    echo 'Error: platform sites restricted';
    http_response_code(403);
    exit;
}

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
    $db->prepared_query('INSERT INTO users (userID, groupID, backupID) VALUES (:userID, :groupID, "")', $vars);

    $vars = array(':groupID' => 1,
                  ':empUID' => $login->getEmpUID());
    $oc_db->prepared_query('INSERT INTO relation_group_employee (empUID, groupID) VALUES (:empUID, :groupID)', $vars);

    echo "Added {$userID} to Portal and Nexus admin lists";
}
else {
    echo 'No action taken';
}
