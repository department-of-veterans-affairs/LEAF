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
        $this->addRoute('GET', '/{otherFile}', 'Portal/other');
        $this->addRoute('GET', '/js/{jsFile}', 'Portal/js');
        $this->addRoute('GET', '/css/{cssFile}', 'Portal/css');
        $this->addRoute('GET', '/images/{imageFile}', 'Portal/image');

        $this->addRoute('GET', '/api/', 'Portal/api');
        $this->addRoute('GET', '/api/dynicons/', 'Portal/dynicons');
        $this->addRoute('GET', '/auth_domain/', 'Portal/auth_domain');
        $this->addRoute('GET', '/scripts/{scriptFile}', 'Portal/scripts');

        //admin routes
        $this->addRoute('GET', '/admin/', 'Portal/admin_index');
        $this->addRoute('GET', '/admin/css/{cssFile}', 'Portal/admin_css');
        $this->addRoute('GET', '/admin/js/{jsFile}', 'Portal/admin_js');
        $this->addRoute('GET', '/admin/{adminFile}', 'Portal/admin_other');
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