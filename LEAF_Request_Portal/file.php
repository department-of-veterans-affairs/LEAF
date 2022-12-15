<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '../libs/loaders/Leaf_autoloader.php';

$login->loginUser();

$oc_employee = new Orgchart\Employee($oc_db, $oc_login);
$oc_position = new Orgchart\Position($oc_db, $oc_login);
$oc_group = new Orgchart\Group($oc_db, $oc_login);
$vamc = new Portal\VAMC_Directory($oc_employee, $oc_group);

$form = new Portal\Form($db, $login, $settings, $oc_employee, $oc_position, $oc_group, $vamc);

$data = $form->getIndicator(
    Leaf\XSSHelpers::xscrub($_GET['id']),
    Leaf\XSSHelpers::xscrub($_GET['series']),
    Leaf\XSSHelpers::xscrub($_GET['form'])
);

$value = $data[$_GET['id']]['value'];

if (!is_numeric($_GET['file'])
    || $_GET['file'] < 0
    || $_GET['file'] > count($value) - 1)
{
    echo 'Invalid file';
    exit();
}
$_GET['file'] = (int)$_GET['file'];
$_GET['form'] = (int)$_GET['form'];
$_GET['id'] = (int)$_GET['id'];
$_GET['series'] = (int)$_GET['series'];

$filename = $site_paths['site_uploads'] . Portal\Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

if (file_exists($filename))
{
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . addslashes($value[$_GET['file']]) . '"');
    header('Content-Length: ' . filesize($filename));
    header('Cache-Control: maxage=1'); //In seconds
    header('Pragma: public');

    readfile($filename);
    exit();
}

    echo 'Error: File does not exist or access may be restricted.';
