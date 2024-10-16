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

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

//get records of each portal db.  Break out vdr for data_history updates.
$q = "SELECT `portal_database` FROM `sites` WHERE `portal_database` IS NOT NULL AND " .
    //"`portal_database` != 'NATIONAL_101_vaccination_data_reporting' AND " .
    //"`portal_database` = 'Academy_Demo1' AND" .
    "`site_type`='portal' ORDER BY id";

$portal_records = $db->query($q);

$total_portals_count = count($portal_records);
$processed_portals_count = 0;
$error_count = 0;

//get org info for enabled users from national.
$orgchart_db = 'national_orgchart';
$orgchart_time_start = date_create();
$empMap = array();

function getOrgchartBatch(&$db, $batch_count = 0) {
    $limit = 50000; //tested in adminer and handles this size ok
    $offset = $batch_count * $limit;

    $qEmployees = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email` FROM `employee`
        JOIN `employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
        WHERE `deleted`=0 AND `indicatorID`=6 ORDER BY `employee`.`empUID` LIMIT $limit OFFSET $offset";

    return $db->query($qEmployees) ?? [];
}

try {
    $db->query("USE `{$orgchart_db}`");

    $org_batch = 0;
    while(count($resEmployees = getOrgchartBatch($db, $org_batch)) > 0) {
        $org_batch += 1;
    
        foreach($resEmployees as $emp) {
            $mapkey = strtoupper($emp['userName']);
            $empMap[$mapkey] = array(
                'userDisplay' => $emp['firstName'] . " " . $emp['lastName'],
                'userMetadata' => json_encode(
                    array(
                        'userName' => $emp['userName'],
                        'firstName' => $emp['firstName'],
                        'lastName' => $emp['lastName'],
                        'middleName' => $emp['middleName'],
                        'email' => $emp['email']
                    )
                ),
            );
        }
    }
    unset($resEmployees);

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
$json_empty = json_encode(
    array(
        "userName" => "",
        "firstName" => "",
        "lastName" => "",
        "middleName" => "",
        "email" => ""
    )
);
$user_not_found_values = array(
    "userMetadata" => $json_empty,
    "userDisplay" => "",
);



function getUniqueIDBatch(&$db, $table_name, $field_name):array {
    $getLimit = $table_name == 'data_history' ? 15000 : 10000;

    $SQL = "SELECT `userID` FROM `$table_name` WHERE `$field_name` IS NULL LIMIT $getLimit";
    $records = $db->query($SQL) ?? [];

    //removing duplicates here since using DISTINCT complicates the query
    $mapAdded = array();
    foreach ($records as $rec) {
        $userID = strtoupper($rec['userID']);
        if(!isset($mapAdded[$userID])) {
            $mapAdded[$userID] = 1;
        }
    }
    return array_keys($mapAdded);
}

foreach($portal_records as $rec) {
    $portal_db = $rec['portal_database'];
    try {
        $db->query("USE `{$portal_db}`");

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

            $id_batch = 0;
            //simple array of upper case userID strings
            while(count($resUniqueIDsBatch = getUniqueIDBatch($db, $table_name, $field_name)) > 0) {
                $id_batch += 1;

                $case_batch = 0;
                //records and notes will usually not have high numbers of rows per user.  VDR had known lower data/user ratio
                $case_high = $table_name != 'data_history' || $portal_db == 'NATIONAL_101_vaccination_data_reporting';
                $case_limit = $case_high ? 1000 : 500;
                while(count($slice = array_slice($resUniqueIDsBatch, $case_batch * $case_limit, $case_limit))) {
                    $sqlUpdateMetadata = "UPDATE `$table_name` SET `$field_name` = CASE `userID` ";
                    $metaVars = array();
                    $case_batch += 1;
                    foreach ($slice as $idx => $userID) {
                        //use mapped info if present, otherwise use empty values.
                        $userInfo = $empMap[$userID] ?? null;
                        $metaVars[":user_" . $idx] = $userID;
                        $metaVars[":meta_" . $idx] = isset($userInfo) ?
                            $userInfo[$field_name] : $user_not_found_values[$field_name];

                        $sqlUpdateMetadata .= " WHEN :user_" . $idx . " THEN :meta_" . $idx;
                    }
                    $sqlUpdateMetadata .= " END";
                    $sqlUpdateMetadata .= " WHERE `$field_name` IS NULL LIMIT 20000;";
                    //Limit to prevent high data/user ratio resulting in mass updates.
                    //~10-15% portals (staging) have over 20k dh rows.  
                    //records not updated due to limit will be re-pulled by another batch of nulls

                    try {
                        $db->prepared_query($sqlUpdateMetadata, $metaVars);
                        $batch_tracking[$table_name] += 1;

                        fwrite(
                            $log_file,
                            $id_batch . "(" . $case_batch . "," . count($slice) . "), "
                        );

                    } catch (Exception $e) {
                        fwrite(
                            $log_file,
                            "Caught Exception (update case batch): " . $e->getMessage() . "\r\n"
                        );
                        $error_count += 1;
                    }
                } //while remaining unprocessed unique IDs from ID batch


            } //while remaining un-updated ids in table
            
            $table_time_end = date_create();
            $table_time_diff = date_diff($table_time_start, $table_time_end);

            fwrite(
                $log_file,
                "(" . $table_time_diff->format('%H hr, %i min, %S sec, %f mcr'). ")"
            );

        } //table loop end

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

    } catch (Exception $e) {
        fwrite(
            $log_file,
            "Caught Exception (portal use): " . $portal_db . " " . $e->getMessage() . "\r\n"
        );
        $error_count += 1;
    }
}

$time_end = date_create();
$time_diff = date_diff($time_start, $time_end);

fwrite(
    $log_file,
    "\r\n-----------------------\r\nProcess took: " . $time_diff->format('%H hr, %i min, %S sec, %f mcr') . "\r\n".
    "total portals: " . $total_portals_count . ", portals processed: " . $processed_portals_count . ", error count: " . $error_count . "\r\n"
);

fclose($log_file);