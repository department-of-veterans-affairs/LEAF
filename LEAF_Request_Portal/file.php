<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include 'globals.php';
include 'db_mysql.php';
include 'db_config.php';
include 'Login.php';
include 'form.php';

$db_config = new DB_Config();
$config = new Config();

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

$uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
$filename = $uploadDir . Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

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
