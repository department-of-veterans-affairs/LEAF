<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/System.php';

class SystemController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $system;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->system = new System($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('system/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('system/dbversion', function () use ($system) {
            return $system->getDatabaseVersion();
        });

        $this->index['GET']->register('system/templates', function ($args) use ($system) {
            return $system->getTemplateList();
        });

        $this->index['GET']->register('system/templates/[text]', function ($args) use ($system) {
            return $system->getTemplate($args[0]);
        });

        $this->index['GET']->register('system/reportTemplates', function ($args) use ($system) {
            return $system->getReportTemplateList();
        });

        $this->index['GET']->register('system/reportTemplates/[text]', function ($args) use ($system) {
            return $system->getReportTemplate($args[0]);
        });


        $this->index['GET']->register('system/employee/update/all', function() use ($system) {
            return $system->refreshOrgchartEmployees();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('system', function ($args) {
        });

        $this->index['POST']->register('system/templates/[text]', function ($args) use ($system) {
            return $system->setTemplate($args[0]);
        });

        $this->index['POST']->register('system/reportTemplates', function ($args) use ($system) {
            return $system->newReportTemplate($_POST['filename']);
        });

        $this->index['POST']->register('system/reportTemplates/[text]', function ($args) use ($system) {
            return $system->setReportTemplate($args[0]);
        });

        $this->index['POST']->register('system/settings/heading', function ($args) use ($system) {
            return $system->setHeading($_POST['heading']);
        });

        $this->index['POST']->register('system/settings/subHeading', function ($args) use ($system) {
            return $system->setSubHeading($_POST['subHeading']);
        });

        $this->index['POST']->register('system/settings/timeZone', function ($args) use ($system) {
            return $system->setTimeZone();
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('system', function ($args) {
        });

        $this->index['DELETE']->register('system/templates/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeCustomTemplate($args[0]);
        });

        $this->index['DELETE']->register('system/reportTemplates/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeReportTemplate($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
