<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class SystemController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $system;

    private $db;

    private $oc_db;

    private $login;

    private $oc_login;

    public function __construct($db, $oc_db, $login, $oc_login, $vamc)
    {
        $this->db = $db;
        $this->oc_db = $oc_db;
        $this->login = $login;
        $this->oc_login = $oc_login;
        $this->system = new System($db, $login, $vamc);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $system = $this->system;
        $group = new \Orgchart\Group($this->oc_db, $this->oc_login);
        $position = new \Orgchart\Position($this->oc_db, $this->oc_login);
        $employee = new \Orgchart\Employee($this->oc_db, $this->oc_login);
        $tag = new \Orgchart\Tag($this->oc_db, $this->oc_login);

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('system/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('system/dbversion', function () use ($system) {
            return $system->getDatabaseVersion();
        });

        $this->index['GET']->register('system/updateService/[digit]', function ($args) use ($system, $group, $position, $employee, $tag) {
            return $system->updateService($args[0], $group, $position, $employee, $tag);
        });

        $this->index['GET']->register('system/updateGroup/[digit]', function ($args) use ($system, $group, $position, $employee, $tag) {
            return $system->updateGroup($args[0], $group, $position, $employee, $tag);
        });

        $this->index['GET']->register('system/importGroup/[digit]', function ($args) use ($system, $group, $position, $employee, $tag) {
            return $system->importGroup($args[0], $group, $position, $employee, $tag);
        });

        $this->index['GET']->register('system/services', function ($args) use ($system) {
            return $system->getServices();
        });

        $this->index['GET']->register('system/groups', function ($args) use ($system) {
            return $system->getGroups();
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

        $this->index['POST']->register('system/settings/heading', function ($args) use ($system) {
            $_POST['heading'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['heading']);

            return $system->setHeading();
        });

        $this->index['POST']->register('system/settings/subHeading', function ($args) use ($system) {
            $_POST['subHeading'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['subHeading']);

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
            $_POST['userID'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['userID']);
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

        $this->index['DELETE']->register('system/files/[text]', function ($args) use ($db, $login, $system) {
            return $system->removeFile($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
