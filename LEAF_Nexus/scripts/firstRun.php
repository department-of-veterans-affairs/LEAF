<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$vars = array();
$res = $db->prepared_query('SELECT * FROM relation_group_employee WHERE groupID=1', $vars);
$res2 = $db->prepared_query('SELECT * FROM employee WHERE empUID=1', $vars);

if (count($res) == 0
    && count($res2) == 0)
{
    $user = $config->adminLogonName;

    if (strlen($user) > 0)
    {
        $vars = array(':name' => $user);
        $res = $db->prepared_query('INSERT INTO employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName)
                                        VALUES (1, :name, "Please run maintenance scripts", "", "", "", "")', $vars);

        $res = $db->prepared_query('INSERT INTO relation_group_employee (groupID, empUID)
                                        VALUES (1, 1)', array());
        echo 'Administrator added: ' . $user;
        $res = $db->prepared_query('UPDATE SETTINGS SET DATA=RAND() WHERE SETTING="salt"', array());
        echo '<br />Random Salt generated.';
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
