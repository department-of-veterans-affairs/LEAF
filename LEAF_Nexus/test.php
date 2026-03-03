<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$login->loginUser();

$emp = new Orgchart\Employee($oc_db, $oc_login);

print_r($emp->search('gao'));
