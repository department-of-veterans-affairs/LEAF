<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

define('PREFIX', 'Update_RMC_DB_');
if (php_sapi_name() == 'cli')
{
    define('BR', "\r\n");
}
else
{
    define('BR', '<br />');
}
include '../../libs/loaders/Leaf_autoloader.php';

$res = $db->prepared_query('SELECT * FROM settings WHERE setting="dbversion"', array());
if (!isset($res[0]) || !is_numeric($res[0]['data']))
{
    exit();
}
$currentVersion = $res[0]['data'];
echo "Current Database Version: $currentVersion" . BR . BR;

clearstatcache();

$folder = '/var/www/db/db_upgrade/portal/';

$updates = scandir($folder);

$updateList = array();

foreach ($updates as $item)
{
    $versionRaw = substr($item, strlen(PREFIX . $currentVersion) - strlen($currentVersion));
    $tIdx = strpos($versionRaw, '-');
    $oldVer = substr($versionRaw, 0, $tIdx);
    $newVer = str_replace('.sql', '', substr($versionRaw, $tIdx + 1));
    if (is_numeric($oldVer))
    {
        $updateList[$oldVer] = $item;
    }
}

updateDB($currentVersion, $updateList, $folder, $db);

echo BR . BR . 'Complete.';

function updateDB($thisVer, $updateList, $folder, $db)
{
    if (isset($updateList[$thisVer]))
    {
        echo 'Update found: ' . $updateList[$thisVer] . BR;
        $update = file_get_contents($folder . $updateList[$thisVer]);
        echo 'Processing update... ';
        $db->prepared_query($update, array());
        echo ' ... Complete.' . BR;
        $res = $db->prepared_query('SELECT * FROM settings WHERE setting="dbversion"', array());
        if ($res[0]['data'] == $thisVer)
        {
            echo 'Update failed.' . BR;
        }
        else
        {
            echo "Database updated to: {$res[0]['data']}" . BR;
            updateDB($res[0]['data'], $updateList, $folder, $db);
        }
    }
}
