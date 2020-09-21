<?php
error_reporting(E_ALL & ~E_NOTICE);
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/routing/Handlers.php';
require_once __DIR__ . '/routing/routing_config.php';
require_once __DIR__ . '/routing/portal_config.php';
require_once __DIR__ . '/routing/nexus_config.php';
require_once __DIR__ . '/routing/LEAFRoutes.php';
require_once __DIR__ . '/LEAF_Request_Portal/globals.php';

// Fetch method and URI
$httpMethod = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];
// Strip query string (?foo=bar) and decode URI
if (false !== $pos = strpos($uri, '?')) {
    $uri = substr($uri, 0, $pos);
}

//301 to add trailing slash
$segments = explode('/', $uri);
if (substr($uri, -1) !== '/' && strpos(end($segments), ".") === false) {
    $parts = explode('?', $_SERVER['REQUEST_URI'], 2);
    $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
    $redirectUri = $protocol . '://' . HTTP_HOST . $parts[0] . '/' . (isset($parts[1]) ? '?' . $parts[1] : '');
    $code = $httpMethod == "GET" ? 301 : 308;
    header('Location: '.$redirectUri, true, $code);
    exit;
}

//rewrite for api
if (false !== $pos = strpos($uri, '/api/')) {
    $_GET['a'] = isset($_GET['a']) ? $_GET['a'] : substr($uri, $pos+5);
    $uri = substr($uri, 0, $pos+5);
}

//Get sitepath
$uri = rawurldecode($uri);
$pattern = '(\/api\/|\/libs\/|\/js\/|\/css\/|\/images\/|\/files\/|\/admin\/|\/scripts\/|\/[^\/]*\.php|\/[^\/]*\.ico|\/auth_domain\/|\/auth_cookie\/|\/auth_token\/|\/login\/|\/utils\/|\/LEAF_test_endpoints\/)';
preg_match ($pattern , $uri, $matches, PREG_OFFSET_CAPTURE);
if(count($matches)){
    $sitePath = substr($uri, 0, $matches[0][1]+1);
    $uri = str_replace($sitePath,'/',$uri);
}else{
    $sitePath = $uri;
    $uri = '/';
}

$siteFound = false;
if(doesSiteExist('portal', $sitePath))//query for portal
{
    $db_config = new DB_Config($sitePath);
    $config = new Config($sitePath);
    $leafRoutes = new LEAFRoutes('portal');
    $siteFound = true;
}elseif(doesSiteExist('nexus', $sitePath))//query for nexus
{
    $config = new Orgchart\Config($sitePath);
    $leafRoutes = new LEAFRoutes('nexus');
    $siteFound = true;
}

if(!$siteFound){
    header("HTTP/1.0 404 Not Found");
        exit;
}
$routeCollectorFunction = function (FastRoute\RouteCollector $r) use ($leafRoutes) {
    foreach($leafRoutes->routes as $leafRoute){
        $r->addRoute($leafRoute->httpMethod, $leafRoute->path, $leafRoute->callback);
    }
};
//pass in routes
$dispatcher = FastRoute\simpleDispatcher($routeCollectorFunction);

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
        "mysql:host=".Routing_Config::$dbHost.";dbname=".Routing_Config::$dbName.";charset=UTF8",
        Routing_Config::$dbUser,
        Routing_Config::$dbPass,
        array()
    );
    $sql = "SELECT * FROM $table WHERE path = '$sitePath';";
    $query = $db->prepare($sql);
    $query->execute(array());
    $res = $query->fetchAll(PDO::FETCH_ASSOC);
    return count($res) > 0;
}