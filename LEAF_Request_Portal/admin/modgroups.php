<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include '../libs/loaders/Leaf_autoloader.php';

$dir = new Portal\VAMC_Directory();

$groups = $db->prepared_query('SELECT * FROM `groups` ORDER BY name ASC', array());
echo 'Access Groups:';
echo '<ul>';
foreach ($groups as $group)
{
    echo '<li>' . Leaf\XSSHelpers::xscrub($group['name']) . ' (groupID#: ' . Leaf\XSSHelpers::xscrub($group['groupID']) . ')';

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
            echo '<li>' . Leaf\XSSHelpers::xscrub($dirdata[0]['Lname']) . ', ' . Leaf\XSSHelpers::xscrub($dirdata[0]['Fname']) . '</li>';
        }
    }
    echo '</ul>';

    echo '</li>';
}
echo '</ul>';
