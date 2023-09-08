<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use App\Leaf\XSSHelpers;

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$oc_login->loginUser();

$type = null;
switch ($_GET['categoryID']) {
    case 1:    // employee
        $type = new Orgchart\Employee($oc_db, $oc_login);

        break;
    case 2:    // position
        $type = new Orgchart\Position($oc_db, $oc_login);

        break;
    case 3:    // group
        $type = new Orgchart\Group($oc_db, $oc_login);

        break;
    default:
        return false;
}

$data = $type->getAllData((int)$_GET['UID'], (int)$_GET['indicatorID']);

$value = $data[$_GET['indicatorID']]['data'];

$inputFilename = html_entity_decode($type->sanitizeInput($_GET['file']));

$filename = $oc_site_paths['site_uploads'] . $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $inputFilename);

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
