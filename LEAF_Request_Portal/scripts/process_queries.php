<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once '../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$login->loginUser();


$form = new Portal\Form($db, $login);


