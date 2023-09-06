<?php
/*
   * As a work of the United States government, this project is in the public domain within the United States.
   */

namespace Portal;

class TemplateFileHistoryController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $templateFileHistory;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->templateFileHistory = new TemplateFileHistory($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $templateFileHistory = $this->templateFileHistory;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('templateFileHistory/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('templateFileHistory/[text]', function ($args) use ($templateFileHistory) {
            return $templateFileHistory->getTemplateFileHistory($args[0]);
        });

        $this->index['GET']->register('templateCompareFileHistory/[text]', function ($args) use ($templateFileHistory) {
            return $templateFileHistory->getComparedTemplateHistoryFile($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }


    public function post($act)
    {
        $templateFileHistory = $this->templateFileHistory;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {

            $this->index['POST'] = new ControllerMap();

            $this->index['POST']->register('templateFileHistory/[text]', function ($args) use ($templateFileHistory) {
                return $templateFileHistory->setTemplateFileHistory($args[0]);
            });

            $this->index['POST']->register('templateHistoryMergeFile/[text]', function ($args) use ($templateFileHistory) {
                return $templateFileHistory->setMergeTemplate($args[0]);
            });

            $this->index['POST']->register('templateEmailHistoryMergeFile/[text]', function ($args) use ($templateFileHistory) {
                return $templateFileHistory->setEmailMergeTemplate($args[0]);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}