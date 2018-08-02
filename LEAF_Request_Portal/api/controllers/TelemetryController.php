<?php

require '../../sources/Telemetry.php';

class TelemetryController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $telemetry;
    private $db;
    private $login;

    function __construct($db, $login)
    {
    	$this->db = $db;
        $this->login = $login;
        $this->telemetry = new Telemetry($db, $login);
    }

    public function get($act)
    {
    	$db = $this->db;
    	$login = $this->login;
    	$telemetry = $this->telemetry;
    	
        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('telemetry/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('telemetry/summary/month', function($args) use ($telemetry) {
        	return $telemetry->getRequestsPerMonth();
        });

       	$this->index['GET']->register('telemetry/simple/requests', function($args) use ($telemetry) {
       		return $telemetry->getRequestsSimple($_GET['startTime'], $_GET['endTime']);
       	});

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
