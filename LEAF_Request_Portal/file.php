<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->loginUser();

$form = new Portal\Form($db, $login);

$data = $form->getIndicator(
    XSSHelpers::xscrub($_GET['id']),
    XSSHelpers::xscrub($_GET['series']),
    XSSHelpers::xscrub($_GET['form'])
);

if (isset($data[$_GET['id']]['value'])){
    $value = $data[$_GET['id']]['value'];
} else {
    $value = 0;
}

if (
    !is_numeric($_GET['file'])
    || $_GET['file'] < 0
    || !is_countable($value)
    || $_GET['file'] > count($value) - 1
) {
    echo 'Invalid file';
    exit();
}
$_GET['file'] = (int)$_GET['file'];
$_GET['form'] = (int)$_GET['form'];
$_GET['id'] = (int)$_GET['id'];
$_GET['series'] = (int)$_GET['series'];

$uploadDir = $site_paths['site_uploads'];
$filename = $uploadDir . Portal\Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

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
