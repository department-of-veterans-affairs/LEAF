<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once $currDir . '/../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

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

echo ini_get('memory_limit') . "\r\n";
if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {
        $currentFileName = $directory . $processQuery['id'] . '_' . $processQuery['userID'] . '.json';
        unlink($currentFileName);

        $vars = [
            ':id' => $processQuery['id']
        ];
        $db->prepared_query("DELETE FROM `process_query` WHERE id = :id", $vars);
    }
}
