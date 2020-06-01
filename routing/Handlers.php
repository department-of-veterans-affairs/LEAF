<?php
namespace Handlers{
    class Portal {
        public $config;
        public $db_config;
        public function __construct($config, $db_config)
        {
            $this->config = $config;
            $this->db_config = $db_config;
        }
        function default(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/index.php';
        }

        function js($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__.'/../LEAF_Request_Portal/js/'.$jsFile);
        }

        function css($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../LEAF_Request_Portal/css/'.$cssFile);
        }

        function image($image){
            header('Content-Type: image/png');
            readfile(__DIR__.'/../LEAF_Request_Portal/images/'.$image);
        }

        function api(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/api/index.php';
        }

        function auth_domain(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/auth_domain/index.php';
        }
    }

    class Nexus {
        public $config;
        public function __construct($config)
        {
            $this->config = $config;
        }
        function default(){
            global $config;
            require __DIR__.'/../LEAF_Nexus/index.php';
        }
    }
}