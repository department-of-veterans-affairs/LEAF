<?php
/*
  * As a work of the United States government, this project is in the public domain within the United States.
  */

namespace Portal;

class AppletController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $applet;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->applet = new Applet($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $applet = $this->applet;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('applet/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('applet', function ($args) use ($applet) {
            return $applet->getReportTemplateList();
        });

        $this->index['GET']->register('applet/[text]', function ($args) use ($applet) {
            return $applet->getReportTemplate($args[0]);
        });

        $this->index['GET']->register('applet/getHistoryFiles/[text]', function ($args) use ($applet) {
            return $applet->getHistoryReportTemplate($args[0]);
        });
        $this->index['GET']->register('applet/getCompareHistoryHistoryFiles/[text]', function ($args) use ($applet) {
            return $applet->getCompareHistoryReportTemplate($args[0]);
        });
        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $applet = $this->applet;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();

            $this->index['POST']->register('applet', function () use ($applet) {
                return $applet->newReportTemplate($_POST['filename']);
            });

            $this->index['POST']->register('applet/[text]', function ($args) use ($applet) {
                return $applet->setReportTemplate($args[0]);
            });

            $this->index['POST']->register('applet/fileHistory/[text]', function ($args) use ($applet) {
                return $applet->setReportTemplateFileHistory($args[0]);
            });

            $this->index['POST']->register('applet/mergeFileHistory/saveReportMergeTemplate/[text]', function ($args) use ($applet) {
                return $applet->setReportMergeTemplate($args[0]);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $applet = $this->applet;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();

            $this->index['DELETE']->register('applet/[text]', function ($args) use ($applet) {
                return $applet->removeReportTemplate($args[0]);
            });

            $this->index['DELETE']->register('applet/deleteHistoryFileReport/[text]', function ($args) use ($applet) {
                return $applet->removeHistoryReportTemplate($args[0]);
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
