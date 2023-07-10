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

        $this->index['GET']->register('system/importGroup/[digit]', function ($args) use ($system) {
            return $system->importGroup($args[0]);
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
        $system = $this->system;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();
            $this->index['POST']->register('system', function () {
            });

            $this->index['POST']->register('system/actions', function () use ($system) {
                return $system->addAction();
            });

            $this->index['POST']->register('system/setDestruction', function () use ($system) {
                return $system->setDestructionFlag();
            });

            $this->index['POST']->register('system/markDestruction', function () use ($system) {
                return $system->markForDestruction();
            });

            $this->index['POST']->register('system/settings/heading', function () use ($system) {
                $_POST['heading'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['heading']);

                return $system->setHeading();
            });

            $this->index['POST']->register('system/settings/subHeading', function () use ($system) {
                $_POST['subHeading'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['subHeading']);

                return $system->setSubHeading();
            });

            $this->index['POST']->register('system/settings/requestLabel', function () use ($system) {
                return $system->setRequestLabel();
            });

            $this->index['POST']->register('system/settings/timeZone', function () use ($system) {
                return $system->setTimeZone();
            });

            $this->index['POST']->register('system/settings/siteType', function () use ($system) {
                return $system->setSiteType();
            });

            $this->index['POST']->register('system/settings/national_linkedSubordinateList', function () use ($system) {
                return $system->setNationalLinkedSubordinateList();
            });

            $this->index['POST']->register('system/settings/national_linkedPrimary', function () use ($system) {
                return $system->setNationalLinkedPrimary();
            });

            $this->index['POST']->register('system/setPrimaryadmin', function () use ($system) {
                $_POST['userID'] = \Leaf\XSSHelpers::sanitizeHTML($_POST['userID']);
                return $system->setPrimaryAdmin();
            });

            $this->index['POST']->register('system/unsetPrimaryadmin', function () use ($system) {
                return $system->unsetPrimaryAdmin();
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $system = $this->system;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();
            $this->index['DELETE']->register('system', function () {
            });

            $this->index['DELETE']->register('system/deleteDestruction', function () use ($system) {
                return $system->deleteMarkedDestruction();
            });

            $this->index['DELETE']->register('system/files/delete', function () use ($system) {
                return $system->removeFile($_GET['file']);
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }

    }
}
