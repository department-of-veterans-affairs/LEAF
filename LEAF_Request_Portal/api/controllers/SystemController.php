<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/System.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

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

        $this->index['GET']->register('system/updateService/[digit]', function ($args) use ($system) {
            return $system->updateService($args[0]);
        });

        $this->index['GET']->register('system/updateGroup/[digit]', function ($args) use ($system) {
            return $system->updateGroup($args[0]);
        });

        $this->index['GET']->register('system/services', function ($args) use ($system) {
            return $system->getServices();
        });

        $this->index['GET']->register('system/groups', function ($args) use ($system) {
            return $system->getGroups();
        });

        $this->index['GET']->register('system/templates', function ($args) use ($system) {
            return $system->getTemplateList();
        });

        $this->index['GET']->register('system/templates/[text]', function ($args) use ($system) {
            return $system->getTemplate($args[0]);
        });

        $this->index['GET']->register('system/templates/[text]/standard', function ($args) use ($system) {
            return $system->getTemplate($args[0], true);
        });

        $this->index['GET']->register('system/emailtemplates', function ($args) use ($system) {
            return $system->getEmailAndSubjectTemplateList();
        });

        $this->index['GET']->register('system/emailtemplates/[text]', function($args) use ($system) {
            return $system->getEmailTemplate($args[0]);
        });

        $this->index['GET']->register('system/emailtemplates/[text]/standard', function ($args) use ($system) {
            return $system->getEmailTemplate($args[0], true);
        });

        $this->index['GET']->register('system/reportTemplates', function ($args) use ($system) {
            return $system->getReportTemplateList();
        });

        $this->index['GET']->register('system/reportTemplates/[text]', function ($args) use ($system) {
            return $system->getReportTemplate($args[0]);
        });

        $this->index['GET']->register('system/files', function ($args) use ($system) {
            return $system->getFileList();
        });

        $this->index['GET']->register('system/settings', function ($args) use ($system) {
            return $system->getSettings();
        });

        $this->index['GET']->register('system/primaryadmin', function ($args) use ($system) {
            return $system->getPrimaryAdmin();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('system', function ($args) {
        });

        $this->index['POST']->register('system/actions', function ($args) use ($db, $login, $system) {
            return $system->addAction();
        });

        $this->index['POST']->register('system/templates/[text]', function ($args) use ($system) {
            return $system->setTemplate($args[0]);
        });

        $this->index['POST']->register('system/emailtemplates/[text]', function ($args) use ($system) {
            return $system->setEmailTemplate($args[0]);
        });

        $this->index['POST']->register('system/reportTemplates', function ($args) use ($system) {
            return $system->newReportTemplate($_POST['filename']);
        });

        $this->index['POST']->register('system/reportTemplates/[text]', function ($args) use ($system) {
            return $system->setReportTemplate($args[0]);
        });

        $this->index['POST']->register('system/settings/heading', function ($args) use ($system) {
            $_POST['heading'] = XSSHelpers::sanitizeHTML($_POST['heading']);

            return $system->setHeading();
        });

        $this->index['POST']->register('system/settings/subHeading', function ($args) use ($system) {
            $_POST['subHeading'] = XSSHelpers::sanitizeHTML($_POST['subHeading']);

            return $system->setSubHeading();
        });

        $this->index['POST']->register('system/settings/requestLabel', function ($args) use ($system) {
            return $system->setRequestLabel();
        });

        $this->index['POST']->register('system/settings/timeZone', function ($args) use ($system) {
            return $system->setTimeZone();
        });

        $this->index['POST']->register('system/settings/siteType', function ($args) use ($system) {
            return $system->setSiteType();
        });

        $this->index['POST']->register('system/settings/national_linkedSubordinateList', function ($args) use ($system) {
            return $system->setNationalLinkedSubordinateList();
        });

        $this->index['POST']->register('system/settings/national_linkedPrimary', function ($args) use ($system) {
            return $system->setNationalLinkedPrimary();
        });

        $this->index['POST']->register('system/setPrimaryadmin', function ($args) use ($system) {
            $_POST['userID'] = XSSHelpers::sanitizeHTML($_POST['userID']);
            return $system->setPrimaryAdmin();
        });

        $this->index['POST']->register('system/unsetPrimaryadmin', function ($args) use ($system) {
            return $system->unsetPrimaryAdmin();
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;

        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('system', function ($args) {
        });

        $this->index['DELETE']->register('system/templates/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeCustomTemplate($args[0]);
        });

        $this->index['DELETE']->register('system/emailtemplates/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeCustomEmailTemplate($args[0]);
        });

        $this->index['DELETE']->register('system/reportTemplates/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeReportTemplate($args[0]);
        });

        $this->index['DELETE']->register('system/files/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeFile($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
