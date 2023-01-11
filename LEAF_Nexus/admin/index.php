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

require_once '../globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$oc_login->loginUser();

if (!$oc_login->isLogin() || !$oc_login->isInDB())
{
    echo 'Your login is not recognized.';
    exit;
}
/*if(!$oc_login->checkGroup(6)) {
    echo 'You must be in the administrator group to access this section.';
    exit();
}*/

$post_name = isset($_POST['name']) ? $_POST['name'] : '';
$post_password = isset($_POST['password']) ? $_POST['password'] : '';

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? $_GET['a'] : '';

// HQ logo
$main->assign('logo', '<img src="../images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

$t_login->assign('name', $oc_login->getName());

$main->assign('useDojo', true);
$main->assign('useDojoUI', true);

switch ($action) {
    case 'admin_refresh_directory':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $memberships = $oc_login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
            $main->assign('libsPath', S_LIB_PATH);
            $main->assign('body', $t_form->fetch('admin_refresh_directory.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
    case 'admin_update_database':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $memberships = $oc_login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
            $t_form->assign('libsPath', S_LIB_PATH);
            $main->assign('body', $t_form->fetch('admin_update_database.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
    case 'mod_system':
           $t_form = new Smarty;
           $t_form->left_delimiter = '<!--{';
           $t_form->right_delimiter = '}-->';

           //$main->assign('useUI', true);
           $main->assign('stylesheets', array('../css/employeeSelector.css',
                                        '../css/mod_system.css'));
           $main->assign('javascripts', array('../js/dialogController.js',
                                        '../js/employeeSelector.js'));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

           $t_form->assign('timeZones', DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US'));

           $t_form->assign('timeZone', $oc_settings['timeZone']);
           $t_form->assign('heading', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['heading']));
           $t_form->assign('subHeading', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['subHeading']));

           $tagObj = new Orgchart\Tag($db, $oc_login);
           $t_form->assign('serviceParent', $tagObj->getParent('service'));
           $t_form->assign('libsPath', S_LIB_PATH);

           $memberships = $oc_login->getMembership();
           if (isset($memberships['groupID'][1]))
           {
               $main->assign('body', $t_form->fetch('mod_system.tpl'));
           }
           else
           {
               $main->assign('body', 'You require System Administrator level access to view this section.');
           }

           $tabText = 'System Administration';

           break;
    case 'setup_medical_center':
        $t_form = new Smarty;
           $t_form->left_delimiter = '<!--{';
           $t_form->right_delimiter = '}-->';

           //$main->assign('useUI', true);
           $main->assign('stylesheets', array('css/mod_groups.css',
                                        '../css/employeeSelector.css'));
           $main->assign('javascripts', array('../js/dialogController.js',
                                        '../js/nationalEmployeeSelector.js'));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

           $t_form->assign('heading', \Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['heading']));
           $t_form->assign('subHeading', \Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['subHeading']));
           $t_form->assign('domainPath', DOMAIN_PATH);
           $t_form->assign('absOrgPath', ABSOLUTE_ORG_PATH);

           $memberships = $oc_login->getMembership();
           if (isset($memberships['groupID'][1]))
           {
                $t_form->assign('libsPath', S_LIB_PATH);
               $main->assign('body', $t_form->fetch('setup_medical_center.tpl'));
           }
           else
           {
               $main->assign('body', 'You require System Administrator level access to view this section.');
           }

           $tabText = 'Setup Medical Center';

           break;
    case 'import_employees_from_spreadsheet':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $main->assign('javascripts', array(S_LIB_PATH . 'js/LEAF/workbookhelper.js'));
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch('orgChart_import.tpl'));

        break;
    case 'mod_templates':
    case 'mod_templates_reports':
           $t_form = new Smarty;
           $t_form->left_delimiter = '<!--{';
           $t_form->right_delimiter = '}-->';

           $main->assign('useUI', true);

           $main->assign('javascripts', array(S_LIB_PATH . 'js/codemirror/lib/codemirror.js',
                   S_LIB_PATH . 'js/codemirror/mode/xml/xml.js',
                   S_LIB_PATH . 'js/codemirror/mode/javascript/javascript.js',
                   S_LIB_PATH . 'js/codemirror/mode/css/css.js',
                   S_LIB_PATH . 'js/codemirror/mode/htmlmixed/htmlmixed.js',
                   S_LIB_PATH . 'js/codemirror/addon/search/search.js',
                   S_LIB_PATH . 'js/codemirror/addon/search/searchcursor.js',
                   S_LIB_PATH . 'js/codemirror/addon/dialog/dialog.js',
                   S_LIB_PATH . 'js/codemirror/addon/scroll/simplescrollbars.js',
                   S_LIB_PATH . 'js/codemirror/addon/scroll/annotatescrollbar.js',
                   S_LIB_PATH . 'js/codemirror/addon/search/matchesonscrollbar.js',
                   S_LIB_PATH . 'js/codemirror/addon/display/fullscreen.js',
                   '../../js/dialogController.js',
           ));
           $main->assign('stylesheets', array(S_LIB_PATH . 'js/codemirror/lib/codemirror.css',
                   S_LIB_PATH . 'js/codemirror/addon/dialog/dialog.css',
                   S_LIB_PATH . 'js/codemirror/addon/scroll/simplescrollbars.css',
                   S_LIB_PATH . 'js/codemirror/addon/search/matchesonscrollbar.css',
                   S_LIB_PATH . 'js/codemirror/addon/display/fullscreen.css',
           ));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
           $t_form->assign('APIroot', '../api/');

           switch ($action) {
               case 'mod_templates':
                    $t_form->assign('libsPath', S_LIB_PATH);
                    $main->assign('body', $t_form->fetch('mod_templates.tpl'));

                   break;
               case 'mod_templates_reports':
                    $t_form->assign('libsPath', S_LIB_PATH);
                    $main->assign('body', $t_form->fetch('mod_templates_reports.tpl'));

                    break;
               default:
                   break;
           }

           $tabText = 'Template Editor';

           break;
    default:
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('javascripts', array('../js/nationalEmployeeSelector.js',
                                           '../js/positionSelector.js',
                                           '../js/groupSelector.js',
                                           '../js/dialogController.js',
                                           '../js/orgchartForm.js', ));
        $main->assign('stylesheets', array('../css/employeeSelector.css',
                                           '../css/view_employee.css',
                                           '../css/positionSelector.css',
                                           '../css/view_position.css',
                                           '../css/groupSelector.css',
                                           '../css/view_group.css', ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('userDomain', $oc_login->getDomain());
        $t_form->assign('domainPath', DOMAIN_PATH);
        $t_form->assign('absOrgPath', ABSOLUTE_ORG_PATH);

        $memberships = $oc_login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
            $t_form->assign('libsPath', S_LIB_PATH);
            $main->assign('body', $t_form->fetch('view_admin.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
}

$memberships = $oc_login->getMembership();
$t_menu->assign('isAdmin', $memberships['groupID'][1]);
$t_menu->assign('libsPath', S_LIB_PATH);
$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['heading']));
$main->assign('city', Leaf\XSSHelpers::sanitizeHTMLRich($oc_settings['subHeading']));
$main->assign('revision', Leaf\XSSHelpers::xscrub($oc_settings['version']));
$main->assign('libsPath', S_LIB_PATH);

if (!isset($_GET['iframe']))
{
    $main->display('main.tpl');
}
else
{
    $main->display('main_iframe.tpl');
}
