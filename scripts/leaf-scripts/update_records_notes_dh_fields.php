<?php

/**
 * The purpose of this script is a one-time update to prior values for portal table fields
 * records.userMetadata, notes.userMetadata and data_history.userDisplay from NULL to 
 * JSON of orgchart information (records, notes) or user firstname lastname (data_history). 
 * NULL values will be updated where the respective userID fields correspond to active orgchart accounts.
 */

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/../Leaf/Db.php';

$log_file = fopen("batch_update_records_notes_dh_log.txt", "w") or die("unable to open file");
$time_start = date_create();

$launch_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

//get records of each portal db.  Break out vdr for data_history updates.
$q = "SELECT `portal_database` FROM `sites` WHERE `portal_database` IS NOT NULL AND " .
    "`portal_database` != 'NATIONAL_101_vaccination_data_reporting' AND " .
    //"`portal_database` = 'Academy_Demo1' AND" .
    "`site_type`='portal' ORDER BY id";

$portal_records = $launch_db->query($q);
$launch_db->__destruct();

$total_portals_count = count($portal_records);
$processed_portals_count = 0;
$error_count = 0;

//get org info up front from national.
$orgchart_db = 'national_orgchart';
$orgchart_time_start = date_create();
$empMap = array();

try {
    $nat_org_db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $orgchart_db);

    $qEmployees = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email` FROM `employee`
        JOIN `employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
        WHERE `userName` NOT LIKE 'disabled_%' AND `indicatorID`=6";

    $resEmployees = $nat_org_db->query($qEmployees) ?? [];
    foreach($resEmployees as $emp) {
        $mapkey = strtoupper($emp['userName']);

        $isActive = $emp['deleted'] === 0;
        $empMap[$mapkey] = array(
            'userDisplay' => $isActive ? $emp['firstName'] . " " . $emp['lastName'] : "",
            'userMetadata' => json_encode(
                array(
                    'userName' => $isActive ? $emp['userName'] : '',
                    'firstName' => $isActive ? $emp['firstName'] : '',
                    'lastName' => $isActive ? $emp['lastName'] : '',
                    'middleName' => $isActive ? $emp['middleName'] : '',
                    'email' => $isActive ? $emp['email'] : '',
                )
            ),
        );
    }
    unset($resEmployees);
    $nat_org_db->__destruct();
    $orgchart_time_end = date_create();
    $orgchart_time_diff = date_diff($orgchart_time_start, $orgchart_time_end);

    fwrite(
        $log_file,
        "\r\nOrgchart " . $orgchart_db . " map info took: " . $orgchart_time_diff->format('%i min, %S sec, %f mcr') . "\r\n"
    );

} catch (Exception $e) {
    fwrite(
        $log_file,
        "Caught Exception (orgchart connect): " . $orgchart_db . " " . $e->getMessage() . "\r\n"
    );
    $portal_records = array();
}


$tables_to_update = [
    "notes",
    "records",
    "data_history"
];
$fields_to_update = array(
    "notes" => "userMetadata",
    "records" => "userMetadata",
    "data_history" => "userDisplay",
);

function getUniqueIDBatch(&$db, $batchcount = 0, $table_name):array {
    $limit = 1000;
    $offset = $limit * $batchcount;

    $SQL = "SELECT DISTINCT `userID` FROM `$table_name` ORDER BY `userID` LIMIT $limit OFFSET $offset";
    return $db->query($SQL) ?? [];
}

foreach($portal_records as $rec) {
    $portal_db = $rec['portal_database'];
    $pdb = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $portal_db);
    
    $batch_tracking = array(
        "notes" => 0,
        "records" => 0,
        "data_history" => 0,
    );
    $portal_time_start = date_create();
    fwrite(
        $log_file,
        "\r\nProcessing " . $portal_db
    );

    foreach ($tables_to_update as $table_name) {
        $field_name = $fields_to_update[$table_name];
        $table_time_start = date_create();
        fwrite(
            $log_file,
            "\r\n" . $table_name . ": "
        );

        $batchcount = 0;
        while(count($resUniqueIDsBatch = getUniqueIDBatch($pdb, $batchcount, $table_name)) > 0) {
            $batchcount += 1;
            $numIDs = count($resUniqueIDsBatch);

            $sqlUpdateMetadata = "UPDATE `$table_name`
                SET `$field_name` = CASE `userID` ";
            $metaVars = array();

            foreach ($resUniqueIDsBatch as $idx => $userRec) {
                $userInfo = $empMap[strtoupper($userRec['userID'])] ?? null;
                //If they are not in the orgchart map don't do anything.
                if(isset($userInfo) && isset($userInfo[$field_name])) {
                    $metaVars[":user_" . $idx] = $userRec['userID'];
                    $metaVars[":meta_" . $idx] = $userInfo[$field_name];
                    $sqlUpdateMetadata .= " WHEN :user_" . $idx . " THEN :meta_" . $idx;
                }
            }
            $sqlUpdateMetadata .= " END";
            $sqlUpdateMetadata .= " WHERE `$field_name` IS NULL";

            try {
                $pdb->prepared_query($sqlUpdateMetadata, $metaVars);
                $batch_tracking[$table_name] += 1;

                fwrite(
                    $log_file,
                    "batch " . $batchcount . "(" . $numIDs . ") "
                );

            } catch (Exception $e) {
                fwrite(
                    $log_file,
                    "Caught Exception (update case batch): " . $e->getMessage() . "\r\n"
                );
                $error_count += 1;
            }
        } // while remaining unique ids
        
        $table_time_end = date_create();
        $table_time_diff = date_diff($table_time_start, $table_time_end);

        fwrite(
            $log_file,
            "(" . $table_time_diff->format('%H hr, %i min, %S sec, %f mcr'). ")"
        );

    } //table loop end
    
    $pdb->query("FLUSH tables `notes`, `records`, `data_history`");
    $pdb->__destruct();

    $portal_time_end = date_create();
    $portal_time_diff = date_diff($portal_time_start, $portal_time_end);
    fwrite(
        $log_file,
        "\r\nPortal update took: " . $portal_time_diff->format('%H hr, %i min, %S sec, %f mcr') . "\r\n"
    );

    $processed_portals_count += 1;
    $update_details = "records: " . 
        $batch_tracking["records"] . ", notes: " . 
        $batch_tracking["notes"] . ", data_history: " . 
        $batch_tracking["data_history"];
    
    fwrite(
        $log_file,
        "Portal " . $portal_db . " (" . $processed_portals_count . "): table batches, " . $update_details  . "\r\n"
    );
}

$time_end = date_create();
$time_diff = date_diff($time_start, $time_end);

fwrite(
    $log_file,
    "\r\n-----------------------\r\nProcess took: " . $time_diff->format('%H hr, %i min, %S sec, %f mcr') . "\r\n".
    "total portals: " . $total_portals_count . ", portals processed: " . $processed_portals_count . ", error count: " . $error_count . "\r\n"
);
fclose($log_file);