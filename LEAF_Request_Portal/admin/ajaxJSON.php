<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    JSON index for legacy ajax endpoints
    Date Created: August 13, 2009

*/

error_reporting(E_ERROR);

include '../../libs/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');

$login->loginUser();
if (!$login->checkGroup(1))
{
    echo 'You must be in the administrator group to access this section.';
    exit();
}

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    case 'mod_groups_getMembers':
        $group = new Portal\Group($db, $login);

        echo json_encode($group->getMembers($_GET['groupID']));

        break;
    case 'directory_lookup':
        require '../sources/VAMC_Directory.php';
        $dir = new Portal\VAMC_Directory();
        $results = $dir->search($_GET['query']);

        echo json_encode($results);

        break;
    default:
        /*
        echo "Action: $action<br /><br />Catchall...<br /><br />POST: <pre>";
        print_r($_POST);
        echo "</pre><br /><br />GET:<pre>";
        print_r($_GET);
        echo "</pre><br /><br />FILES:<pre>";
        print_r($_FILES);
        echo "</pre>";
        */
        break;
}
