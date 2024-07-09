<?php
// this file will need to be added, Pete's destruction ticket has it already.
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$sql = 'SELECT `cacheID`, `data`
        FROM `cache`';

$VISNS = $db->query($sql);

foreach ($VISNS as $visn) {
    if (str_starts_with($visn['data'], 'DN,')) {
        $response = exec('php ../updateNationalOrgchart.php ' . $visn['cacheID']);
    }
}
