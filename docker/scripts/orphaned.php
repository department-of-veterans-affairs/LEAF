<?php

require_once '../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$output_file = fopen("orphan_query_log.txt", "w") or die("Unable to open output file.");

$query = "SELECT `site_path`, `portal_database` FROM `sites`
    WHERE `portal_database` IS NOT NULL
    AND `site_type` = 'portal'";

$portalrecords = $db->query($query);

$tables = array(
    "records_dependencies",
    "records_step_fulfillment",
    "records_workflow_state",
    "notes",
    "email_tracker",
    "data_history",
    "data",
    "category_count",
    "action_history",
    "signatures",
    "tags"
);

foreach ($portalrecords as $row) {
    $portal_site = $row['site_path'];
    $portal_db = $row['portal_database'];

    $db->query("USE `{$portal_db}`");

    foreach ($tables as $t) {
        try {
            $condQuery = "SELECT recordID FROM `$t`
                WHERE recordID NOT IN (SELECT recordID FROM records)";

            $orphans = $db->query($condQuery) ?? [];
            $totalIssues = count($orphans);

            if($totalIssues > 0) {
                fwrite(
                    $output_file,
                    "\r\nPath: ".$portal_site.", Database: ".$portal_db.", count: ".$totalIssues."\r\n"
                );
            }

        } catch (Exception $e) {
            fwrite($output_file, "Caught exception: ".$e->getMessage()."\r\n");
        }
    }
}
fclose($output_file);