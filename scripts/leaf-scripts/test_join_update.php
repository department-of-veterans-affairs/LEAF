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
    "`portal_database` = 'Academy_Demo1' AND " .
    "`site_type`='portal'";

$portal_records = $db->query($q);
$total_portals_count = count($portal_records);
$processed_portals_count = 0;
$error_count = 0;


//make a temp table to store the required information from national
$orgchart_time_start = date_create();

$temp_table_name = "`national_leaf_launchpad`.`temp_orgchart_info_table`";
$db->query("
    CREATE TEMPORARY TABLE $temp_table_name (
        `userID` varchar(50) NOT NULL,
        `userDisplay` varchar(90) DEFAULT NULL,
        `userMetadata` json DEFAULT NULL
    )"
);

function getOrgchartBatch(&$db, $batchcount = 0):array {
    $limit = 10000;
    $offset = $limit * $batchcount;

    //get info from enabled accounts.
    $SQL = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email`
    FROM `national_orgchart`.`employee`
    JOIN `national_orgchart`.`employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
    WHERE `deleted`=0 AND `indicatorID`=6 ORDER BY empUID LIMIT $limit OFFSET $offset ";

    return $db->query($SQL) ?? [];
}

try {
    $batchcount = 0;
    while(count($resEmployees = getOrgchartBatch($db, $batchcount)) > 0) {
        $batchcount += 1;
        $sql = "INSERT INTO $temp_table_name (`userID`, `userDisplay`, `userMetadata`) VALUES ";
        $vars = array();
        foreach($resEmployees as $idx => $emp) {
            $vars[":userID_$idx"] = $emp['userName'];
            $vars[":userDisplay_$idx"] = $emp['firstName'] . " " . $emp['lastName'];
            $vars[":userMetadata_$idx"] = json_encode(
                array(
                    'userName' => $emp['userName'],
                    'firstName' => $emp['firstName'],
                    'lastName' => $emp['lastName'],
                    'middleName' => $emp['middleName'],
                    'email' => $emp['email']
                )
            );
            $sql .= "(:userID_$idx, :userDisplay_$idx, :userMetadata_$idx),";
        }
        $sql = trim($sql, ',');

        $db->prepared_query($sql, $vars);
        unset($sql);
        unset($vars);
    }
    $orgchart_time_end = date_create();
    $orgchart_time_diff = date_diff($orgchart_time_start, $orgchart_time_end);

    fwrite(
        $log_file,
        "\r\nTemp table prep took: " . $orgchart_time_diff->format('%i min, %S sec, %f mcr') . "\r\n"
    );

} catch (Exception $e) {
    fwrite(
        $log_file,
        "Caught Exception (temp table prep): " . $e->getMessage() . "\r\n"
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

//join version requires ordering
function getUniqueIDBatch(&$db, $batchcount = 0, $table_name):array {
    $limit = 200;
    $offset = $limit * $batchcount;
    $SQL = "SELECT DISTINCT `userID` FROM `$table_name` ORDER BY `userID` LIMIT $limit OFFSET $offset";
    return $db->query($SQL) ?? [];
}

foreach($portal_records as $rec) {
    $portal_db = $rec['portal_database'];

    try {
        $batch_tracking = array(
            "notes" => 0,
            "records" => 0,
            "data_history" => 0,
        );
        fwrite(
            $log_file,
            "\r\nProcessing " . $portal_db
        );
        $portal_time_start = date_create();
        foreach ($tables_to_update as $table_name) {
            $field_name = $fields_to_update[$table_name];
            fwrite(
                $log_file,
                "\r\n" . $table_name . ": "
            );

            $batchcount = 0;
            while(count($resUniqueIDsBatch = getUniqueIDBatch($db, $batchcount, $table_name)) > 0) {
                $batchcount += 1;
                $batch_tracking[$table_name] += 1;
                
                $SQLupdate = "UPDATE `$portal_db`.$table_name A
                    LEFT JOIN $temp_table_name B
                    ON A.userID = B.userID
                    SET A.$field_name = B.$field_name
                    WHERE A.$field_name IS NULL";

                try {
                    $db->query($SQLupdate);

                    fwrite(
                        $log_file,
                        "batch " . $batchcount - 1 . " (" . count($resUniqueIDsBatch) . "), "
                    );

                } catch (Exception $e) {
                    fwrite(
                        $log_file,
                        "Caught Exception updating " . $portal_db ." table: " . $table_name . " " . $e->getMessage() . "\r\n"
                    );
                    $error_count += 1;
                }
            }
        }

        $processed_portals_count += 1;
        $update_details = "records: " . $batch_tracking["records"] .
            ", notes: " . $batch_tracking["notes"] .
            ", data_history: " . $batch_tracking["data_history"] . "\r\n";
        fwrite(
            $log_file,
            "\r\nPortal " . $portal_db . " (" . $processed_portals_count . "): table batches, " . $update_details
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