<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use Nexus\Data\Repositories\Dao\DataDao;
use Nexus\Data\Repositories\Contracts\EmployeesRepository;

class EmployeesDao extends DataDao implements EmployeesRepository
{
    protected $connectionName = "nexus";
    protected $tableName = "employee";

    public $position;

    protected $dataTable = 'employee_data';

    protected $dataHistoryTable = 'employee_data_history';

    protected $dataTableUID = 'empUID';

    protected $dataTableDescription = 'Employee';

    protected $dataTableCategoryID = 1;

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($id)
    {
        return $this->getConn()->where('empUID', $id)->first();
    }

    public function getByUsername($username)
    {
        return $this->getConn()->where([
                ['userName', $username], 
                ['deleted', 0]
            ])->first();
    }

    public function lookupEmpUID($empUID)
    {
        if (isset($this->cache["lookupEmpUID_{$empUID}"]))
        {
            return $this->cache["lookupEmpUID_{$empUID}"];
        }

        $result =  $this->getConn()
        ->where([['empUID', $empUID], ['deleted', 0]])
        ->get()
        ->toArray();

        //fall back to the oldEmpUID
        if(count($result) === 0)
        {
            $result =  $this->getConn()
            ->where([['oldEmpUID', $empUID], ['deleted', 0]])
            ->get()
            ->toArray();
        }
        //fall back to the username
        if(count($result) === 0)
        {
            $result =  $this->getConn()
            ->where([['userName', $empUID], ['deleted', 0]])
            ->get()
            ->toArray();
        }
        $this->cache["lookupEmpUID_{$empUID}"] = $result;

        return $result;
    }

    public function VAMC_Directory_lookupEmpUID($empUID)
    {
        $res = $this->lookupEmpUID($empUID);
        $data = array();
        foreach ($res as $result)
        {
            $tdata = array();
            $tdata = $result;
            $tdata['Lname'] = $result['lastName'];
            $tdata['Fname'] = $result['firstName'];

            // orgchart data
            $ocData = $this->getAllData($result['empUID']);
            $tdata['Email'] = $ocData[6]['data'];
            $data[] = $tdata;
        }

        return $data;
    }

    //$login is userName
    public function lookupLogin($login)
    {
        $cacheHash = "lookupLogin{$login}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }
        $result =  $this->getConn()
        ->where([['userName', $login], ['deleted', 0]])
        ->get()
        ->toArray();

        $this->cache[$cacheHash] = $result;

        return $result;
    }

    //$login is userName
    public function VAMC_Directory_lookupLogin($login, $onlyGetName = false)
    {
        $res = $this->lookupLogin($login);
        $data = array();
        foreach ($res as $result)
        {
            $tdata = array();
            $tdata = $result;
            $tdata['Lname'] = $result['lastName'];
            $tdata['Fname'] = $result['firstName'];

            if (!$onlyGetName)
            {
                // orgchart data
                $ocData = $this->getAllData($result['empUID']);
                $tdata['Email'] = $ocData[6]['data'];
            }
            $data[] = $tdata;
        }

        return $data;
    }
}
