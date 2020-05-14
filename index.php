<?php
error_reporting(E_ALL & ~E_NOTICE);
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/routing/Handlers.php';
require_once __DIR__ . '/routing/portal_config.php';
require_once __DIR__ . '/routing/nexus_config.php';
require_once __DIR__ . '/routing/LEAFRoutes.php';

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

//Get sitepath
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

//TODO check for portal or orgchart


if(doesSiteExist('portal', $sitePath))//query for portal
{
    $db_config = new DB_Config($sitePath);
    $config = new Config($sitePath);

}elseif(doesSiteExist('nexus', $sitePath))//query for nexus
{
    $config = new Orgchart\Config($sitePath);
}

//pass in routes
$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) {
    $leafRoutes = new LEAFRoutes('portal');
    foreach($leafRoutes->routes as $leafRoute){
        $r->addRoute($leafRoute->httpMethod, $leafRoute->path, $leafRoute->callback);
    }
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
        $class = "Handlers\\" . $class;
        call_user_func_array(array(new $class($config, $db_config), $method), $vars);
        break;
    default:
        header("HTTP/1.0 404 Not Found");
        exit;
        break;
}

function doesSiteExist($typeToCheck, $sitePath){
    if($typeToCheck == 'portal'){
        $table = 'portal_configs';
    } elseif($typeToCheck == 'nexus' || $typeToCheck == 'orgchart') {
        $table = 'orgchart_configs';
    }

    $db = new PDO(
        "mysql:host=localhost;dbname=leaf_config;charset=UTF8",
        'testuser',
        'testuserpass',
        array()
    );
    $sql = "SELECT * FROM $table WHERE path = '$sitePath';";
    $query = $db->prepare($sql);
    $query->execute(array());
    $res = $query->fetchAll(PDO::FETCH_ASSOC);

    return count($res) > 0;
}