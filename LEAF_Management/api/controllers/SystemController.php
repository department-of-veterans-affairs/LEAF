<?php
/************************
    RESTful Controller
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: November 30, 2011

*/

require '../sources/System.php';

class SystemController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $system;
    private $db;
    private $login;

    function __construct($db, $login)
    {
    	$this->db = $db;
        $this->login = $login;
        $this->system = new System($db, $login);
    }

    public function get($act)
    {
    	$db = $this->db;
    	$login = $this->login;
    	$system = $this->system;
    	
        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('system/version', function() {
            return $this->API_VERSION;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('system', function($args) {
        });

       	$this->index['POST']->register('system/settings/heading', function($args) use ($system) {
       		return $system->setHeading($_POST['heading']);
       	});

       	$this->index['POST']->register('system/settings/subHeading', function($args) use ($system) {
       		return $system->setSubHeading($_POST['subHeading']);
       	});

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
