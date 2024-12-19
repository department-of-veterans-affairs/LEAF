<?php
use App\Leaf\DbUpdate;
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$update = new DbUpdate($db, $setting_up, 'orgchart', PORTAL_PATH);

$update->run();

echo $update->getMessage();