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

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

if (isset(LEAF_SETTINGS['timeZone'])) {
    date_default_timezone_set(LEAF_SETTINGS['timeZone']);
}

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

$group = new Portal\Group(DB, $login);

switch ($action) {
    case 'add_user_old':
        checkToken();

        $group->addMember($_POST['userID'], $_POST['groups']);

        break;
    case 'remove_user_old':
        // this should be deprecated as of 8/18/2023
        checkToken();

        $deleteList = XSSHelpers::scrubObjectOrArray(json_decode($_POST['json'], true));

        foreach ($deleteList as $del)
        {
            $group->removeMember(XSSHelpers::xscrub($del['userID']), $del['groupID']);
        }

        break;
    case 'add_user':
          checkToken();

           $group->addMember($_POST['userID'], $_POST['groupID']);

           break;
    case 'remove_user':
        // this should be deprecated as of 8/18/2023
           checkToken();

           $group->removeMember($_POST['userID'], $_POST['groupID']);

           break;
    case 'printview':
        if ($login->isLogin())
        {
            $form = new Portal\Form(DB, $login);

            $t_form = new Smarty;
            $t_form->left_delimiter = '<!--{';
            $t_form->right_delimiter = '}-->';
            $t_form->assign('recordID', (int)$_GET['recordID']);
            $t_form->assign('orgchartPath', $site_paths['orgchart_path']);

            $t_form->assign('form', $form->getFormByCategory($_GET['categoryID']));
            $t_form->display('print_form_ajax.tpl');
            $tabText = 'Form Editor';
        }

        break;
    case 'importForm':
        $formStack = new Portal\FormStack(DB, $login);
        $result = $formStack->importForm();

        echo $result;

        break;
    case 'manualImportForm':
           $formStack = new Portal\FormStack(DB, $login);
           $result = $formStack->importForm();

        if ($result === true)
        {   session_write_close();
            header('Location: ./?a=form');
            exit();
        }
        else
        {
            echo $result;
        }

           break;
    case 'uploadFile':
           $system = new Portal\System(DB, $login);
           $result = $system->newFile();
           if ($result === true)
           {
                session_write_close();
                header('Location: ./?a=mod_file_manager');
                exit();
           }
           else
           {
                echo $result;
           }

           break;
    case 'gethistoryall':
        $page = isset($_GET['page']) ? XSSHelpers::xscrub((int)$_GET['page']) : 1;
        $typeName = isset($_GET['type']) ? XSSHelpers::xscrub((string)$_GET['type']) : '';
        $gethistoryslice = isset($_GET['gethistoryslice']) ? XSSHelpers::xscrub((int)$_GET['gethistoryslice']) : 0;
        $tz = isset($_GET['tz']) ? $_GET['tz'] : null;

        if($tz == null){
            if(isset(LEAF_SETTINGS['timeZone'])) {
                $tz = LEAF_SETTINGS['timeZone'];
            } else {
                $tz = 'America/New_York';
            }
        }

        //pagination
        $pageLength = 6;

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('orgchartPath', $site_paths['orgchart_path']);

        $type = null;
        switch ($typeName) {
            case 'service':
                $dataName = "All Services";
                $type = new Portal\Service(DB, $login);
                break;
            case 'form':
                $dataName = "All Forms";
                $type = new Portal\FormEditor(DB, $login);
                break;
            case 'group':
                $dataName = "All Groups";
                $type = new Portal\Group(DB, $login);

                $orgchartGroup = new Orgchart\Group(OC_DB, $login);
                break;
        }

        /*
            First time around, gethistoryslice = false, so this loads view_history_all which calls
            this method again which loads view_history & displays it appropriately in the paginator
        */
        if($gethistoryslice)
        {

            $totalHistory = array();
            if(isset($orgchartGroup))
            {
                //special case for getting group history, since the only group tracked in portal is sysadmin
                $adminHistory = $type->getHistory(1);
                $adminHistory = $adminHistory ?? array();

                $allGroupHistory = $type->getHistory(null);
                $allGroupHistory = $allGroupHistory ?? array();

                $totalHistory = array_merge($allGroupHistory, $adminHistory);
                $type = $orgchartGroup;
            }

            usort($totalHistory, function($a, $b) {
                return $b['timestamp'] <=> $a['timestamp'];
            });

            $pageStart = ($page * $pageLength) - $pageLength;
            $totalHistorySlice = array_slice($totalHistory, $pageStart, $pageLength);
            $t_form->assign('dataType', ucwords($typeName));
            $t_form->assign('dataName', $dataName);
            $t_form->assign('history', $totalHistorySlice);
            $t_form->display('view_history.tpl');
        }
        else
        {
            $t_form->assign('dataType', $typeName);
            $t_form->display('view_history_all.tpl');
        }

        break;
    case 'gethistory':
        $typeName = isset($_GET['type']) ? XSSHelpers::xscrub((string)$_GET['type']) : '';
        $page = isset($_GET['page']) ? XSSHelpers::xscrub((int)$_GET['page']) : 1;
        $itemID = isset($_GET['id']) ? XSSHelpers::xscrub((string)$_GET['id']) : '';
        $tz = isset($_GET['tz']) ? $_GET['tz'] : null;
        $gethistoryslice = isset($_GET['gethistoryslice']) ? XSSHelpers::xscrub((int)$_GET['gethistoryslice']) : 0;

        if($tz == null){
            if(isset(LEAF_SETTINGS['timeZone'])) {
                $tz = LEAF_SETTINGS['timeZone'];
            } else {
                $tz = 'America/New_York';
            }
        }
        //pagination
        $pageLength = 6;

        $t_form = new Smarty;
        $t_form->left_delimiter = '<!--{';
        $t_form->right_delimiter = '}-->';

        $t_form->assign('orgchartPath', ABSOLUTE_ORG_PATH);

        $type = null;
        switch ($typeName) {
            case 'service':
                $type = new Portal\Service(DB, $login);
                $title = $type->getServiceName($itemID);
                break;
            case 'form':
                $type = new Portal\FormEditor(DB, $login);
                $title = $type->getFormName($itemID);
                break;
            case 'group':
                $type = new Portal\Group(DB, $login);
                $title = $type->getGroupName($itemID);
                break;
            case 'workflow':
                $type = new Portal\Workflow(DB, $login);
                $title = $type->getDescription($itemID);
                break;
            case 'primaryAdmin':
                $type = new Portal\System(DB, $login);
                $itemID = null;
                $title = 'Primary Admin';
                $t_form->assign('titleOverride', "Primary Admin History");
                break;
            case 'emailTemplate':
                $type = new Portal\EmailTemplate(DB, $login);
                $t_form->assign('titleOverride', ' ');
                break;
            case 'templateEditor':
                // this is depricated and should be removed once it has not been used in over 30 days
                $type = new Portal\Template(DB, $login);
                $t_form->assign('titleOverride', ' ');
                break;
            case 'TemplateReports':
                // this is depricated and should be removed once it has not been used in over 30 days
                $type = new Portal\Applet(DB, $login);
                $t_form->assign('titleOverride', ' ');
                break;
            case 'template':
                $type = new Portal\Template(DB, $login);
                $t_form->assign('titleOverride', ' ');
                break;
            case 'applet':
                $type = new Portal\Applet(DB, $login);
                $t_form->assign('titleOverride', ' ');
                break;
        }


        $resHistory = $type->getHistory($itemID);
        usort($resHistory, function($a, $b) {
            return $b['timestamp'] <=> $a['timestamp'];
        });

        for($i = 0; $i<count($resHistory); $i++){
            $dateInLocal = new DateTime($resHistory[$i]['timestamp'], new DateTimeZone('UTC'));
            $resHistory[$i]["timestamp"] = $dateInLocal->setTimezone(new DateTimeZone($tz))->format('F j, Y. g:i A');
            if (array_key_exists("targetUID", $resHistory[$i])) {
                $resHistory[$i]["targetEmpUID"] = $type->getEmployeeUserID($resHistory[$i]["targetUID"]);
            }
        }

        if($gethistoryslice)
        {
            $pageStart = ($page * $pageLength) - $pageLength;
            $totalHistorySlice = array_slice($resHistory, $pageStart, $pageLength);
            $t_form->assign('dataType', ucwords($typeName));
            $t_form->assign('dataName', $title);
            $t_form->assign('history', $totalHistorySlice);
            $t_form->display('view_history.tpl');
        }
        else
        {
            $totalPages = ceil(count($resHistory)/$pageLength);
            $t_form->assign('itemId', $itemID);
            $t_form->assign('totalPages', $totalPages);
            $t_form->assign('dataName', $title);
            $t_form->assign('dataType', $typeName);
            $t_form->display('view_history_paginated.tpl');
        }

        break;
    case 'checkstatus':
        checkToken();
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
