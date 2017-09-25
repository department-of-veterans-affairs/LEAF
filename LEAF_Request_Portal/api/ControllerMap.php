<?php

class ControllerMap
{
    private $controllers = array();
    
    function __construct()
    {
        // register default controllers
    }
   
    /**
     * Register a controller, throwing an exception if there is an existing key
     * @param string $key
     * @param closure $code
     * @throws Exception
     */
    public function register($key, $code)
    {
        if(!isset($this->controllers[$key])) {
            $this->controllers[$key] = $code;
        }
        else {
            throw new Exception('Controller already exists.');
        }
    }

    /**
     * Run the control
     * @param string $key
     * @param array $args
     * @return string
     */
    public function runControl($key, $args = null)
    {
        if(isset($this->controllers[$key])) {
            return $this->controllers[$key]($args);
        }
        else {
            return 'Controller is undefined.';
        }
    }

    public function toStr()
    {
        $str = "";
        foreach ($this->controllers as $k => $v) {
            $str .= " ".$k."\n";
        }
        return $str."  End of ControllerMap\n";
    }
    
    public function listEndpoints() {
        return array_keys($this->controllers);
    }
}
