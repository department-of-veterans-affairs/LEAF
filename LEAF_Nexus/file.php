<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/globals.php';
include __DIR__ . '/db_mysql.php';
include __DIR__ . '/./sources/Login.php';
include __DIR__ . "/../libs/php-commons/aws/AWSUtil.php";

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

$type = null;
switch ($_GET['categoryID']) {
    case 1:    // employee
        include __DIR__ . '/./sources/Employee.php';
        $type = new OrgChart\Employee($db, $login);

        break;
    case 2:    // position
        include __DIR__ . '/./sources/Position.php';
        $type = new OrgChart\Position($db, $login);

        break;
    case 3:    // group
        include __DIR__ . '/./sources/Group.php';
        $type = new OrgChart\Group($db, $login);

        break;
    default:
        return false;

        break;
}

$data = $type->getAllData((int)$_GET['UID'], (int)$_GET['indicatorID']);

$value = $data[$_GET['indicatorID']]['data'];

$inputFilename = html_entity_decode($type->sanitizeInput($_GET['file']));

$filename = $config->uploadDir . $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $inputFilename);

$awsUtil = new \AWSUtil();
$awsUtil->s3registerStreamWrapper();

$s3objectKey = "s3://" . $awsUtil->s3getBucketName() . "/" . $filename;

if (is_array($value)
    && array_search($inputFilename, $value) === false)
{
    echo 'Error: File does not exist or access may be restricted.';
    exit();
}
 if (!is_array($value)
            && $value != $inputFilename)
 {
     echo 'Error: File does not exist or access may be restricted.';
     exit();
 }

if (file_exists($s3objectKey))
{
    $inputFilename = XSSHelpers::scrubNewLinesFromURL($inputFilename);
    header('Content-Disposition: attachment; filename="' . addslashes(html_entity_decode($inputFilename)) . '"');
    header('Content-Length: ' . filesize($s3objectKey));
    header('Cache-Control: maxage=1'); //In seconds
    header('Pragma: public');

    readfile($s3objectKey);
    exit();
}

    echo 'Error: File does not exist or access may be restricted.';
