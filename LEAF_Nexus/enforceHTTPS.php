<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

// Include XSSHelpers
include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';

// Enforce HTTPS
if (isset($config->enforceHTTPS) && $config->enforceHTTPS == true)
{
    if (!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] != 'on')
    {
        header('Location: https://' . XSSHelpers::scrubNewLinesFromURL($_SERVER['SERVER_NAME']) . XSSHelpers::scrubNewLinesFromURL($_SERVER['REQUEST_URI']));
        exit();
    }
}
