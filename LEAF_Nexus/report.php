<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

error_reporting(E_ERROR);

require_once 'globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$oc_login->loginUser();

if (!$oc_login->isLogin() || !$oc_login->isInDB())
{
    echo 'Your login is not recognized.';
    exit;
}

$post_name = isset($_POST['name']) ? $_POST['name'] : '';
$post_password = isset($_POST['password']) ? $_POST['password'] : '';

$main = new \Smarty;
$t_login = new \Smarty;
$t_menu = new \Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? Leaf\XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

$t_login->assign('name', $oc_login->getName());

$main->assign('useDojo', true);
$main->assign('useDojoUI', true);

switch ($action) {
    case 'about':
        $t_form = new \Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $rev = $oc_db->prepared_query("SELECT * FROM settings WHERE setting='dbversion'", array());
        $t_form->assign('dbversion', Leaf\XSSHelpers::xscrub($rev[0]['data']));

        $main->assign('hideFooter', true);
        $t_form->assign('libsPath', S_LIB_PATH);
        $main->assign('body', $t_form->fetch('view_about.tpl'));

        break;
    default:
        if ($action != ''
            && file_exists("templates/reports/{$action}.tpl"))
        {
            $main->assign('useUI', true);
            if ($oc_login->isLogin())
            {
                $o_login = $t_login->fetch('login.tpl');

                $t_form = new \Smarty;
                $t_form->left_delimiter = '<!--{';
                $t_form->right_delimiter = '}-->';
                $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
                $t_form->assign('empUID', $oc_login->getEmpUID());
                $t_form->assign('empMembership', $oc_login->getMembership());

                //url
                // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//                $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
                $protocol = 'https';
                $qrcodeURL = "{$protocol}://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
                $main->assign('qrcodeURL', urlencode($qrcodeURL));

                $main->assign('body', $t_form->fetch("reports/{$action}.tpl"));
                $tabText = '';
            }
        }
        else
        {
            $main->assign('body', 'Input error');
        }

        break;
}

$memberships = $oc_login->getMembership();

$t_menu->assign('isAdmin', $memberships['groupID'][1]);
$t_menu->assign('action', $action);
$t_menu->assign('libsPath', S_LIB_PATH);
$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['heading']));
$main->assign('city', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['subHeading']));
$main->assign('revision', Leaf\XSSHelpers::scrubNewLinesFromURL($oc_settings['version']));
$main->assign('libsPath', S_LIB_PATH);

if (!isset($_GET['iframe']))
{
    $main->display('main.tpl');
}
else
{
    $main->display('main_iframe.tpl');
}
