<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for Iframes
    Date Created: June 29, 2011

*/

error_reporting(E_ALL & ~E_NOTICE);

if (false)
{
    echo '<img src="../libs/dynicons/?img=dialog-error.svg&amp;w=96" alt="error" style="float: left" /><div style="font: 36px verdana">Site currently undergoing maintenance, will be back shortly!</div>';
    exit();
}

include 'globals.php';
include '../libs/smarty/Smarty.class.php';
include 'Login.php';
include 'db_mysql.php';
include 'db_config.php';
include 'form.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$db_config = new DB_Config();
$config = new Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);

$login->loginUser();
if (!$login->isLogin() || !$login->isInDB())
{
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

$action = isset($_GET['a']) ? XSSHelpers::xscrub($_GET['a']) : '';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

// HQ logo
if (strpos($_SERVER['HTTP_USER_AGENT'], 'MSIE 6'))
{ // issue with dijit tabcontainer and ie6
    $main->assign('status', 'You appear to be using Microsoft Internet Explorer version 6. Some portions of this website may not display correctly unless you use Internet Explorer version 7 or higher.');
}

$main->assign('logo', '<img src="images/VA_icon_small.png" style="width: 80px" alt="VA logo" />');

$t_login->assign('name', $login->getName());
$t_menu->assign('is_admin', $login->checkGroup(1));

$main->assign('useUI', false);

$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
if (isset($settings['timeZone']))
{
    date_default_timezone_set(XSSHelpers::xscrub($settings['timeZone']));
}

switch ($action) {
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
    case 'printview':
        $main->assign('useUI', true);
        $main->assign('javascripts', array('js/form.js', 'js/workflow.js', 'js/formGrid.js', 'js/formQuery.js', 'js/jsdiff.js'));

        $form = new Form($db, $login);
        $t_menu->assign('recordID', (int)$_GET['recordID']);
        $t_menu->assign('action', $action);
        $o_login = $t_login->fetch('login.tpl');

        $recordInfo = $form->getRecordInfo((int)$_GET['recordID']);
        $comments = $form->getActionComments((int)$_GET['recordID']);

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';
        $t_form->assign('orgchartPath', Config::$orgchartPath);
        $t_form->assign('is_admin', $login->checkGroup(1));
        $t_form->assign('recordID', (int)$_GET['recordID']);
        $t_form->assign('name', XSSHelpers::sanitizeHMTL($recordInfo['name']));
        $t_form->assign('title', XSSHelpers::sanitizeHTML($recordInfo['title']));
        $t_form->assign('priority', (int)$recordInfo['priority']);
        $t_form->assign('submitted', XSSHelpers::sanitizeHTML($recordInfo['submitted']));
        $t_form->assign('stepID', XSSHelpers::sanitizeHTML($recordInfo['stepID']));
        $t_form->assign('service', XSSHelpers::sanitizeHTML($recordInfo['service']));
        $t_form->assign('serviceID', (int)$recordInfo['serviceID']);
        $t_form->assign('date', XSSHelpers::sanitizeHTML($recordInfo['date']));
        $t_form->assign('deleted', (int)$recordInfo['deleted']);
        $t_form->assign('bookmarked', XSSHelpers::sanitizeHTML($recordInfo['bookmarked']));
        $t_form->assign('categories', $recordInfo['categories']);
        $t_form->assign('comments', $comments);
        $t_form->assign('CSRFToken', $_SESSION['CSRFToken']);

        if ($recordInfo['priority'] == -10)
        {
            $main->assign('emergency', '<span style="position: absolute; right: 0px; top: -28px; padding: 2px; border: 1px solid black; background-color: white; color: red; font-weight: bold; font-size: 20px">EMERGENCY</span> ');
        }

        //url
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $qrcodeURL = "{$protocol}://" . HTTP_HOST . $_SERVER['REQUEST_URI'];
        $main->assign('qrcodeURL', urlencode($qrcodeURL));

        switch ($action) {
            default:
                $childForms = $form->getChildForms((int)$_GET['recordID']);
                $t_form->assign('childforms', $childForms);

                if ($_GET['childCategoryID'] != '')
                {
                    $match = 0;
                    foreach ($childForms as $cForm)
                    {
                        if ($cForm['childCategoryID'] == $_GET['childCategoryID'])
                        {
                            $match = 1;
                        }
                    }
                    if ($match = 1)
                    {
                        // safe to pass in $_GET
                        $t_form->assign('childCategoryID', XSSHelpers::xscrub($_GET['childCategoryID']));
                    }
                }

                $main->assign('body', $t_form->fetch(customTemplate('print_form_iframe.tpl')));
                $t_menu->assign('hide_main_control', true);

                break;
        }

        $requestLabel = $settings['requestLabel'] == '' ? 'Request' : XSSHelpers::sanitizeHTML($settings['requestLabel']);
        $tabText = $requestLabel . ' #' . (int)$_GET['recordID'];

        break;
    case 'menu':
    default:
        if ($login->isLogin())
        {
            $o_login = $t_login->fetch('login.tpl');

            if ($action != 'menu' && $action != '' && $action != 'dosubmit')
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

$main->assign('login', $t_login->fetch('login.tpl'));
$o_menu = $t_menu->fetch('menu.tpl');
$main->assign('menu', $o_menu);
$tabText = $tabText == '' ? '' : $tabText . '&nbsp;';
$main->assign('tabText', $tabText);

$main->assign('title', $settings['heading'] == '' ? $config->title : XSSHelpers::sanitizeHTML($settings['heading']));
$main->assign('city', $settings['subHeading'] == '' ? $config->city : XSSHelpers::sanitizeHTML($settings['subHeading']));
$main->assign('revision', XSSHelpers::xscrub($settings['version']));

$main->display('main_iframe.tpl');
