<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class ServiceController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $db;

    private $login;

    private $service;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->service = new Service($db, $login);
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $service = $this->service;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('service/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('service', function ($args) use ($db, $login, $service) {
            return $service->getGroupsAndMembers();
        });

        $this->index['GET']->register('service/quadrads', function ($args) use ($db, $login, $service) {
            return $service->getQuadrads();
        });

        $this->index['GET']->register('service/[digit]/members', function ($args) use ($db, $login, $service) {
            return $service->getMembers($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $service = $this->service;

        if ($login->checkGroup(1)) {
          $verified = $this->verifyAdminReferrer();

          if ($verified) {
              echo $verified;
          } else {
              $this->index['POST'] = new ControllerMap();
              $this->index['POST']->register('service', function ($args) use ($service) {
                  return $service->addService(\Leaf\XSSHelpers::sanitizeHTML($_POST['service']), $_POST['groupID']);
              });

              $this->index['POST']->register('service/[digit]/members', function ($args) use ($service) {
                  return $service->addMember($args[0], $_POST['userID']);
              });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $service = $this->service;

        $verified = $this->verifyAdminReferrer();

        if ($login->checkGroup(1)) {
            if ($verified) {
                echo $verified;
            } else {
                $this->index['DELETE'] = new ControllerMap();
                $this->index['DELETE']->register('service', function ($args) {
                });

                $this->index['DELETE']->register('service/[digit]', function ($args) use ($service) {
                    return $service->removeService($args[0]);
                });

                $this->index['DELETE']->register('service/[digit]/members/[text]', function ($args) use ($service) {
                    return $service->removeMember($args[0], $args[1]);
                });

                return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
