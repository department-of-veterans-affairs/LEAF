<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class TelemetryController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $telemetry;

    private $db;

    private $login;

    public function __construct($db, $login)
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
        $this->index['GET']->register('telemetry/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('telemetry/summary/month', function ($args) use ($telemetry) {
            return $telemetry->getRequestsPerMonth();
        });

        $this->index['GET']->register('telemetry/simple/requests', function ($args) use ($telemetry) {
            return $telemetry->getRequestsSimple($_GET['startTime'], $_GET['endTime']);
        });

        $this->index['GET']->register('telemetry/upload/storage', function ($args) use ($telemetry) {
            return $telemetry->getRequestUploadStorage();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
