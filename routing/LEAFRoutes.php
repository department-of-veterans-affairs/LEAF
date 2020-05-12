<?php
class LEAFRoutes {
    public $routes = [];

    public function __construct($routesToLoad)
    {
        if($routesToLoad == "portal"){
            $this->portalRoutes();
        }else{
            $this->nexusRoutes();
        }
    }

    private function portalRoutes(){
        $this->addRoute('GET', '/', 'Portal/default');
        $this->addRoute('GET', '/js/{jsfile}', 'Portal/js');
        $this->addRoute('GET', '/css/{cssfile}', 'Portal/css');
        $this->addRoute('GET', '/images/{imagefile}', 'Portal/image');
        $this->addRoute('GET', '/libs/dynicons/', 'Portal/dynicons');
        $this->addRoute('GET', '/libs/js/jquery/css/dcvamc/{cssfile}', 'Portal/libsjquerycss');
        //$this->addRoute('GET', '/libs/js/jquery/chosen/{cssfile}', 'Portal/libsjquerychosencss');
        $this->addRoute('GET', '/libs/js/jquery/trumbowyg/ui/{cssfile}', 'Portal/libstrumbowygcss');
        $this->addRoute('GET', '/libs/js/jquery/icheck/skins/square/{cssfile}', 'Portal/libsicheckcss');

        $this->addRoute('GET', '/libs/js/jquery/{jsfile}', 'Portal/js_jquery');
        $this->addRoute('GET', '/libs/js/jquery/chosen/{jsfile}', 'Portal/chosen');
        $this->addRoute('GET', '/libs/js/jquery/trumbowyg/{jsfile}', 'Portal/js_trumbowyg');
        $this->addRoute('GET', '/libs/js/jquery/icheck/{jsfile}', 'Portal/js_icheck');

        $this->addRoute('GET', '/api/', 'Portal/api');
        $this->addRoute('GET', '/api/dynicons/', 'Portal/dynicons');
    }
    private function nexusRoutes(){

    }
    private function addRoute($httpMethod, $path, $callback){
        $route = new stdClass;
        $route->httpMethod = $httpMethod;
        $route->path = $path;
        $route->callback = $callback;
        $this->routes[] = $route;
    }
}