<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once '/var/www/html/libs/loaders/Leaf_autoloader.php';

$config = new Orgchart\Config();

$db = new Db($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

$login = new Orgchart\Login($db, $db);
$login->loginUser();

$type = null;
switch ($_GET['categoryID']) {
    case 1:    // employee
        $type = new Orgchart\Employee($db, $login);

        break;
    case 2:    // position
        $type = new Orgchart\Position($db, $login);

        break;
    case 3:    // group
        $type = new Orgchart\Group($db, $login);

        break;
    default:
        return false;

        break;
}

$data = $type->getAllData((int)$_GET['UID'], (int)$_GET['indicatorID']);

$value = $data[$_GET['indicatorID']]['data'];

$inputFilename = html_entity_decode($type->sanitizeInput($_GET['file']));

$filename = Orgchart\Config::$uploadDir . $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $inputFilename);

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

if (file_exists($filename))
{
    $inputFilename = XSSHelpers::scrubNewLinesFromURL($inputFilename);
    header('Content-Disposition: attachment; filename="' . addslashes(html_entity_decode($inputFilename)) . '"');
    header('Content-Length: ' . filesize($filename));
    header('Cache-Control: maxage=1'); //In seconds
    header('Pragma: public');

    readfile($filename);
    exit();
}

    echo 'Error: File does not exist or access may be restricted.';
