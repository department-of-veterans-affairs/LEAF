<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->loginUser();

$form = new Portal\Form($db, $login);

$data = $form->getIndicator(
    XSSHelpers::sanitizeHTML($_GET['id']),
    XSSHelpers::sanitizeHTML($_GET['series']),
    $_GET['form']
);

$value = $data[$_GET['id']]['value'];

if (!is_numeric($_GET['file'])
    || $_GET['file'] < 0
    || !is_countable($value) || $_GET['file'] > count($value) - 1)
{
    echo 'Invalid file';
    exit();
}
$_GET['file'] = (int)$_GET['file'];
$_GET['form'] = (int)$_GET['form'];
$_GET['id'] = (int)$_GET['id'];
$_GET['series'] = (int)$_GET['series'];

$uploadDir = $site_paths['site_uploads'];
$filename = $uploadDir . Portal\Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

$filenameParts = explode('.', $filename);
$fileExtension = array_pop($filenameParts);
$fileExtension = strtolower($fileExtension);

$imageExtensionWhitelist = array('png', 'jpg', 'jpeg', 'gif');

if (file_exists($filename) && in_array($fileExtension, $imageExtensionWhitelist))
{
    header_remove('Pragma');
    header_remove('Cache-Control');
    header_remove('Expires');
    $etag = sha1_file($filename);
    header('Content-Type: image/' . $fileExtension);

    if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
           && $_SERVER['HTTP_IF_NONE_MATCH'] == $etag)
    {
        header('Etag: ' . $etag, true, 304);
    }
    else
    {
        header('Etag: ' . $etag);
    }
    readfile($filename);
    exit();
}

    echo 'Error: File does not exist or access may be restricted.';
