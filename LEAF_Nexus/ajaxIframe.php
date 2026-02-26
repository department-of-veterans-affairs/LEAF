<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

 /*
    Index for Iframes
    Date: June 29, 2011

*/

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$oc_login->loginUser();
if (!$oc_login->isLogin() || !$oc_login->isInDB())
{
    echo 'Your login is not recognized. This system is locked to the following groups:<br /><pre>';
    print_r($oc_config->adPath);
    echo '</pre>';
    exit;
}

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? $_GET['a'] : '';

// HQ logo
if (strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 6'))
{ // issue with dijit tabcontainer and ie6
    $main->assign('status', 'You appear to be using Microsoft Internet Explorer version 6. Some portions of this website may not display correctly unless you use Internet Explorer version 7 or higher.');
}

if (strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 6') || strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 7'))
{
    $main->assign('logo', '<img src="images/VA_icon_small_ie6.png" alt="VA seal, U.S. Department of Veterans Affairs" />');
}
else
{
    $main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA seal, U.S. Department of Veterans Affairs" />');
}

$t_login->assign('name', XSSHelpers::xscrub($oc_login->getName()));

$main->assign('useDojo', true);
$main->assign('useDojoUI', true);
$main->assign('app_js_path', APP_JS_PATH);

switch ($action) {
    case 'getuploadprompt':
        $main->assign('useDojoUI', false);
        $t_iframe = new Smarty;

        $t_iframe->assign('categoryID', (int)$_GET['categoryID']);
        $t_iframe->assign('UID', (int)$_GET['UID']);
        $t_iframe->assign('indicatorID', (int)$_GET['indicatorID']);
        $t_iframe->assign('max_filesize', ini_get('upload_max_filesize'));
        $t_iframe->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('body', $t_iframe->fetch('file_form.tpl'));

        break;
    case 'getdeleteprompt':
        $main->assign('useDojoUI', false);
        $t_iframe = new Smarty;
        $t_iframe->left_delimiter = '<!--{';
        $t_iframe->right_delimiter = '}-->';

        $t_iframe->assign('categoryID', (int)$_GET['categoryID']);
        $t_iframe->assign('UID', (int)$_GET['UID']);
        $t_iframe->assign('indicatorID', (int)$_GET['indicatorID']);
        $t_iframe->assign('file', XSSHelpers::xscrub(strip_tags($_GET['file'])));
        $t_iframe->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('body', $t_iframe->fetch('file_form_delete.tpl'));

        break;
    case 'permission':
        $main->assign('useDojo', false);
        $main->assign('useDojoUI', false);

        $type = null;
        $categoryID = $_GET['categoryID'];
        if (is_numeric($categoryID))
        {
            switch ($_GET['categoryID']) {
                case 1:    // employee
                    $type = 'empUID';

                    break;
                case 2:    // position
                    $type = 'positionID';

                    break;
                case 3:    // group
                    $type = 'groupID';

                    break;
                default:
                    return false;
            }
        }
        else
        {
            return false;
        }

        $t_iframe = new Smarty;

        $t_iframe->left_delimiter = '<!--{';
        $t_iframe->right_delimiter = '}-->';
        $t_iframe->assign('privileges', $oc_login->getIndicatorPrivileges(array((int)$_GET['indicatorID']), XSSHelpers::xscrub($type), (int)$_GET['UID']));
        $t_iframe->assign('indicatorID', (int)$_GET['indicatorID']);
        $t_iframe->assign('UID', (int)$_GET['UID']);
        $main->assign('body', $t_iframe->fetch('permission_iframe.tpl'));

        break;
    case 'view_position_permissions':
        $position = new Orgchart\Position($oc_db, $oc_login);

        $t_iframe = new Smarty;
        $t_iframe->left_delimiter = '<!--{';
        $t_iframe->right_delimiter = '}-->';

        //$main->assign('useDojoUI', true);
        $main->assign('javascripts', array('js/employeeSelector.js',
                'js/positionSelector.js',
                'js/groupSelector.js',
                'js/dialogController.js',
                'js/orgchartForm.js', ));
        $main->assign('stylesheets', array('css/employeeSelector.css',
                'css/view_employee.css',
                'css/positionSelector.css',
                'css/view_position.css',
                'css/groupSelector.css',
                'css/view_group.css', ));

        $positionID = isset($_GET['positionID']) ? (int)$_GET['positionID'] : 0;
        $t_iframe->assign('positionID', $positionID);
        $t_iframe->assign('positionTitle', $position->getTitle($positionID));
        $t_iframe->assign('permissions', $position->getPrivileges($positionID));
        $t_iframe->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('body', $t_iframe->fetch('view_position_permissions.tpl'));

        $tabText = 'Permission Editor';

        break;
    default:
        //$main->assign('useDojo', false);
        $main->assign('useDojoUI', false);
        if ($oc_login->isLogin())
        {
            $o_login = $t_login->fetch('login.tpl');

            if ($action != 'menu' && $action != '' && $action != 'dosubmit')
            {
                $main->assign('status', 'The page you are looking for does not exist or may have been moved. Please update your bookmarks.');
            }
        }
        else
        {
            $t_login->assign('name', '');
            $main->assign('status', 'Your login session has expired, You must log in again.');
        }
        $o_login = $t_login->fetch('login.tpl');

        break;
}

$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);
$main->assign('title', $config->title);
$main->assign('city', $config->city);

$rev = $oc_db->prepared_query("SELECT * FROM settings WHERE setting='version'", array());
$main->assign('revision', XSSHelpers::xscrub($rev[0]['data']));

$main->display('main_iframe.tpl');
