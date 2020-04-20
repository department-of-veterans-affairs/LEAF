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

        $this->index['GET']->register('national/employee/[digit]', function ($args) use ($employee) {
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

    /**
     * Wrapper for post endpoints
     * 
     * @param $act endpoint
     * @return response for post endpoint
     */
    public function post($act)
    {
        $employee = $this->employee;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('national/employee/import/email', function() use ($employee) {
            try 
            {   
                $email = $_POST["email"];
                $username = $employee->lookupEmail($email);

                require_once __DIR__ . "/../../sources/Employee.php";
                require_once __DIR__ . "/../../sources/Login.php";
                require_once __DIR__ . "/../../config.php";
                require_once __DIR__ . "/../../db_mysql.php";

                $config = new Orgchart\Config();
                $db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
                $login = new Orgchart\Login($db, $db);
                $localEmp = new Orgchart\Employee($db, $login);

                $localUID = $localEmp->importFromNational($username[0]["userName"]);
                
                if (strcmp($localUID, "Invalid user") == 0) {
                    throw new Exception("Could not import invalid user");
                }

                $empObj = array("empUID" => $localUID,
                                "userName" => $username[0]["userName"],
                                "email" => $username[0]["data"]);

                return $empObj;
            }
            catch (Exception $e) 
            {
                http_response_code(404);
                return $e->getMessage();
            }
            
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
