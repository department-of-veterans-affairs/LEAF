<?php
require_once getenv('APP_LIBS_PATH') . '/globals.php';
require_once getenv('APP_LIBS_PATH') . '../Leaf/Db.php';

$startTime = microtime(true);

$db = new Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

$portals = $db->query("SELECT `portal_database` FROM `sites` WHERE `site_type` = 'portal'");

foreach ($portals as $portal) {
    // Initialize record destruction counter
    $count = 0;

    // Switch to portal in list
    $db->query("USE `{$portal['portal_database']}`");

    // Grab the categoryID's that have a destructionAge
    $catStrSQL = "SELECT categoryID, destructionAge FROM categories WHERE destructionAge IS NOT NULL";
    $catForDestruction = $db->query($catStrSQL);

    if (count($catForDestruction) > 0) {
        foreach ($catForDestruction as $category) {
            // Calculate and convert destructionAge to epoch timestamp
            $destructionTime = strtotime("-{$category['destructionAge']} days");

            // Get records matching destructionAge time
            $catVars = array(':destructionTime' => $destructionTime,
                ':categoryID' => $category['categoryID']);
            $prelimStrSQL = "SELECT recordID FROM records " .
                "LEFT JOIN records_step_fulfillment USING (recordID) " .
                "LEFT JOIN category_count USING (recordID) " .
                "WHERE ((submitted > 0 AND submitted <= :destructionTime) OR (deleted > 0 AND deleted <= :destructionTime)) " .
                "AND (fulfillmentTime IS NULL OR fulfillmentTime <= :destructionTime) " .
                "AND (categoryID = :categoryID AND count > 0) " .
                "AND recordID NOT IN (SELECT DISTINCT recordID FROM records_workflow_state) " .
                "AND recordID NOT IN (SELECT recordID FROM category_count
                                    WHERE count > 0
                                    GROUP BY recordID
                                    HAVING count(recordID) > 1) " .
                "GROUP BY recordID";
            $prelimRes = $db->prepared_query($prelimStrSQL, $catVars);

            foreach ($prelimRes as $record) {
                // Delete Record
                $deleteVars = array(':recordID' => $record['recordID']);
                $deleteStrSQL = "DELETE FROM records WHERE recordID=:recordID";
                $db->prepared_query($deleteStrSQL, $deleteVars);

                // Log Deletion
                $logVars = array(':recordID' => $record['recordID'],
                    ':categoryID' => $category['categoryID']);
                $logStrSQL = "INSERT INTO destruction_log (recordID, categoryID, destructionTime) ".
                            "VALUES (:recordID, :categoryID, UNIX_TIMESTAMP())";
                $db->prepared_query($logStrSQL, $logVars);

                echo "{$record['recordID']} Deleted\r\n";

                $count++;
            }
        }
        echo "{$portal['portal_database']}: {$count} records deleted.\r\n";
    } else {
        echo "No Destruction for {$portal['portal_database']}\r\n";
    }
}

$endTime = microtime(true);
$timeInMinutes = round(($endTime - $startTime) / 60, 2);
echo "Destruction took {$timeInMinutes} minutes\r\n";
echo date('Y-m-d g:i:s a') . "\r\n";
