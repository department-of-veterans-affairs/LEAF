<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.

    Dynicon (runtime)
    Dynamic icons
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

    Dynicon for Microsoft Windows
    Dynamic icons (svg to png)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/

use App\Leaf\Dynicon;
use App\Leaf\XSSHelpers;

require_once '/var/www/html/app/libs/globals.php';
include_once '/var/www/html/app/Leaf/Dynicon.php';
include_once '/var/www/html/app/Leaf/XSSHelpers.php';

if (!isset($_GET['w']) && !isset($_GET['img'])) {
    // want to see what is being sent to here if anything.
    error_log(print_r($_GET, true));
} else {
    if (!isset($_GET['w']) && isset($_GET['img'])) {
        // some apps are sending an array with img only and that value is
        // system-users.svg;w=16
        // create two variables here extracted from this value
        $index = strpos($_GET['img'], ';w=');
        $img = substr($_GET['img'], 0, $index);

        $width = substr($_GET['img'], $index + 3);
    } else {
        $img = $_GET['img'];
        $width = $_GET['w'];
    }

    $image = new Dynicon(XSSHelpers::scrubFilename($img), $width);
}
