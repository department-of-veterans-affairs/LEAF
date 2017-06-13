<?php
/************************
    Index for Iframes
    Date Created: June 29, 2011

*/

error_reporting(E_ALL & ~E_NOTICE);

if(false) {
    echo '<img src="../libs/dynicons/?img=dialog-error.svg&amp;w=96" alt="error" style="float: left" /><div style="font: 36px verdana">Site currently undergoing maintenance, will be back shortly!</div>';
    exit();
}

include '../libs/smarty/Smarty.class.php';
include 'Login.php';
include 'db_mysql.php';
include 'db_config.php';
include 'form.php';

$db_config = new DB_Config();
$config = new Config();

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
    echo 'Your login is not recognized. This system is locked to the following groups:<br /><pre>';
    print_r($config->adPath);
    echo '</pre>';
    exit;
}

$main = new Smarty;
$t_login = new Smarty;
$t_menu = new Smarty;
$o_login = '';
$o_menu = '';
$tabText = '';

$action = isset($_GET['a']) ? $_GET['a'] : '';

// HQ logo
if(strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 6')) { // issue with dijit tabcontainer and ie6
    $main->assign('status', 'You appear to be using Microsoft Internet Explorer version 6. Some portions of this website may not display correctly unless you use Internet Explorer version 7 or higher.');
}

$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

$t_login->assign('name', $login->getName());
$t_menu->assign('is_admin', $login->checkGroup(1));

$main->assign('useUI', false);

$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
if(isset($settings['timeZone'])) {
	date_default_timezone_set($settings['timeZone']);
}

switch($action) {
    case 'getuploadprompt':
        $t_iframe = new Smarty;

        $t_iframe->assign('recordID', (int)$_GET['recordID']);
        $t_iframe->assign('indicatorID', (int)$_GET['indicatorID']);
        $t_iframe->assign('series', (int)$_GET['series']);
        $t_iframe->assign('max_filesize', ini_get('upload_max_filesize'));
        $t_iframe->assign('CSRFToken', $_SESSION['CSRFToken']);
        $main->assign('body', $t_iframe->fetch('file_form.tpl'));
        break;
    case 'getimageuploadprompt':
       	$t_iframe = new Smarty;

       	$t_iframe->assign('recordID', (int)$_GET['recordID']);
       	$t_iframe->assign('indicatorID', (int)$_GET['indicatorID']);
       	$t_iframe->assign('series', (int)$_GET['series']);
       	$t_iframe->assign('max_filesize', ini_get('upload_max_filesize'));
       	$t_iframe->assign('CSRFToken', $_SESSION['CSRFToken']);
       	$main->assign('body', $t_iframe->fetch('file_image_form.tpl'));
       	break;
    case 'menu':
    default:
        if($login->isLogin()) {
            $o_login = $t_login->fetch('login.tpl');

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
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', $settings['heading'] == '' ? $config->title : $settings['heading']);
$main->assign('city', $settings['subheading'] == '' ? $config->city : $settings['subheading']);
$main->assign('revision', $settings['version']);

$main->display('main_iframe.tpl');
