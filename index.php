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
$queryPos = strpos($uri, '?');
if ($queryPos !== false) {
    $uri = substr($uri, 0, $queryPos);
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
$apiPos = strpos($uri, '/api/');
if ($apiPos !== false) {
    $_GET['a'] = isset($_GET['a']) ? $_GET['a'] : substr($uri, $apiPos+5);
    $uri = substr($uri, 0, $apiPos+5);
}

//Get sitepath
$uri = rawurldecode($uri);

$pattern = '(' . addslashes(implode("|",Routing_Config::$pathDelimiterArray)) . ')';
preg_match ($pattern , $uri, $matches, PREG_OFFSET_CAPTURE);
if(count($matches)){
    $sitePath = substr($uri, 0, $matches[0][1]+1);
    $uri = str_replace($sitePath,'/',$uri);
}else{
    $sitePath = $uri;
    $uri = '/';
}

//set $isOrgchart
$pattern = '(' . addslashes(implode("|",Routing_Config::$orgchartArray)) . ')';
preg_match ($pattern , $sitePath, $matches, PREG_OFFSET_CAPTURE);
$isOrgchart = count($matches) > 0;

//skip config lookup if looking for static files
$pattern = '(' . addslashes(implode("|",Routing_Config::$configBypassArray)) . ')';
preg_match ($pattern , $uri, $matches, PREG_OFFSET_CAPTURE);
if (count($matches)) {    
    if($isOrgchart)
    {
        $leafRoutes = new LEAFRoutes('orgchart');
    }
    else
    {
        $leafRoutes = new LEAFRoutes('portal');
    }
}
else
{
    $db = new PDO(
        "mysql:host=".Routing_Config::$dbHost.";dbname=".Routing_Config::$dbName.";charset=UTF8",
        Routing_Config::$dbUser,
        Routing_Config::$dbPass,
        array()
    );
    $siteFound = false;
    if(!$isOrgchart)//query for portal
    {
        $sql = "SELECT a.*, b.database_name as phonedbName, b.path as orgchart_path_ext FROM portal_configs as a JOIN orgchart_configs as b ON a.orgchart_id = b.id WHERE a.path = '$sitePath';";
        $query = $db->prepare($sql);
        $query->execute(array());
        $res = $query->fetchAll(PDO::FETCH_ASSOC);
        if(count($res) > 0)
        {
            $db_config = new DB_Config($res);
            $config = new Config($res);
            $leafRoutes = new LEAFRoutes('portal');
            $siteFound = true;
        }
    }else//query for nexus
    {
        $sql = "SELECT * FROM orgchart_configs WHERE path = '$sitePath';";
        $query = $db->prepare($sql);
        $query->execute(array());
        $res = $query->fetchAll(\PDO::FETCH_ASSOC);
        if(count($res) > 0)
        {
            $config = new Orgchart\Config($res);
            $leafRoutes = new LEAFRoutes('nexus');
            $siteFound = true;
        }
    }

    if(!$siteFound){
        handleRoute([FastRoute\Dispatcher::NOT_FOUND]);
    }
}

$routeCollectorFunction = function (FastRoute\RouteCollector $r) use ($leafRoutes) {
    foreach($leafRoutes->routes as $leafRoute){
        $r->addRoute($leafRoute->httpMethod, $leafRoute->path, $leafRoute->callback);
    }
};
//pass in routes
$dispatcher = FastRoute\simpleDispatcher($routeCollectorFunction);

$routeInfo = $dispatcher->dispatch($httpMethod, $uri);
handleRoute($routeInfo);

function handleRoute($routeInfo)
{
    switch ($routeInfo[0]) {
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
        case FastRoute\Dispatcher::NOT_FOUND:
        default:
            header("HTTP/1.0 404 Not Found");
            include __DIR__ . '/error_404.php';
            exit;
            break;
    }
}
