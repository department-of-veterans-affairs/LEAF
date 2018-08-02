<?php

require '../../sources/NationalEmployee.php';

class NationalEmployeeController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $employee;

    function __construct($db, $login)
    {
        $this->employee = new OrgChart\NationalEmployee($db, $login);
    }

    public function get($act)
    {
        $employee = $this->employee;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('national/employee/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('national/employee/[digit]', function($args) use ($employee) {
            return $employee->getSummary($args[0]);
        });


        $this->index['GET']->register('national/employee/search', function() use ($employee) {
        	if(isset($_GET['noLimit']) && $_GET['noLimit'] == 1) {
        		$employee->setNoLimit();
        	}
        	if(isset($_GET['domain'])) {
        		$employee->setDomain($_GET['domain']);
        	}
            return $employee->search($_GET['q'], $_GET['indicatorID']);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
