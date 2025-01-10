<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Refreshes employee data into local orgchart
*/
exit(); // need this to stop the cron job on staging will remove once job has stopped.
require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$employee = new Orgchart\Employee($oc_db, $oc_login);

$employee->refreshBatch();