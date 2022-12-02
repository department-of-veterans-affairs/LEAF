<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Database config
    Date Created: November 23, 2009

    Central place to put database login information
    This should be kept outside of web accessible directories
*/

class DbConfig
{
    public $dbHost = DIRECTORY_HOST;

    public $dbName = 'leaf_portal';

    public $dbUser = DIRECTORY_USER;

    public $dbPass = DIRECTORY_PASS;
}
