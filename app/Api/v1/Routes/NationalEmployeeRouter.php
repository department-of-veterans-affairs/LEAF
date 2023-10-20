<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Api\v1\Routes;

use App\Api\v1\ApiMap;
use App\Api\v1\RESTfulResponse;
use App\Nexus\Controllers\NationalEmployeeController;
use Orgchart\Employee;

class NationalEmployeeRouter extends RESTfulResponse
{
    public $index = array();

    protected $employee;

    public function __construct(NationalEmployeeController $controller, ApiMap $map, Employee $employee)
    {
        $this->controller = $controller;
        $this->map = $map;
        $this->employee = $employee;
    }

    public function get(array $act): mixed
    {
        $employee = $this->controller;

        $this->index['GET'] = $this->map;

        $this->index['GET']->register('national/employee/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('national/employee/search', function () use ($employee) {
            error_log(print_r('hit', true));
            if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1) {
                $employee->setNoLimit();
            }

            if (isset($_GET['domain'])) {
                $employee->setDomain($_GET['domain']);
            }

            if (isset($_GET['includeDisabled'])) {
                if (isset($_GET['indicatorID'])) {
                    return $employee->search($_GET['q'], $_GET['indicatorID'], $_GET['includeDisabled']);
                } else {
                    return $employee->search($_GET['q'], '', $_GET['includeDisabled']);
                }

            } else {
                if (isset($_GET['indicatorID'])) {
                    return $employee->search($_GET['q'], $_GET['indicatorID']);
                } else {
                    return $employee->search($_GET['q']);
                }
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
    public function post(array $act): mixed
    {
        $employee = $this->controller;
        $localEmp = $this->employee;

        $this->index['POST'] = $this->map;
        $this->index['POST']->register('national/employee/import/email', function() use ($employee, $localEmp) {
            try
            {
                $email = $_POST["email"];
                $username = $employee->lookupEmail($email);

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

    public function delete(array $act): mixed
    {
        // this method is not used here
    }
}
