<?php

/**
 * Potentially needed for dev / local for mysql data volumes older than Jul 2024.
 * Run in fpm container to update data.metadata field associated with orgchart_employee format data.
 * Requires portal dbversion 2024052000 or higher.
 */

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/../Leaf/Db.php';

$log_file = fopen("update_metadata_log.txt", "w") or die("unable to open file");
$time_start = date_create();

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'leaf_portal');


$portal_db = 'leaf_portal';
$orgchart_db = 'leaf_users';

try {
    //************ PORTAL ************ */
    $db->query("USE `{$portal_db}`");

    //get distinct data (empUID) entries from orghcart_employee format indicators that don't have metadata
    try {
        $dataQ = "SELECT DISTINCT `data` as `empUID_Data` FROM `data`
            JOIN `indicators` on `data`.`indicatorID`=`indicators`.`indicatorID`
            WHERE `indicators`.`format`='orgchart_employee' AND metadata IS NULL";

        $resUniqueIDs = $db->query($dataQ) ?? [];
        $numEmpUIDs = count($resUniqueIDs);

        if($numEmpUIDs > 0) {
            fwrite(
                $log_file,
                "\r\nUnique data empUID count for " . $portal_db . ": " . $numEmpUIDs . "\r\n-----------------------\r\n"
            );

            try {
                //switch to orgchart and get needed info for these IDs
                //************ ORGCHART ************ */
                $db->query("USE `{$orgchart_db}`");

                $inEmpsArr = array_column($resUniqueIDs, 'empUID_Data');
                $inEmpsSet = implode(',', $inEmpsArr);

                $v = array(':inEmpsSet' => $inEmpsSet);

                $qEmployee = "SELECT `employee`.`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `deleted`, `data` AS `email` FROM `employee`
                    JOIN `employee_data` ON `employee`.`empUID`=`employee_data`.`empUID`
                    WHERE `indicatorID`=6 AND FIND_IN_SET(`employee`.`empUID`, :inEmpsSet)";

                try {
                    $resEmployeeInfo = $db->prepared_query($qEmployee, $v) ?? [];

                    //************ switch to PORTAL to update metadata ************ */
                    $db->query("USE `{$portal_db}`");

                    //build CASE statement for org_emp indicators
                    $sqlUpdateMetadata = "UPDATE `data`
                        SET `metadata` = CASE `data` ";

                    $metaVars = array();
                    foreach ($resEmployeeInfo as $idx => $emp) {
                        $isActive = $emp['deleted'] === 0;
                        $metadata = json_encode(
                            array(
                                'userName' => $isActive ? $emp['userName'] : '',
                                'firstName' => $isActive ? $emp['firstName'] : '',
                                'lastName' => $isActive ? $emp['lastName'] : '',
                                'middleName' => $isActive ? $emp['middleName'] : '',
                                'email' => $isActive ? $emp['email'] : ''
                            )
                        );
                        $metaVars[":emp_" . $idx] = $emp['empUID'];
                        $metaVars[":meta_" . $idx] = $metadata;
                        $sqlUpdateMetadata .= " WHEN :emp_" . $idx . " THEN :meta_" . $idx;
                    }

                    $sqlUpdateMetadata .= " END";
                    $sqlUpdateMetadata .= " WHERE `indicatorID` IN (
                        SELECT `indicatorID` FROM `indicators`
                            WHERE `indicators`.`format`='orgchart_employee' AND `metadata` IS NULL
                        )";

                    try {
                        $db->prepared_query($sqlUpdateMetadata, $metaVars);

                    } catch (Exception $e) {
                        fwrite(
                            $log_file,
                            "Caught Exception (update metadata case): " . $e->getMessage() . "\r\n"
                        );
                    }

                } catch (Exception $e) {
                    fwrite(
                        $log_file,
                        "Caught Exceptioni (query employee join employee_data): " . $e->getMessage() . "\r\n"
                    );
                }

            } catch (Exception $e) {
                fwrite(
                    $log_file,
                    "Caught Exception (orgchart connect): " . $e->getMessage() . "\r\n"
                );
            }
        }

    } catch (Exception $e) {
        fwrite(
            $log_file,
            "Caught Exception (query distinct data): " . $e->getMessage() . "\r\n"
        );
    }

} catch (Exception $e) {
    fwrite(
        $log_file,
        "Caught Exception (portal connect): " . $e->getMessage() . "\r\n"
    );
}

$time_end = date_create();
$time_diff = date_diff($time_start, $time_end);

fwrite(
    $log_file,
    "\r\n-----------------------\r\nProcess took: " . $time_diff->format('%i min, %S sec, %f mcr') . "\r\n"
);

fclose($log_file);