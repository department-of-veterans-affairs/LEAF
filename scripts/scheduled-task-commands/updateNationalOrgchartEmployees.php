<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$sql = 'SELECT `cacheID`, LEFT(`data`, 5) AS `data`
        FROM `cache`
        WHERE LEFT(`data`, 3) = "DN,"';

$VISNS = $db->query($sql);

function updateEmps($VISNS) {
    foreach ($VISNS as $visn) {
        if (str_starts_with($visn['data'], 'DN,')) {
            exec("php /var/www/scripts/updateNationalOrgchart.php {$visn['cacheID']} > /dev/null 2>/dev/null &");
            echo "Deploying to: {$visn['cacheID']}\r\n";
        }
    }
}

updateEmps($VISNS);