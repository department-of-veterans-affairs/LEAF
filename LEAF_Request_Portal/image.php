<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include 'globals.php';
include 'db_mysql.php';
include 'db_config.php';
include 'Login.php';
include 'form.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$db_config = new DB_Config();
$config = new Config();

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
$login->loginUser();

$form = new Form($db, $login);

$data = $form->getIndicator(
    XSSHelpers::sanitizeHTML($_GET['id']),
    XSSHelpers::sanitizeHTML($_GET['series']),
    $_GET['form']
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

$uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
$filename = $uploadDir . Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

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
