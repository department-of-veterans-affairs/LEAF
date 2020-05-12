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

        function js_jquery($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/'.$jsFile);
        }

        function chosen($file){
            $mimeType = mime_content_type(__DIR__.'/../libs/js/jquery/chosen/'.$file);
            $mimeType = $mimeType == 'text/plain' ? 'text/css' : $mimeType;
            header('Content-Type: '. $mimeType);
            echo file_get_contents(__DIR__.'/../libs/js/jquery/chosen/'.$file);
        }

        function js_trumbowyg($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/trumbowyg/'.$jsFile);
        }

        function js_icheck($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/icheck/'.$jsFile);
        }

        function css($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../LEAF_Request_Portal/css/'.$cssFile);
        }

        function libsjquerycss($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/css/dcvamc/'.$cssFile);
        }

        function libsjquerychosencss($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/chosen/'.$cssFile);
        }

        function libstrumbowygcss($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/trumbowyg/ui/'.$cssFile);
        }

        function libsicheckcss($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__.'/../libs/js/jquery/icheck/skins/square/'.$cssFile);
        }

        function image($image){
            header('Content-Type: image/png');
            readfile(__DIR__.'/../LEAF_Request_Portal/images/'.$image);
        }

        function dynicons(){
            require __DIR__.'/../libs/dynicons/index.php';
        }

        function api(){
            global $config, $db_config;
            require __DIR__.'/../LEAF_Request_Portal/api/index.php';
        }
    }
}