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
        public function __construct($sitePath)
        {
            $db = new \PDO(
                "mysql:host=".\Routing_Config::$dbHost.";dbname=".\Routing_Config::$dbName.";charset=UTF8",
                \Routing_Config::$dbUser,
                \Routing_Config::$dbPass,
                array()
            );
            $sql = "SELECT * FROM orgchart_configs WHERE path = '$sitePath';";
            $query = $db->prepare($sql);
            $query->execute(array());
            $res = $query->fetchAll(\PDO::FETCH_ASSOC);
            
            $this->title = $res[0]['title'];
            $this->city = $res[0]['city'];
            $this->adminLogonName = $res[0]['adminLogonName'];
            $this->adPath = json_decode($res[0]['active_directory_path']);
            $this->uploadDir = ltrim($res[0]['path'], "/") . $res[0]['upload_directory'];
            $this->ocPath = ltrim($res[0]['path'], '/');

            $this->dbHost = \Routing_Config::$dbHost;
            $this->dbName = $res[0]['database_name'];
            $this->dbUser = \Routing_Config::$dbUser;
            $this->dbPass = \Routing_Config::$dbPass;
        }
    }
}