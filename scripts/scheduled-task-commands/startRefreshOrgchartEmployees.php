<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$sql = 'SELECT `site_path`
        FROM `sites`
        WHERE `site_type` = "orgchart"';

$orgcharts = $db->query($sql);

function updateEmps($orgcharts) {
    foreach ($orgcharts as $orgchart) {
        exec("php refreshOrgchartEmployeesNew.php {$orgchart['site_path']} > /dev/null 2>/dev/null &");
        echo "Refreshing: {$orgcharts['site_path']}\r\n";
    }
}

updateEmps($orgcharts);