<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date Created: September 11, 2007

*/

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$login->loginUser();

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? XSSHelpers::xscrub($_GET['a']) : '';

// HQ logo
$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA seal, U.S. Department of Veterans Affairs" />');

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
$main->assign('abs_portal_path', ABSOLUTE_PORT_PATH);
$main->assign('app_js_path', APP_JS_PATH);

$main->assign('useUI', false);

//$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

foreach (array_keys($settings) as $key)
{
    $settings[$key] = XSSHelpers::sanitizeHTMLRich($settings[$key]);
}

switch ($action) {
    case 'showServiceFTEstatus':
        $main->assign('useUI', true);
        $main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/formQuery.js', APP_JS_PATH . '/LEAF/XSSHelpers.js',));

        $form = new Portal\Form($db, $login);
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
            $main->assign('stylesheets', array(APP_JS_PATH . '/choicesjs/choices.min.css'));
            $main->assign('javascripts', array(
                'js/form.js',
                'js/workflow.js',
                'js/formGrid.js',
                'js/formQuery.js',
                'js/formSearch.js',
                'js/gridInput.js',
                'js/lz-string/lz-string.min.js',
                APP_JS_PATH . '/LEAF/XSSHelpers.js',
                APP_JS_PATH . '/nexus/LEAFNexusAPI.js',
                APP_JS_PATH . '/portal/LEAFPortalAPI.js',
                APP_JS_PATH . '/choicesjs/choices.min.js'
            ));

            $form = new Portal\Form($db, $login);
            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('userID', $login->getUserID());
            $t_form->assign('empUID', $login->getEmpUID());
            $t_form->assign('empMembership', $login->getMembership());
            $t_form->assign('currUserActualName', XSSHelpers::xscrub($login->getName()));
            $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
            $t_form->assign('systemSettings', $settings);
            $t_form->assign('LEAF_NEXUS_URL', LEAF_NEXUS_URL);
            $t_form->assign('title', $settings['heading'] == '' ? $config->title : XSSHelpers::xscrub($settings['heading']));
            $t_form->assign('city', $settings['subHeading'] == '' ? $config->city : $settings['subHeading']);
            $t_form->assign('app_css_path', APP_CSS_PATH);
            $t_form->assign('app_js_path', APP_JS_PATH);

            $main->assign('body', $t_form->fetch("reports/{$action}.tpl"));
            $tabText = '';
        }
        else
        {
            $main->assign('body', 'Report does not exist');
        }

        break;
}

$main->assign('leafSecure', XSSHelpers::sanitizeHTML($settings['leafSecure']));
$main->assign('login', $t_login->fetch('login.tpl'));
$main->assign('empMembership', $login->getMembership());
$t_menu->assign('action', $action);
$t_menu->assign('orgchartPath', $site_paths['orgchart_path']);
$t_menu->assign('empMembership', $login->getMembership());
$o_menu = $t_menu->fetch(customTemplate('menu.tpl'));
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', $settings['heading'] == '' ? $config->title : $settings['heading']);
$main->assign('city', $settings['subHeading'] == '' ? $config->city : $settings['subHeading']);
$main->assign('revision', $settings['version']);

if (!isset($_GET['iframe']))
{
    $main->display(customTemplate('main.tpl'));
}
else
{
    $main->display(customTemplate('main_iframe.tpl'));
}
