<?php
require_once 'globals.php';
require_once LIB_PATH . '/php-commons/Db.php';

// national_orgchart for stage/live leaf_user for dev
$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_orgchart');

$vars = [
    ':lastUpdated' => strtotime('-2 weeks')
    //':lastUpdated' => 1623606681
];

$sql = "SELECT empUID, userName, lastUpdated FROM `employee` Where `lastUpdated` > 0 and `lastUpdated` < :lastUpdated and `deleted` = 0";

$employees = $db->prepared_query($sql,$vars);

// set this all to the same to help with when things were deleted.
$deletedTime = time();
foreach( $employees as $employee ){

    // we could use a bit of the logic from checkLastLogin.php to see if the user has been logged in recently. 

    $employeeVars = [
        ':empUID' => $employee['empUID'],
        ':deleted' => $deletedTime
    ];
    $employeeSql = 'UPDATE `employee` SET `deleted`=:deleted WHERE empUID=:empUID';
    $db->prepared_query($employeeSql, $employeeVars);
}
