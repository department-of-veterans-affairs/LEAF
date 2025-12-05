<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$dir = new Portal\VAMC_Directory();

$vars = [];
$sql = 'SELECT `groupID`, `name`
        FROM `groups`
        ORDER BY `name` ASC';

$groups = $db->prepared_query($sql, $vars);

echo 'Access Groups:';
echo '<ul>';

foreach ($groups as $group) {
    $groupName = XSSHelpers::xscrub($group['name']);
    $groupID = XSSHelpers::xscrub($group['groupID']);

    echo "<li>{$groupName} (groupID#: {$groupID})";

    $vars = [':groupID' => $group['groupID']];
    $sql = 'SELECT `userID`
            FROM `users`
            WHERE `groupID` = :groupID
            AND `active` = 1
            ORDER BY `userID`';

    $users = $db->prepared_query($sql, $vars);

    echo '<ul>';

    foreach ($users as $user) {
        $dirdata = $dir->lookupLogin($user['userID']);

        if (empty($dirdata)) {
            $sanitizeUser = htmlentities($user['userID']);
            echo "<li style='color: red; font-weight: bold'>NOT FOUND: {$sanitizeUser}</li>";
        } else {
            $lastName = XSSHelpers::xscrub($dirdata[0]['Lname']);
            $firstName = XSSHelpers::xscrub($dirdata[0]['Fname']);

            echo "<li>{$lastName}, {$firstName}</li>";
        }
    }

    echo '</ul></li>';
}

echo '</ul>';
