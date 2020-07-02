<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/globals.php';
include __DIR__ . '/db_mysql.php';
include __DIR__ . '/Login.php';
include __DIR__ . '/form.php';
include __DIR__ . "/../libs/php-commons/aws/AWSUtil.php";

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
$login->loginUser();

$form = new Form($db, $login);

$data = $form->getIndicator(
    XSSHelpers::xscrub($_GET['id']),
    XSSHelpers::xscrub($_GET['series']),
    XSSHelpers::xscrub($_GET['form'])
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

$uploadDir = isset($config->uploadDir) ? $config->uploadDir : '';
$filename = $uploadDir . Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

$awsUtil = new AWSUtil();

if (!empty($uploadDir)) {
    $result = $awsUtil->s3GetObject($filename);

    if ($result != "NoSuchKey") {
        header('Content-Type: {$result["ContentType"]}');
        header('Content-Disposition: attachment; filename="' . basename($filename) . '"');
        header('Content-Length: ' . $result['ContentLength']);
        header('Cache-Control: maxage=1'); //In seconds
        header('Pragma: public');

        echo $result['Body'] . "\n";
        exit();
    }
}

echo 'Error: File does not exist or access may be restricted.';
