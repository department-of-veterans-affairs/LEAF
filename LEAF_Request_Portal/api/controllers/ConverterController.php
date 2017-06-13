<?php

class ConverterController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $login;

    function __construct($db, $login)
    {
        $this->login = $login;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('converter/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('converter', function($args) use ($form) {

        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $form = $this->form;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('converter', function($args) {
        });
        
        $this->index['POST']->register('converter/json', function($args) {
            return json_decode($_POST['input'], true);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}

