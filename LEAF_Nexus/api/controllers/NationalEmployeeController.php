<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/NationalEmployee.php';

class NationalEmployeeController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $employee;

    public function __construct($db, $login)
    {
        $this->employee = new OrgChart\NationalEmployee($db, $login);
    }

    public function get($act)
    {
        $employee = $this->employee;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('national/employee/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('national/employee/[text]', function ($args) use ($employee) {
            return $employee->getSummary($args[0]);
        });

        $this->index['GET']->register('national/employee/search', function () use ($employee) {
            if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1)
            {
                $employee->setNoLimit();
            }
            if (isset($_GET['domain']))
            {
                $employee->setDomain($_GET['domain']);
            }

            return $employee->search($_GET['q'], $_GET['indicatorID']);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
