<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

/* TODO:
1. prevent double submits
2. clean up
*/
error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$oc_login->loginUser();

if ($oc_login)
{
}

$employee = new Orgchart\Employee($oc_db, $oc_login);

$action = isset($_GET['a']) ? $_GET['a'] : '';

$uid = isset($_GET['empUID']) && is_numeric($_GET['empUID']) ? $_GET['empUID'] : 0;
$indicatorID = isset($_GET['indicatorID']) && is_numeric($_GET['indicatorID']) ? $_GET['indicatorID'] : 0;


switch ($action) {
    case 'getForm':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $employee->getAllData($uid));
        $t_form->assign('uid', $uid);
        $t_form->assign('categoryID', $employee->getDataTableCategoryID());
        $t_form->display('print_subindicators.tpl');

        break;
    case 'getFormContent':
        if (is_numeric($_GET['indicatorID']))
        {
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';

            if (is_numeric($_GET['empUID']))
            {
                $t_form->assign('uid', $uid);
                $t_form->assign('categoryID', $employee->getDataTableCategoryID());
                $indicator = $employee->getAllData($uid, $indicatorID);
                $t_form->assign('indicator', $indicator[$indicatorID]);
                $t_form->display('print_subindicators_ajax.tpl');
            }
        }

        break;
    case 'getindicator':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $employee->getAllData($uid, $indicatorID));
        $t_form->assign('UID', $uid);
        $t_form->assign('categoryID', $employee->getDataTableCategoryID());
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
