<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$login->loginUser();

$employee = new Orgchart\Employee(OC_DB, $login);
$group = new Orgchart\Group(OC_DB, $login);
$position = new Orgchart\Position(OC_DB, $login);
$tag = new Orgchart\Tag(OC_DB, $login);

$group_portal = new Portal\Group(DB, $login);
$service_portal = new Portal\Service(DB, $login);
$system_portal = new Portal\System(DB, $login);
$syncing = $system_portal->syncSystem($group);

echo $syncing;