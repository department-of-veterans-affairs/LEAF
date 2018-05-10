<?php

require '../sources/Signature.php';

/**
 * Handles API methods related to signatures.
 */
class SignaturesController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;

    private $signature;

    public function __construct($db, $login)
    {
        $this->signature = new Signature($db, $login);
    }

    public function get($action)
    {
        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('signature/version', function () {
            return $this->API_VERSION;
        });

        return $this->index['GET']->runControl($action['key'], $action['args']);
    }

    public function post($act)
    {
        $signature = $this->signature;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('signature/create', function () use ($signature) {
            return $signature->create(
                $_POST['signature'],
                (int)$_POST['recordID'],
                $_POST['message']
            );
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
