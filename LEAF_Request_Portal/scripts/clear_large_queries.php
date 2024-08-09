<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
error_reporting(E_ALL ^ E_WARNING);

$currDir = dirname(__FILE__);

require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';
require_once APP_PATH . '/Leaf/Email.php';
$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');



$vars = [];
$processQueryTotalSQL = 'SELECT id,userID FROM process_query';
$processQueryTotalRes = $db->prepared_query($processQueryTotalSQL, $vars);
// make sure our memory limit did not get reduced, we need to make sure we are not having scripts take it all up.

if (!empty($processQueryTotalRes)) {

    foreach ($processQueryTotalRes as $processQuery) {

        // remove the previous file
        $currentFileName = $directory . $processQuery['id'] . '_' . $processQuery['userID'] . '.json';
        if (is_file($currentFileName)) {
            unlink($currentFileName);
        }

        // do we want to actually delete this? if the query is called again in the future it will trigger the email again.
        $vars = [
            ':id' => $processQuery['id']
        ];
        $db->prepared_query("DELETE FROM `process_query` WHERE id = :id", $vars);
    }
}
