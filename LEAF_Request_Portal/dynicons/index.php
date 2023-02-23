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

require_once '../globals.php';
require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

$image = new \Leaf\Dynicon($_GET['img'], $_GET['w']);