<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$login->loginUser();

$form = new Portal\Form($db, $login);

// Validate and sanitize input parameters
if (!isset($_GET['id']) || !isset($_GET['series']) || !isset($_GET['form']) || !isset($_GET['file'])) {
    echo 'Missing required parameters';
    exit();
}

// Validate numeric parameters early
if (!is_numeric($_GET['file']) || !is_numeric($_GET['form']) ||
    !is_numeric($_GET['id']) || !is_numeric($_GET['series'])) {
    echo 'Invalid parameters';
    exit();
}

$fileIndex = (int)$_GET['file'];
$formId = (int)$_GET['form'];
$indicatorId = (int)$_GET['id'];
$seriesId = (int)$_GET['series'];

// Validate file index is non-negative
if ($fileIndex < 0) {
    echo 'Invalid file index';
    exit();
}

$data = $form->getIndicator(
    XSSHelpers::sanitizeHTML($indicatorId),
    XSSHelpers::sanitizeHTML($seriesId),
    $formId
);

if (isset($data[$indicatorId]['value'])) {
    $value = $data[$_GET['id']]['value'];
} else {
    echo 'Indicator value not found';
    exit();
}

if (!is_countable($value) || $fileIndex > count($value) - 1) {
    echo 'Invalid file';
    exit();
}


$uploadDir = $site_paths['site_uploads'];
$realUploadDir = realpath($uploadDir);

if ($realUploadDir === false) {
    echo 'Upload directory not found';
    error_log("Image display error: Upload directory does not exist: {$uploadDir}");
    exit();
}

$fileHash = Portal\Form::getFileHash($formId, $indicatorId, $seriesId, $value[$fileIndex]);
$filename = $realUploadDir . '/' . $fileHash;

if (!XSSHelpers::isPathSafe($filename, $realUploadDir)) {
    echo 'Invalid file path';
    error_log("Image display error: Path traversal attempt detected. File: {$filename}, Upload Dir: {$realUploadDir}");
    exit();
}

if (!file_exists($filename)) {
    echo 'Error: File does not exist or access may be restricted.';
    error_log("Image display error: File not found: {$filename}");
    exit();
}

if (!is_file($filename)) {
    echo 'Invalid file type';
    error_log("Image display error: Not a regular file: {$filename}");
    exit();
}

$filenameParts = explode('.', $filename);
$fileExtension = array_pop($filenameParts);
$fileExtension = strtolower($fileExtension);

$imageExtensionWhitelist = array('png', 'jpg', 'jpeg', 'gif');

if (!in_array($fileExtension, $imageExtensionWhitelist)) {
    echo 'Invalid image format';
    error_log("Image display error: Invalid file extension: {$fileExtension} for file: {$filename}");
    exit();
}

header_remove('Pragma');
header_remove('Cache-Control');
header_remove('Expires');
$etag = sha1_file($filename);
header('Content-Type: image/' . $fileExtension);

if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
        && $_SERVER['HTTP_IF_NONE_MATCH'] == $etag
) {
    header('Etag: ' . $etag, true, 304);
} else {
    header('Etag: ' . $etag);
}

readfile($filename);
exit();
