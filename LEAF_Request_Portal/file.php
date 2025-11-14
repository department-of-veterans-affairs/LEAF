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

// Cast to integers after validation
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
    XSSHelpers::xscrub($indicatorId),
    XSSHelpers::xscrub($seriesId),
    XSSHelpers::xscrub($formId),
    false // don't need to parse the template for file downloads
);

if (isset($data[$indicatorId]['value'])) {
    $value = $data[$indicatorId]['value'];
} else {
    echo 'Indicator value not found';
    exit();
}

// Validate the file index is within bounds
if (!is_countable($value) || $fileIndex > count($value) - 1) {
    echo 'Invalid file index';
    exit();
}

// Validate upload directory exists and is safe
$uploadDir = $site_paths['site_uploads'];
$realUploadDir = realpath($uploadDir);

if ($realUploadDir === false) {
    echo 'Upload directory not found';
    error_log("File download error: Upload directory does not exist: {$uploadDir}");
    exit();
}

// Build the filename using the validated parameters
$fileHash = Portal\Form::getFileHash($formId, $indicatorId, $seriesId, $value[$fileIndex]);
$filename = $realUploadDir . '/' . $fileHash;

// CRITICAL: Use XSSHelpers::isPathSafe to validate the file path
if (!XSSHelpers::isPathSafe($filename, $realUploadDir)) {
    echo 'Invalid file path';
    error_log("File download error: Path traversal attempt detected. File: {$filename}, Upload Dir: {$realUploadDir}");
    exit();
}

// Verify file exists
if (!file_exists($filename)) {
    echo 'Error: File does not exist or access may be restricted.';
    error_log("File download error: File not found: {$filename}");
    exit();
}

// Additional validation: Ensure the file is a regular file
if (!is_file($filename)) {
    echo 'Invalid file type';
    error_log("File download error: Not a regular file: {$filename}");
    exit();
}

// All validations passed - safe to serve the file
$mimetype = mime_content_type($filename) ?: "application/octet-stream";
header('Content-Type: '. $mimetype);

if (!isset($_GET['inline'])) {
    $originalFilename = basename($value[$fileIndex]);
    $safeFilename = str_replace('"', '\\"', $originalFilename);
    header('Content-Disposition: attachment; filename="' . $safeFilename . '"');
}

header('Content-Length: ' . filesize($filename));
header('Cache-Control: maxage=1');
header('Pragma: public');

readfile($filename);
exit();