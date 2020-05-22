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

        function other($otherFile){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/'.$otherFile;
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

        function scripts($scriptFile){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/scripts/'.$scriptFile;
        }

        function auth_domain(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/auth_domain/index.php';
        }

        function admin_index(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/admin/index.php';
        }

        function admin_css($cssFile){
            header('Content-Type: text/css');
            require __DIR__.'/../LEAF_Request_Portal/admin/css/'.$cssFile;
        }

        function admin_js($jsFile){
            header('Content-Type: text/javascript');
            require __DIR__.'/../LEAF_Request_Portal/admin/js/'.$jsFile;
        }
        
        function admin_other($adminFile){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/admin/'.$adminFile;
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