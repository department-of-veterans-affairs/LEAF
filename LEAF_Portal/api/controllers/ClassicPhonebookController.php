<?php

require_once '../VAMC_Directory.php';

class ClassicPhonebookController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $phonebook;

    function __construct($db, $login)
    {
        $this->phonebook = new VAMC_Directory();
    }

    public function get($act)
    {
        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('classicphonebook/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('classicphonebook/search', function($args) {
            $data = $this->phonebook->search($_GET['q']);
            return $data;
        });

        $this->index['GET']->register('classicphonebook/search/[text]', function($args) {
            $data = $this->phonebook->search($args[0]);
            return $data;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}

