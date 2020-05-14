<?php
namespace Orgchart{

    ini_set('display_errors', 0); // Set to 1 to display errors
    $_SERVER['REMOTE_USER'] = '\\VACOLayJ';
    //$_SERVER['REMOTE_USER'] = '\\tester';
    class Config
    {
        public $title;
        public $city;
        public $adminLogonName;    // Administrator's logon name
        public $adPath; // Active directory paths
        public static $uploadDir;
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
            $sql = "SELECT * FROM orgchart_configs WHERE path = '$sitePath';";
            $query = $db->prepare($sql);
            $query->execute(array());
            $res = $query->fetchAll(PDO::FETCH_ASSOC);
            
            $this->title = $res[0]['title'];;
            $this->city = $res[0]['city'];;
            $this->adminLogonName = $res[0]['adminLogonName'];;
            $this->adPath = $res[0]['active_directory_path'];;
            $this->uploadDir = $res[0]['upload_directory'];;

            $this->dbHost = 'localhost';
            $this->dbName = $res[0]['database_name'];
            $this->dbUser = 'testuser';
            $this->dbPass = 'testuserpass';
        }
    }
}