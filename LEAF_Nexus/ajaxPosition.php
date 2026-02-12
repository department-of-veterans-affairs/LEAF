<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$oc_login->loginUser();
if ($oc_login)
{
}

$position = new Orgchart\Position($oc_db, $oc_login);

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    case 'getForm':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $position->getAllData((int)$_GET['pID']));
        $t_form->assign('uid', (int)$_GET['pID']);
        $t_form->assign('categoryID', $position->getDataTableCategoryID());
        $t_form->display('print_subindicators.tpl');

        break;
    case 'getFormContent':
        if (is_numeric($_GET['indicatorID']))
        {
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';

            if (is_numeric($_GET['indicatorID']) && is_numeric($_GET['pID']))
            {
                $t_form->assign('uid', (int)$_GET['pID']);
                $t_form->assign('categoryID', $position->getDataTableCategoryID());
                $indicator = $position->getAllData($_GET['pID'], $_GET['indicatorID']);
                $t_form->assign('indicator', $indicator[$_GET['indicatorID']]);
                $t_form->display('print_subindicators_ajax.tpl');
            }
        }

        break;
    case 'getindicator':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('form', $position->getAllData((int)$_GET['pID'], (int)$_GET['indicatorID']));
        $t_form->assign('UID', (int)$_GET['pID']);
        $t_form->assign('categoryID', $position->getDataTableCategoryID());
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
