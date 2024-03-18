<?php

use App\Leaf\CommonConfig;
use App\Leaf\Db;
use App\Leaf\XSSHelpers;

/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date Created: September 11, 2007

*/

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$login->setBaseDir('../');

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
    echo 'Your computer login is not recognized.';
    exit;
}
if (!$login->checkGroup(1))
{
    echo 'You must be in the administrator group to access this section.';
    exit();
}

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

function hasDevConsoleAccess($login, $oc_db)
{
    // automatically allow coaches
    $db_national = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
    $vars = array(':userID' => $login->getUserID());
    $res = $db_national->prepared_query('SELECT * FROM employee WHERE userName=:userID', $vars);
    if(count($res) == 0) {
        return 0;
    }
    $empUID = $res[0]['empUID'];

    $vars = array(':groupID' => 17,
                  ':empUID' => $empUID);
    $res = $db_national->prepared_query('SELECT * FROM relation_group_employee WHERE groupID=:groupID AND empUID=:empUID', $vars);
    if(count($res) > 0) {
        return 1;
    }

    $vars = array(':empUID' => $login->getEmpUID());
    $res = $oc_db->prepared_query('SELECT data FROM employee_data
                                            WHERE empUID=:empUID
                                                AND indicatorID=27
                                                AND data="Yes"
                                                AND author="DevConsoleWorkflow"', $vars);
    if(count($res) > 0) {
        return 1;
    }
    return 0;
}

// HQ logo
$main->assign('status', '');
if (strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 6'))
{ // issue with dijit tabcontainer and ie6
    $main->assign('status', 'You appear to be using Microsoft Internet Explorer version 6. Some portions of this website may not display correctly unless you use Internet Explorer version 10 or higher.');
}

//$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');

$main->assign('logo', '<img src="../images/VA_icon_small.png" alt="VA seal, U.S. Department of Veterans Affairs" />');

$t_login->assign('name', $login->getName());

$qrcodeURL = "https://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
$main->assign('qrcodeURL', urlencode($qrcodeURL));
$main->assign('abs_portal_path', ABSOLUTE_PORT_PATH);
$main->assign('app_css_path', APP_CSS_PATH);
$main->assign('app_js_path', APP_JS_PATH);

$main->assign('emergency', '');
$main->assign('hideFooter', false);
$main->assign('useUI', false);
$main->assign('useLiteUI', false);
$main->assign('useDojo', true);
$main->assign('useDojoUI', true);

switch ($action) {
    case 'mod_groups':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('javascripts', array($site_paths['orgchart_path'] . '/js/nationalEmployeeSelector.js',
                                           $site_paths['orgchart_path'] . '/js/groupSelector.js',
        ));

        //$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
        $tz = isset($settings['timeZone']) ? $settings['timeZone'] : null;

        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('timeZone', $tz);
        $t_form->assign('orgchartImportTag', $settings['orgchartImportTags'][0]);
        $t_form->assign('app_libs', APP_LIBS_PATH);

        $main->assign('useUI', true);
        $main->assign('stylesheets', array('css/mod_groups.css',
                                           $site_paths['orgchart_path'] . '/css/employeeSelector.css',
                                           $site_paths['orgchart_path'] . '/css/groupSelector.css',
        ));
        $main->assign('body', $t_form->fetch(customTemplate('mod_groups.tpl')));

        $tabText = 'User Access Groups';

        break;
    case 'mod_svcChief':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);

        $main->assign('javascripts', array($site_paths['orgchart_path'] . '/js/nationalEmployeeSelector.js',
        ));

        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('stylesheets', array('css/mod_groups.css',
                $site_paths['orgchart_path'] . '/css/employeeSelector.css',
        ));
        $main->assign('body', $t_form->fetch(customTemplate('mod_svcChief.tpl')));

        $tabText = 'Service Chiefs';

        break;
    case 'workflow':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);

        $main->assign('javascripts', array(APP_JS_PATH . '/jsPlumb/dom.jsPlumb-min.js',
                                           $site_paths['orgchart_path'] . '/js/groupSelector.js',
                                           APP_JS_PATH . '/portal/LEAFPortalAPI.js',
                                           APP_JS_PATH . '/LEAF/XSSHelpers.js',
        ));
        $main->assign('stylesheets', array('css/mod_workflow.css',
                                           $site_paths['orgchart_path'] . '/css/groupSelector.css',
        ));
        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('orgchartImportTags', $settings['orgchartImportTags'][0]);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('body', $t_form->fetch('mod_workflow.tpl'));

        $tabText = 'Workflow Editor';

        break;
    case 'form_vue':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $main->assign('javascripts', array(APP_JS_PATH . '/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
                                            APP_JS_PATH . '/filesaver/FileSaver.min.js',
                                            APP_JS_PATH . '/codemirror/lib/codemirror.js',
                                            APP_JS_PATH . '/codemirror/mode/xml/xml.js',
                                            APP_JS_PATH . '/codemirror/mode/javascript/javascript.js',
                                            APP_JS_PATH . '/codemirror/mode/css/css.js',
                                            APP_JS_PATH . '/codemirror/mode/htmlmixed/htmlmixed.js',
                                            APP_JS_PATH . '/codemirror/addon/display/fullscreen.js',
                                            APP_JS_PATH . '/LEAF/XSSHelpers.js',
                                            APP_JS_PATH . '/choicesjs/choices.min.js',
                                            '../js/formQuery.js',
                                            $site_paths['orgchart_path'] . '/js/employeeSelector.js',
                                            $site_paths['orgchart_path'] . '/js/groupSelector.js',
                                            $site_paths['orgchart_path'] . '/js/positionSelector.js'
        ));
        $main->assign('stylesheets', array(APP_JS_PATH . '/jquery/trumbowyg/plugins/colors/ui/trumbowyg.colors.min.css',
                                            APP_JS_PATH . '/codemirror/lib/codemirror.css',
                                            APP_JS_PATH . '/codemirror/addon/display/fullscreen.css',
                                            APP_JS_PATH . '/choicesjs/choices.min.css',
                                            APP_JS_PATH . '/vue-dest/form_editor/LEAF_FormEditor.css',
                                            $site_paths['orgchart_path'] . '/css/employeeSelector.css',
                                            $site_paths['orgchart_path'] . '/css/groupSelector.css',
                                            $site_paths['orgchart_path'] . '/css/positionSelector.css'
        ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $t_form->assign('app_js_path', APP_JS_PATH);
        $t_form->assign('libsPath', LEAF_DOMAIN.'app/libs/');
        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('referFormLibraryID', (int)$_GET['referFormLibraryID']);
        $t_form->assign('hasDevConsoleAccess', hasDevConsoleAccess($login, $oc_db));

        $main->assign('body', $t_form->fetch('form_editor_vue.tpl'));

        $tabText = 'Form Editor Testing';
        break;
    case 'form':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $main->assign('javascripts', array(APP_JS_PATH . '/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
                                            APP_JS_PATH . '/filesaver/FileSaver.min.js',
                                            APP_JS_PATH . '/codemirror/lib/codemirror.js',
                                            APP_JS_PATH . '/codemirror/mode/xml/xml.js',
                                            APP_JS_PATH . '/codemirror/mode/javascript/javascript.js',
                                            APP_JS_PATH . '/codemirror/mode/css/css.js',
                                            APP_JS_PATH . '/codemirror/mode/htmlmixed/htmlmixed.js',
                                            APP_JS_PATH . '/codemirror/addon/display/fullscreen.js',
                                            APP_JS_PATH . '/LEAF/XSSHelpers.js',
                                            APP_JS_PATH . '/portal/LEAFPortalAPI.js',
                                            APP_JS_PATH . '/choicesjs/choices.min.js',
                                            '../js/gridInput.js',
                                            '../js/formQuery.js',
                                            $site_paths['orgchart_path'] . '/js/employeeSelector.js',
                                            $site_paths['orgchart_path'] . '/js/groupSelector.js',
                                            $site_paths['orgchart_path'] . '/js/positionSelector.js'
        ));
        $main->assign('stylesheets', array('css/mod_form.css',
                                            APP_JS_PATH . '/jquery/trumbowyg/plugins/colors/ui/trumbowyg.colors.min.css',
                                            APP_JS_PATH . '/codemirror/lib/codemirror.css',
                                            APP_JS_PATH . '/codemirror/addon/display/fullscreen.css',
                                            APP_JS_PATH . '/choicesjs/choices.min.css',
                                            $site_paths['orgchart_path'] . '/css/employeeSelector.css',
                                            $site_paths['orgchart_path'] . '/css/groupSelector.css',
                                            $site_paths['orgchart_path'] . '/css/positionSelector.css'
        ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('referFormLibraryID', (int)$_GET['referFormLibraryID']);
        $t_form->assign('hasDevConsoleAccess', hasDevConsoleAccess($login, $oc_db));
        $t_form->assign('app_js_path', APP_JS_PATH);

        if (isset($_GET['form']))
        {
            $vars = array(':categoryID' => XSSHelpers::xscrub($_GET['form']));
            $res = $db->prepared_query('SELECT * FROM categories WHERE categoryID=:categoryID', $vars);
            if (count($res) > 0)
            {
                $t_form->assign('form', XSSHelpers::xscrub($res[0]['categoryID']));
            }
        }

        $main->assign('body', $t_form->fetch('mod_form.tpl'));

        $tabText = 'Form Editor';

        break;
    case 'mod_templates':
    case 'mod_templates_reports':
    case 'mod_templates_email':
            if(!hasDevConsoleAccess($login, $oc_db)) {
               header('Location: ../report.php?a=LEAF_start_leaf_dev_console_request');
            }

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';

            $main->assign('useUI', true);
            $main->assign('javascripts', array(APP_JS_PATH . '/codemirror/lib/codemirror.js',
                                                APP_JS_PATH . '/codemirror/mode/xml/xml.js',
                                                APP_JS_PATH . '/codemirror/mode/javascript/javascript.js',
                                                APP_JS_PATH . '/codemirror/mode/css/css.js',
                                                APP_JS_PATH . '/codemirror/mode/htmlmixed/htmlmixed.js',
                                                APP_JS_PATH . '/codemirror/addon/search/search.js',
                                                APP_JS_PATH . '/codemirror/addon/search/searchcursor.js',
                                                APP_JS_PATH . '/codemirror/addon/dialog/dialog.js',
                                                APP_JS_PATH . '/codemirror/addon/scroll/annotatescrollbar.js',
                                                APP_JS_PATH . '/codemirror/addon/search/matchesonscrollbar.js',
                                                APP_JS_PATH . '/codemirror/addon/display/fullscreen.js',
            ));
            $main->assign('stylesheets', array(APP_JS_PATH . '/codemirror/lib/codemirror.css',
                                                APP_JS_PATH . '/codemirror/addon/dialog/dialog.css',
                                                APP_JS_PATH . '/codemirror/addon/scroll/simplescrollbars.css',
                                                APP_JS_PATH . '/codemirror/addon/search/matchesonscrollbar.css',
                                                APP_JS_PATH . '/codemirror/addon/display/fullscreen.css',
            ));

            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('APIroot', '../api/');
            $t_form->assign('domain_path', DOMAIN_PATH);
            $t_form->assign('app_js_path', APP_JS_PATH);

            switch ($action) {
                case 'mod_templates':
                    $main->assign('body', $t_form->fetch('mod_templates.tpl'));
                    $tabText = 'Template Editor';

                    break;
                case 'mod_templates_reports':
                    $main->assign('body', $t_form->fetch('mod_templates_reports.tpl'));
                    $tabText = 'Report Template Editor';

                    break;
                case 'mod_templates_email':
                    $main->assign('body', $t_form->fetch('mod_templates_email.tpl'));
                    $tabText = 'Email Template Editor';

                    break;
                default:
                    break;
            }

        break;
    case 'admin_update_database':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch('admin_update_database.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
    case 'admin_sync_services':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch('admin_sync_services.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'System Administration';

        break;
    case 'formLibrary':
          $t_form = new Smarty;
           $t_form->left_delimiter = '<!--{';
           $t_form->right_delimiter = '}-->';

           $main->assign('useUI', true);

           if ($login->checkGroup(1))
           {
               $t_form->assign('LEAF_DOMAIN', LEAF_DOMAIN);
               $t_form->assign('app_js_path', APP_JS_PATH);

               $main->assign('body', $t_form->fetch('view_form_library.tpl'));
           }
           else
           {
               $main->assign('body', 'You require System Administrator level access to view this section.');
           }

           $tabText = 'Form Library';

           break;
    case 'importForm':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch('admin_import_form.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'Import Form';

        break;
    case 'uploadFile':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $commonConfig = new CommonConfig();

        $t_form->assign('fileExtensions', $commonConfig->fileManagerWhitelist);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch('admin_upload_file.tpl'));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }

        $tabText = 'Upload File';

        break;
    case 'mod_combined_inbox':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('app_css_path', APP_CSS_PATH);
        $t_form->assign('app_js_path', APP_JS_PATH);
        $main->assign('javascripts', array(
            APP_JS_PATH . '/choicesjs/choices.min.js',
            APP_JS_PATH . '/LEAF/XSSHelpers.js',
        ));
        $main->assign('stylesheets', array(APP_JS_PATH . '/choicesjs/choices.min.css'));

        $main->assign('body', $t_form->fetch(customTemplate('mod_combined_inbox.tpl')));

        $tabText = 'Combined Inbox Editor';

        break;
    case 'mod_system':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
//   		$t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('javascripts', array(APP_JS_PATH . '/LEAF/XSSHelpers.js',
                                           '../js/formQuery.js'));

        $t_form->assign('timeZones', DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US'));

        $t_form->assign('importTags', $settings['orgchartImportTags'][0]);
//   		$main->assign('stylesheets', array('css/mod_groups.css'));
        $main->assign('body', $t_form->fetch(customTemplate('mod_system.tpl')));

        $tabText = 'Site Settings';

        break;
    case 'mod_file_manager':
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $main->assign('javascripts', array(APP_JS_PATH . '/LEAF/XSSHelpers.js'));
            $main->assign('useUI', true);
            //   		$t_form->assign('orgchartPath', $site_paths['orgchart_path']);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('importTags', $settings['orgchartImportTags'][0]);
            //   		$main->assign('stylesheets', array('css/mod_groups.css'));
            $main->assign('body', $t_form->fetch(customTemplate('mod_file_manager.tpl')));

            $tabText = 'File Manager';

            break;
    case 'disabled_fields':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('body', $t_form->fetch(customTemplate('view_disabled_fields.tpl')));

        $tabText = 'Recover disabled fields';

        break;
    case 'mod_account_updater':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $main->assign('javascripts', array(
            '../js/formGrid.js',
            '../js/formQuery.js',
            $site_paths['orgchart_path'] . '/js/employeeSelector.js',
            APP_JS_PATH . '/LEAF/XSSHelpers.js',
            APP_JS_PATH . '/LEAF/intervalQueue.js'
        ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
        $t_form->assign('APIroot', '../api/');

        $main->assign('body', $t_form->fetch(customTemplate('mod_account_updater.tpl')));
        $tabText = 'Account Updater';
        break;
    case 'access_matrix':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('app_js_path', APP_JS_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('mod_access_matrix.tpl')));

        $tabText = 'Access Matrix';

        break;
    case 'import_data':

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);

        $main->assign('javascripts', array(
            APP_JS_PATH . '/LEAF/XSSHelpers.js',
            APP_JS_PATH . '/nexus/LEAFNexusAPI.js',
            APP_JS_PATH . '/portal/LEAFPortalAPI.js',
        ));

        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch(customTemplate('import_data.tpl')));
        }
        else
        {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }
        $tabText = 'Import Data';
        break;
    case 'site_designer':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $t_form->assign('app_js_path', APP_JS_PATH);
        $t_form->assign('libsPath', LEAF_DOMAIN.'app/libs/');
        $t_form->assign('orgchartPath', '../..'.$site_paths['orgchart_path']);
        $t_form->assign('userID', XSSHelpers::sanitizeHTML($login->getUserID()));

        $main->assign('javascripts', array(
            '../js/form.js', '../js/formGrid.js', '../js/formQuery.js', '../js/formSearch.js',
            APP_JS_PATH . '/jquery/chosen/chosen.jquery.min.js',
            APP_JS_PATH . '/choicesjs/choices.min.js',
            APP_JS_PATH . '/LEAF/XSSHelpers.js',
            APP_JS_PATH . '/jquery/jquery-ui.custom.min.js',
            APP_JS_PATH . '/jquery/trumbowyg/trumbowyg.min.js'
        ));
        $main->assign('stylesheets', array(
            APP_JS_PATH . '/jquery/chosen/chosen.min.css',
            APP_JS_PATH . '/choicesjs/choices.min.css',
            APP_JS_PATH . '/vue-dest/site_designer/LEAF_Designer.css'
        ));

        if ($login->checkGroup(1)) {
            $main->assign('body', $t_form->fetch('site_designer_vue.tpl'));
        } else {
            $main->assign('body', 'You require System Administrator level access to view this section.');
        }
        break;
    default:
//        $main->assign('useDojo', false);
        if ($login->isLogin())
        {
            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('orgchartPath', $site_paths['orgchart_path']);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('siteType', XSSHelpers::xscrub($settings['siteType']));

            $main->assign('javascripts', array(APP_JS_PATH . '/jquery/jquery.min.js',
                                           APP_JS_PATH . '/jquery/jquery-ui.custom.min.js',
                                           APP_JS_PATH . '/jsPlumb/dom.jsPlumb-min.js', ));

            $main->assign('body', $t_form->fetch(customTemplate('view_admin_menu.tpl')));

            if ($action != 'menu' && $action != '')
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
        $tabText = 'System Administration';
        break;
}

$main->assign('leafSecure', XSSHelpers::sanitizeHTML($settings['leafSecure']));
$main->assign('login', $t_login->fetch('login.tpl'));
$t_menu->assign('action', $action);
$t_menu->assign('orgchartPath', $site_paths['orgchart_path']);
$t_menu->assign('name', XSSHelpers::sanitizeHTML($login->getName()));
$t_menu->assign('siteType', XSSHelpers::xscrub($settings['siteType']));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', XSSHelpers::sanitizeHTMLRich($settings['heading'] == '' ? $config->title : $settings['heading']));
$main->assign('city', XSSHelpers::sanitizeHTMLRich($settings['subHeading'] == '' ? $config->city : $settings['subHeading']));
$main->assign('revision', XSSHelpers::xscrub($settings['version']));

if (!isset($_GET['iframe']))
{
    $main->display(customTemplate('main.tpl'));
}
else
{
    $main->display(customTemplate('main_iframe.tpl'));
}
