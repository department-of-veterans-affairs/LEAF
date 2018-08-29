<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for legacy ajax endpoints
    Date Created: September 11, 2007

*/

/* TODO:
1. prevent double submits
2. clean up
*/
error_reporting(E_ALL & ~E_NOTICE);

include '../../libs/smarty/Smarty.class.php';
include '../Login.php';
include '../db_mysql.php';
include '../db_config.php';

// Enforce HTTPS
include_once '../enforceHTTPS.php';

$db_config = new DB_Config();
$config = new Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');

$login->loginUser();
if (!$login->checkGroup(1))
{
    echo 'You must be in the administrator group to access this section.';
    exit();
}

function checkToken()
{
    if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
    {
        echo 'Invalid Token.';
        exit();
    }
}

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    case 'add_user_old':
        checkToken();
        require 'Group.php';

        $group = new Group($db, $login);
        $group->addMember($_POST['userID'], $_POST['groups']);

        break;
    case 'remove_user_old':
        checkToken();
        require 'Group.php';

        $deleteList = json_decode($_POST['json'], true);

        $group = new Group($db, $login);
        foreach ($deleteList as $del)
        {
            $group->removeMember($del['userID'], $del['groupID']);
        }

        break;
    case 'add_user':
          checkToken();
           require 'Group.php';

           $group = new Group($db, $login);
           $group->addMember($_POST['userID'], $_POST['groupID']);

           break;
    case 'remove_user':
           checkToken();
           require 'Group.php';

           $group = new Group($db, $login);
           $group->removeMember($_POST['userID'], $_POST['groupID']);

           break;
    case 'printview':
        if ($login->isLogin())
        {
            require '../form.php';
            $form = new Form($db, $login);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('recordID', (int)$_GET['recordID']);
            $t_form->assign('orgchartPath', Config::$orgchartPath);

            $t_form->assign('form', $form->getFormByCategory($_GET['categoryID']));
            $t_form->display('print_form_ajax.tpl');
            $tabText = 'Form Editor';
        }

        break;
    case 'importForm':
        require '../sources/formStack.php';
        $formStack = new FormStack($db, $login);
        $result = $formStack->importForm();

        echo $result;

        break;
    case 'manualImportForm':
           require '../sources/formStack.php';
           $formStack = new FormStack($db, $login);
           $result = $formStack->importForm();

        if ($result === true)
        {
            header('Location: ./?a=form');
        }
        else
        {
            echo $result;
        }

           break;
    case 'uploadFile':
           require '../sources/System.php';
           $system = new System($db, $login);
           $result = $system->newFile();
           if ($result === true)
           {
               header('Location: ./?a=mod_file_manager');
           }
           else
           {
               echo $result;
           }

           break;
    default:
        /*
        echo "Action: $action<br /><br />Catchall...<br /><br />POST: <pre>";
        print_r($_POST);
        echo "</pre><br /><br />GET:<pre>";
        print_r($_GET);
        echo "</pre><br /><br />FILES:<pre>";
        print_r($_FILES);
        echo "</pre>";
        */
        break;
}
