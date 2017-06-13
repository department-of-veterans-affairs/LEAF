<?php

require '../VAMC_Directory.php';

include '../db_mysql.php';
include '../db_config.php';

$db_config = new DB_Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$dir = new VAMC_Directory();

$groups = $db->query('SELECT * FROM groups ORDER BY name ASC');
echo 'Access Groups:';
echo '<ul>';
foreach($groups as $group) {
    echo "<li>{$group['name']} (groupID#: {$group['groupID']})";

    $users = $db->query("SELECT * FROM users WHERE groupID={$group['groupID']} ORDER BY userID");
    echo '<ul>';
    foreach($users as $user) {
        $dirdata = $dir->lookupLogin($user['userID']);
        if(!isset($dirdata[0])) {
            echo "<li style='color: red; font-weight: bold'>NOT FOUND: {$user['userID']}</li>";          
        }
        else {
            echo "<li>{$dirdata[0]['Lname']}, {$dirdata[0]['Fname']}</li>";
        }
    }
    echo '</ul>';


    echo "</li>";
}
echo '</ul>';
