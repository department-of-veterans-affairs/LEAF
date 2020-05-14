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
        $this->dbUser = 'testuser';
        $this->dbPass = 'testuserpass';
    }

}

class Config
{
    public $title;
    public $city;
    public $adminLogonName;
    public $adPath;
    public static $uploadDir;
    public static $orgchartPath;
    public static $orgchartImportTags;
    public static $leafSecure;
    public static $onPrem;
    public $descriptionID;
    public static $emailPrefix;
    public static $emailCC;
    public static $emailBCC;
    public $phonedbHost;
    public $phonedbName;
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
        $this->orgchartPath = '../LEAF_Nexus'; // HTTP Path to orgchart with no trailing slash
        $this->orgchartImportTags = array('resources_site_access');
        $this->onPrem = false;
        $this->descriptionID = 16;
        $this->emailPrefix = 'Resources: ';
        $this->emailCC = array();    // CCed for every email
        $this->emailBCC = array();    // BCCed for every email
        $this->phonedbHost = 'localhost';
        $this->phonedbName = $res[0]['database_name'];
        $this->phonedbUser = 'testuser';
        $this->phonedbPass = 'testuserpass';
    }
}