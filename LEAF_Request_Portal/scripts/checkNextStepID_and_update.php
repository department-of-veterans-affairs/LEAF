<?php

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/../Leaf/Db.php';

/**
 * update recordIDs stuck at step -1
 * @param recordIDs string of comma sep record IDs to update
 */
function update_stepID_minus_one($recordIDs) {
	$vars = array(':recordIDs' => $recordIDs);
	$res = $this->db->prepared_query('UPDATE records SET
		submitted=0, isWritableUser=1, lastStatus="Re-opened for editing"
		WHERE FIND_IN_SET(recordID, :recordIDs)', $vars);

	$res = $this->db->prepared_query('UPDATE records_dependencies SET
		filled=0 WHERE FIND_IN_SET(recordID, :recordIDs)', $vars);
	// delete state
	$this->db->prepared_query('DELETE FROM records_workflow_state
		WHERE FIND_IN_SET(recordID, :recordIDs)', $vars);
}

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');


$log_file = fopen("nextStepID_log.txt", "w") or die("unable to open file");
$time_start = date_create();

//get records of db for each portal
$q = "SELECT `portal_database` FROM `sites`
    WHERE `portal_database` IS NOT NULL AND `site_type`='portal'";

$portal_records = $db->query($q);
$total = count($portal_records);

$pcount = 0;
$issues = 0;
foreach($portal_records as $rec) {
    $portal_db = $rec['portal_database'];

    try {
        //************ PORTAL ************ */
        $db->query("USE `{$portal_db}`");

        //look for next step -1 and workflow routes that have a next step of -1
        //these can be independent of each other since wf could have been updated or requests might not be stuck yet
        try {
            $sql_routes = "SELECT `workflowID`, `stepID`, `nextStepID` FROM `workflow_routes` WHERE `nextStepID`=-1";
            $res_routes = $db->query($sql_routes) ?? [];

            $sql_rws = "SELECT `recordID` FROM `records_workflow_state` WHERE `stepID`=-1";
            $resStuck = $db->query($sql_rws) ?? [];

            $pcount += 1;
            if(count($res_routes) > 0 || count($resStuck) > 0) {
                $issues += 1;
                fwrite(
                    $log_file,
                    "\r\ncheck routes and requests for " . $portal_db . "\r\n"
                );

                //fix stuck requests
                if(count($resStuck) > 0) {
                    $recordIDsArr = array_column($resStuck, 'recordID');
                    $recordIDsSet = implode(',', $recordIDsArr);

                    update_stepID_minus_one($recordIDs);
                }

                //fix workflow route next step ID setting
                if (count($res_routes) > 0) {
                    $sql_update = "UPDATE workflow_routes SET nextStepID = 0 WHERE nextStepID = -1 AND actionType = 'sendback'"
                    $db->query($sql_update) ?? [];
                }
            }

        } catch (Exception $e) {
            fwrite(
                $log_file,
                "Caught Exception (query workflow routes): " . $e->getMessage() . "\r\n"
            );
        }

    } catch (Exception $e) {
        fwrite(
            $log_file,
            "Caught Exception (portal connect): " . $e->getMessage() . "\r\n"
        );
    }
}

$time_end = date_create();
$time_diff = date_diff($time_start, $time_end);

fwrite(
    $log_file,
    "\r\ntotal: ". $total .", count: ". $pcount. ", issues: ". $issues ."\r\nProcess took: " . $time_diff->format('%i min, %S sec, %f mcr') . "\r\n"
);

fclose($log_file);