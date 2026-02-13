<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ExportController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $export;

    public function __construct($db, $login)
    {
        $this->export = new Export($db, $login);
    }

    public function get($act)
    {
        $export = $this->export;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('export/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('export/pdl', function ($args) use ($export) {
            return $export->exportPDL();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $this->index['POST'] = new ControllerMap();

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $this->index['DELETE'] = new ControllerMap();


        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
