<?php
error_reporting(E_ALL & ~E_NOTICE);
require_once __DIR__ . '/vendor/autoload.php';

// Fetch method and URI from somewhere
$httpMethod = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];
// Strip query string (?foo=bar) and decode URI
if (false !== $pos = strpos($uri, '?')) {
    $uri = substr($uri, 0, $pos);
}

//rewrite for api
if (false !== $pos = strpos($uri, '/api/')) {
    $uri = substr($uri, 0, $pos+5);
    $_GET['a'] = isset($_GET['a']) ? $_GET['a'] : substr($uri, $pos+5);
}


$uri = rawurldecode($uri);

$pattern = '(\/api\/|\/libs\/|\/js\/|\/css\/|\/images\/)';
preg_match ($pattern , $uri, $matches, PREG_OFFSET_CAPTURE);
if(count($matches)){
    $sitePath = substr($uri, 0, $matches[0][1]+1);
    $uri = str_replace($sitePath,'/',$uri);
}else{
    $sitePath = $uri;
    $uri = '/';
}
//var_dump($sitePath);var_dump($uri);exit;
$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) {
    $r->addRoute('GET', '/', 'Handlers/default');
    $r->addRoute('GET', '/js/{jsfile}', 'Handlers/js');
    $r->addRoute('GET', '/css/{cssfile}', 'Handlers/css');
    $r->addRoute('GET', '/images/{imagefile}', 'Handlers/image');
    $r->addRoute('GET', '/libs/dynicons/', 'Handlers/dynicons');
    $r->addRoute('GET', '/libs/js/jquery/css/dcvamc/{cssfile}', 'Handlers/libsjquerycss');
    //$r->addRoute('GET', '/libs/js/jquery/chosen/{cssfile}', 'Handlers/libsjquerychosencss');
    $r->addRoute('GET', '/libs/js/jquery/trumbowyg/ui/{cssfile}', 'Handlers/libstrumbowygcss');
    $r->addRoute('GET', '/libs/js/jquery/icheck/skins/square/{cssfile}', 'Handlers/libsicheckcss');

    $r->addRoute('GET', '/libs/js/jquery/{jsfile}', 'Handlers/js_jquery');
    $r->addRoute('GET', '/libs/js/jquery/chosen/{jsfile}', 'Handlers/chosen');
    $r->addRoute('GET', '/libs/js/jquery/trumbowyg/{jsfile}', 'Handlers/js_trumbowyg');
    $r->addRoute('GET', '/libs/js/jquery/icheck/{jsfile}', 'Handlers/js_icheck');

    $r->addRoute('GET', '/api/', 'Handlers/api');
    $r->addRoute('GET', '/api/dynicons/', 'Handlers/dynicons');
});

$routeInfo = $dispatcher->dispatch($httpMethod, $uri);

switch ($routeInfo[0]) {
    case FastRoute\Dispatcher::NOT_FOUND:
        header("HTTP/1.0 404 Not Found");
        exit;
        break;
    case FastRoute\Dispatcher::METHOD_NOT_ALLOWED:
        $allowedMethods = $routeInfo[1];
        header($_SERVER["SERVER_PROTOCOL"]." 405 Method Not Allowed", true, 405);
        exit;
        break;
    case FastRoute\Dispatcher::FOUND:
        $handler = $routeInfo[1];
        $vars = $routeInfo[2];
        
        list($class, $method) = explode("/", $handler, 2);
        call_user_func_array(array(new $class($sitePath), $method), $vars);
        break;
    default:
        header("HTTP/1.0 404 Not Found");
        exit;
        break;
}
class Handlers {
    public $sitePath;
    public function __construct($sitePath)
    {
        $this->sitePath = $sitePath;
    }
    function default(){
        $sitePath = $this->sitePath;
        require __DIR__.'/LEAF_Request_Portal/index.php';
    }

    function js($jsFile){
        header('Content-Type: text/javascript');
        echo file_get_contents(__DIR__.'/LEAF_Request_Portal/js/'.$jsFile);
    }

    function js_jquery($jsFile){
        header('Content-Type: text/javascript');
        echo file_get_contents(__DIR__.'/libs/js/jquery/'.$jsFile);
    }

    function chosen($file){
        $mimeType = mime_content_type(__DIR__.'/libs/js/jquery/chosen/'.$file);
        $mimeType = $mimeType == 'text/plain' ? 'text/css' : $mimeType;
        header('Content-Type: '. $mimeType);
        echo file_get_contents(__DIR__.'/libs/js/jquery/chosen/'.$file);
    }

    function js_trumbowyg($jsFile){
        header('Content-Type: text/javascript');
        echo file_get_contents(__DIR__.'/libs/js/jquery/trumbowyg/'.$jsFile);
    }

    function js_icheck($jsFile){
        header('Content-Type: text/javascript');
        echo file_get_contents(__DIR__.'/libs/js/jquery/icheck/'.$jsFile);
    }

    function css($cssFile){
        header('Content-Type: text/css');
        echo file_get_contents(__DIR__.'/LEAF_Request_Portal/css/'.$cssFile);
    }

    function libsjquerycss($cssFile){
        header('Content-Type: text/css');
        echo file_get_contents(__DIR__.'/libs/js/jquery/css/dcvamc/'.$cssFile);
    }

    function libsjquerychosencss($cssFile){
        header('Content-Type: text/css');
        echo file_get_contents(__DIR__.'/libs/js/jquery/chosen/'.$cssFile);
    }

    function libstrumbowygcss($cssFile){
        header('Content-Type: text/css');
        echo file_get_contents(__DIR__.'/libs/js/jquery/trumbowyg/ui/'.$cssFile);
    }

    function libsicheckcss($cssFile){
        header('Content-Type: text/css');
        echo file_get_contents(__DIR__.'/libs/js/jquery/icheck/skins/square/'.$cssFile);
    }

    function image($image){
        header('Content-Type: image/png');
        readfile(__DIR__.'/LEAF_Request_Portal/images/'.$image);
    }

    function dynicons(){
        require __DIR__.'/libs/dynicons/index.php';
    }

    function api(){
        $sitePath = $this->sitePath;
        require __DIR__.'/LEAF_Request_Portal/api/index.php';
    }
}