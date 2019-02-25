<?php

namespace RequestPortal\Data\Repositories\Dao;

use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;

class PortalUsersDao extends CachedDbDao implements PortalUsersRepository
{
    protected $tableName = "users";

    public function getAll()
    {
        return $this->getConn()->select();
    }

    public function getById($userID)
    {
        return $this->getConn()->where('userID', $userID)->first();
    }

    public function isAdmin($userID)
    {
        $result = $this->getConn()->where('userID', $userID)->first();
        
        return $result->groupID == 1;
    }

    /**
     * Retrieves the positions and groups the current user is a member of
     * @return array
     * 
     * TODO this whole one
     */
    public function getMembership($userID)
    {
        $empUID = XSSHelpers::xscrub($this->empUID);

        if (isset($this->cache['getMembership_' . $empUID]))
        {
            return $this->cache['getMembership_' . $empUID];
        }

        $membership = array();
        // inherit permissions if employee is a backup for someone else
        $vars = array(':empUID' => XSSHelpers::xscrub($empUID));
        $res = $this->db->prepared_query('SELECT * FROM relation_employee_backup
                                            WHERE backupEmpUID=:empUID
        										AND approved=1', $vars);
        $temp = XSSHelpers::xscrub($empUID);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $var = XSSHelpers::xscrub($item['empUID']);
                $temp .= ",{$var}";
                $membership['inheritsFrom'][] = $var;
            }
            $vars = array(':empUID' => XSSHelpers::xscrub($temp));
        }

        $res = $this->db->prepared_query("SELECT positionID, empUID,
                                                relation_group_employee.groupID as employee_groupID,
                                                relation_group_position.groupID as position_groupID FROM employee
                                            LEFT JOIN relation_position_employee USING (empUID)
                                            LEFT JOIN relation_group_employee USING (empUID)
                                            LEFT JOIN relation_group_position USING (positionID)
                                            WHERE empUID IN ({$temp})", array());
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                if (isset($item['positionID']))
                {
                    $membership['positionID'][$item['positionID']] = 1;
                }
                /*	            if(isset($item['employee_groupID'])) {
                                    $membership['groupID'][$item['employee_groupID']] = 1;
                                }
                                if(isset($item['position_groupID'])) {
                                    $membership['groupID'][$item['position_groupID']] = 1;
                                }*/
            }
        }
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // incorporate groups from local DB
        $vars = array(':empUID' => $this->empUID);
        $res = $this->userDB->prepared_query('SELECT * FROM users
												WHERE empUID = :empUID', $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $membership['groupID'][$item['groupID']] = 1;
            }
        }
        $vars = array(':empUID' => $this->empUID);
        $res = $this->userDB->prepared_query('SELECT * FROM service_chiefs
												WHERE empUID = :empUID
													AND active=1', $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $membership['groupID'][$item['serviceID']] = 1;
            }
        }

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        $this->cache['getMembership_' . $empUID] = $membership;

        return $this->cache['getMembership_' . $empUID];
    }
}