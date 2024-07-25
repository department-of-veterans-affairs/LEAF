<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once __DIR__ . '/../../../../LEAF_Request_Portal/sources/FormEditor.php';

class FormEditorController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $formEditor;

    private $login;

    public function __construct($db, $login)
    {
        $this->formEditor = new FormEditor($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $formEditor = $this->formEditor;

        $this->index['GET'] = new ControllerMap();

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formEditor = $this->formEditor;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('formEditor/setFormat', function ($args) use ($formEditor) {
            return $formEditor->setFormat($_POST['indicatorID'], $_POST['format']);
        });

        $this->index['POST']->register('formEditor/genericFunctionCall/[text]', function ($args) use ($formEditor) {
            return call_user_func_array(array($formEditor, $args[0]), $_POST);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
