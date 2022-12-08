<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include '../libs/loaders/Leaf_autoloader.php';

$login->loginUser();

include './sources/Employee.php';

$emp = new Orgchart\Employee($oc_db, $oc_login);

print_r($emp->search('gao'));
