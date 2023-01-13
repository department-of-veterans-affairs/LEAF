<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date Created: September 11, 2007

*/

error_reporting(E_ERROR);

require_once '../globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

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

$action = isset($_GET['a']) ? Leaf\XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

function hasDevConsoleAccess($login, $oc_db)
{
    // automatically allow coaches
    $db_national = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
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

$main->assign('logo', '<img src="../images/VA_icon_small.png" alt="VA logo" />');

$t_login->assign('name', $login->getName());

$qrcodeURL = "https://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
$main->assign('qrcodeURL', urlencode($qrcodeURL));

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

        $main->assign('javascripts', array(ABSOLUTE_ORG_PATH . '/js/nationalEmployeeSelector.js',
                                           ABSOLUTE_ORG_PATH . '/js/groupSelector.js',
        ));

        $tz = isset($settings['timeZone']) ? $settings['timeZone'] : null;

        $t_form->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);
        $t_form->assign('absOrgPath', ABSOLUTE_ORG_PATH);
        $t_form->assign('domainPath', DOMAIN_PATH);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('timeZone', $tz);
        $t_form->assign('orgchartImportTag', $site_paths['importTags'][0]);

        $main->assign('useUI', true);
        $main->assign('stylesheets', array('css/mod_groups.css',
                                           ABSOLUTE_ORG_PATH . '/css/employeeSelector.css',
                                           ABSOLUTE_ORG_PATH . '/css/groupSelector.css',
        ));
        $t_form->assign('libsPath', '../..' . S_LIB_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('mod_groups.tpl')));

        $tabText = 'User Access Groups';

        break;
    case 'mod_svcChief':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);

        $main->assign('javascripts', array('../..' . $site_paths['orgchart_path'] . '/js/nationalEmployeeSelector.js',
        ));

        $t_form->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);
        $t_form->assign('domainPath', DOMAIN_PATH);
        $t_form->assign('absOrgPath', ABSOLUTE_ORG_PATH);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('stylesheets', array('css/mod_groups.css',
                '../..' . $site_paths['orgchart_path'] . '/css/employeeSelector.css',
        ));
        $main->assign('body', $t_form->fetch(customTemplate('mod_svcChief.tpl')));

        $tabText = 'Service Chiefs';

        break;
    case 'workflow':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);

        $main->assign('javascripts', array(S_LIB_PATH . 'js/jsPlumb/dom.jsPlumb-min.js',
                                           ABSOLUTE_ORG_PATH . '/js/groupSelector.js',
                                           S_LIB_PATH . 'jsapi/portal/LEAFPortalAPI.js',
                                           S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
        ));
        $main->assign('stylesheets', array('css/mod_workflow.css',
                                           ABSOLUTE_ORG_PATH . '/css/groupSelector.css',
        ));
        $t_form->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);
        $t_form->assign('orgchartImportTags', $site_paths['importTags']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch('mod_workflow.tpl'));

        $tabText = 'Workflow Editor';

        break;
    /*
    case 'form_vue':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $main->assign('javascripts', array('../../libs/js/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
                                            '../../libs/js/filesaver/FileSaver.min.js',
                                            '../../libs/js/codemirror/lib/codemirror.js',
                                            '../../libs/js/codemirror/mode/xml/xml.js',
                                            '../../libs/js/codemirror/mode/javascript/javascript.js',
                                            '../../libs/js/codemirror/mode/css/css.js',
                                            '../../libs/js/codemirror/mode/htmlmixed/htmlmixed.js',
                                            '../../libs/js/codemirror/addon/display/fullscreen.js',
                                            '../../libs/js/LEAF/XSSHelpers.js',
                                            '../../libs/jsapi/portal/LEAFPortalAPI.js',
                                            '../../libs/js/choicesjs/choices.min.js',
                                            S_LIB_PATH . '/js/LEAF/formQuery.js'
        ));
        $main->assign('stylesheets', array('../../libs/js/jquery/trumbowyg/plugins/colors/ui/trumbowyg.colors.min.css',
                                            '../../libs/js/codemirror/lib/codemirror.css',
                                            '../../libs/js/codemirror/addon/display/fullscreen.css',
                                            '../../libs/js/choicesjs/choices.min.css'
        ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $t_form->assign('absPortalPath', ABSOLUTE_PORT_PATH);
        $t_form->assign('orgchartPath', '../' . Config::$orgchartPath);
        $t_form->assign('referFormLibraryID', (int)$_GET['referFormLibraryID']);
        $t_form->assign('hasDevConsoleAccess', hasDevConsoleAccess($login, $db_phonebook));

        $main->assign('body', $t_form->fetch('form_editor_vue.tpl'));

        $tabText = 'Form Editor Testing';
        break;
    */
    case 'form':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $main->assign('javascripts', array(S_LIB_PATH . 'js/jquery/trumbowyg/plugins/colors/trumbowyg.colors.min.js',
                                            S_LIB_PATH . 'js/filesaver/FileSaver.min.js',
                                            S_LIB_PATH . 'js/codemirror/lib/codemirror.js',
                                            S_LIB_PATH . 'js/codemirror/mode/xml/xml.js',
                                            S_LIB_PATH . 'js/codemirror/mode/javascript/javascript.js',
                                            S_LIB_PATH . 'js/codemirror/mode/css/css.js',
                                            S_LIB_PATH . 'js/codemirror/mode/htmlmixed/htmlmixed.js',
                                            S_LIB_PATH . 'js/codemirror/addon/display/fullscreen.js',
                                            S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
                                            S_LIB_PATH . 'jsapi/portal/LEAFPortalAPI.js',
                                            S_LIB_PATH . 'js/choicesjs/choices.min.js',
                                            '../js/gridInput.js',
                                            S_LIB_PATH . 'js/LEAF/formQuery.js'
        ));
        $main->assign('stylesheets', array('css/mod_form.css',
                                            S_LIB_PATH . 'js/jquery/trumbowyg/plugins/colors/ui/trumbowyg.colors.min.css',
                                            S_LIB_PATH . 'js/codemirror/lib/codemirror.css',
                                            S_LIB_PATH . 'js/codemirror/addon/display/fullscreen.css',
                                            S_LIB_PATH . 'js/choicesjs/choices.min.css'
        ));

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('APIroot', '../api/');
        $t_form->assign('referFormLibraryID', (int)$_GET['referFormLibraryID']);
        $t_form->assign('hasDevConsoleAccess', hasDevConsoleAccess($login, $oc_db));

        if (isset($_GET['form']))
        {
            $vars = array(':categoryID' => Leaf\XSSHelpers::xscrub($_GET['form']));
            $res = $db->prepared_query('SELECT * FROM categories WHERE categoryID=:categoryID', $vars);
            if (count($res) > 0)
            {
                $t_form->assign('form', Leaf\XSSHelpers::xscrub($res[0]['categoryID']));
            }
        }

        $t_form->assign('libsPath', S_LIB_PATH);
        $t_form->assign('portalPath', ABSOLUTE_PORT_PATH . '/');

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
            $main->assign('javascripts', array(S_LIB_PATH . 'js/codemirror/lib/codemirror.js',
                                                S_LIB_PATH . 'js/codemirror/mode/xml/xml.js',
                                                S_LIB_PATH . 'js/codemirror/mode/javascript/javascript.js',
                                                S_LIB_PATH . 'js/codemirror/mode/css/css.js',
                                                S_LIB_PATH . 'js/codemirror/mode/htmlmixed/htmlmixed.js',
                                                S_LIB_PATH . 'js/codemirror/addon/search/search.js',
                                                S_LIB_PATH . 'js/codemirror/addon/search/searchcursor.js',
                                                S_LIB_PATH . 'js/codemirror/addon/dialog/dialog.js',
                                                S_LIB_PATH . 'js/codemirror/addon/scroll/annotatescrollbar.js',
                                                S_LIB_PATH . 'js/codemirror/addon/search/matchesonscrollbar.js',
                                                S_LIB_PATH . 'js/codemirror/addon/display/fullscreen.js',
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
                    $tabText = 'Template Editor';

                    break;
                case 'mod_templates_reports':
                    $t_form->assign('libsPath', S_LIB_PATH);
                    $main->assign('body', $t_form->fetch('mod_templates_reports.tpl'));
                    $tabText = 'Editor';

                    break;
                case 'mod_templates_email':
                    $t_form->assign('libsPath', S_LIB_PATH);
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
            $main->assign('libsPath', S_LIB_PATH);
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
               $t_form->assign('LEAF_NEXUS_URL', $site_paths['orgchart_path']);
               $t_form->assign('domainPath', DOMAIN_PATH);
               $t_form->assign('libsPath', S_LIB_PATH);
               $t_form->assign('portalPath', PORTAL_PATH);

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
            $t_form->assign('libsPath', S_LIB_PATH);
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

        $commonConfig = new Leaf\CommonConfig();

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
    case 'mod_system':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('javascripts', array(S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
                                           S_LIB_PATH . 'js/LEAF/formQuery.js'));

        $t_form->assign('timeZones', DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US'));

        $t_form->assign('importTags', $settings['importTags']);
        $t_form->assign('portalPath', PORTAL_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('mod_system.tpl')));

        $tabText = 'Site Settings';

        break;
    case 'mod_file_manager':
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';

            $main->assign('useUI', true);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('importTags', $settings['importTags']);
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
    case 'access_matrix':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('useUI', true);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('mod_access_matrix.tpl')));

        $tabText = 'Access Matrix';

        break;
    case 'import_data':

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);

        $main->assign('javascripts', array(
            S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
            S_LIB_PATH . 'jsapi/nexus/LEAFNexusAPI.js',
            S_LIB_PATH . 'jsapi/portal/LEAFPortalAPI.js',
        ));

        if ($login->checkGroup(1))
        {
            $main->assign('body', $t_form->fetch(customTemplate('import_data.tpl')));
        }
        else
        {
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
            $t_form->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('siteType', Leaf\XSSHelpers::xscrub($settings['siteType']));

            $main->assign('javascripts', array(S_LIB_PATH . 'js/jquery/jquery.min.js',
                                           S_LIB_PATH . 'js/jquery/jquery-ui.custom.min.js',
                                           S_LIB_PATH . 'js/jsPlumb/dom.jsPlumb-min.js', ));

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

        break;
}

$main->assign('leafSecure', Leaf\XSSHelpers::sanitizeHTML($settings['leafSecure']));
$main->assign('login', $t_login->fetch('login.tpl'));
$t_menu->assign('action', $action);
$t_menu->assign('orgchartPath', '../..' . $site_paths['orgchart_path']);
$t_menu->assign('name', Leaf\XSSHelpers::sanitizeHTML($login->getName()));
$t_menu->assign('siteType', Leaf\XSSHelpers::xscrub($settings['siteType']));
$t_menu->assign('libsPath', S_LIB_PATH);
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', Leaf\XSSHelpers::sanitizeHTML($settings['heading']));
$main->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));
$main->assign('revision', Leaf\XSSHelpers::xscrub($settings['version']));
$main->assign('libsPath', S_LIB_PATH);

if (!isset($_GET['iframe']))
{
    $main->display(customTemplate('main.tpl'));
}
else
{
    $main->display(customTemplate('main_iframe.tpl'));
}
