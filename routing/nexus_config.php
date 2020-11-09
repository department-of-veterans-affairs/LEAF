<?php
namespace Orgchart{
    class Config
    {
        public $title;
        public $city;
        public $adminLogonName;    // Administrator's logon name
        public $adPath; // Active directory paths
        public $uploadDir;
        public $ocPath;
        public $dbHost;
        public $dbName;
        public $dbUser;
        public $dbPass;
        public function __construct($configData)
        {            
            $this->title = $configData[0]['title'];
            $this->city = $configData[0]['city'];
            $this->adminLogonName = $configData[0]['adminLogonName'];
            $this->adPath = json_decode($configData[0]['active_directory_path']);
            $this->uploadDir = ltrim($configData[0]['upload_directory'], "/");
            $this->ocPath = ltrim($configData[0]['path'], '/');

            $this->dbHost = \Routing_Config::$dbHost;
            $this->dbName = $configData[0]['database_name'];
            $this->dbUser = \Routing_Config::$dbUser;
            $this->dbPass = \Routing_Config::$dbPass;
        }
    }
}