<?php
use App\Leaf\DbUpdate;
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

$update = new DbUpdate($db, $setting_up, 'portal', PORTAL_PATH);

$update->run();

echo $update->getMessage();