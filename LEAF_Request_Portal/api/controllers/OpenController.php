<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class OpenController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $short;

    private $login;

    public function __construct($db, $login)
    {
        $this->short = new Shortener($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $short = $this->short;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('open/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('open', function ($args) {
        });

        $this->index['GET']->register('open/form/query/[text]', function ($args) use ($short) {
            return $short->getFormQuery($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $short = $this->short;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('open', function ($args) {
        });

        $this->index['POST']->register('open/form/query', function ($args) use ($short) {
            return $short->shortenFormQuery($_POST['data']);
        });

        $this->index['POST']->register('open/report', function ($args) use ($short) {
            return $short->shortenReport($_POST['data']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
