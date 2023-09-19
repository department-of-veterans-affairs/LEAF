<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

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

        $this->index['GET']->register('formStack/categoryList', function ($args) use ($formStack) {
            return $formStack->getCategories();
        });

        $this->index['GET']->register('formStack/categoryList/all', function ($args) use ($formStack) {
            return $formStack->getAllCategories();
        });

        $this->index['GET']->register('formStack/categoryList/allWithStaples', function ($args) use ($formStack) {
            return $formStack->getAllCategoriesWithStaples();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formStack = $this->formStack;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();
            $this->index['POST']->register('formStack', function ($args) {
            });

            $this->index['POST']->register('formStack/import', function ($args) use ($formStack) {
                return $formStack->importForm();
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $formStack = $this->formStack;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();
            $this->index['DELETE']->register('workflow', function ($args) {
            });

            $this->index['DELETE']->register('formStack/[text]', function ($args) use ($formStack) {
                return $formStack->deleteForm(XSSHelpers::xscrub($args[0]));
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
