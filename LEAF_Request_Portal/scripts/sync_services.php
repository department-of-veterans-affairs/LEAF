<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$login->loginUser();

$employee = new Orgchart\Employee($oc_db, $login);
$group = new Orgchart\Group($oc_db, $login);
$position = new Orgchart\Position($oc_db, $login);
$tag = new Orgchart\Tag($oc_db, $login);

$group_portal = new Portal\Group($db, $login);
$service_portal = new Portal\Service($db, $login);
$system_portal = new Portal\System($db, $login);
$syncing = $system_portal->syncSystem($group, $site_paths);

echo $syncing;