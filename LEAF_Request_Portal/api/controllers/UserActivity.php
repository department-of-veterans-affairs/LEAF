<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class UserActivity extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $login;

    public function __construct($db, $login)
    {
        $this->login = $login;
    }

    public function get($act)
    {
        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('userActivity/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('userActivity', function () {
            return $_SESSION['lastAction'];
        });

        $this->index['GET']->register('userActivity/warn/[digit]', function ($args) {
            $_SESSION['expireTime'] = (int)$args[0];
            return true;
        });

        $this->index['GET']->register('userActivity/status/[digit]', function ($args) {
            $reportedTime = (int)$args[0];
            if(isset($_SESSION['lastAction']) && $reportedTime > $_SESSION['lastAction']) {
                $_SESSION['lastAction'] = $reportedTime;
                $_SESSION['expireTime'] = null;
            }

            $status = [
                'lastAction' => $_SESSION['lastAction'],
                'sessExpireTime' => $_SESSION['expireTime'],
            ];
            return $status;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
