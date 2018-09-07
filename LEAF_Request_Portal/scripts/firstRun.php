<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include '../db_mysql.php';
include_once '../db_config.php';
require_once '../VAMC_Directory.php';

$db_config = new DB_Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$vars = array();
$res = $db->prepared_query('SELECT * FROM users WHERE groupID=1', $vars);

if (count($res) == 0)
{
    $config = new Config();

    if (strlen($config->adminLogonName) > 0)
    {
        $vars = array(':name' => $config->adminLogonName);
        $res = $db->prepared_query('INSERT INTO users (userID, groupID)
                                        VALUES (:name, 1)', $vars);
        echo 'Administrator added: ' . $config->adminLogonName;
    }
    else
    {
        echo 'Please check administrator configuration.';
    }
}
else
{
    echo 'Administrator already set. Exiting.';
}
