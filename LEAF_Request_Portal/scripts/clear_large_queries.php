<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
error_reporting(E_ALL ^ E_WARNING);

$currDir = dirname(__FILE__);


require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$protocol = 'https';
$request_uri = str_replace(['/var/www/html/', '/scripts'], '', $currDir);
$siteRoot = "{$protocol}://" . HTTP_HOST . '/' . $request_uri . '/';
$directory = __DIR__ . '/../files/temp/processedQuery/';
$login->setBaseDir('../');
$login->loginUser();
$dir = new Portal\VAMC_Directory;

$form = new Portal\Form($db, $login);
$vars = [];
$processQueryTotalSQL = 'SELECT id,userID FROM process_query';
$processQueryTotalRes = $db->prepared_query($processQueryTotalSQL, $vars);
// make sure our memory limit did not get reduced, we need to make sure we are not having scripts take it all up.

$email = new Portal\Email();
$email->setSiteRoot($siteRoot);

if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {
        $currentFileName = $directory . $processQuery['id'] . '_' . $processQuery['userID'] . '.json';
        if(is_file($currentFileName)){
            unlink($currentFileName);
        }

        // do we want to actually delete this? if the query is called again in the future it will trigger the email again.
        $vars = [
            ':id' => $processQuery['id']
        ];
        $db->prepared_query("DELETE FROM `process_query` WHERE id = :id", $vars);
    }
}