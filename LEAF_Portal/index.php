<?php
/************************
    Index for everything
    Date Created: September 11, 2007

*/

error_reporting(E_ALL & ~E_NOTICE);

if(false) {
    echo '<img src="../libs/dynicons/?img=dialog-error.svg&amp;w=96" alt="error" style="float: left" /><div style="font: 36px verdana">Site currently undergoing maintenance, will be back shortly!</div>';
    exit();
}

include 'globals.php';
include '../libs/smarty/Smarty.class.php';
include 'Login.php';
include 'db_mysql.php';
include 'db_config.php';
include 'form.php';

$db_config = new DB_Config();
$config = new Config();

header('X-UA-Compatible: IE=edge');

// Enforce HTTPS
if(isset($config->enforceHTTPS) && $config->enforceHTTPS == true) {
    if(!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] != 'on') {
        header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
        exit();
    }
}

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);

$login->loginUser();
if(!$login->isLogin() || !$login->isInDB()) {
    echo 'Session expired, please refresh the page.<br /><br />If this message persists, please include the following information to your administrator:';
    echo '<pre>';
    print_r($_SESSION);
    echo '</pre>';
    $login->logout();
    exit;
}

$post_name = isset($_POST['name']) ? $_POST['name'] : '';
$post_password = isset($_POST['password']) ? $_POST['password'] : '';

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? $_GET['a'] : '';

function customTemplate($tpl) {
	return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$t_login->assign('name', $login->getName());
$t_menu->assign('is_admin', $login->checkGroup(1));

$main->assign('useUI', false);

$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
if(isset($settings['timeZone'])) {
	date_default_timezone_set($settings['timeZone']);
}

switch($action) {
    case 'newform':
    	$main->assign('useLiteUI', true);
        if($login->isLogin()) {
            $form = new Form($db, $login);
            include './sources/FormStack.php';
            $stack = new FormStack($db, $login);

            $t_menu->assign('action', $action);
            $o_login = $t_login->fetch('login.tpl');

            $currEmployee = $form->employee->lookupLogin($_SESSION['userID']);
            $currEmployeeData = $form->employee->getAllData($currEmployee[0]['empUID'], 5);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';
            $t_form->assign('categories', $stack->getCategories());
            $t_form->assign('recorder', $login->getName());
            $t_form->assign('services', $form->getServices2());
            $t_form->assign('city', $config->city);
            $t_form->assign('phone', $currEmployeeData[5]['data']);
            $t_form->assign('empMembership', $login->getMembership());
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

            $main->assign('body', $t_form->fetch(customTemplate('initial_form.tpl')));
        }
        else {
            $t_login->assign('name', '');
            $main->assign('status', 'Your login session has expired, You must log in again.');
        }
        $o_login = $t_login->fetch('login.tpl');
        $tabText = 'Resource Request';
        break;
    case 'view':
    	$main->assign('useUI', true);
    	$main->assign('stylesheets', array('css/view.css'));
    	$main->assign('javascripts', array('js/form.js', 'js/formGrid.js'));
        $form = new Form($db, $login);
        // prevent view if form is submitted
        // defines who can edit the form
        if($form->hasWriteAccess($_GET['recordID'])
                || $login->checkGroup(1)) {
            $t_menu->assign('recordID', (int)$_GET['recordID']);
            $t_menu->assign('action', $action);
            $o_login = $t_login->fetch('login.tpl');

//            $thisRecord = $form->getRecord($_GET['recordID']);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';
            $t_form->assign('recordID', (int)$_GET['recordID']);
            $t_form->assign('lastStatus', $form->getLastStatus($_GET['recordID']));
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            $t_form->assign('isIframe', $_GET['iframe'] == 1 ? 1 : 0);
            if(isset($thisRecord['approval'])) {
                $t_form->assign('approval', $thisRecord['approval']);
            }

            switch($action) {
                case 'review':
                    break;
                default:
                    $main->assign('body', $t_form->fetch(customTemplate('form.tpl')));
                    break;
            }
        }
        else {
            $main->assign('status', 'This form is locked from editing.');
        }
        $o_login = $t_login->fetch('login.tpl');

        $requestLabel = $settings['requestLabel'] == '' ? 'Request' : $settings['requestLabel'];
        $tabText = $requestLabel . ' #' . (int)$_GET['recordID'];
        break;
    case 'printview':
    	$main->assign('useUI', true);
    	$main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/formQuery.js', 'js/jsdiff.js'));
        if($login->isLogin()) {
            $form = new Form($db, $login);
            $t_menu->assign('recordID', (int)$_GET['recordID']);
            $t_menu->assign('action', $action);
            $o_login = $t_login->fetch('login.tpl');

            $recordInfo = $form->getRecordInfo($_GET['recordID']);
            $comments = $form->getActionComments($_GET['recordID']);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';
            $t_form->assign('orgchartPath', Config::$orgchartPath);
            $t_form->assign('is_admin', $login->checkGroup(1));
            $t_form->assign('recordID', (int)$_GET['recordID']);
            $t_form->assign('name', $recordInfo['name']);
            $t_form->assign('title', $recordInfo['title']);
            $t_form->assign('priority', $recordInfo['priority']);
            $t_form->assign('submitted', $recordInfo['submitted']);
            $t_form->assign('stepID', $recordInfo['stepID']);
            $t_form->assign('service', $recordInfo['service']);
            $t_form->assign('serviceID', $recordInfo['serviceID']);
            $t_form->assign('date', $recordInfo['date']);
            $t_form->assign('deleted', $recordInfo['deleted']);
            $t_form->assign('bookmarked', $recordInfo['bookmarked']);
            $t_form->assign('categories', $recordInfo['categories']);
            $t_form->assign('comments', $comments);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

            if($recordInfo['priority'] == -10) {
                $main->assign('emergency', '<span style="position: absolute; right: 0px; top: -28px; padding: 2px; border: 1px solid black; background-color: white; color: red; font-weight: bold; font-size: 20px">EMERGENCY</span> ');
            }

            // get workflow status and check permissions
            require_once 'FormWorkflow.php';
            $formWorkflow = new FormWorkflow($db, $login, $_GET['recordID']);
            $t_form->assign('workflow', $formWorkflow->isActive());

            //url
            $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
            $qrcodeURL = "{$protocol}://{$_SERVER['HTTP_HOST']}" . $_SERVER['REQUEST_URI'];
            $main->assign('qrcodeURL', urlencode($qrcodeURL));

            switch($action) {
                default:
					$childForms = $form->getChildForms($_GET['recordID']);
                    $t_form->assign('childforms', $childForms);
                    
                    if($_GET['childCategoryID'] != '') {
                    	$match = 0;
                    	foreach($childForms as $cForm) {
                    		if($cForm['childCategoryID'] == $_GET['childCategoryID']) {
                    			$match = 1;
                    		}
                    	}
                    	if($match = 1) {
                    		// safe to pass in $_GET
                    		$t_form->assign('childCategoryID', $_GET['childCategoryID']);
                    	}
                    }
                    
                    $main->assign('body', $t_form->fetch(customTemplate('print_form.tpl')));
                    $t_menu->assign('hide_main_control', true);
                    break;
            }
            
            $requestLabel = $settings['requestLabel'] == '' ? 'Request' : $settings['requestLabel'];
            $tabText = $requestLabel . ' #' . (int)$_GET['recordID'];
        }
        break;
    case 'inbox':
    	$main->assign('useUI', true);
    	$main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js'));
        if($login->isLogin()) {
            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';

            require_once 'Inbox.php';
            $inbox = new Inbox($db, $login);

            $inboxItems = $inbox->getInbox();

            $depIndex = array_keys($inboxItems);
            $depColors = array();
            foreach($depIndex as $depID) {
                $color = '';
                foreach($inboxItems[$depID]['records'] as $item) {
                    $color = $item['stepBgColor'];
                    break;
                }
                $depColors[$depID] = $color;
            }

            $t_form->assign('inbox', $inboxItems);
            $t_form->assign('depColors', $depColors);
            $t_form->assign('descriptionID', $config->descriptionID);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

            $main->assign('body', $t_form->fetch(customTemplate('view_inbox.tpl')));
        }
        $tabText = 'Inbox';
        break;
    case 'status':
        if($login->isLogin()) {
            $form = new Form($db, $login);
            include_once 'View.php';
            $view = new View($db, $login);
            $t_menu->assign('recordID', (int)$_GET['recordID']);
            $t_menu->assign('action', $action);
            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';
            $recordInfo = $form->getRecordInfo($_GET['recordID']);
            $t_form->assign('name', $recordInfo['name']);
            $t_form->assign('title', $recordInfo['title']);
            $t_form->assign('priority', $recordInfo['priority']);
            $t_form->assign('submitted', $recordInfo['submitted']);
            $t_form->assign('service', $recordInfo['service']);
            $t_form->assign('date', $recordInfo['date']);
            $t_form->assign('recordID', (int)$_GET['recordID']);
            $t_form->assign('agenda', $view->buildViewStatus($_GET['recordID']));
            $t_form->assign('dependencies', $form->getDependencyStatus($_GET['recordID']));            

            $main->assign('body', $t_form->fetch('view_status.tpl'));
        }
        break;
    case 'cancelled_request':
    	$main->assign('useUI', false);
        $body = '<div style="width: 50%; margin: 0px auto; border: 1px solid black; padding: 16px">';
        $body .= '<img src="../libs/dynicons/?img=user-trash-full.svg&amp;w=96" alt="empty" style="float: left"/><span style="font-size: 200%"> Request <b>#' . (int)$_GET['cancelled'] .'</b> has been cancelled!<br /><br /></span></div>';
        $main->assign('body', $body);
        break;
    case 'import_from_webHR':
       	if($login->isLogin()) {

       		$t_menu->assign('action', $action);
       		$o_login = $t_login->fetch('login.tpl');
       
       		$t_form = new Smarty;
       		$t_form->left_delimiter = '<!--{';
       		$t_form->right_delimiter= '}-->';
       
       		$filter = isset($_GET['filter']) ? $_GET['filter'] : '';
       
       		$main->assign('body', $t_form->fetch('import_from_webHR.tpl'));
       	}
       	$tabText = 'WebHR Importer';
       	break;
    case 'bookmarks':
        include_once 'View.php';
        $view = new View($db, $login);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter= '}-->';

        $t_form->assign('is_service_chief', $login->isServiceChief());
        $t_form->assign('ingroup_quadrad', $login->checkGroup(1) || $login->checkGroup(2)
                                            || $login->checkGroup(3) || $login->checkGroup(4)
                                            || $login->checkGroup(5)|| $login->checkGroup(1));        

        $t_form->assign('bookmarks', $view->buildViewBookmarks($login->getUserID()));
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('body', $t_form->fetch('view_bookmarks.tpl'));

        $tabText = 'Bookmarks';
        break;
    case 'tag_cloud':
        $form = new Form($db, $login);
        $tags = $form->getUniqueTags();
        $count = 0;
        $tempTags = array();
        foreach($tags as $tag) {
            $count += $tag['COUNT(tag)'];
            $tempTags[$tag['tag']]['tag'] = $tag['tag'];
            $tempTags[$tag['tag']]['count'] = $tag['COUNT(tag)'];
        }

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter= '}-->';
        $t_form->assign('total', $count);
        $t_form->assign('tags', $tempTags);
        $main->assign('body', $t_form->fetch('tag_cloud.tpl'));

        $tabText = 'Tag Cloud';
        break;
    case 'gettagmembers':
        $form = new Form($db, $login);
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter= '}-->';        

        $tagMembers = $form->getTagMembers($_GET['tag']);

        $t_form->assign('tag', strip_tags($_GET['tag']));
        $t_form->assign('totalNum', count($tagMembers));
        $t_form->assign('requests', $tagMembers);
        $main->assign('body', $t_form->fetch('tag_show_members.tpl'));
        
        $tabText = 'Tagged Requests';
        break;
    case 'about':
        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter= '}-->';
        
        $rev = $db->query("SELECT * FROM settings WHERE setting='dbversion'");
        $t_form->assign('dbversion', $rev[0]['data']);

        $main->assign('hideFooter', true);
        $main->assign('body', $t_form->fetch('view_about.tpl'));
        break;
    case 'search':
    	$main->assign('javascripts', array('js/form.js', 'js/formGrid.js', 'js/formQuery.js', 'js/formSearch.js'));
    	$main->assign('useUI', true);
        if($login->isLogin()) {
            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';

            $t_form->assign('orgchartPath', Config::$orgchartPath);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            
            $main->assign('body', $t_form->fetch(customTemplate('view_search.tpl')));
        }
        else {
            $t_login->assign('name', '');
            $main->assign('status', 'Your login session has expired, You must log in again.');
        }
        $o_login = $t_login->fetch('login.tpl');
        break;
    case 'reports':
    	$main->assign('stylesheets', array('css/report.css'));
       	$main->assign('javascripts', array('js/form.js', 'js/formGrid.js', 'js/formQuery.js', 'js/formSearch.js', 'js/lz-string/lz-string.min.js'));
       	$main->assign('useUI', true);
       	if($login->isLogin()) {
       		$o_login = $t_login->fetch('login.tpl');
       
       		$t_form = new Smarty;
       		$t_form->left_delimiter = '<!--{';
       		$t_form->right_delimiter= '}-->';
       
       		$t_form->assign('orgchartPath', Config::$orgchartPath);
       		$t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
       		$t_form->assign('query', $_GET['query']);
       		$t_form->assign('indicators', $_GET['indicators']);
       		$t_form->assign('title', $_GET['title']);
       		$t_form->assign('version', (int)$_GET['v']);
       
       		$main->assign('body', $t_form->fetch(customTemplate('view_reports.tpl')));
       	}
       	else {
       		$t_login->assign('name', '');
       		$main->assign('status', 'Your login session has expired, You must log in again.');
       	}
       	$o_login = $t_login->fetch('login.tpl');
       	$tabText = 'Report Builder';
       	break;
    case 'logout':
    	$login->logout();

    	$t_form = new Smarty;
    	$t_form->left_delimiter = '<!--{';
    	$t_form->right_delimiter= '}-->';

    	$main->assign('title', $settings['heading'] == '' ? $config->title : $settings['heading']);
    	$main->assign('city', $settings['subheading'] == '' ? $config->city : $settings['subheading']);
    	$main->assign('revision', $settings['version']);

    	$main->assign('body', $t_form->fetch(customTemplate('view_logout.tpl')));
    	$main->display(customTemplate('main.tpl'));
    	exit();
    	break;
    default:
    	$main->assign('javascripts', array('js/form.js', 'js/formGrid.js', 'js/formQuery.js', 'js/formSearch.js'));
    	$main->assign('useLiteUI', true);
        if($login->isLogin()) {
            $o_login = $t_login->fetch('login.tpl');

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter= '}-->';

            $t_form->assign('userID', $login->getUserID());
            $t_form->assign('empUID', $login->getEmpUID());
            $t_form->assign('empMembership', $login->getMembership());
            $t_form->assign('is_service_chief', $login->isServiceChief());
            $t_form->assign('is_quadrad', $login->isQuadrad() || $login->checkGroup(1));
            $t_form->assign('is_admin', $login->checkGroup(1));
            $t_form->assign('orgchartPath', Config::$orgchartPath);
            $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);
            
            $t_form->assign('tpl_search', customTemplate('view_search.tpl'));

            require_once 'Inbox.php';
            $inbox = new Inbox($db, $login);
            $t_form->assign('inbox_status', $inbox->getInboxStatus());
            
            $main->assign('body', $t_form->fetch(customTemplate('view_homepage.tpl')));

            if($action != 'menu' && $action != '' && $action != 'dosubmit') {
                $main->assign('status', 'The page you are looking for does not exist or may have been moved. Please update your bookmarks.');
            }
        }
        else {
            $t_login->assign('name', '');
            $main->assign('status', 'Your login session has expired, You must log in again.');
        }
        $o_login = $t_login->fetch('login.tpl');
        break;
}

$main->assign('login', $t_login->fetch('login.tpl'));
$t_menu->assign('action', $action);
$t_menu->assign('orgchartPath', Config::$orgchartPath);
$t_menu->assign('empMembership', $login->getMembership());
$o_menu = $t_menu->fetch(customTemplate('menu.tpl'));
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', $settings['heading'] == '' ? $config->title : $settings['heading']);
$main->assign('city', $settings['subheading'] == '' ? $config->city : $settings['subheading']);
$main->assign('revision', $settings['version']);

if(!isset($_GET['iframe'])) {
	$main->display(customTemplate('main.tpl'));
}
else {
	$main->display(customTemplate('main_iframe.tpl'));
}
