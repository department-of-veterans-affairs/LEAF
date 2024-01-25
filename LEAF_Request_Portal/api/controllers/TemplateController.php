<?php
 /*
  * As a work of the United States government, this project is in the public domain within the United States.
  */

namespace Portal;

class TemplateController extends RESTfulResponse
{
     public $index = array();

     private $API_VERSION = 1;    // Integer

     private $template;

     private $db;

     private $login;

     public function __construct($db, $login)
     {
         $this->db = $db;
         $this->login = $login;
         $this->template = new Template($db, $login);
     }

     public function get($act)
     {
         $db = $this->db;
         $login = $this->login;
         $template = $this->template;

         $this->index['GET'] = new ControllerMap();
         $cm = $this->index['GET'];
         $this->index['GET']->register('template/version', function () {
             return $this->API_VERSION;
         });

         $this->index['GET']->register('template', function ($args) use ($template) {
          return $template->getTemplateList();
      });

        $this->index['GET']->register('template/custom', function ($args) use ($template) {
            return $template->getCustomTemplateList();
        });

      $this->index['GET']->register('template/[text]', function ($args) use ($template) {
          return $template->getTemplate($args[0]);
      });

      $this->index['GET']->register('template/[text]/standard', function ($args) use ($template) {
          return $template->getTemplate($args[0], true);
      });


         return $this->index['GET']->runControl($act['key'], $act['args']);
     }

     public function post($act)
     {
        $template = $this->template;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();

            $this->index['POST']->register('template/[text]', function ($args) use ($template) {
                return $template->setTemplate($args[0]);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
     }

     public function delete($act)
     {
        $template = $this->template;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();

            $this->index['DELETE']->register('template/[text]', function ($args) use ($template) {
                return $template->removeCustomTemplate($args[0]);
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
     }
 }
