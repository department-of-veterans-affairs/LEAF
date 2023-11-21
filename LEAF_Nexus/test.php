<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->loginUser();

$emp = new Orgchart\Employee(OC_DB, $oc_login);

print_r($emp->search('gao'));
