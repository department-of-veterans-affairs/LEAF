<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class ConverterController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $login;

    public function __construct($db, $login)
    {
        $this->login = $login;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('converter/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('converter', function ($args) use ($form) {
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $form = $this->form;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('converter', function ($args) {
        });

        $this->index['POST']->register('converter/json', function ($args) {
            return XSSHelpers::scrubObjectOrArray(json_decode($_POST['input'], true));
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
