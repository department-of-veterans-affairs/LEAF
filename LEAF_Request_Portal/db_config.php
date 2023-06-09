<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

ini_set('display_errors', 0); // Set to 1 to display errors

require_once(dirname(__FILE__) . '/globals.php');

class DB_Config
{
    public $dbHost = DIRECTORY_HOST;
    public $dbName = 'leaf_portal';
    public $dbUser = DIRECTORY_USER;
    public $dbPass = DIRECTORY_PASS;
}

class Config
{
    public $title = 'New LEAF Site';
    public $city = '';
    public $adminLogonName = DATABASE_DB_ADMIN;    // Administrator's logon name
    public $adPath = array('OU=myOU,DC=domain,DC=tld'); // Active directory path
    public static $uploadDir = './UPLOADS/';
    // Directory for user uploads
                                             // using backslashes (/), with trailing slash
    public static $orgchartPath = '../LEAF_Nexus'; // HTTP Path to orgchart with no trailing slash
    public static $orgchartImportTags = array('Academy_Demo1'); // Import org chart groups if they match these tags
    public $descriptionID = 16;    // indicator ID for description field
    public static $emailPrefix = 'Resources: ';              // Email prefix
    public static $emailCC = array();    // CCed for every email
    public static $emailBCC = array();    // BCCed for every email
    public $phonedbHost = DIRECTORY_HOST;
    public $phonedbName = DIRECTORY_DB;
    public $phonedbUser = DIRECTORY_USER;
    public $phonedbPass = DIRECTORY_PASS;
}