<?php

/*
Intended for one-time update to foreign key constraint names
that are inconsistent with the current schema.
*/

require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '/../Leaf/Db.php';

$log_file = fopen("constraint_update_log.txt", "w") or die("unable to open file");

//NOTE: confirm entries reflect local dev, since that should have initial boiler plus subsequent DB updates
$constraints_to_update = array(
    "portal" => array(
        /*
        CONSTRAINT `route_events_ibfk_1` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`),
        CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`) ON DELETE CASCADE ON UPDATE CASCADE
        */
        "route_events" => array(
            "route_events_ibfk_1" => array(
                "correctName" => "route_events_ibfk_1",
                "foreignTable" => "actions",
                "foreignKey" => "actionType",
                "constraint" => "ON DELETE RESTRICT ON UPDATE RESTRICT",
            ),
            "route_events_ibfk_2" => array(
                "correctName" => "route_events_ibfk_2",
                "foreignTable" => "events",
                "foreignKey" => "eventID",
                "constraint" => "ON DELETE CASCADE ON UPDATE CASCADE",
            ),
        ),
        /*
        CONSTRAINT `workflow_routes_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`),
        CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`)
        */
        "workflow_routes" => array(
            "workflow_routes_ibfk_1" => array(
                "correctName" => "workflow_routes_ibfk_1",
                "foreignTable" => "workflows",
                "foreignKey" => "workflowID",
                "constraint" => "ON DELETE RESTRICT ON UPDATE RESTRICT",
            ),
            "workflow_routes_ibfk_3" => array(
                "correctName" => "workflow_routes_ibfk_3",
                "foreignTable" => "actions",
                "foreignKey" => "actionType",
                "constraint" => "ON DELETE RESTRICT ON UPDATE RESTRICT",
            ),
        )
    ),
    "orgchart" => array(),
);

//args for site type (portal or orgchart) and table name are required
//add --dry-run flag to preview changes
//eg php script.php portal route_events --dry-run

$dry_run = false;
$filtered_argv = [];
foreach ($argv as $arg) {
    if ($arg === '--dry-run') {
        $dry_run = true;
    } else {
        $filtered_argv[] = $arg;
    }
}

if(
    count($filtered_argv) < 3 ||
    !isset($constraints_to_update[$filtered_argv[1]]) ||
    !isset($constraints_to_update[$filtered_argv[1]][$filtered_argv[2]])
    ) {
    fwrite(
        $log_file,
        "Invalid args given: site type and defined table required" . PHP_EOL
    );
    return;
}

$site_type = $filtered_argv[1];
$tname = $filtered_argv[2];

$time_start = date_create();

$db = new App\Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$table_entries = $constraints_to_update[$site_type][$tname];

foreach($table_entries as $entry) {
    $hasName = array();
    $correctName = $entry['correctName'];
    $ft = $entry['foreignTable'];
    $fk = $entry['foreignKey'];
    $infoConstraint = $entry['constraint'];

    fwrite(
        $log_file,
        "Checking " . $tname . " for " . $correctName . PHP_EOL
    );

    $v = array(
        ':tname' => $tname,
        ':ft' => $ft,
        ':fk' => $fk,
        ':correctName' => $correctName,
    );

    $qmissing = "SELECT CONSTRAINT_NAME, CONSTRAINT_SCHEMA
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE table_name=:tname
        AND REFERENCED_TABLE_NAME=:ft AND REFERENCED_COLUMN_NAME=:fk
        AND CONSTRAINT_NAME!=:correctName";

    $qexists = "SELECT CONSTRAINT_SCHEMA
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE table_name=:tname
        AND REFERENCED_TABLE_NAME=:ft AND REFERENCED_COLUMN_NAME=:fk
        AND CONSTRAINT_NAME=:correctName";
 
    //constraint for correct table, foreign table, foreign key but not correct name
    $recordsToUpdate = $db->prepared_query($qmissing, $v) ?? [];

    //add existing correct names to tracker in case alternate name(s) exists
    $recordsNameExists = $db->prepared_query($qexists, $v) ?? [];
    foreach($recordsNameExists as $exists) {
        $d = $exists['CONSTRAINT_SCHEMA'];
        $hasName[$d] = 1;
    }

    $records_count = count($recordsToUpdate);
    $processed_count = 0;
    $error_count = 0;

    foreach($recordsToUpdate as $rec) {
        $rec_db = $rec['CONSTRAINT_SCHEMA'];
        $current_name = $rec['CONSTRAINT_NAME'];
        
        try {
            $db->query("USE `{$rec_db}`");

            $db->query("START TRANSACTION");

            if ($dry_run) {
                fwrite(
                    $log_file,
                    "[DRY RUN] Would drop constraint " . $current_name . " from " . $rec_db . PHP_EOL
                );

            } else {
                $db->query("ALTER TABLE `{$tname}` DROP FOREIGN KEY `{$current_name}`");

                fwrite(
                    $log_file,
                    "Dropped constraint " . $current_name . " from " . $rec_db  . PHP_EOL
                );
            }

            if(!isset($hasName[$rec_db])) {
                if($dry_run) {
                    fwrite(
                        $log_file,
                        "[DRY RUN] Would add constraint " . $correctName . " to " . $rec_db . " (" . $ft . "," . $fk . ")" . PHP_EOL
                    );

                } else {
                    $db->query(
                        "ALTER TABLE `{$tname}` ADD CONSTRAINT `{$correctName}` 
                        FOREIGN KEY (`{$fk}`) REFERENCES `{$ft}` (`{$fk}`) {$infoConstraint}"
                    );

                    fwrite(
                        $log_file,
                        "Added constraint " . $correctName . " to " . $rec_db  . PHP_EOL
                    );
                }
                $hasName[$rec_db] = 1;
            }
            $db->query("COMMIT");

            $processed_count += 1;

        } catch (Exception $e) {
            fwrite(
                $log_file,
                "Caught Exception (portal use): DB " . $rec_db . ", MSG " . $e->getMessage() . PHP_EOL
            );
            $error_count += 1;
        }
    }

    //Get records of dbs based on site type and check constraint names are accounted for.
    //They should have been present to begin with or added after dropping other name.
    try {
        $db->query("USE `national_leaf_launchpad`");

        $v = array(':site_type' => $site_type);
        $q = "SELECT `portal_database`, `orgchart_database` FROM `sites`
            WHERE :site_type IS NOT NULL AND
            `site_type`=:site_type";

        $db_records = $db->prepared_query($q, $v);
        $db_missing_name = array();

        foreach($db_records as $rec) {
            $d = $site_type === 'portal' ?
                $rec['portal_database'] : $rec['orgchart_database'];

            if(!isset($hasName[$d])) {
                $db_missing_name[$d] = 1;
            }
        }

        foreach($db_missing_name as $key => $value) {
            try {
                $db->query("USE `{$key}`");
                $db->query("START TRANSACTION");

                if ($dry_run) {
                    fwrite(
                        $log_file,
                        "[DRY RUN] Would add missing constraint " . $correctName . " to " . $key . " (" . $ft . "," . $fk . ")" . PHP_EOL
                    );

                } else {
                    $db->query(
                        "ALTER TABLE `{$tname}` ADD CONSTRAINT `{$correctName}` 
                        FOREIGN KEY (`{$fk}`) REFERENCES `{$ft}` (`{$fk}`) {$infoConstraint}"
                    );

                    fwrite(
                        $log_file,
                        "Added constraint " . $correctName . " to " . $key . PHP_EOL
                    );
                }
                $db->query("COMMIT");

            } catch (Exception $e) {
                fwrite(
                    $log_file,
                    "Caught Exception (portal use): DB " . $key . ", MSG " . $e->getMessage() . PHP_EOL
                );
                $error_count += 1;
            }
        }
    
    } catch (Exception $e) {
        fwrite(
            $log_file,
            "Caught Exception (use launchpad): DB " . $e->getMessage() . PHP_EOL
        );
        $error_count += 1;
    }
}


$time_end = date_create();
$time_diff = date_diff($time_start, $time_end);
$ftime_diff = $time_diff->format('%H hr, %i min, %S sec, %f mcr');

fwrite(
    $log_file,
    "-----------------------" . PHP_EOL . 
    "Process took: " . $ftime_diff . PHP_EOL .
    "total portals: " . $records_count . ", portals processed: " . $processed_count . ", error count: " . $error_count . PHP_EOL
);

fclose($log_file);