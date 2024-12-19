<?php
 /*
  * As a work of the United States government, this project is in the public domain within the United States.
  */

namespace Portal;

class TemplateEditorController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $templateEditor;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->templateEditor = new Template($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $templateEditor = $this->templateEditor;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('templateEditor/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('templateEditor', function ($args) use ($templateEditor) {
            return $templateEditor->getTemplateList();
        });

        $this->index['GET']->register('templateEditor/[text]', function ($args) use ($templateEditor) {
            return $templateEditor->getTemplate($args[0]);
        });

        $this->index['GET']->register('templateEditor/[text]/standard', function ($args) use ($templateEditor) {
            return $templateEditor->getTemplate($args[0], true);
        });


        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $templateEditor = $this->templateEditor;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();

            $this->index['POST']->register('templateEditor/[text]', function ($args) use ($templateEditor) {
                return $templateEditor->setTemplate($args[0]);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $templateEditor = $this->templateEditor;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();

            $this->index['DELETE']->register('templateEditor/[text]', function ($args) use ($templateEditor) {
                return $templateEditor->removeCustomTemplate($args[0]);
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
