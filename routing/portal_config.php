<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */



ini_set('display_errors', 1); // Set to 1 to display errors
$_SERVER['REMOTE_USER'] = '\\VACOLayJ';

class DB_Config
{
    public $dbHost;

    public $dbName;
    //public $dbName = 'portal_testing';

    public $dbUser;

    public $dbPass;

    public function __construct($sitePath)
    {
        $db = new PDO(
            "mysql:host=localhost;dbname=leaf_config;charset=UTF8",
            'testuser',
            'testuserpass',
            array()
        );
        $sql = "SELECT a.* FROM portal_configs as a WHERE a.path = '$sitePath';";
        $query = $db->prepare($sql);
        $query->execute(array());
        $res = $query->fetchAll(PDO::FETCH_ASSOC);
        
        $this->dbHost = 'localhost';

        $this->dbName = $res[0]['database_name'];
        //$dbName = 'portal_testing';
    
        $this->dbUser = 'testuser';
    
        $this->dbPass = 'testuserpass';
    }

}

class Config
{
    public $title;

    public $city;

    public $adminLogonName;    // Administrator's logon name

    public $adPath; // Active directory path

    public static $uploadDir;

    // Directory for user uploads
                                             // using backslashes (/), with trailing slash
    public static $orgchartPath = '../LEAF_Nexus'; // HTTP Path to orgchart with no trailing slash

    public static $orgchartImportTags = ''; // Import org chart groups if they match these tags

    public static $leafSecure;      //toggle LEAF-Secure on and off, default is off

    public static $onPrem;         //used to display on-prem banner warning

    public $descriptionID;    // indicator ID for description field

    public static $emailPrefix = '';              // Email prefix

    public static $emailCC = array();    // CCed for every email

    public static $emailBCC = array();    // BCCed for every email

    public $phonedbHost;

    public $phonedbName;
    //public $phonedbName = 'nexus_testing';

    public $phonedbUser;

    public $phonedbPass;

    public function __construct($sitePath)
    {
        $db = new PDO(
            "mysql:host=localhost;dbname=leaf_config;charset=UTF8",
            'testuser',
            'testuserpass',
            array()
        );
        $sql = "SELECT b.* FROM portal_configs as a JOIN orgchart_configs as b ON a.orgchart_id = b.id WHERE a.path = '$sitePath';";
        $query = $db->prepare($sql);
        $query->execute(array());
        $res = $query->fetchAll(PDO::FETCH_ASSOC);
        
        $this->dbHost = 'localhost';

        $this->title = $res[0]['title'];

        $this->city = $res[0]['city'];
    
        $this->adminLogonName = 'myAdmin';    // Administrator's logon name
    
        $this->adPath = array('OU=myOU,DC=domain,DC=tld'); // Active directory path
    
        $this->uploadDir = './UPLOADS/';
    
        // Directory for user uploads
        // using backslashes (/), with trailing slash
        $this->orgchartPath = '../LEAF_Nexus'; // HTTP Path to orgchart with no trailing slash
    
        $this->orgchartImportTags = array('resources_site_access'); // Import org chart groups if they match these tags
    
        $this->leafSecure = false;      //toggle LEAF-Secure on and off, default is off
    
        $this->onPrem = false;         //used to display on-prem banner warning
    
        $this->descriptionID = 16;    // indicator ID for description field
    
        $this->emailPrefix = 'Resources: ';              // Email prefix
    
        $this->emailCC = array();    // CCed for every email
    
        $this->emailBCC = array();    // BCCed for every email
    
        $this->phonedbHost = 'localhost';
    
        $this->phonedbName = $res[0]['database_name'];
        //$this->phonedbName = 'nexus_testing';
    
        $this->phonedbUser = 'testuser';
    
        $this->phonedbPass = 'testuserpass';
    }
}