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
            require __DIR__ . '/../LEAF_Request_Portal/index.php';
        }

        function other($otherFile){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/' . $otherFile;
        }

        function favicon($favicon){
            header('Content-Type: image/png');
            readfile(__DIR__ . '/../LEAF_Request_Portal/' . $favicon);
        }

        function js($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__ . '/../LEAF_Request_Portal/js/' . $jsFile);
        }

        function css($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__ . '/../LEAF_Request_Portal/css/' . $cssFile);
        }

        function image($image){
            header('Content-Type: image/png');
            readfile(__DIR__ . '/../LEAF_Request_Portal/images/' . $image);
        }

        function file($fileName){
            global $config;
            require __DIR__ . '/../libs/php-commons/aws/AWSUtil.php';
            
            $awsUtil = new \AWSUtil();
            $awsUtil->s3registerStreamWrapper();

            $s3objectKey = "s3://" . $awsUtil->s3getBucketName() . "/" . $config->fileManagerDir . $fileName;

            if (file_exists($s3objectKey)) {
                header('Content-Type: ' . mime_content_type($s3objectKey));
                // header('Content-Disposition: attachment; filename="' . addslashes(html_entity_decode($in)) . '"');
                // header('Content-Length: ' . filesize($s3objectKey));
                // header('Cache-Control: maxage=1'); //In seconds
                // header('Pragma: public');

                readfile($s3objectKey);
            }
            else
            {
                return 'Error: File does not exist or access may be restricted.';
            }
        }

        function api(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/api/index.php';
        }

        function login(){
            global $config, $db_config;
            echo file_get_contents(__DIR__ . '/../LEAF_Request_Portal/login/index.php');
        }

        function scripts($scriptFile){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/scripts/' . $scriptFile;
        }

        function auth_domain(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/auth_domain/index.php';
        }

        function auth_domain_api(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/auth_domain/api/index.php';
        }

        function auth_cookie(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/auth_cookie/index.php';
        }

        function auth_token(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/auth_token/index.php';
        }

        function admin_index(){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/admin/index.php';
        }

        function admin_css($cssFile){
            header('Content-Type: text/css');
            require __DIR__ . '/../LEAF_Request_Portal/admin/css/' . $cssFile;
        }

        function admin_js($jsFile){
            header('Content-Type: text/javascript');
            require __DIR__ . '/../LEAF_Request_Portal/admin/js/' . $jsFile;
        }
        
        function admin_other($adminFile){
            global $config, $db_config;
            require __DIR__ . '/../LEAF_Request_Portal/admin/' . $adminFile;
        }
    }

    class Nexus {
        public $config;
        public function __construct($config)
        {
            $this->config = $config;
        }

        function other($otherFile){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/' . $otherFile;
        }

        function api(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/api/index.php';
        }

        function auth_domain(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/auth_domain/index.php';
        }

        function auth_cookie(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/auth_cookie/index.php';
        }

        function auth_token(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/auth_token/index.php';
        }

        function js($jsFile){
            header('Content-Type: text/javascript');
            echo file_get_contents(__DIR__ . '/../LEAF_Nexus/js/' . $jsFile);
        }

        function css($cssFile){
            header('Content-Type: text/css');
            echo file_get_contents(__DIR__ . '/../LEAF_Nexus/css/' . $cssFile);
        }

        function image($image){
            header('Content-Type: image/png');
            readfile(__DIR__ . '/../LEAF_Nexus/images/' . $image);
        }

        function login(){
            global $config;
            echo file_get_contents(__DIR__ . '/../LEAF_Nexus/login/index.php');
        }

        function admin_index(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/admin/index.php';
        }

        function admin_css($cssFile){
            header('Content-Type: text/css');
            require __DIR__ . '/../LEAF_Nexus/admin/css/' . $cssFile;
        }
        
        function admin_other($adminFile){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/admin/' . $adminFile;
        }

        function default(){
            global $config;
            require __DIR__ . '/../LEAF_Nexus/index.php';
        }
    }

    class Test {
        public $config;
        public $db_config;
        public function __construct($config, $db_config)
        {
            $this->config = $config;
            $this->db_config = $db_config;
        }
        function nexus(){
            global $config, $db_config;
            require __DIR__ . '/../test/LEAF_test_endpoints/nexus/index.php';
        }
        function request_portal(){
            global $config, $db_config;
            require __DIR__ . '/../test/LEAF_test_endpoints/request_portal/index.php';
        }
    }
}