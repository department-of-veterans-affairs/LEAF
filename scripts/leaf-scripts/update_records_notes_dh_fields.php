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

//get records of each portal. Keeping order the same as prev script
$q = "SELECT `portal_database` FROM `sites`
    WHERE `portal_database` IS NOT NULL AND
	`portal_database` != 'NATIONAL_101_vaccination_data_reporting' AND
	`site_type`='portal' ORDER BY BINARY `orgchart_database`";

$portal_records = $db->query($q);
$total_portals_count = count($portal_records);
$processed_portals_count = 0;
$error_count = 0;

//used to limit update queries
$caselimit = 1000;

//get org info up front from national.
$empMap = array();
$orgchart_db = 'national_orgchart';
$orgchart_time_start = date_create();

try {
    //************ ORGCHART ************
    //map out required metadata up front for users in national_orgchart
    $db->query("USE `{$orgchart_db}`");

    $qEmployees = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email` FROM `employee`
        JOIN `employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
        WHERE `indicatorID`=6";

    $resEmployees = $db->query($qEmployees) ?? [];
    foreach($resEmployees as $emp) {
        $mapkey = strtoupper($emp['userName']);

        $isActive = $emp['deleted'] === 0;
        $mapInfo = array(
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
        $empMap[$mapkey] = $mapInfo;
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


foreach($portal_records as $rec) {
    $portal_db = $rec['portal_database'];
	$resUniqueIDs = array();
	$numIDs = 0;
	$curr_ids_slice = array();
	$sqlUpdateMetadata = '';
	$metaVars = array();

    try {
        $db->query("USE `{$portal_db}`");
        $update_tracking = array(
            "notes" => 0,
            "records" => 0,
            "data_history" => 0,
        );

        /* loop through the tables to be updated */
        foreach ($tables_to_update as $table_name) {
			$resUniqueIDs = array();
			$numIDs = 0;
			$curr_ids_slice = array();
			$sqlUpdateMetadata = '';
			$metaVars = array();

            $field_name = $fields_to_update[$table_name];
            try {
                $usersQ = "SELECT DISTINCT `userID` FROM `$table_name` WHERE `$field_name` IS NULL";

                $resUniqueIDs = $db->query($usersQ) ?? [];
                $numIDs = count($resUniqueIDs);
                if($numIDs > 0) {
                    $portal_time_start = date_create();

                    fwrite(
                        $log_file,
                        "\r\nUnique " . $table_name . " userID count for " . $portal_db . ": " . $numIDs . "\r\n"
                    );

                    $totalBatches = intdiv($numIDs, $caselimit);
                    foreach(range(0, $totalBatches) as $batchcount) {
                        //This will include the last partial batch. New records don't matter.  array, offset, limit
                        $curr_ids_slice = array_slice($resUniqueIDs, $batchcount * $caselimit, $caselimit);

                        //Build limited CASE statement for each batch
                        $sqlUpdateMetadata = "UPDATE `$table_name`
                            SET `$field_name` = CASE `userID` ";

                        $metaVars = array();
                        foreach ($curr_ids_slice as $idx => $userRec) {
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
                            $db->prepared_query($sqlUpdateMetadata, $metaVars);
                            $update_tracking[$table_name] += 1;

                            fwrite(
                                $log_file,
                                $table_name . " ... batch: " . $batchcount
                            );

                        } catch (Exception $e) {
                            fwrite(
                                $log_file,
                                "Caught Exception (update case batch): " . $e->getMessage() . "\r\n"
                            );
                            $error_count += 1;
                        }
                        
                        //seems like it should be ok, but reset these to make sure they clear out of memory
                        $sqlUpdateMetadata = '';
                        $metaVars = array();
						$curr_ids_slice = array();
                    }
                    
                    $portal_time_end = date_create();
                    $portal_time_diff = date_diff($portal_time_start, $portal_time_end);

                    fwrite(
                        $log_file,
                        "\r\nPortal " . $table_name . " update took: " . $portal_time_diff->format('%H hr, %i min, %S sec, %f mcr') . "\r\n"
                    );
                }

            } catch (Exception $e) {
                fwrite(
                    $log_file,
                    "Caught Exception (query distinct userIDs): " . $e->getMessage() . "\r\n"
                );
                $error_count += 1;
            }
        
        } //table loop end
        
        $processed_portals_count += 1;

        $update_details = "records: " . $update_tracking["records"] . ", notes: " . $update_tracking["notes"] . ", data_history: " . $update_tracking["data_history"];
        fwrite(
            $log_file,
            "Portal " . $portal_db . " (" . $processed_portals_count . "): table batches, " . $update_details  . "\r\n"
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
unset($db);