<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class SimpleDataController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $form;

    private $db;

    public function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->db = $db;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('simpledata/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('simpledata/[digit]/[digit]/[digit]', function ($args) use ($form) {
            $data = $form->getIndicator($args[1], $args[2], $args[0]);

            return $data;
        });

        $this->index['GET']->register('simpledata/equiptest', function ($args) {
            $res = $this->db->prepared_query('SELECT SUM(data) as total FROM records_workflow_state
            					LEFT JOIN (SELECT * FROM data WHERE indicatorID=76) lj1 USING (recordID)
            					WHERE indicatorID IS NOT NULL', array());

            return $res[0];
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
