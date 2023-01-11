<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ERROR);

require_once 'globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

header('X-UA-Compatible: IE=edge');

$login->loginUser();

if (!$login->isLogin() || !$login->isInDB()) {
    $login->logout(); // destroy current session tokens
    header("Location: session_expire.php");
    exit;
}

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? Leaf\XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl) {
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$t_login->assign('name', Leaf\XSSHelpers::xscrub($login->getName()));
$t_menu->assign('libsPath', S_LIB_PATH);
$t_menu->assign('menu_links', customTemplate('menu_links.tpl'));
$t_menu->assign('menu_help', customTemplate('menu_help.tpl'));
$t_menu->assign('is_admin', $login->checkGroup(1));
$t_menu->assign('hide_main_control', false);

$qrcodeURL = "https://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
$main->assign('qrcodeURL', urlencode($qrcodeURL));

$main->assign('emergency', '');
$main->assign('status', '');
$main->assign('hideFooter', false);
$main->assign('useUI', false);
$main->assign('userID', $login->getUserID());

if (isset($settings['timeZone'])) {
    date_default_timezone_set(Leaf\XSSHelpers::xscrub($settings['timeZone']));
}

$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

switch ($action) {
    case 'newform':
        $main->assign('useLiteUI', true);
        $main->assign('javascripts', array('js/titleValidator.js'));

        $stack = new Portal\FormStack($db, $login);

        $t_menu->assign('action', Leaf\XSSHelpers::xscrub($action));
        $o_login = $t_login->fetch('login.tpl');

        $currEmployee = $form->employee->lookupLogin($_SESSION['userID']);
        $currEmployeeData = $form->employee->getAllData($currEmployee[0]['empUID'], 5);

        $categoryArray = $stack->getCategories();
        foreach ($categoryArray as $key => $cat)
        {
            $categoryArray[$key] = array_map('Leaf\XSSHelpers::xscrub', $cat);
        }

        $servicesArray = $form->getServices2();
        foreach ($servicesArray as $key => $service)
        {
            $servicesArray[$key]['service'] = Leaf\XSSHelpers::xscrub($servicesArray[$key]['service']);
        }

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('categories', $categoryArray);
        $t_form->assign('recorder', Leaf\XSSHelpers::sanitizeHTML($login->getName()));
        $t_form->assign('services', $servicesArray);
        $t_form->assign('city', Leaf\XSSHelpers::sanitizeHTML($setting['subHeading']));
        $t_form->assign('phone', Leaf\XSSHelpers::sanitizeHTML($currEmployeeData[5]['data']));
        $t_form->assign('userID', Leaf\XSSHelpers::sanitizeHTML($login->getUserID()));
        $t_form->assign('empUID', (int)$login->getEmpUID());
        $t_form->assign('empMembership', $login->getMembership());
        $t_form->assign('CSRFToken', Leaf\XSSHelpers::xscrub($_SESSION['CSRFToken']));
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('initial_form.tpl')));

        $o_login = $t_login->fetch('login.tpl');
        $tabText = 'Resource Request';

        break;
    case 'view':
        $main->assign('useUI', true);
        $main->assign('stylesheets', array('css/view.css', S_LIB_PATH . 'js/choicesjs/choices.min.css'));
        $main->assign('javascripts', array('js/form.js', 'js/gridInput.js', 'js/formGrid.js', S_LIB_PATH . 'js/LEAF/XSSHelpers.js', S_LIB_PATH . 'js/choicesjs/choices.min.js'));

        $recordIDToView = (int)$_GET['recordID'];
        // prevent view if form is submitted
        // defines who can edit the form
        if ($form->hasWriteAccess($recordIDToView) || $login->checkGroup(1))
        {
            $t_menu->assign('recordID', $recordIDToView);
            $t_menu->assign('action', Leaf\XSSHelpers::xscrub($action));
            $o_login = $t_login->fetch('login.tpl');

            // $thisRecord = $form->getRecord($_GET['recordID']);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('recordID', $recordIDToView);
            $t_form->assign('lastStatus', Leaf\XSSHelpers::sanitizeHTMl($form->getLastStatus($recordIDToView)));
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('isIframe', (int)$_GET['iframe'] == 1 ? 1 : 0);
            $t_form->assign('userID', Leaf\XSSHelpers::sanitizeHTML($login->getUserID()));
            $t_form->assign('empUID', (int)$login->getEmpUID());
            $t_form->assign('empMembership', $login->getMembership());

            // since $thisRecord was already commented out above, this can probably be removed
            // if(isset($thisRecord['approval'])) {
            //     $t_form->assign('approval', $thisRecord['approval']);
            // }

            switch ($action) {
                case 'review':
                    break;
                default:
                    $t_form->assign('libsPath', S_LIB_PATH);
                    $main->assign('body', $t_form->fetch(customTemplate('form.tpl')));

                    break;
            }
        }
        else
        {
            $main->assign('status', 'This form is locked from editing.');
        }
        $o_login = $t_login->fetch('login.tpl');

        $requestLabel = $settings['requestLabel'] == '' ? 'Request' : Leaf\XSSHelpers::sanitizeHTML($settings['requestLabel']);
        $tabText = $requestLabel . ' #' . $recordIDToView;

        break;
    case 'printview':
        $main->assign('useUI', true);
        $main->assign('stylesheets', array(S_LIB_PATH . 'js/choicesjs/choices.min.css'));
        $main->assign('javascripts', array(
            'js/form.js',
            'js/gridInput.js',
            'js/workflow.js',
            'js/formGrid.js',
            'js/formQuery.js',
            'js/formPrint.js',
            'js/jsdiff.js',
            S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
            S_LIB_PATH . 'jsapi/portal/LEAFPortalAPI.js',
            S_LIB_PATH . 'js/es6-promise/es6-promise.min.js',
            S_LIB_PATH . 'js/es6-promise/es6-promise.auto.min.js',
            S_LIB_PATH . 'js/jspdf/jspdf.min.js',
            S_LIB_PATH . 'js/jspdf/jspdf.plugin.autotable.min.js',
            S_LIB_PATH . 'js/choicesjs/choices.min.js',
            'js/titleValidator.js'
        ));

        $recordIDToPrint = (int)$_GET['recordID'];

        $t_menu->assign('recordID', $recordIDToPrint);
        $t_menu->assign('action', Leaf\XSSHelpers::xscrub($action));
        $o_login = $t_login->fetch('login.tpl');

        $recordInfo = $form->getRecordInfo($recordIDToPrint);
        $comments = $form->getActionComments($recordIDToPrint);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('canWrite', $form->hasWriteAccess($recordIDToPrint));
        $t_form->assign('canRead', $form->hasReadAccess($recordIDToPrint));
        $t_form->assign('accessLogs', $form->log);
        $t_form->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
        $t_form->assign('is_admin', $login->checkGroup(1));
        $t_form->assign('recordID', $recordIDToPrint);
        $t_form->assign('userID', Leaf\XSSHelpers::sanitizeHTML($login->getUserID()));
        $t_form->assign('empUID', (int)$login->getEmpUID());
        $t_form->assign('empMembership', $login->getMembership());
        $t_form->assign('name', Leaf\XSSHelpers::sanitizeHTML($recordInfo['name']));
        $t_form->assign('title', Leaf\XSSHelpers::sanitizeHTML($recordInfo['title']));
        $t_form->assign('priority', (int)$recordInfo['priority']);
        $t_form->assign('submitted', Leaf\XSSHelpers::sanitizeHTML($recordInfo['submitted']));
        $t_form->assign('stepID', (int)$recordInfo['stepID']);
        $t_form->assign('service', Leaf\XSSHelpers::sanitizeHTML($recordInfo['service']));
        $t_form->assign('serviceID', (int)$recordInfo['serviceID']);
        $t_form->assign('date', Leaf\XSSHelpers::sanitizeHTML($recordInfo['date']));
        $t_form->assign('deleted', (int)$recordInfo['deleted']);
        $t_form->assign('bookmarked', Leaf\XSSHelpers::sanitizeHTML($recordInfo['bookmarked']));
        $t_form->assign('categories', $recordInfo['categories']);
        $t_form->assign('comments', $comments);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        if ($recordInfo['priority'] == -10)
        {
            $main->assign('emergency', '<span style="position: absolute; right: 0px; top: -28px; padding: 2px; border: 1px solid black; background-color: white; color: red; font-weight: bold; font-size: 20px">EMERGENCY</span> ');
        }

        // get workflow status and check permissions
        $formWorkflow = new Portal\FormWorkflow($db, $login, $recordIDToPrint, $form, $vamc);
        $t_form->assign('workflow', $formWorkflow->isActive());

        switch ($action) {
            default:
                $childForms = $form->getChildForms($recordIDToPrint);
                $t_form->assign('childforms', $childForms);

                $childCatID = Leaf\XSSHelpers::xscrub($_GET['childCategoryID']);
                if ($childCatID != '')
                {
                    $match = 0;
                    foreach ($childForms as $cForm)
                    {
                        if ($cForm['childCategoryID'] == $childCatID)
                        {
                            $match = 1;
                        }
                    }
                    if ($match = 1)
                    {
                        // safe to pass in $_GET
                        $t_form->assign('childCategoryID', $childCatID);
                    }
                }
                $t_form->assign('libsPath', S_LIB_PATH);
                $t_form->assign('absPortPath', ABSOLUTE_PORT_PATH . '/');

                $main->assign('body', $t_form->fetch(customTemplate('print_form.tpl')));

                break;
        }

        $requestLabel = $settings['requestLabel'] == '' ? 'Request' : Leaf\XSSHelpers::sanitizeHTML($settings['requestLabel']);
        $tabText = $requestLabel . ' #' . $recordIDToPrint;

        break;
    case 'inbox':
        $main->assign('useUI', true);
        $main->assign('stylesheets', array(S_LIB_PATH . 'js/choicesjs/choices.min.css'));
        $main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/gridInput.js', S_LIB_PATH . 'js/choicesjs/choices.min.js'));

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $inbox = new Portal\Inbox($db, $login, $form);

        $inboxItems = $inbox->getInbox($vamc);

        $errors = [];
        if(array_key_exists("errors", $inboxItems))
        {
            $errors = $inboxItems['errors'];
            unset($inboxItems['errors']);
        }
        $depIndex = array_keys($inboxItems);
        $depColors = array();
        foreach ($depIndex as $depID)
        {
            $color = '';
            foreach ($inboxItems[$depID]['records'] as $item)
            {
                $color = $item['stepBgColor'];

                break;
            }
            $depColors[$depID] = $color;
        }

        $descriptionID = $settings['descriptionID'] ?: '';

        $t_form->assign('inbox', $inboxItems);
        $t_form->assign('depColors', $depColors);
        $t_form->assign('descriptionID', $descriptionID);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('errors', $errors);
        $t_form->assign('libsPath', S_LIB_PATH);
        $t_form->assign('portalPath', PORTAL_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('view_inbox.tpl')));

        $tabText = 'Inbox';

        break;
    case 'status':
        $view = new Portal\View($db, $login);

        $recordIDForStatus = (int)$_GET['recordID'];

        $t_menu->assign('recordID', $recordIDForStatus);
        $t_menu->assign('action', Leaf\XSSHelpers::xscrub($action));
        $o_login = $t_login->fetch('login.tpl');

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $recordInfo = $form->getRecordInfo($recordIDForStatus);
        $t_form->assign('name', Leaf\XSSHelpers::sanitizeHTML($recordInfo['name']));
        $t_form->assign('title', Leaf\XSSHelpers::sanitizeHTML($recordInfo['title']));
        $t_form->assign('priority', (int)$recordInfo['priority']);
        $t_form->assign('submitted', (int)$recordInfo['submitted']);
        $t_form->assign('service', Leaf\XSSHelpers::sanitizeHTML($recordInfo['service']));
        $t_form->assign('date', Leaf\XSSHelpers::sanitizeHTML($recordInfo['date']));
        $t_form->assign('recordID', $recordIDForStatus);
        $t_form->assign('agenda', $view->buildViewStatus($recordIDForStatus, $form, $vamc));
        $t_form->assign('dependencies', $form->getDependencyStatus($recordIDForStatus));
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch('view_status.tpl'));

        break;
    case 'cancelled_request':
        $main->assign('useUI', false);
        $body = '<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px">';
        $body .= '<img src="' . S_LIB_PATH . 'dynicons/?img=user-trash-full.svg&amp;w=96" alt="empty" style="float: left"/><span style="font-size: 200%"> Request <b>#' . (int)$_GET['cancelled'] . '</b> has been cancelled!<br /><br /></span></div>';
        $main->assign('body', $body);

        break;
    case 'import_from_webHR':
        $t_menu->assign('action', $action);
        $o_login = $t_login->fetch('login.tpl');

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $filter = isset($_GET['filter']) ? $_GET['filter'] : '';
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch('import_from_webHR.tpl'));

           $tabText = 'WebHR Importer';

           break;
    case 'bookmarks':
        $view = new Portal\View($db, $login);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('is_service_chief', (int)$login->isServiceChief());
        $t_form->assign('empMembership', $login->getMembership());

        $t_form->assign('bookmarks', $view->buildViewBookmarks($login->getUserID()));
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('libsPath', S_LIB_PATH);
        $main->assign('body', $t_form->fetch('view_bookmarks.tpl'));

        $tabText = 'Bookmarks';

        break;
    case 'tag_cloud':
        $tags = $form->getUniqueTags();
        $count = 0;
        $tempTags = array();
        foreach ($tags as $tag)
        {
            $count += $tag['COUNT(tag)'];
            $tempTags[$tag['tag']]['tag'] = $tag['tag'];
            $tempTags[$tag['tag']]['count'] = $tag['COUNT(tag)'];
        }

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('total', $count);
        $t_form->assign('tags', $tempTags);
        $main->assign('body', $t_form->fetch('tag_cloud.tpl'));

        $tabText = 'Tag Cloud';

        break;
    case 'gettagmembers':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $tagMembers = $form->getTagMembers($_GET['tag']);

        $t_form->assign('tag', Leaf\XSSHelpers::xscrub(strip_tags($_GET['tag'])));
        $t_form->assign('totalNum', count($tagMembers));
        $t_form->assign('requests', $tagMembers);
        $main->assign('body', $t_form->fetch('tag_show_members.tpl'));

        $tabText = 'Tagged Requests';

        break;
    case 'about':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $rev = $db->prepared_query("SELECT * FROM settings WHERE setting='dbversion'", array());
        $t_form->assign('dbversion', Leaf\XSSHelpers::xscrub($rev[0]['data']));

        $main->assign('hideFooter', true);
        $t_form->assign('libsPath', S_LIB_PATH);
        $main->assign('body', $t_form->fetch('view_about.tpl'));

        break;
    case 'search':
        $main->assign('javascripts', array(
                'js/form.js',
                'js/formGrid.js',
                'js/formQuery.js',
                'js/formSearch.js'
        ));
        $main->assign('useUI', true);

        $o_login = $t_login->fetch('login.tpl');

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $main->assign('body', $t_form->fetch(customTemplate('view_search.tpl')));

        $o_login = $t_login->fetch('login.tpl');

        break;

    case 'sitemap':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('sitemap', $settings['sitemap_json']);
        $t_form->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));
        $t_form->assign('libsPath', S_LIB_PATH);
        $main->assign('body', $t_form->fetch('sitemap.tpl'));

        break;

    case 'reports':
        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
//        $powerQueryURL = "{$protocol}://" . AUTH_URL . "/report_auth.php?r=";
        $powerQueryURL = "https://" . AUTH_URL . "/report_auth.php?r=";

        $main->assign('stylesheets', array('css/report.css', S_LIB_PATH . 'js/choicesjs/choices.min.css'));
        $main->assign('javascripts', array('js/form.js',
               'js/formGrid.js',
               'js/formQuery.js',
               'js/formSearch.js',
               'js/gridInput.js',
               'js/workflow.js',
               'js/lz-string/lz-string.min.js',
               S_LIB_PATH . 'jsapi/portal/LEAFPortalAPI.js',
               S_LIB_PATH . 'js/LEAF/XSSHelpers.js',
               S_LIB_PATH . 'js/choicesjs/choices.min.js'
           ));
           $main->assign('useUI', true);

        $o_login = $t_login->fetch('login.tpl');

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $t_form->assign('query', Leaf\XSSHelpers::xscrub($_GET['query']));
        $t_form->assign('indicators', Leaf\XSSHelpers::xscrub($_GET['indicators']));
        $t_form->assign('colors', Leaf\XSSHelpers::xscrub($_GET['colors']));
        $t_form->assign('title', Leaf\XSSHelpers::sanitizeHTML($_GET['title']));
        $t_form->assign('version', (int)$_GET['v']);
        $t_form->assign('empMembership', $login->getMembership());
        $t_form->assign('powerQueryURL', $powerQueryURL);
        $t_form->assign('libsPath', S_LIB_PATH);
        $t_form->assign('absPortPath', ABSOLUTE_PORT_PATH . '/');

        $main->assign('body', $t_form->fetch(customTemplate('view_reports.tpl')));

           $o_login = $t_login->fetch('login.tpl');
           $tabText = 'Report Builder';

           break;
    case 'logout':
        $login->logout();

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $main->assign('title', Leaf\XSSHelpers::sanitizeHTML($settings['heading']));
        $main->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));
        $main->assign('logout', true);
        $main->assign('leafSecure', Leaf\XSSHelpers::sanitizeHTML($settings['leafSecure']));
        $main->assign('revision', Leaf\XSSHelpers::sanitizeHTML($settings['version']));

        $main->assign('body', $t_form->fetch(customTemplate('view_logout.tpl')));
        $main->assign('libsPath', S_LIB_PATH);

        $main->display(customTemplate('main.tpl'));
        exit();
    default:

        $main->assign('javascripts', array('js/form.js', 'js/formGrid.js', 'js/formQuery.js', 'js/formSearch.js'));
        $main->assign('useLiteUI', true);

        $o_login = $t_login->fetch('login.tpl');

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('userID', Leaf\XSSHelpers::sanitizeHTML($login->getUserID()));
        $t_form->assign('empUID', (int)$login->getEmpUID());
        $t_form->assign('empMembership', $login->getMembership());
        $t_form->assign('is_service_chief', (int)$login->isServiceChief());
        $t_form->assign('is_quadrad', (int)$login->isQuadrad() || (int)$login->checkGroup(1));
        $t_form->assign('is_admin', (int)$login->checkGroup(1));
        $t_form->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        $t_form->assign('tpl_search', customTemplate('view_search.tpl'));

        $inbox = new Portal\Inbox($db, $login, $form);
        //$t_form->assign('inbox_status', $inbox->getInboxStatus()); // see Inbox.php -> getInboxStatus()

        $t_form->assign('inbox_status', 1);
        $t_form->assign('libsPath', S_LIB_PATH);

        $main->assign('body', $t_form->fetch(customTemplate('view_homepage.tpl')));

        if ($action != 'menu' && $action != '' && $action != 'dosubmit') {
            $main->assign('status', 'The page you are looking for does not exist or may have been moved. Please update your bookmarks.');
        }

        $o_login = $t_login->fetch('login.tpl');

        break;
}

$main->assign('leafSecure', Leaf\XSSHelpers::sanitizeHTML($settings['leafSecure']));
$main->assign('login', $t_login->fetch('login.tpl'));
$main->assign('empMembership', $login->getMembership());
$t_menu->assign('action', Leaf\XSSHelpers::xscrub($action));
$t_menu->assign('orgchartPath', '..' . $site_paths['orgchart_path']);
$t_menu->assign('empMembership', $login->getMembership());
$t_menu->assign('libsPath', S_LIB_PATH);
$o_menu = $t_menu->fetch(customTemplate('menu.tpl'));
$main->assign('menu', $o_menu);
$main->assign('tabText', Leaf\XSSHelpers::sanitizeHTML($tabText));

$main->assign('title', Leaf\XSSHelpers::sanitizeHTML($settings['heading']));
$main->assign('city', Leaf\XSSHelpers::sanitizeHTML($settings['subHeading']));
$main->assign('revision', Leaf\XSSHelpers::sanitizeHTML($settings['version']));
$main->assign('libsPath', S_LIB_PATH);

if (!isset($_GET['iframe'])) {
    $main->display(customTemplate('main.tpl'));
} else {
    $main->display(customTemplate('main_iframe.tpl'));
}
