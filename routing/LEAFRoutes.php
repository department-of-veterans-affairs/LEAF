<?php
class LEAFRoutes {
    public $routes = [];

    public function __construct($routesToLoad)
    {
        if($routesToLoad == "portal"){
            $this->portalRoutes();
        }elseif($routesToLoad == 'nexus' || $routesToLoad == 'orgchart'){
            $this->nexusRoutes();
        }
    }

    private function portalRoutes(){
        $this->addRoute('GET', '/', 'Portal/default');
        $this->addRoute('GET', '/js/{jsfile}', 'Portal/js');
        $this->addRoute('GET', '/css/{cssfile}', 'Portal/css');
        $this->addRoute('GET', '/images/{imagefile}', 'Portal/image');

        $this->addRoute('GET', '/api/', 'Portal/api');
        $this->addRoute('GET', '/api/dynicons/', 'Portal/dynicons');
        $this->addRoute('GET', '/auth_domain/', 'Portal/auth_domain');
    }
    private function nexusRoutes(){
        $this->addRoute('GET', '/', 'Nexus/default');
    }
    private function addRoute($httpMethod, $path, $callback){
        $route = new stdClass;
        $route->httpMethod = $httpMethod;
        $route->path = $path;
        $route->callback = $callback;
        $this->routes[] = $route;
    }
}