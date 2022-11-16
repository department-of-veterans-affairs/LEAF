<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/EmailTemplate.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

class EmailTemplateController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $emailTemplate;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->emailTemplate = new EmailTemplate($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $emailTemplate = $this->emailTemplate;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('emailTemplates', function ($args) use ($emailTemplate) {
            return $emailTemplate->getEmailAndSubjectTemplateList();
        });

        $this->index['GET']->register('emailTemplates/[text]', function($args) use ($emailTemplate) {
            return $emailTemplate->getEmailTemplate($args[0]);
        });

        $this->index['GET']->register('emailTemplates/[text]/standard', function ($args) use ($emailTemplate) {
            return $emailTemplate->getEmailTemplate($args[0], true);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;
        $emailTemplate = $this->emailTemplate;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('emailTemplates/[text]', function ($args) use ($emailTemplate) {
            return $emailTemplate->setEmailTemplate($args[0]);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $db = $this->db;
        $login = $this->login;
        $emailTemplate = $this->emailTemplate;

        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();

        $this->index['DELETE']->register('emailTemplates/[text]', function ($args) use ($db, $login, $emailTemplate) {
            return $emailTemplate->removeCustomEmailTemplate($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
