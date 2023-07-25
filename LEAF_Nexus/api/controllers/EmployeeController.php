<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class EmployeeController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $employee;

    private $national_db;

    public function __construct($db, $login, $national_db = false)
    {
        $this->employee = new Employee($db, $login);
        $this->national_db = $national_db;
    }

    public function get($act)
    {
        $employee = $this->employee;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('employee/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('employee/[digit]', function ($args) use ($employee) {
            return $employee->getSummary((int)$args[0]);
        });

        $this->index['GET']->register('employee/[digit]/backup', function ($args) use ($employee) {
            return $employee->getBackups($args[0]);
        });

        $this->index['GET']->register('employee/[digit]/backupFor', function ($args) use ($employee) {
            return $employee->getBackupsFor($args[0]);
        });

        $this->index['GET']->register('employee/search', function () use ($employee) {
            if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1)
            {
                $employee->setNoLimit();
            }

            return $employee->search($_GET['q'], $_GET['indicatorID']);
        });

        $this->index['GET']->register('employee/search/userName/[text]', function ($args) use ($employee) {
            return $employee->lookupLogin($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $employee = $this->employee;
        $national_db = $this->national_db;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('employee', function ($args) {
            return print_r($args, true) . print_r($_GET, true);
        });

        // Deprecated
        $this->index['POST']->register('employee/refresh/[text]/[digit]', function ($args) use ($employee, $national_db) {
            if (!$national_db) {
                $return_value = $employee->refresh($args[0]);
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'You can\'t update the national orgchart'
                    )
                );
            }

            return json_encode($return_value);
        });

        $this->index['POST']->register('employee/refresh/[text]', function ($args) use ($employee, $national_db) {
            if (!$national_db) {
                $return_value = $employee->refresh($args[0]);
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'You can\'t update the national orgchart'
                    )
                );
            }

            return json_encode($return_value);
        });

        $this->index['POST']->register('employee/refresh/batch', function ($args) use ($employee, $national_db) {
            if (!$national_db) {
                $return_value = $employee->refreshBatch();
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'You can\'t update the national orgchart'
                    )
                );
            }

            return json_encode($return_value);
        });

        $this->index['POST']->register('employee/new', function ($args) use ($employee) {
            try
            {
                return $employee->addNew($_POST['firstName'], $_POST['lastName'], $_POST['middleName'], $_POST['userName']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('employee/[digit]', function ($args) use ($employee) {
            try
            {
                return $employee->modify($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('employee/[digit]/backup', function ($args) use ($employee) {
            try
            {
                return $employee->setBackup($args[0], $_POST['backupEmpUID']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('employee/[digit]/activate', function ($args) use ($employee) {
            try
            {
                return $employee->enableAccount($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('employee/import/[text]', function ($args) use ($employee) {
            try
            {
                return $employee->importFromNational($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $employee = $this->employee;

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('employee', function ($args) {
            return print_r($args, true) . print_r($_GET, true);
        });

        $this->index['DELETE']->register('employee/[digit]', function ($args) use ($employee) {
            try
            {
                return $employee->disableAccount($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        $this->index['DELETE']->register('employee/[digit]/backup/[digit]', function ($args) use ($employee) {
            try
            {
                return $employee->removeBackup($args[0], $args[1]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
