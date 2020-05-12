<?php
error_reporting(E_ALL & ~E_NOTICE);
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/routing/Handlers.php';
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

//if portal
include __DIR__.'/LEAF_Request_Portal/db_config.php';
$db_config = new DB_Config($sitePath);
$config = new Config($sitePath);

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
        call_user_func_array(array(new $class($config, $db_config), $method), $vars);
        break;
    default:
        header("HTTP/1.0 404 Not Found");
        exit;
        break;
}
