<?php

namespace Orgchart;

ini_set('display_errors', 0); // Set to 1 to display errors

require_once(dirname(__FILE__) . '/globals.php');

class Config
{
    public $title = 'Organizational Chart';

    public $city = '';

    public $adminLogonName = DATABASE_DB_ADMIN;    // Administrator's logon name

    public $adPath = array('OU=Users,DC=va,DC=gov'); // Active directory paths

    public static $uploadDir = './UPLOADS/';

    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $ERM_Sites = array('resource_management' => ''); // URL to ERM sites with trailing slash

    public $dbHost = DIRECTORY_HOST;
    public $dbName = DIRECTORY_DB;
    public $dbUser = DIRECTORY_USER;
    public $dbPass = DIRECTORY_PASS;
}
