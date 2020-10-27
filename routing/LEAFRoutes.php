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
        $this->addRoute('GET', '/js/{jsFile:.+}', 'Portal/js');
        $this->addRoute('GET', '/css/{cssFile:.+}', 'Portal/css');
        $this->addRoute('GET', '/images/{imageFile:.+}', 'Portal/image');
        $this->addRoute('GET', '/files/{fileName:.+}', 'Portal/file');
        $this->addRoute('GET', '/login/', 'Portal/login');

        $this->addRoute(['GET','POST','DELETE'], '/api/', 'Portal/api');
        $this->addRoute('GET', '/api/dynicons/', 'Portal/dynicons');
        $this->addRoute('GET', '/auth_domain/', 'Portal/auth_domain');
        $this->addRoute('GET', '/auth_domain/LEAF_Coach_Key.php', 'Portal/auth_domain_coach_key');
        $this->addRoute('GET', '/auth_domain/api/', 'Portal/auth_domain_api');
        $this->addRoute('GET', '/auth_cookie/', 'Portal/auth_cookie');
        $this->addRoute('GET', '/auth_token/', 'Portal/auth_token');
        $this->addRoute('GET', '/scripts/{scriptFile:.+}', 'Portal/scripts');
        $this->addRoute(['GET','POST','DELETE'], '/{favicon:[a-zA-Z]+\b.ico}', 'Portal/favicon');
        
        //admin routes
        $this->addRoute('GET', '/admin/', 'Portal/admin_index');
        $this->addRoute('GET', '/admin/css/{cssFile:.+}', 'Portal/admin_css');
        $this->addRoute('GET', '/admin/js/{jsFile:.+}', 'Portal/admin_js');
        $this->addRoute(['GET','POST','DELETE'], '/admin/{adminFile:.+}', 'Portal/admin_other');

        //test routes
        $this->addRoute(['GET','POST','DELETE'], '/LEAF_test_endpoints/nexus/', 'Test/nexus');
        $this->addRoute(['GET','POST','DELETE'], '/LEAF_test_endpoints/request_portal/', 'Test/request_portal');
        //default
        $this->addRoute(['GET','POST','DELETE'], '/{otherFile:.+}', 'Portal/other');
        
    }
    private function nexusRoutes(){
        $this->addRoute('GET', '/', 'Nexus/default');
        $this->addRoute(['GET','POST','DELETE'], '/api/', 'Nexus/api');
        $this->addRoute('GET', '/auth_domain/', 'Nexus/auth_domain');
        $this->addRoute('GET', '/auth_cookie/', 'Nexus/auth_cookie');
        $this->addRoute('GET', '/auth_token/', 'Nexus/auth_token');
        $this->addRoute('GET', '/js/{jsFile:.+}', 'Nexus/js');
        $this->addRoute('GET', '/css/{cssFile:.+}', 'Nexus/css');
        $this->addRoute('GET', '/images/{imageFile:.+}', 'Nexus/image');
        $this->addRoute('GET', '/login/', 'Nexus/login');

        $this->addRoute('GET', '/admin/', 'Nexus/admin_index');
        $this->addRoute('GET', '/admin/css/{cssFile:.+}', 'Nexus/admin_css');
        $this->addRoute(['GET','POST','DELETE'], '/admin/{adminFile:.+}', 'Nexus/admin_other');
        //default
        $this->addRoute(['GET','POST','DELETE'], '/{otherFile:.+}', 'Nexus/other');
    }

    private function addRoute($httpMethod, $path, $callback){
        $route = new stdClass;
        $route->httpMethod = $httpMethod;
        $route->path = $path;
        $route->callback = $callback;
        $this->routes[] = $route;
    }
}