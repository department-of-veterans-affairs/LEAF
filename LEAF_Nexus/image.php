<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

include __DIR__ . '/globals.php';
include __DIR__ . '/db_mysql.php';
include __DIR__ . '/./sources/Login.php';
include __DIR__ . "/../libs/php-commons/aws/AWSUtil.php";

$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);

session_cache_limiter('');
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

$data = $type->getAllData($_GET['UID'], $_GET['indicatorID']);

$value = $data[$_GET['indicatorID']]['data'];

$filename = $config->uploadDir . $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $value);
$origFile = $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $value);

$filenameParts = explode('.', $value);
$fileExtension = array_pop($filenameParts);
$fileExtension = strtolower($fileExtension);

$imageExtensionWhitelist = array('png', 'jpg', 'jpeg', 'gif');

$awsUtil = new \AWSUtil();
$awsUtil->s3registerStreamWrapper();

$s3objectKey = "s3://" . $awsUtil->s3getBucketName() . "/" . $filename;

if (in_array($fileExtension, $imageExtensionWhitelist) && file_exists($s3objectKey))
{
    $time = filemtime($s3objectKey);

    if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && $_SERVER['HTTP_IF_MODIFIED_SINCE'] == date(DATE_RFC822, $time))
    {
        header('Last-Modified: ' . date(DATE_RFC822, $time), true, 304);
    }
    else
    {
        header('Last-Modified: ' . date(DATE_RFC822, $time));
        header('Expires: ' . date(DATE_RFC822, time() + 604800));
        header('Content-Type: image/' . $fileExtension);

        // shrink images if they're too big
        if (filesize($s3objectKey) > 131072)
        {
            if (file_exists($config->uploadDir . 'img_' . $origFile)
                && filemtime($config->uploadDir . 'img_' . $origFile) > time() - 604800)
            {
                readfile($config->uploadDir . 'img_' . $origFile);
            }
            else
            {
                list($width, $height) = getimagesize($s3objectKey);
                $newWidth = 0;
                $newHeight = 0;
                if ($width > 500)
                {
                    $ratio = 500 / $width;
                    $newWidth = 500;
                    $newHeight = $ratio * $height;
                    $newImg = imagecreatetruecolor($newWidth, $newHeight);
                    switch ($fileExtension) {
                        case 'jpg':
                        case 'jpeg':
                            $src = imagecreatefromjpeg($s3objectKey);

                            break;
                        case 'png':
                            $src = imagecreatefrompng($s3objectKey);

                            break;
                        case 'gif':
                            $src = imagecreatefromgif($s3objectKey);

                            break;
                        default:
                            break;
                    }
                    if ($src !== false)
                    {
                        imagecopyresampled($newImg, $src, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);
                        imagejpeg($newImg, $config->uploadDir . 'img_' . $origFile, 90);
                        readfile($config->uploadDir . 'img_' . $origFile);
                    }
                    else
                    {
                        readfile($s3objectKey);
                    }
                }
            }
        }
        else
        {
            readfile($s3objectKey);
        }
    }
}
else
{
    $time = time();
    if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && $_SERVER['HTTP_IF_MODIFIED_SINCE'] == date(DATE_RFC822, $time))
    {
        header('Last-Modified: ' . date(DATE_RFC822, $time), true, 304);
    }
    else
    {
        header('Last-Modified: ' . date(DATE_RFC822, $time));
        header('Expires: ' . date(DATE_RFC822, $time + 60));
        header('Content-Type: image/png');

        readfile('./images/aboutlogo_small.png');
    }
}

exit();
