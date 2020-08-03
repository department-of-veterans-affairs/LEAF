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
error_reporting(E_ALL & ~E_NOTICE);

if (false)
{
    echo '<img src="../libs/dynicons/?img=dialog-error.svg&amp;w=96" alt="error" style="float: left" /><div style="font: 36px verdana">Site currently undergoing maintenance, will be back shortly!</div>';
    exit();
}

include '../globals.php';
include '../../libs/smarty/Smarty.class.php';
include '../sources/Login.php';
include '../db_mysql.php';
include '../config.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}

$config = new Orgchart\Config();

header('X-UA-Compatible: IE=edge');

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
    echo 'Your login is not recognized.';
    exit;
}
/*if(!$login->checkGroup(6)) {
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

$t_login->assign('name', $login->getName());

$main->assign('useDojo', true);
$main->assign('useDojoUI', true);

switch ($action) {
    case 'admin_refresh_directory':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $memberships = $login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
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

        $memberships = $login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
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
           $main->assign('javascripts', array('js/dialogController.js'));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

           $t_form->assign('timeZones', DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US'));

           $settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
           $t_form->assign('timeZone', $settings['timeZone']);
           $t_form->assign('heading', XSSHelpers::sanitizeHTMLRich($settings['heading'] == '' ? $config->title : $settings['heading']));
           $t_form->assign('subheading', XSSHelpers::sanitizeHTMLRich($settings['subheading'] == '' ? $config->city : $settings['subheading']));

           require_once '../sources/Tag.php';
           $tagObj = new Orgchart\Tag($db, $login);
           $t_form->assign('serviceParent', $tagObj->getParent('service'));

           $memberships = $login->getMembership();
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
           $main->assign('stylesheets', array('admin/css/mod_groups.css', 'css/employeeSelector.css'));
           $main->assign('javascripts', array('js/dialogController.js', 'js/nationalEmployeeSelector.js'));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

           $settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
           $t_form->assign('heading', XSSHelpers::sanitizeHTMLRich($settings['heading'] == '' ? $config->title : $settings['heading']));
           $t_form->assign('subheading', XSSHelpers::sanitizeHTMLRich($settings['subheading'] == '' ? $config->city : $settings['subheading']));

           $memberships = $login->getMembership();
           if (isset($memberships['groupID'][1]))
           {
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
        $main->assign('javascripts', array('../libs/js/LEAF/workbookhelper.js'));

        $main->assign('body', $t_form->fetch('orgChart_import.tpl'));
        
        break;
    case 'mod_templates':
    case 'mod_templates_reports':
           $t_form = new Smarty;
           $t_form->left_delimiter = '<!--{';
           $t_form->right_delimiter = '}-->';

           $main->assign('useUI', true);
           $main->assign('javascripts', array('js/dialogController.js',
                   '../libs/js/codemirror/lib/codemirror.js',
                   '../libs/js/codemirror/mode/xml/xml.js',
                   '../libs/js/codemirror/mode/javascript/javascript.js',
                   '../libs/js/codemirror/mode/css/css.js',
                   '../libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
                   '../libs/js/codemirror/addon/search/search.js',
                   '../libs/js/codemirror/addon/search/searchcursor.js',
                   '../libs/js/codemirror/addon/dialog/dialog.js',
                   '../libs/js/codemirror/addon/scroll/simplescrollbars.js',
                   '../libs/js/codemirror/addon/scroll/annotatescrollbar.js',
                   '../libs/js/codemirror/addon/search/matchesonscrollbar.js',
                   '../libs/js/codemirror/addon/display/fullscreen.js',
           ));
           $main->assign('stylesheets', array('../libs/js/codemirror/lib/codemirror.css',
                   '../libs/js/codemirror/addon/dialog/dialog.css',
                   '../libs/js/codemirror/addon/scroll/simplescrollbars.css',
                   '../libs/js/codemirror/addon/search/matchesonscrollbar.css',
                   '../libs/js/codemirror/addon/display/fullscreen.css',
           ));

           $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
           $t_form->assign('APIroot', '../api/');

           switch ($action) {
               case 'mod_templates':
                   $main->assign('body', $t_form->fetch('mod_templates.tpl'));

                   break;
               case 'mod_templates_reports':
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

        $main->assign('javascripts', array('js/nationalEmployeeSelector.js',
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

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('userDomain', $login->getDomain());

        $memberships = $login->getMembership();
        if (isset($memberships['groupID'][1]))
        {
            $main->assign('body', $t_form->fetch('view_admin.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
}

$memberships = $login->getMembership();
$t_menu->assign('isAdmin', $memberships['groupID'][1]);
$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
$main->assign('title', XSSHelpers::sanitizeHTMLRich($settings['heading'] == '' ? $config->title : $settings['heading']));
$main->assign('city', XSSHelpers::sanitizeHTMLRich($settings['subheading'] == '' ? $config->city : $settings['subheading']));
$main->assign('revision', XSSHelpers::xscrub($settings['version']));

if (!isset($_GET['iframe']))
{
    $main->display('main.tpl');
}
else
{
    $main->display('main_iframe.tpl');
}
