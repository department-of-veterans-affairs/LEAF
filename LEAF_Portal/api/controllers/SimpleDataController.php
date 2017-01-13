<?php

require '../form.php';

class SimpleDataController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $form;
    private $db;

    function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->db = $db;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('simpledata/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('simpledata/[digit]/[digit]/[digit]', function($args) use ($form) {
            $data = $form->getIndicator($args[1], $args[2], $args[0]);
            return $data;
        });
        
        $this->index['GET']->register('simpledata/equiptest', function($args) {
            $res = $this->db->query('SELECT SUM(data) as total FROM records_workflow_state
            					LEFT JOIN (SELECT * FROM data WHERE indicatorID=76) lj1 USING (recordID)
            					WHERE indicatorID IS NOT NULL');
            return $res[0];
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}

