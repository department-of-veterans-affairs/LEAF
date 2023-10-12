<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Api\v1;

use App\Nexus\Controllers\NationalEmployeeController;
use Orgchart\Employee;
use Orgchart\Login;

class NationalEmployeeApi extends RESTfulResponseApi
{
    public $index = array();

    private $employee;

    private $db;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->employee = new NationalEmployeeController($db, $login);
    }

    public function get($act)
    {
        $employee = $this->employee;

        $this->index['GET'] = new MapApi();
        $this->index['GET']->register('national/employee/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('national/employee/[digit]', function ($args) use ($employee) {
            // getSummary does not exist in the NationalEmployee class
            // return $employee->getSummary($args[0]);
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
            if (isset($_GET['includeDisabled'])) {
                return $employee->search($_GET['q'], $_GET['indicatorID'], $_GET['includeDisabled']);
            } else {
                return $employee->search($_GET['q'], $_GET['indicatorID']);
            }

        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    /**
     * Wrapper for post endpoints
     *
     * @param array $act
     *
     * @return mixed
     *
     * Created at: 12/2/2022, 1:43:20 PM (America/New_York)
     */
    public function post($act)
    {
        $employee = $this->employee;

        $this->index['POST'] = new MapApi();
        $this->index['POST']->register('national/employee/import/email', function() use ($employee) {
            try
            {
                $email = $_POST["email"];
                $username = $employee->lookupEmail($email);

                $login = new Login($this->db, $this->db);
                $localEmp = new Employee($this->db, $login);

                $localUID = $localEmp->importFromNational($username[0]["userName"]);

                if (strcmp($localUID, "Invalid user") == 0) {
                    throw new \Exception("Could not import invalid user");
                }

                $empObj = array("empUID" => $localUID,
                                "userName" => $username[0]["userName"],
                                "email" => $username[0]["data"]);

                return $empObj;
            }
            catch (\Exception $e)
            {
                http_response_code(404);
                return $e->getMessage();
            }

        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
