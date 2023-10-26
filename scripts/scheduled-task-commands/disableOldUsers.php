<?php
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';

// national_orgchart for stage/live leaf_user for dev
$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$employeeVars = [
    ':lastUpdated' => strtotime('-1 week'),
    ':deleted' => time()
];
$employeeSql = 'UPDATE `employee` SET `deleted`=:deleted WHERE `lastUpdated` > 0 and `lastUpdated` < :lastUpdated and `deleted` = 0';
$db->prepared_query($employeeSql, $employeeVars);
