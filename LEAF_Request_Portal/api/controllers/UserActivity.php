<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */


class UserActivity extends RESTfulResponse
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
        $this->index['GET']->register('userActivity/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('userActivity', function ($args) use ($form) {
            return $_SESSION['lastAction'];
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
