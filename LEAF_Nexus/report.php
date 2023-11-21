<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

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

$action = isset($_GET['a']) ? XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

$t_login->assign('name', $oc_login->getName());

$main->assign('useDojo', true);
$main->assign('useDojoUI', true);
$main->assign('app_js_path', APP_JS_PATH);

switch ($action) {
    case 'about':
        $t_form = new \Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('dbversion', XSSHelpers::xscrub(OC_SETTINGS['dbversion']));

        $main->assign('hideFooter', true);
        $main->assign('body', $t_form->fetch('view_about.tpl'));

        break;
    default:
        if ($action != ''
            && file_exists("templates/reports/{$action}.tpl"))
        {
            $main->assign('useUI', true);
//    			$main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/formQuery.js', 'js/formSearch.js'));
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
                $main->assign('abs_portal_path', ABSOLUTE_PORT_PATH);

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
$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', XSSHelpers::sanitizeHTMLRich(LEAF_SETTINGS['heading']));
$main->assign('city', XSSHelpers::sanitizeHTMLRich(LEAF_SETTINGS['subheading']));
$main->assign('revision', XSSHelpers::scrubNewLinesFromURL(LEAF_SETTINGS['version']));

if (!isset($_GET['iframe']))
{
    $main->display('main.tpl');
}
else
{
    $main->display('main_iframe.tpl');
}
