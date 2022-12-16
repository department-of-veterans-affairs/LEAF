<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date Created: September 11, 2007

*/

error_reporting(E_ERROR);

require_once '../libs/loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
    echo 'Session expired, please refresh the page.<br /><br />If this message persists, please contact your administrator.';
    echo '<br />' . $login->getName();
    echo '<br />' . $login->getUserID();
    $login->logout(); // destroy current session tokens
    exit;
}

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? Leaf\XSSHelpers::xscrub($_GET['a']) : '';

// HQ logo
$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$t_login->assign('name', $login->getName());
$t_menu->assign('is_admin', $login->checkGroup(1));
$t_menu->assign('menu_links', customTemplate('menu_links.tpl'));
$t_menu->assign('menu_help', customTemplate('menu_help.tpl'));

$qrcodeURL = "https://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
$main->assign('qrcodeURL', urlencode($qrcodeURL));

$main->assign('useUI', false);

$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

switch ($action) {
    case 'showServiceFTEstatus':
        $main->assign('useUI', true);
        $main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/formQuery.js'));

        $o_login = $t_login->fetch('login.tpl');

        $currentEmployee = $form->employee->lookupLogin($login->getUserID());
        $employeePositions = $form->employee->getPositions($currentEmployee[0]['empUID']);
        $resolvedService = $form->position->getService($employeePositions[0]['positionID']);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('services', $form->getServices2());
        $t_form->assign('resolvedServiceID', $resolvedService[0]['groupID']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('body', $t_form->fetch('reports/showServiceFTEstatus.tpl'));
        $tabText = 'Service FTE Status';

        break;
    default:
        if ($action != ''
            && file_exists("templates/reports/{$action}.tpl"))
        {
            $main->assign('useUI', true);
            $main->assign('stylesheets', array('../libs/js/choicesjs/choices.min.css'));
            $main->assign('javascripts', array(
                'js/form.js',
                'js/workflow.js',
                'js/formGrid.js',
                'js/formQuery.js',
                'js/formSearch.js',
                'js/gridInput.js',
                'js/lz-string/lz-string.min.js',
                '../libs/js/LEAF/XSSHelpers.js',
                '../libs/jsapi/nexus/LEAFNexusAPI.js',
                '../libs/jsapi/portal/LEAFPortalAPI.js',
                '../libs/jsapi/portal/model/FormQuery.js',
                '../libs/js/choicesjs/choices.min.js'
            ));

            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('userID', $login->getUserID());
            $t_form->assign('empUID', $login->getEmpUID());
            $t_form->assign('empMembership', $login->getMembership());
            $t_form->assign('currUserActualName', Leaf\XSSHelpers::xscrub($login->getName()));
            $t_form->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
            $t_form->assign('systemSettings', $settings);
            $t_form->assign('LEAF_NEXUS_URL', LEAF_NEXUS_URL);
            $t_form->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));

            $main->assign('body', $t_form->fetch("reports/{$action}.tpl"));
            $tabText = '';
        }
        else
        {
            $main->assign('body', 'Report does not exist');
        }

        break;
}

$main->assign('leafSecure', Leaf\XSSHelpers::sanitizeHTML($settings['leafSecure']));
$main->assign('login', $t_login->fetch('login.tpl'));
$main->assign('empMembership', $login->getMembership());
$t_menu->assign('action', $action);
$t_menu->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
$t_menu->assign('empMembership', $login->getMembership());
$o_menu = $t_menu->fetch(customTemplate('menu.tpl'));
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', Leaf\XSSHelpers::sanitizeHTML($settings['heading']));
$main->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));
$main->assign('revision', $settings['version']);

if (!isset($_GET['iframe']))
{
    $main->display(customTemplate('main.tpl'));
}
else
{
    $main->display(customTemplate('main_iframe.tpl'));
}
