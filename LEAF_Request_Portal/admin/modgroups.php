<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../VAMC_Directory.php';

include '../globals.php';
include '../db_mysql.php';
include '../db_config.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}

$db_config = new DB_Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$dir = new VAMC_Directory();

$groups = $db->prepared_query('SELECT * FROM `groups` ORDER BY name ASC', array());
echo 'Access Groups:';
echo '<ul>';
foreach ($groups as $group)
{
    echo '<li>' . XSSHelpers::xscrub($group['name']) . ' (groupID#: ' . XSSHelpers::xscrub($group['groupID']) . ')';

    $vars = array('groupID' => $group['groupID']);
    $users = $db->prepared_query('SELECT * FROM users WHERE groupID=:groupID ORDER BY userID', $vars);
    echo '<ul>';
    foreach ($users as $user)
    {
        $dirdata = $dir->lookupLogin($user['userID']);
        if (!isset($dirdata[0]))
        {
            $sanitizeUser = htmlentities($user['userID']);
            echo "<li style='color: red; font-weight: bold'>NOT FOUND: {$sanitizeUser}</li>";
        }
        else
        {
            echo '<li>' . XSSHelpers::xscrub($dirdata[0]['Lname']) . ', ' . XSSHelpers::xscrub($dirdata[0]['Fname']) . '</li>';
        }
    }
    echo '</ul>';

    echo '</li>';
}
echo '</ul>';
