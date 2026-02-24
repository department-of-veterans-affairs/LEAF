<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Refreshes employee data into local orgchart
*/

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$employee = new Orgchart\Employee($oc_db, $oc_login);

$employee->refreshBatch();