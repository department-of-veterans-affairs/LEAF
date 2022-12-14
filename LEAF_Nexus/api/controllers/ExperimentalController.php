<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ExperimentalController extends RESTfulResponse
{
    public $index = array();

    private $db;
    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('x/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('x/demo', function ($args) use ($db, $login) {
            return 'example';
        });

        $this->index['GET']->register('x/position/employees/hrsmart/[digit]', function($args) use ($db, $login) {
            $position = new Position($db, $login);
            return $position->getEmployeesHrsmart($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $db = $this->db;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('x/demo', function ($args) use ($db, $login) {
            return 'example';
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $db = $this->db;
        $login = $this->login;

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('x/demo', function ($args) use ($db, $login) {
            return 'example';
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
