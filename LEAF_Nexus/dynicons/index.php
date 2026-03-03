<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Dynicon (runtime)
    Dynamic icons
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/

use App\Leaf\Dynicon;
use App\Leaf\XSSHelpers;

error_reporting(E_ERROR);
ini_set('display_errors', 0);

/*
    Dynicon for Microsoft Windows
    Dynamic icons (svg to png)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/

require_once '/var/www/html/app/libs/globals.php';
include_once getenv('APP_PATH') . '/Leaf/Dynicon.php';
include_once getenv('APP_PATH') . '/Leaf/XSSHelpers.php';

$image = new Dynicon(XSSHelpers::scrubFilename($_GET['img']), $_GET['w']);