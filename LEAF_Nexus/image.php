<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$oc_login->loginUser();

$type = null;
switch ($_GET['categoryID']) {
    case 1:    // employee
        $type = new Orgchart\Employee(OC_DB, $oc_login);

        break;
    case 2:    // position
        $type = new Orgchart\Position(OC_DB, $oc_login);

        break;
    case 3:    // group
        $type = new Orgchart\Group(OC_DB, $oc_login);

        break;
    default:
        return false;
}

$data = $type->getAllData($_GET['UID'], $_GET['indicatorID']);

$value = $data[$_GET['indicatorID']]['data'];

$filename = $oc_site_paths['site_uploads'] . $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $value);
$origFile = $type->getFileHash($_GET['categoryID'], $_GET['UID'], $_GET['indicatorID'], $value);

$filenameParts = explode('.', $value);
$fileExtension = array_pop($filenameParts);
$fileExtension = strtolower($fileExtension);

$imageExtensionWhitelist = array('png', 'jpg', 'jpeg', 'gif');

if (in_array($fileExtension, $imageExtensionWhitelist) && file_exists($filename))
{
    $time = filemtime($filename);

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
        if (filesize($filename) > 131072)
        {
            if (file_exists($oc_site_paths['site_uploads'] . 'img_' . $origFile)
                && filemtime($oc_site_paths['site_uploads'] . 'img_' . $origFile) > time() - 604800)
            {
                readfile($oc_site_paths['site_uploads'] . 'img_' . $origFile);
            }
            else
            {
                list($width, $height) = getimagesize($filename);
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
                            $src = imagecreatefromjpeg($filename);

                            break;
                        case 'png':
                            $src = imagecreatefrompng($filename);

                            break;
                        case 'gif':
                            $src = imagecreatefromgif($filename);

                            break;
                        default:
                            break;
                    }
                    if ($src !== false)
                    {
                        imagecopyresampled($newImg, $src, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);
                        imagejpeg($newImg, $oc_site_paths['site_uploads'] . 'img_' . $origFile, 90);
                        readfile($oc_site_paths['site_uploads'] . 'img_' . $origFile);
                    }
                    else
                    {
                        readfile($filename);
                    }
                }
            }
        }
        else
        {
            readfile($filename);
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
