<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

class DB_Config
{
    public $dbHost;
    public $dbName;
    public $dbUser;
    public $dbPass;

    public function __construct($configData)
    {
        $this->dbHost = Routing_Config::$dbHost;
        $this->dbName = $configData[0]['database_name'];
        $this->dbUser = Routing_Config::$dbUser;
        $this->dbPass = Routing_Config::$dbPass;
    }

}

class Config
{
    public $title;
    public $city;
    public $adminLogonName;
    public $adPath;
    public $portalPath;
    public $uploadDir;
    public $fileManagerDir;
    public $orgchartPath;
    public $orgchartPathExt;
    public $orgchartImportTags;
    public $leafSecure;
    public $onPrem;
    public $descriptionID;
    public $emailPrefix;
    public $emailCC;
    public $emailBCC;
    public $phonedbHost;
    public $phonedbName;
    public $phonedbUser;
    public $phonedbPass;
    public function __construct($configData)
    {
        $this->title = $configData[0]['title'];
        $this->city = $configData[0]['city'];
        $this->adminLogonName = $configData[0]['adminLogonName'];    // Administrator's logon name
        $this->adPath = json_decode($configData[0]['active_directory_path']); // Active directory path
        $this->uploadDir = ltrim($configData[0]['upload_directory'], "/");
        $this->fileManagerDir = ltrim($configData[0]['path'], "/") . "files/"; // file manager directory
        $this->portalPath = ltrim($configData[0]['path'], '/');
        $this->orgchartPath = "../LEAF_Nexus"; // Internal orgchart path
        $this->orgchartPathExt = rtrim($configData[0]['orgchart_path_ext'], '/'); // HTTP Path to orgchart
        $this->orgchartImportTags = json_decode($configData[0]['orgchart_tags']);
        $this->descriptionID = $configData[0]['descriptionID'];
        $this->emailPrefix = $configData[0]['emailPrefix'];
        $this->emailCC = json_decode($configData[0]['emailCC']);    // CCed for every email
        $this->emailBCC = json_decode($configData[0]['emailBCC']);    // BCCed for every email
        $this->phonedbHost = Routing_Config::$dbHost;
        $this->phonedbName = $configData[0]['phonedbName'];
        $this->phonedbUser = Routing_Config::$dbUser;
        $this->phonedbPass = Routing_Config::$dbPass;
    }
}
