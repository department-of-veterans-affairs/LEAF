<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

require_once '../globals.php';
require_once LIB_PATH . 'loaders/Leaf_autoloader.php';

$login->setBaseDir('../');
$login->loginUser();

$dal = new Leaf\DataActionLogger($db, $login);
$employee = new Orgchart\Employee($oc_db, $oc_login);
$group = new Orgchart\Group($oc_db, $oc_login);
$position = new Orgchart\Position($oc_db, $oc_login);
$tag = new Orgchart\Tag($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($employee, $group);

$group_portal = new Portal\Group($db, $login, $dal, $employee, $vamc);
$service_portal = new Portal\Service($db, $login, $dal, $employee, $vamc);
$system_portal = new Portal\System($db, $login, $vamc);
$syncing = $system_portal->syncSystem($group_portal, $service_portal, $group, $employee, $tag, $position, $settings['importTags']);

echo $syncing;