<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for everything
    Date: September 11, 2007

*/

use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

if (isset(LEAF_SETTINGS['timeZone'])) {
    date_default_timezone_set(XSSHelpers::xscrub(LEAF_SETTINGS['timeZone']));
}


$oc_login->loginUser();

$type = null;
switch ($_GET['categoryID']) {
    case 1:    // employee
        $type = new Orgchart\Employee(OC_DB, $oc_login);

        break;
    case 2:    // position
        $type = new Orgchart\Position(OC_DB, $oc_login);

        break;
    case 3:    // group
        $type = new Orgchart\Group(OC_DB, $oc_login);

        break;
    default:
        return false;
}

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    case 'doupload': // handle file upload
        $uploadOk = true;
        $uploadedFilename = '';
        foreach ($_FILES as $file)
        {
            if ($file['error'] != UPLOAD_ERR_OK)
            {
                $uploadOk = false;
            }
            $uploadedFilename = $file['name'];
        }

        // wrap output in html for dojo
        echo '<html><body><textarea>';

        if ($uploadOk)
        {
            try
            {
                if ($type->modify($_GET['UID']))
                {
                    echo "{$uploadedFilename} has been attached!";
                }
                else
                {
                    echo 'File extension may not be supported.';
                }
            }
            catch (Exception $e)
            {
                echo $e->getMessage();
            }
        }
        else
        {
            $errorCode = '';
            switch ($file['error']) {
                case UPLOAD_ERR_INI_SIZE:
                    $errorCode = 'The uploaded file exceeds the maximum server filesize limit.';

                    break;
                case UPLOAD_ERR_FORM_SIZE:
                    $errorCode = 'The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form';

                    break;
                case UPLOAD_ERR_PARTIAL:
                    $errorCode = 'The uploaded file was only partially uploaded, please try again.';

                    break;
                case UPLOAD_ERR_NO_FILE:
                    $errorCode = 'No file was selected to be attached.';

                    break;
                case UPLOAD_ERR_NO_TMP_DIR:
                    $errorCode = 'Missing a temporary folder';

                    break;
                case UPLOAD_ERR_CANT_WRITE:
                    $errorCode = 'Failed to write file to disk';

                    break;
                case UPLOAD_ERR_EXTENSION:
                    $errorCode = 'File upload stopped by extension';

                    break;
                default:
                    $errorCode = 'Unknown upload error';

                    break;
            }
        }
        // wrap output in html for dojo
        echo '</textarea></body></html>';

        break;
    case 'deleteattachment':
        echo $type->deleteAttachment($_POST['categoryID'], $_POST['UID'], $_POST['indicatorID'], $_POST['file']);

        break;
    case 'gethistory':
        $t_form = getSmarty();
        $itemID = isset($_GET['itemID']) ? (int)$_GET['itemID'] : 0;
        $tz = isset($_GET['tz']) ? $_GET['tz'] : null;

        if($tz == null){
            if (isset(LEAF_SETTINGS['timeZone'])) {
                $tz = LEAF_SETTINGS['timeZone'];
            } else {
                $tz = 'America/New_York';
            }
        }

        if ($itemID != 0)
        {
            $resHistory = $type->getHistory($itemID);

            $t_form->assign('dataType', $type->getDataTableDescription());
            $t_form->assign('dataID', $itemID);
            $t_form->assign('dataName', $type->getTitle($itemID));

            $resHistory = $resHistory ?? array();

            for($i = 0; $i<count($resHistory); $i++){
                $dateInLocal = new DateTime($resHistory[$i]['timestamp'], new DateTimeZone('UTC'));
                $resHistory[$i]["timestamp"] = $dateInLocal->setTimezone(new DateTimeZone($tz))->format('Y-m-d H:i:s T');;
            }


            $t_form->assign('history', $resHistory);

            $t_form->display('view_history.tpl');
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

function getSmarty(){

    $t_form = new Smarty;
    $t_form->left_delimiter = '<!--{';
    $t_form->right_delimiter = '}-->';

    return $t_form;
}
