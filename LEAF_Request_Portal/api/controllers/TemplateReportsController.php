<?php
/*
  * As a work of the United States government, this project is in the public domain within the United States.
  */

namespace Portal;

class TemplateReportsController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $templateReports;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->templateReports = new TemplateReports($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $templateReports = $this->templateReports;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('reportTemplates/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('reportTemplates', function ($args) use ($templateReports) {
            return $templateReports->getReportTemplateList();
        });

        $this->index['GET']->register('reportTemplates/[text]', function ($args) use ($templateReports) {
            return $templateReports->getReportTemplate($args[0]);
        });
        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;
        $templateReports = $this->templateReports;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('reportTemplates', function ($args) use ($templateReports) {
            return $templateReports->newReportTemplate($_POST['filename']);
        });

        $this->index['POST']->register('reportTemplates/[text]', function ($args) use ($templateReports) {
            return $templateReports->setReportTemplate($args[0]);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $db = $this->db;
        $login = $this->login;
        $templateReports = $this->templateReports;

        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();

        $this->index['DELETE']->register('reportTemplates/[text]', function ($args) use ($db, $login, $templateReports) {
            return $templateReports->removeReportTemplate($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}