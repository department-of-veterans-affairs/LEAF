<?php
include 'db_mysql.php';
include 'db_config.php';
include 'login.php';
include 'form.php';

$db_config = new DB_Config();
$config = new Config();

// Enforce HTTPS
if(isset($config->enforceHTTPS) && $config->enforceHTTPS == true) {
	if(!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] != 'on') {
		header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
		exit();
	}
}

$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
unset($db_config);

$login = new Login($db_phonebook, $db);
$login->loginUser();

$form = new Form($db, $login);

$data = $form->getIndicator($_GET['id'], $_GET['series'], $_GET['form']);

$value = $data[$_GET['id']]['value'];

if(!is_numeric($_GET['file'])
	||$_GET['file'] < 0
	|| $_GET['file'] > count($value) - 1) {
	echo 'Invalid file';
	exit();
}
$_GET['file'] = (int)$_GET['file'];

$uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
$filename = $uploadDir . Form::getFileHash($_GET['form'], $_GET['id'], $_GET['series'], $value[$_GET['file']]);

if(file_exists($filename)) {
    header('Content-Disposition: attachment; filename="'.addslashes($value[$_GET['file']]).'"');
    header("Content-Length: " . filesize($filename));
    header("Cache-Control: maxage=1"); //In seconds
    header("Pragma: public");

    readfile($filename);
}
else {
    echo 'Error: File does not exist or access may be restricted.';
}
