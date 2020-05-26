<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/../db_mysql.php';
require_once __DIR__ . '/../VAMC_Directory.php';

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

$vars = array();
$res = $db->prepared_query('SELECT * FROM users WHERE groupID=1', $vars);

if (count($res) == 0)
{

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
