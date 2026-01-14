<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$dir = new Portal\VAMC_Directory();

$groups = $db->prepared_query('SELECT * FROM `groups` ORDER BY name ASC', array());
echo 'Access Groups:';
echo '<ul>';
foreach ($groups as $group)
{
    echo '<li>' . XSSHelpers::xscrub($group['name']) . ' (groupID#: ' . XSSHelpers::xscrub($group['groupID']) . ')';

    $vars = array('groupID' => $group['groupID']);
    $users = $db->prepared_query('SELECT * FROM users WHERE groupID=:groupID AND `active` = 1 ORDER BY userID', $vars);
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
