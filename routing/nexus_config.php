<?php
namespace Orgchart{

ini_set('display_errors', 0); // Set to 1 to display errors
$_SERVER['REMOTE_USER'] = '\\VACOLayJ';
//$_SERVER['REMOTE_USER'] = '\\tester';
class Config
{
    public $title = 'Organizational Chart';

    public $city = 'Washington D.C. VAMC';

    public $adminLogonName = 'admin';    // Administrator's logon name

    public $adPath = array('OU=Users,DC=va,DC=gov'); // Active directory paths

    //toggle LEAF-Secure on and off, default is off
    public static $leafSecure = false;

    public static $onPrem = false;         //used to display on-prem banner warning

    public static $uploadDir = './UPLOADS/';

    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $ERM_Sites = array('resource_management' => ''); // URL to ERM sites with trailing slash

    public $dbHost = 'localhost';

    public $dbName = 'nexus_dev';
    //public $dbName = 'nexus_testing';

    public $dbUser = 'testuser';

    public $dbPass = 'testuserpass';
}
}