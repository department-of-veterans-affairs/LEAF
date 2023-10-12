<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Api\v1;

class MapApi
{
    private $controllers = array();

    public function __construct()
    {
        // register default controllers
    }

    /**
     * Register a controller, throwing an exception if there is an existing key
     * @param string $key
     * @param \closure $code
     * @throws \Exception
     */
    public function register($key, $code)
    {
        if (!isset($this->controllers[$key]))
        {
            $this->controllers[$key] = $code;
        }
        else
        {
            throw new \Exception('Controller already exists.');
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
        if (isset($this->controllers[$key]))
        {
            return $this->controllers[$key]($args);
        }

        http_response_code(400);
        return 'Controller is undefined.';
    }
}
