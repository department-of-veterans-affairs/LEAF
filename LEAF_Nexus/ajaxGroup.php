<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

error_reporting(E_ALL & ~E_NOTICE);

include 'globals.php';
include '../libs/smarty/Smarty.class.php';
include './sources/Login.php';
include 'db_mysql.php';
include 'config.php';
include './sources/Exception.php';
include './sources/Group.php';

$config = new Orgchart\Config();

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);

$login->loginUser();
if ($login)
{
}

$group = new OrgChart\Group($db, $login);

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    case 'getForm':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $group->getAllData((int)$_GET['groupID']));
        $t_form->assign('uid', (int)$_GET['groupID']);
        $t_form->assign('categoryID', $group->getDataTableCategoryID());
        $t_form->display('print_subindicators.tpl');

        break;
    case 'getFormContent':
        if (is_numeric($_GET['indicatorID']))
        {
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';

            if (is_numeric($_GET['indicatorID']) && is_numeric($_GET['groupID']))
            {
                $t_form->assign('uid', (int)$_GET['groupID']);
                $t_form->assign('categoryID', $group->getDataTableCategoryID());
                $indicator = $group->getAllData($_GET['groupID'], $_GET['indicatorID']);
                $t_form->assign('indicator', $indicator[$_GET['indicatorID']]);
                $t_form->display('print_subindicators_ajax.tpl');
            }
        }

        break;
    case 'list':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $parentID = isset($_GET['pID']) ? (int)$_GET['pID'] : 0;
        $list = $group->listGroups($parentID);
        foreach ($list as $item)
        {
            $t_form->assign('groupData', $item);
            $t_form->display('widget_group_small.tpl');
        }

        break;
    case 'listPositions':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $groupID = isset($_GET['gID']) ? (int)$_GET['gID'] : 0;
        $list = $group->listGroupPositions($groupID);
        foreach ($list as $item)
        {
            $t_form->assign('positionData', $item);
            $t_form->display('widget_position_small.tpl');
        }

        break;
    case 'listPositionData':
        include './sources/Employee.php';
        $employee = new OrgChart\Employee($db, $login);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $groupID = isset($_GET['gID']) ? (int)$_GET['gID'] : 0;
        $list = $group->listGroupPositions($groupID);

        $out = array();
        foreach ($list as $item)
        {
            $empData = $employee->getAllData($item['empUID']);
            $temp = array();
            $temp['photo'] = $empData[1]['data'];
            $temp['positionID'] = $item['positionID'];
            $out[] = $temp;
        }
        echo json_encode($out);

        break;
    case 'getData':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $group->getAllData((int)$_GET['gID']));
        $t_form->assign('uid', (int)$_GET['gID']);
        $t_form->assign('categoryID', $group->getDataTableCategoryID());
        $t_form->display('print_subindicators.tpl');

        break;
    case 'getindicator':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $group->getAllData((int)$_GET['groupID'], (int)$_GET['indicatorID']));
        $t_form->assign('UID', (int)$_GET['groupID']);
        $t_form->assign('categoryID', $group->getDataTableCategoryID());
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $t_form->display('ajaxForm.tpl');

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
