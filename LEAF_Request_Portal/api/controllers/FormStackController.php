<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/FormStack.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

class FormStackController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $formStack;

    private $login;

    public function __construct($db, $login)
    {
        $this->formStack = new FormStack($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $formStack = $this->formStack;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('formStack/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('formStack', function ($args) use ($formStack) {
        });

        $this->index['GET']->register('formStack/categoryList/all', function ($args) use ($formStack) {
            return $formStack->getAllCategories();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formStack = $this->formStack;
        $login = $this->login;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('formStack', function ($args) {
        });

        $this->index['POST']->register('formStack/import', function ($args) use ($formStack) {
            $formStack->import();
        });

        $this->index['POST']->register('formStack/importLiteral', function ($args) use ($formStack) {
            $formStack->import(true);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $formStack = $this->formStack;

        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('workflow', function ($args) {
        });

        $this->index['DELETE']->register('formStack/[text]', function ($args) use ($formStack) {
            return $formStack->deleteForm(XSSHelpers::xscrub($args[0]));
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
