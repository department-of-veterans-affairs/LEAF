<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
define('PREFIX', 'Update_RMC_DB_');
if (php_sapi_name() == 'cli')
{
    define('BR', "\r\n");
}
else
{
    define('BR', '<br />');
}
$currDir = dirname(__FILE__);

include_once $currDir . '/../db_mysql.php';

if( empty($_SERVER['REMOTE_ADDR']) and !isset($_SERVER['HTTP_USER_AGENT']) and count($_SERVER['argv']) > 0) 
{
    if(count($argv) < 2)
    {
        echo "Portal Path must be passed.";
        die;
    }

    $path = '/' . rtrim(ltrim($argv[1], '/'), '/') . '/';//ensure leading and trailing slashes are in place 
    include_once $currDir . '/../../routing/routing_config.php';
    
    $routingDB = new DB(Routing_Config::$dbHost, Routing_Config::$dbUser, Routing_Config::$dbPass, Routing_Config::$dbName);
    $res = $routingDB->prepared_query('SELECT database_name FROM portal_configs WHERE path="'.$path.'"', array());
    
    if(count($res) == 0)
    {
        echo "Portal Path does not exist.";
        die;
    }
    
    $dbHost = Routing_Config::$dbHost;
    $dbUser = Routing_Config::$dbUser;
    $dbPass = Routing_Config::$dbPass;
    $dbName = $res[0]['database_name'];
}
else
{
    $dbHost = $db_config->dbHost;
    $dbUser = $db_config->dbUser;
    $dbPass = $db_config->dbPass;
    $dbName = $db_config->dbName;
}

$db = new DB($dbHost, $dbUser, $dbPass, $dbName);
//$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);

$res = $db->prepared_query('SELECT * FROM settings WHERE setting="dbversion"', array());
if (!isset($res[0]) || !is_numeric($res[0]['data']))
{
    exit();
}
$currentVersion = $res[0]['data'];
echo "Current Database Version: $currentVersion" . BR . BR;

clearstatcache();

$folder = $currDir . '/../utils/db_upgrade/';

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
