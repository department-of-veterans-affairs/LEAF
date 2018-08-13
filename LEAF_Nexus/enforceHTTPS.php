<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

// Enforce HTTPS
if (isset($config->enforceHTTPS) && $config->enforceHTTPS == true)
{
    if (!isset($_SERVER['HTTPS']) || $_SERVER['HTTPS'] != 'on')
    {
        header('Location: https://' . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']);
        exit();
    }
}
