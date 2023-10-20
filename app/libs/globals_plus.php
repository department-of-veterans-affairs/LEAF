<?php
session_start();
/*
    This file is needed because there are instances where one of the defined global variables is needed but the
    autoloader isn't loaded on that particular page. So this will be loaded on those pages only.

    We need to extract the portal url from the SCRIPT_FILENAME so we can get the data from the sites table.
    There are times where there is another folder tacked on to the end of the url, in those cases that folder
    needs to be striped from the url

    i.e. /Academy/Demo1/admin
    I decided it best to put this into a class and have the class deal with it to keep this file clean
*/

use App\Leaf\GlobalSession;
use App\Leaf\Model\GlobalSession as ModelGlobalSession;
use App\Leaf\Model\Site as ModelSite;
use App\Leaf\Site;

require_once getenv('APP_PATH') . '/Leaf/Db.php';
require_once getenv('APP_PATH') . '/Leaf/Site.php';
require_once getenv('APP_PATH') . '/Leaf/Model/Site.php';
require_once getenv('APP_PATH') . '/Leaf/GlobalSession.php';
require_once getenv('APP_PATH') . '/Leaf/Model/GlobalSession.php';

$file_paths_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');
$modelSite = new ModelSite($file_paths_db);
$model_global_sessions = new ModelGlobalSession($file_paths_db);
$global_sessions = new GlobalSession($model_global_sessions);

$site = new Site($modelSite, $global_sessions, $_SERVER['SCRIPT_FILENAME'], $_SESSION['CSRFToken']);

if ($site->error) {
    throw new Exception("Sorry the page you are looking for could not be found, please check the url and try again.");
} else {
    $my_path = $site->getPortalPath();
    if (!defined('PORTAL_PATH')) define('PORTAL_PATH', $my_path);
    if (!defined('LEAF_NEXUS_URL')) define('LEAF_NEXUS_URL', getenv('APP_URL_NEXUS') . trim($my_path) . '/');
    $site_paths = $site->getSitePath();
}