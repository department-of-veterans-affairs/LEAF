<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */


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
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('userActivity/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('userActivity', function ($args) use ($form) {
            return $_SESSION['lastAction'];
        });

        $this->index['GET']->register('userActivity/warn/[digit]', function ($args) use ($form) {
            $_SESSION['expireTime'] = (int)$args[0];
            return true;
        });

        $this->index['GET']->register('userActivity/status/[digit]', function ($args) use ($form) {
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
}
