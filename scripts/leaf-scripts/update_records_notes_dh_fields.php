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
$tables_to_update = ["notes", "records", "data_history"];
$fields_to_update = array(
    "notes" => "userMetadata",
    "records" => "userMetadata",
    "data_history" => "userDisplay",
);

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

//get records of each portal and assoc orgchart
$q = "SELECT `portal_database`, `orgchart_database` FROM `sites`
    WHERE `portal_database` IS NOT NULL AND `site_type`='portal' ORDER BY `orgchart_database`";

$portal_records = $db->query($q);

$total_portals_count = count($portal_records);
$processed_portals_count = 0;

$error_count = 0;

//used during update query to limit query
$caselimit = 2500;
$empMap = array();

$orgchart_db = null;
foreach($portal_records as $rec) {

    //get org info up front for each new orgchart db.  reset and update empmap if changed
    if(!isset($orgchart_db) || $orgchart_db !==  $rec['orgchart_database']) {
        $empMap = array();
        $orgchart_db = $rec['orgchart_database'];
        $orgchart_time_start = date_create();

        try {
            //************ ORGCHART ************ */
            $db->query("USE `{$orgchart_db}`");

            $qEmployees = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email` FROM `employee`
                JOIN `employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
                WHERE `indicatorID`=6";

            $resEmployees = $db->query($qEmployees) ?? [];
            foreach($resEmployees as $emp) {
                $mapkey = strtoupper($emp['userName']);
                $empMap[$mapkey] = $emp;
            }

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
            $error_count += 1;
        }
    }

    $portal_db = $rec['portal_database'];

    try {
        //************ PORTAL ************ */
        $db->query("USE `{$portal_db}`");
        $update_tracking = array(
            "notes" => 0,
            "records" => 0,
            "data_history" => 0,
        );

        /* loop through the tables to be updated */
        foreach ($tables_to_update as $table_name) { //NOTE: table loop start
            $field_name = $fields_to_update[$table_name];

            try {
                $usersQ = "SELECT DISTINCT `userID` FROM `$table_name` WHERE `$field_name` IS NULL";

                $resUniqueIDs = $db->query($usersQ) ?? [];
                $numIDs = count($resUniqueIDs);

                if($numIDs > 0) {
                    $portal_db = $rec['portal_database'];
                    $portal_time_start = date_create();

                    fwrite(
                        $log_file,
                        "\r\nUnique " . $table_name . " userID count for " . $portal_db . ": " . $numIDs . "\r\n"
                    );

                    $totalBatches = intdiv($numIDs, $caselimit);
                    foreach(range(0, $totalBatches) as $batchcount) { //this will include the last partial batch
                        $curr_ids_slice = array_slice($resUniqueIDs, $batchcount * $caselimit, $caselimit);

                        //build and exec CASE statement for each batch
                        $sqlUpdateMetadata = "UPDATE `$table_name`
                            SET `$field_name` = CASE `userID` ";

                        $metaVars = array();
                        foreach ($curr_ids_slice as $idx => $userRec) {
                            $userInfo = $empMap[strtoupper($userRec['userID'])] ?? null;
                            /* If they are not in the orgchart info at all just don't do anything. If they are there but explicitly deleted 
                            set empty metadata properties (info is not being used for inactive accounts since we don't want to assume accuracy) */
                            if(isset($userInfo)) {
                                $isActive = $userInfo['deleted'] === 0;

                                if($table_name === "data_history") {
                                    $metadata = $isActive ?  $userInfo['firstName'] . " " . $userInfo['lastName'] : "";
                                } else {
                                    $metadata = json_encode(
                                        array(
                                            'userName' => $isActive ? $userInfo['userName'] : '',
                                            'firstName' => $isActive ? $userInfo['firstName'] : '',
                                            'lastName' => $isActive ? $userInfo['lastName'] : '',
                                            'middleName' => $isActive ? $userInfo['middleName'] : '',
                                            'email' => $isActive ? $userInfo['email'] : ''
                                        )
                                    );
                                }

                                $metaVars[":user_" . $idx] = $userInfo['userName'];
                                $metaVars[":meta_" . $idx] = $metadata;
                                $sqlUpdateMetadata .= " WHEN :user_" . $idx . " THEN :meta_" . $idx;
                            }
                        }

                        $sqlUpdateMetadata .= " END";
                        $sqlUpdateMetadata .= " WHERE `$field_name` IS NULL";

                        try {
                            $db->prepared_query($sqlUpdateMetadata, $metaVars);
                            $update_tracking[$table_name] += 1;

                            fwrite(
                                $log_file,
                                $table_name . " ... batch: " . $batchcount
                            );

                        } catch (Exception $e) {
                            fwrite(
                                $log_file,
                                "Caught Exception (update action_history usermetadata case batch): " . $e->getMessage() . "\r\n"
                            );
                            $error_count += 1;
                        }
                    }
                    
                    $portal_time_end = date_create();
                    $portal_time_diff = date_diff($portal_time_start, $portal_time_end);

                    fwrite(
                        $log_file,
                        "\r\nPortal " . $table_name . " update took: " . $portal_time_diff->format('%i min, %S sec, %f mcr') . "\r\n"
                    );

                }

            } catch (Exception $e) {
                fwrite(
                    $log_file,
                    "Caught Exception (query distinct ah userIDs): " . $e->getMessage() . "\r\n"
                );
                $error_count += 1;
            }
        
        } //NOTE: table loop end

        $processed_portals_count += 1;
        $update_details = "records: " . $update_tracking["records"] . ", notes: " . $update_tracking["notes"] . ", data_history: " . $update_tracking["data_history"];
        fwrite(
            $log_file,
            "Portal " . $portal_db . " tables updated(1/0), " . $update_details  . "\r\n"
        );




    } catch (Exception $e) {
        fwrite(
            $log_file,
            "Caught Exception (use portal connect): " . $e->getMessage() . "\r\n"
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