<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once __DIR__ . '/../../../../LEAF_Request_Portal/form.php';

/**
 * FormController defines endpoints for testing
 * 
 * @version Release: 1.0
 */
class FormController extends RESTfulResponse
{
    public $index = array();

    private $form;

    private $login;

    private $db;

    /**
     * sets DB, login, and creates form object
     * @param object $db database object
     * @param object $login login object
     */
    public function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->login = $login;
        $this->db = $db;
    }

    /**
     * GET endpoints
     * @param string $act action object
     * @return mixed result of api call
     */
    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('form/[digit]/actionhistory', function ($args) use ($form) {
            return $form->getActionComments((int)$args[0]);
        });

        $this->index['GET']->register('form/[digit]/recordsworkflowstate', function ($args) use ($form) {
            $res = $this->db->prepared_query('SELECT * FROM records_workflow_state WHERE recordID = :recordID;', array(':recordID' => $args[0]));

            return $res;
        });

        $this->index['GET']->register('form/[digit]/tags', function ($args) use ($form) {
            $res = $this->db->prepared_query('SELECT * FROM tags WHERE recordID = :recordID;', array(':recordID' => $args[0]));

            return $res;
        });

        $this->index['GET']->register('form/[digit]/records_dependencies', function ($args) use ($form) {
            $res = $this->db->prepared_query('SELECT * FROM records_dependencies WHERE recordID = :recordID;', array(':recordID' => $args[0]));

            return $res;
        });
        
        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    /**
     * POST endpoints
     * @param string $act action object
     * @return mixed result of api call
     */
    public function post($act)
    {
        $form = $this->form;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('form/addbookmark', function ($args) use ($form) {
            return $form->addTag($_POST['recordID'], $_POST['tag']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
