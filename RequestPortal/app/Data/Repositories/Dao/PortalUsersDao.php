<?php

namespace RequestPortal\Data\Repositories\Dao;

use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;

class PortalUsersDao extends CachedDbDao implements PortalUsersRepository
{
    protected $tableName = "users";

    protected $cache = array();

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
        $result = $this->getById($userID);
        
        return $result['groupID'] == 1;
    }

    /**
     * Retrieves the positions and groups the current user is a member of
     * @return array
     */
    public function getMembership($userID)
    {
        $empUID = $this->getEmpUID($userID);

        if (isset($this->cache['getMembership_' . $empUID]))
        {
            return $this->cache['getMembership_' . $empUID];
        }

        $membership = array();
        // inherit permissions if employee is a backup for someone else
        $res = $this->getConnForTable('relation_employee_backup')
            ->where([['backupEmpUID', $empUID],['approved', 1]])
            ->get()
            ->toArray();  
        $temp = array($empUID);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $item = (array) $item;
                $var = $item['empUID'];
                $temp[] = $var;
                $membership['inheritsFrom'][] = $var;
            }
        }
        $res = $this->getConnForTable('employee')
                ->select('relation_group_position.positionID', 'employee.empUID', 'relation_group_employee.groupID as employee_groupID', 'relation_group_position.groupID as position_groupID')
                ->leftJoin('relation_position_employee', 'employee.empUID', '=', 'relation_position_employee.empUID')
                ->leftJoin('relation_group_employee', 'employee.empUID', '=', 'relation_position_employee.empUID')
                ->leftJoin('relation_group_position', 'relation_position_employee.positionID', '=', 'relation_group_position.positionID')
                ->whereIn('employee.empUID', $temp)
                ->get()
                ->toArray();  
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $item = (array) $item;
                if (isset($item['positionID']))
                {
                    $membership['positionID'][$item['positionID']] = 1;
                }
            }
        }
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // incorporate groups from local DB
        $res = $this->getConn()
            ->where('empUID', $empUID)
            ->get()
            ->toArray();  
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $item = (array) $item;
                $membership['groupID'][$item['groupID']] = 1;
            }
        }

        $res = $this->getConnForTable('service_chiefs')
            ->where([['empUID', $empUID],['active', 1]])
            ->get()
            ->toArray();  
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $item = (array) $item;
                $membership['groupID'][$item['serviceID']] = 1;
            }
        }

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        $this->cache['getMembership_' . $empUID] = $membership;

        return $this->cache['getMembership_' . $empUID];
    }

    public function getEmpUID($userID)
    {
        $result = $this->getById($userID);
        return $result['empUID'];
    }

    /**
     * Checks if the current user is part of a group
     * @param int $groupID Group ID number
     * @return boolean
     */
    public function checkGroup($userID, $groupID)
    {
        
        $empUID = $this->getEmpUID($userID);
        if (!isset($this->cache['checkGroup']))
        {
            $result = $this->getConn()
                ->where('empUID', $empUID)
                ->get()
                ->toArray(); 

            foreach ($result as $group)
            {
                $this->cache['checkGroup'][$group['groupID']] = true;
            }
        }

        // special case for "Everyone" groupID 2, workaround until Orgchart is more integrated
        if ($groupID == 2)
        {
            $this->cache['checkGroup'][2] = true;
        }

        if (!isset($this->cache['checkGroup']))
        {
            $this->cache['checkGroup'] = array();
        }

        return isset($this->cache['checkGroup'][$groupID]);
    }

    /**
     * Checks if the current user has service chief access for a particular service
     * @param int $groupID Service ID number
     * @return boolean
     */
    public function checkService($userID, $serviceID)
    {
        $empUID = $this->getEmpUID($userID);
        if (isset($this->cache["isInService$groupID"]))
        {
            return $this->cache["isInService$groupID"];
        }
        $result = $this->getConnForTable('service_chiefs')
            ->where([['empUID', $empUID],['serviceID', $serviceID],['active', 1]])
            ->get()
            ->toArray(); 

        if (isset($result[0]))
        {
            $this->cache["isInService$groupID"] = true;

            return true;
        }
        $this->cache["isInService$groupID"] = false;

        return false;
    }

    public function getQuadradGroupID($userID)
    {
        $empUID = $this->getEmpUID($userID);
        if (isset($this->cache['getQuadradGroupID']))
        {
            return $this->cache['getQuadradGroupID'];
        }

        $result = $this->getConnForTable('groups')
            ->leftJoin('users', 'groups.groupID', '=', 'users.groupID')
            ->where([['empUID', $empUID], ['parentGroupID', -1]])
            ->get()
            ->toArray(); 

        $buffer = '';
        foreach ($result as $group)
        {
            $group = (array) $group;
            $buffer .= $group['groupID'] . ',';
        }
        $buffer = trim($buffer, ',');

        if (isset($result[0]))
        {
            $this->cache['getQuadradGroupID'] = $buffer;

            return $buffer;
        }
        $this->cache['getQuadradGroupID'] = 0;

        return 0;
    }

    /**
     * Checks if the current user has access to a particular dependency
     * @param dependencyID
     * @param details - Associative Array containing dependency-specific details, eg: $details['groupID']
     * @return boolean
     */
    public function hasDependencyAccess($userID, $dependencyID, $details)
    {
        switch ($dependencyID) {
            case 1:
                if ($this->checkService($userID, $details['serviceID']))
                {
                    return true;
                }

                break;
            case 8:
                $quadGroupIDs = $this->getQuadradGroupID($userID);
                $res3 = array();
                if ($quadGroupIDs != 0)
                {
                    if (isset($this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']]))
                    {
                        $res3 = $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']];
                    }
                    else
                    {
                        $res3 = $this->getConnForTable('services')
                            ->where('serviceID', $details['serviceID'])
                            ->whereIn('groupID', explode(',', $quadGroupIDs))
                            ->get()
                            ->toArray();

                        $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']] = $res3;
                    }
                }

                if (isset($res3[0]))
                {
                    return true;
                }

                break;
            case -1: // dependencyID -1 : person designated by the requestor
                $empUID = 0;
                if (isset($this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']]))
                {
                    $empUID = $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']];
                }
                else
                {
                    $resEmpUID = $this->getConnForTable('services')
                        ->where([['series', 1],['recordID',$details['recordID']],['indicatorID',$details['indicatorID_for_assigned_empUID']]])
                        ->get()
                        ->toArray();
                    if (isset($resEmpUID[0]))
                    {
                        $empUID = $resEmpUID[0]['data'];
                        $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']] = $empUID;
                    }
                }

                //check if the requester has any backups 
                $nexusDB = new CachedDbDao();
                $nexusDB->connectionName = 'nexus';
                $backupIds = $this->getConnForTable('relation_employee_backup')
                    ->where('empUID', $empUID)
                    ->get()
                    ->toArray();

                if ($empUID == $this->getEmpUID($userID))
                {
                    return true;
                }
                    //check and provide access to backups
                    foreach ($backupIDs as $row)
                    {
                        $row = (array) $row;
                        if ($row['backupEmpUID'] == $this->getEmpUID($userID))
                        {
                            return true;
                        }
                    }

                break;
            case -2: // dependencyID -2 : requestor followup
                $resPerson = $this->getConnForTable('records')
                    ->select('empUID')
                    ->where('recordID',$details['recordID'])
                    ->get()
                    ->toArray();

                if ($resPerson[0]['empUID'] == $this->getEmpUID($userID))
                {
                    return true;
                }

                break;
            case -3: // dependencyID -3 : group designated by the requestor
                $groupID = 0;
                if (isset($this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']]))
                {
                    $groupID = $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']];
                }
                else
                {
                    $resGroupID = $this->getConnForTable('data')
                        ->where([['series', 1],['recordID',$details['recordID']],['indicatorID',$details['indicatorID_for_assigned_groupID']]])
                        ->get()
                        ->toArray();
                    if (isset($resGroupID[0]))
                    {
                        $groupID = $resGroupID[0]['data'];
                        $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']] = $groupID;
                    }
                }

                if ($this->checkGroup($userID, $groupID))
                {
                    return true;
                }

                break;
            default:
                if ($this->checkGroup($userID, $details['groupID']))
                {
                    return true;
                }

                break;
        }

        return false;
    }

    /**
     * Scrubs a list of records to remove records that the current user doesn't have access to
     * Defaults to enable read access, unless needToKnow mode is set for any form
     * @param array
     * @return array Returns the input array, scrubbing records that the current user doesn't have access to
     */
    public function checkReadAccess($userID, $records)
    {
        if (count($records) == 0)
        {
            return $records;
        }

        $recordIDs = '';
        foreach ($records as $item)
        {
            $item = (array) $item;
            if (is_numeric($item['recordID']))
            {
                $recordIDs .= $item['recordID'] . ',';
            }
        }
        $recordIDs = trim($recordIDs, ',');
        $recordIDsHash = sha1($recordIDs);

        $res = array();
        $hasCategoryAccess = array(); // the keys will be categoryIDs that the current user has access to
        if (isset($this->cache["checkReadAccess_{$recordIDsHash}"]))
        {
            $res = $this->cache["checkReadAccess_{$recordIDsHash}"];
        }
        else
        {
            // get a list of records which have categories marked as need-to-know
            $res = $this->getConnForTable('records')
            ->select('records.recordID', 'categories.categoryID', 'step_dependencies.dependencyID', 'groupID', 'serviceID', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID')
            ->leftJoin('category_count', 'records.recordID', '=', 'category_count.recordID')
            ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
            ->leftJoin('workflows', 'categories.workflowID', '=', 'workflows.workflowID')
            ->leftJoin('workflow_steps', 'workflows.workflowID', '=', 'workflow_steps.workflowID')
            ->leftJoin('step_dependencies', 'workflow_steps.stepID', '=', 'step_dependencies.stepID')
            ->leftJoin('dependency_privs', 'step_dependencies.dependencyID', '=', 'dependency_privs.dependencyID')
            ->where([['needToKnow', 1],['count', '>', 0]])
            ->whereIn('records.recordID', explode(',', $recordIDs))
            ->get()
            ->toArray();

            // if a needToKnow form doesn't have a workflow (eg: general info), pull in approval chain for associated forms
            $t_needToKnowRecords = '';
            $t_uniqueCategories = array();
            foreach ($res as $dep)
            {
                $dep = (array) $dep;
                if ($dep['dependencyID'] == null)
                {
                    if (is_numeric($dep['recordID']))
                    {
                        $t_needToKnowRecords .= $dep['recordID'] . ',';
                    }
                }

                // keep track of unique categories
                if (isset($dep['categoryID']) && !isset($t_uniqueCategories[$dep['categoryID']]))
                {
                    $t_uniqueCategories[$dep['categoryID']] = 1;
                }
            }

            $t_needToKnowRecords = trim($t_needToKnowRecords, ',');
            if ($t_needToKnowRecords != '')
            {
                $res2 = $this->getConnForTable('records')
                ->select('records.recordID', 'step_dependencies.dependencyID', 'groupID', 'serviceID', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID')
                ->leftJoin('category_count', 'records.recordID', '=', 'category_count.recordID')
                ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
                ->leftJoin('workflows', 'categories.workflowID', '=', 'workflows.workflowID')
                ->leftJoin('workflow_steps', 'workflows.workflowID', '=', 'workflow_steps.workflowID')
                ->leftJoin('step_dependencies', 'workflow_steps.stepID', '=', 'step_dependencies.stepID')
                ->leftJoin('dependency_privs', 'step_dependencies.dependencyID', '=', 'dependency_privs.dependencyID')
                ->where([['needToKnow', 0],['count', '>', 0]])
                ->whereIn('records.recordID', explode(',', $t_needToKnowRecords))
                ->get()
                ->toArray();       

                $res = array_merge($res, $res2);
            }
            
            // find out if "collaborator access" is being used for any categoryID in the set
            // and whether the current user has access
            $uniqueCategoryIDs = array_keys($t_uniqueCategories);
            $catsInGroups = $this->getConnForTable('category_privs')
                ->where('readable', 1)
                ->whereIn('categoryID', $uniqueCategoryIDs)
                ->get()
                ->toArray(); 
            if (count($catsInGroups) > 0)
            {
                $groups = $this->getMembership();
                foreach ($catsInGroups as $cat)
                {
                    $cat = (array) $cat;
                    if (isset($groups['groupID'][$cat['groupID']])
                        && $groups['groupID'][$cat['groupID']] == 1)
                    {
                        $hasCategoryAccess[$cat['categoryID']] = 1;
                    }
                }
            }

            $this->cache["checkReadAccess_{$recordIDsHash}"] = $res;
        }

        // don't scrub anything if no limits are in place
        if (count($res) == 0)
        {
            return $records;
        }

        // admin group
        if ($this->isAdmin($userID))
        {
            return $records;
        }

        $temp = isset($this->cache['checkReadAccess_tempArray']) ? $this->cache['checkReadAccess_tempArray'] : array();

        // grant access
        foreach ($res as $dep)
        {
            $dep = (array) $dep;
            if (!isset($temp[$dep['recordID']]) || $temp[$dep['recordID']] == 0)
            {
                $temp[$dep['recordID']] = 0;

                $temp[$dep['recordID']] = $this->hasDependencyAccess($userID, $dep['dependencyID'], $dep) ? 1 : 0;

                // request initiator
                if ($dep['empUID'] == $this->getEmpUID($userID))
                {
                    $temp[$dep['recordID']] = 1;
                }

                // collaborator access
                if (isset($hasCategoryAccess[$dep['categoryID']]))
                {
                    $temp[$dep['recordID']] = 1;
                }
            }
        }
        $this->cache['checkReadAccess_tempArray'] = $temp;

        foreach ($records as $record)
        {
            if (isset($temp[$record['recordID']]) && $temp[$record['recordID']] == 0)
            {
                unset($records[$record['recordID']]);
            }
        }

        return $records;
    }

    public function getBackups($empUID)
    {
        return $this->getConnForTable('relation_employee_backup')
        ->where(['empUID', $empUID])
        ->get()
        ->toArray();
    }
}