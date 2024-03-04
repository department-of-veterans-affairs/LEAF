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

$login->setBaseDir('../');
$login->loginUser();

$uploadPath = '';
$queue = array();
clearstatcache();
if (strpos($oc_site_paths['site_uploads'], '.') !== 0)
{
    $uploadPath = $oc_site_paths['site_uploads'];
    $queue = scandir($oc_site_paths['site_uploads']);
}
else
{
    $uploadPath = '../' . $oc_site_paths['site_uploads'];
    $queue = scandir('../' . $oc_site_paths['site_uploads']);
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
                $type = new Orgchart\Employee(OC_DB, $login);

                break;
            case 2:
                $type = new Orgchart\Position(OC_DB, $login);

                break;
            case 3:
                $type = new Orgchart\Group(OC_DB, $login);

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
