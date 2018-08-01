<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

exit();
function oldFileHash($categoryID, $uid, $indicatorID, $fileName)
{
    // pre r2917 file hash function
    //$fileName = md5($fileName);

    // pre r2930
    $fileName = md5(sha1($fileName) . $categoryID . $uid . $indicatorID);

    return "{$categoryID}_{$uid}_{$indicatorID}_{$fileName}";
}

include '../sources/Login.php';
include '../db_mysql.php';
include '../config.php';

$config = new Orgchart\Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->setBaseDir('../');
$login->loginUser();

$uploadPath = '';
$queue = array();
clearstatcache();
if (strpos(Orgchart\Config::$uploadDir, '.') !== 0)
{
    $uploadPath = Orgchart\Config::$uploadDir;
    $queue = scandir(Orgchart\Config::$uploadDir);
}
else
{
    $uploadPath = '../' . Orgchart\Config::$uploadDir;
    $queue = scandir('../' . Orgchart\Config::$uploadDir);
}

foreach ($queue as $file)
{
    $exploded = explode('_', $file);
    if (is_numeric($exploded[0]))
    {
        $categoryID = $exploded[0];
        $uid = $exploded[1];
        $indicatorID = $exploded[2];
        $fileHash = $exploded[3];
        //echo $file . '<br />';
        $type = null;
        $res = null;
        switch ($categoryID) {
            case 1:
                include_once '../sources/Employee.php';
                $type = new OrgChart\Employee($db, $login);

                break;
            case 2:
                include_once '../sources/Position.php';
                $type = new OrgChart\Position($db, $login);

                break;
            case 3:
                include_once '../sources/Group.php';
                $type = new OrgChart\Group($db, $login);

                break;
            default:
                break;
        }

        $res = $type->getAllData($uid, $indicatorID);

        if (is_array($res[$indicatorID]['data']))
        {
            foreach ($res[$indicatorID]['data'] as $dbFile)
            {
                if ($file == oldFileHash($categoryID, $uid, $indicatorID, $dbFile))
                {
                    $oldName = $uploadPath . $file;
                    $newName = $uploadPath . $type->getFileHash($categoryID, $uid, $indicatorID, $dbFile);
                    echo 'Renaming: ' . $oldName . ' to ' . $newName . '... ';
                    copy($oldName, $newName);
                    unlink($oldName);
                    echo 'Renamed. <br />';
                }
            }
        }
        else
        {
            $dbFile = $res[$indicatorID]['data'];
            if ($file == oldFileHash($categoryID, $uid, $indicatorID, $dbFile))
            {
                $oldName = $uploadPath . $file;
                $newName = $uploadPath . $type->getFileHash($categoryID, $uid, $indicatorID, $dbFile);
                echo 'Renaming: ' . $oldName . ' to ' . $newName . '... ';
                copy($oldName, $newName);
                unlink($oldName);
                echo 'Renamed. <br />';
            }
        }
    }
}
