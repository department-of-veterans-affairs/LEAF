<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    JSON index for legacy ajax endpoints
    Date Created: August 13, 2009

    This file has been deprecated, as of June 28, 2023 there is nothing in here
    that is used in the general LEAF application, It is being left until we can
    verify that it is not used in any custom setups.

*/

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

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

        echo $group->getMembers($_GET['groupID'])['data'];

        break;
    case 'directory_lookup':
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
