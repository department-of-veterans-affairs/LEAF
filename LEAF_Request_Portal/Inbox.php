<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Inbox
    Date Created: June 1, 2011

*/

require_once 'form.php';

class Inbox
{
    public $form;

    private $db;

    private $login;

    private $cache = array();

    private $dir;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->form = new Form($db, $login);
    }

    /**
     * Retrieve the current user's inbox
     * @param int Optional dependencyID to filter inbox based on the dependencyID
     * @return array database result
     */
    public function getInbox($dependencyID = 0)
    {
        $vars = array();
        $tmpQuery = '';
        if ($dependencyID != 0 && is_numeric($dependencyID))
        {
            $tmpQuery = " AND dependencyID = :dependencyID";
            $vars = array("dependencyID" => $dependencyID);
        }

        $out = array();
        $res = $this->db->prepared_query("SELECT * FROM records_workflow_state
        									  LEFT JOIN records USING (recordID)
        									  LEFT JOIN workflow_steps USING (stepID)
        									  LEFT JOIN step_dependencies USING (stepID)
        									  LEFT JOIN dependency_privs USING (dependencyID)
        									  LEFT JOIN dependencies USING (dependencyID)
        									  LEFT JOIN services USING (serviceID)
        									  LEFT JOIN records_dependencies USING (recordID, dependencyID)
        									  WHERE filled = 0 and deleted = 0{$tmpQuery}", $vars);

        // build temporary list for request types
        $res2 = $this->db->prepared_query('SELECT recordID, categoryName FROM records
        							LEFT JOIN category_count USING (recordID)
        							LEFT JOIN categories USING (categoryID)
        							WHERE deleted = 0
        								AND disabled = 0
        								AND workflowID != 0', array());

        $formCategories = array();
        foreach ($res2 as $category)
        {
            $formCategories[$category['recordID']][] = $category['categoryName'];
        }

        // build inbox data
        $personDesignatedRecords = array(); // array[indicatorID][] = recordID
        $groupDesignatedRecords = array(); // array[indicatorID][] = recordID
        $numRes = count($res);
        if ($numRes > 0)
        {
            // bundle requests that use dynamically assigned approvers
            for ($i = 0; $i < $numRes; $i++)
            {
                if (!isset($out[$res[$i]['dependencyID']]['records'][$res[$i]['recordID']]))
                {
                    // dependencyID -1 is for a person designated by the requestor
                    if ($res[$i]['dependencyID'] == -1)
                    {
                        $personDesignatedRecords[$res[$i]['indicatorID_for_assigned_empUID']][] = $res[$i]['recordID'];
                    }

                    // dependencyID -3 is for a group designated by the requestor
                    if ($res[$i]['dependencyID'] == -3)
                    {
                        $groupDesignatedRecords[$res[$i]['indicatorID_for_assigned_groupID']][] = $res[$i]['recordID'];
                    }
                }
            }

            // pull data for requestor designated approvers
            $resPersonDesignatedRecords = array(); // array[indicatorID] of DB results
            $resGroupDesignatedRecords = array(); // array[indicatorID] of DB results
            foreach ($personDesignatedRecords as $indicatorID => $recordIDList)
            {
              foreach ($recordIDList as $key => $recordID)
              {
                  //casting as an int to prevent sql injection
                  $recordIDList[$key] = (int)$recordID;

              }
                $recordIDs = implode(',', $recordIDList);
                $vars = array(':indicatorID' => $indicatorID);
                $resPersonDesignatedRecords[$indicatorID] = $this->db->prepared_query("SELECT * FROM data
                                                                    LEFT JOIN indicators USING (indicatorID)
                                                                    WHERE recordID IN ({$recordIDs})
                                                                        AND indicatorID=:indicatorID
                                                                        AND series=1", $vars);
            }
            foreach ($groupDesignatedRecords as $indicatorID => $recordIDList)
            {
                $recordIDs = implode(',', $recordIDList);
                $vars = array(':indicatorID' => $indicatorID);
                $resGroupDesignatedRecords[$indicatorID] = $this->db->prepared_query("SELECT * FROM data
                                                                    LEFT JOIN indicators USING (indicatorID)
                                                                    WHERE recordID IN ({$recordIDs})
                                                                        AND indicatorID=:indicatorID
                                                                        AND series=1", $vars);
            }

            // apply access rules
            for ($i = 0; $i < $numRes; $i++)
            {
                if (!isset($out[$res[$i]['dependencyID']]['records'][$res[$i]['recordID']]))
                {
                    // populate request type
                    if (is_array($formCategories[$res[$i]['recordID']]))
                    {
                        foreach ($formCategories[$res[$i]['recordID']] as $categoryName)
                        {
                            $res[$i]['categoryNames'] = isset($res[$i]['categoryNames']) ? $res[$i]['categoryNames'] . $categoryName . ' | ' : $categoryName . ' | ';
                        }
                        $res[$i]['categoryNames'] = trim($res[$i]['categoryNames'], ' | ');
                    }

                    // override access if user is in the admin group
                    $res[$i]['hasAccess'] = $this->login->checkGroup(1); // initialize hasAccess

                    // check permissions
                    $res2 = null;
                    if (isset($this->cache["dependency_privs_{$res[$i]['dependencyID']}"]))
                    {
                        $res2 = $this->cache["dependency_privs_{$res[$i]['dependencyID']}"];
                    }
                    else
                    {
                        $vars = array(':dependencyID' => $res[$i]['dependencyID']);
                        $res2 = $this->db->prepared_query('SELECT * FROM dependency_privs
                    									WHERE dependencyID=:dependencyID', $vars);
                        $this->cache["dependency_privs_{$res[$i]['dependencyID']}"] = $res2;
                    }

                    // dependencyID 1 is for a special service chief group
                    if ($res[$i]['dependencyID'] == 1)
                    {
                        if ($this->login->checkService($res[$i]['serviceID']))
                        {
                            $res[$i]['hasAccess'] = true;
                        }
                    }

                    // dependencyID 8 is for a special quadrad group
                    if ($res[$i]['dependencyID'] == 8)
                    {
                        if (!isset($this->cache['getInbox_quadradCheck' . $res[$i]['serviceID']]))
                        {
                            $quadGroupIDs = $this->login->getQuadradGroupID();
                            $vars3 = array(':serviceID' => $res[$i]['serviceID']);

                            $res3 = $this->db->prepared_query("SELECT * FROM services
                            									WHERE groupID IN ({$quadGroupIDs})
                            										AND serviceID=:serviceID", $vars3);

                            $this->cache['getInbox_quadradCheck' . $res[$i]['serviceID']] = $res3;
                        }

                        if (isset($this->cache['getInbox_quadradCheck' . $res[$i]['serviceID']][0]))
                        {
                            $res[$i]['hasAccess'] = true;
                        }
                    }

                    // dependencyID -1 is for a person designated by the requestor
                    if ($res[$i]['dependencyID'] == -1)
                    {
                        $resEmpUID = null;
                        foreach ($resPersonDesignatedRecords[$res[$i]['indicatorID_for_assigned_empUID']] as $record)
                        {
                            if ($res[$i]['recordID'] == $record['recordID'])
                            {
                                $resEmpUID = $record;

                                break;
                            }
                        }
                        $empUID = $resEmpUID['data'];
                        $res[$i]['dependencyID'] = '-1_' . $empUID;

                        //check if the person designated has any backups
                        $backupIds = null;
                        if (!isset($this->cache['getInbox_currUserIsABackup']))
                        {
                            // see if the current user is a backup for anyone
                            $nexusDB = $this->login->getNexusDB();
                            $vars4 = array(':empId' => $this->login->getEmpUID());
                            $isBackup = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE backupEmpUID =:empId', $vars4);
                            if(count($isBackup) > 0) {
                                $this->cache['getInbox_currUserIsABackup'] = true;
                            }
                            else {
                                $this->cache['getInbox_currUserIsABackup'] = false;
                            }
                        }

                        $backupIds = [];
                        if (isset($this->cache["getInbox_employeeBackups_{$empUID}"]))
                        {
                            $backupIds = $this->cache["getInbox_employeeBackups_{$empUID}"];
                        }
                        else if($this->cache['getInbox_currUserIsABackup'])
                        {
                            $nexusDB = $this->login->getNexusDB();
                            $vars4 = array(':empId' => $empUID);
                            $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);
                            $this->cache["getInbox_employeeBackups_{$empUID}"] = $backupIds;
                        }

                        if ($empUID == $this->login->getEmpUID())
                        {
                            $res[$i]['hasAccess'] = true;
                        }
                        else
                        {
                            //check and provide access to backups
                            foreach ($backupIds as $row)
                            {
                                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                                {
                                    $res[$i]['hasAccess'] = true;
                                }
                            }
                        }

                        if ($res[$i]['hasAccess'])
                        {
                            // populate relevant info
                            if (!isset($this->dir))
                            {
                                require_once 'VAMC_Directory.php';
                                $this->dir = new VAMC_Directory;
                            }

                            $user = $this->dir->lookupEmpUID($empUID);

                            $approverName = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $field['userID'];
                            $out[$res[$i]['dependencyID']]['approverName'] = $approverName;
                        }
                    }

                    // dependencyID -2 is for requestor followup
                    if ($res[$i]['dependencyID'] == -2)
                    {
                        if ($res[$i]['userID'] == $this->login->getUserID())
                        {
                            $res[$i]['hasAccess'] = true;
                            $out[$res[$i]['dependencyID']]['approverName'] = $this->login->getName();
                        }

                        if(!$res[$i]['hasAccess'])
                        {                            
                            $empUID = $this->getEmpUIDByUserName($res[$i]['userID']);
                            $res[$i]['hasAccess'] = $this->checkIfBackup($empUID);

                            if($res[$i]['hasAccess']){

                                if (!isset($this->dir))
                                {
                                    require_once 'VAMC_Directory.php';
                                    $this->dir = new VAMC_Directory;
                                }
    
                                $user = $this->dir->lookupEmpUID($empUID);
    
                                $approverName = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : "unknown user";
                                
                                $out[$res[$i]['dependencyID']]['approverName'] = 'Backup for '.$approverName;
                            }
                        }
                    }

                    // dependencyID -3 is for a group designated by the requestor
                    if ($res[$i]['dependencyID'] == -3)
                    {
                        $resGroupID = null;
                        foreach ($resGroupDesignatedRecords[$res[$i]['indicatorID_for_assigned_groupID']] as $record)
                        {
                            if ($res[$i]['recordID'] == $record['recordID'])
                            {
                                $resGroupID = $record;

                                break;
                            }
                        }

                        $groupID = $resGroupID['data'];
                        $res[$i]['dependencyID'] = '-3_' . $groupID;

                        if ($this->login->checkGroup($groupID))
                        {
                            $res[$i]['hasAccess'] = true;
                        }

                        if ($res[$i]['hasAccess'])
                        {
                            // populate relevant info
                            $resDepGroup = null;
                            if (isset($this->cache["getInbox_resDepGroup_{$groupID}"]))
                            {
                                $resDepGroup = $this->cache["getInbox_resDepGroup_{$groupID}"];
                            }
                            else
                            {
                                $vars = array(':groupID' => $groupID);
                                $resDepGroup = $this->db->prepared_query('SELECT name FROM `groups` WHERE groupID=:groupID', $vars);
                                $this->cache["getInbox_resDepGroup_{$groupID}"] = $resDepGroup;
                            }
                            $approverName = '';
                            if (isset($resDepGroup[0]['name']))
                            {
                                $approverName = $resDepGroup[0]['name'];
                            }
                            else
                            {
                                $approverName = $resGroupID[$res[$i]['indicatorID_for_assigned_groupID']]['name'];
                            }
                            $out[$res[$i]['dependencyID']]['approverName'] = $approverName;
                        }
                    }

                    foreach ($res2 as $group)
                    {
                        if ($this->login->checkGroup($group['groupID']))
                        {
                            $res[$i]['hasAccess'] = true;

                            break;
                        }
                    }

                    if ($res[$i]['hasAccess'] == true && $res[$i]['blockingStepID'] == 0)
                    {
                        $out[$res[$i]['dependencyID']]['records'][$res[$i]['recordID']] = $res[$i];
                        $out[$res[$i]['dependencyID']]['dependencyID'] = $res[$i]['dependencyID'];
                        $out[$res[$i]['dependencyID']]['dependencyDesc'] = $res[$i]['description'];
                        $out[$res[$i]['dependencyID']]['count'] = count($out[$res[$i]['dependencyID']]['records']);

                        /*
                         if($field['workflowID'] != 0) {
                         $index[$idx]['categories'] = $field['categoryName'];
                         }*/

                        // darken header color
                        if (isset($this->cache[$res[$i]['stepBgColor']]))
                        {
                            $out[$res[$i]['dependencyID']]['dependencyBgColor'] = $this->cache[$res[$i]['stepBgColor']];
                        }
                        else
                        {
                            $tmp = ltrim($res[$i]['stepBgColor'], '#');
                            $tmpR = dechex(round(hexdec(substr($tmp, 0, 2)) * 0.9));
                            $tmpG = dechex(round(hexdec(substr($tmp, 2, 2)) * 0.9));
                            $tmpB = dechex(round(hexdec(substr($tmp, 4, 2)) * 0.9));

                            $out[$res[$i]['dependencyID']]['dependencyBgColor'] = "#{$tmpR}{$tmpG}{$tmpB}";
                            $this->cache[$res[$i]['stepBgColor']] = $out[$res[$i]['dependencyID']]['dependencyBgColor'];
                        }
                    }
                    if(substr($res[$i]['dependencyID'], 0, 3) == "-1_" && isset($out[$res[$i]['dependencyID']]['records']) && count($out[$res[$i]['dependencyID']]['records']) > 1000)
                    {
                        $out['errors'][] = ['code' => '1', 'message' => 'dependencyID: -1 has over 1000 results'];
                        break;
                    }
                }
            }
        }

        return $out;
    }

    /**
     * Gets empuID for given username
     * @param string $userName Username
     * @return string
     */
    public function getEmpUIDByUserName($userName)
    {
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        $response = $nexusDB->prepared_query('SELECT * FROM employee WHERE userName =:userName', $vars);
        return $response[0]["empUID"];
    }

    /**
     * Checks if logged in user serves as a backup for given empUID
     * @param string $empUID empUID to check 
     * @return boolean
     */
    public function checkIfBackup($empUID)
    {
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':empId' => $empUID);
        $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars);

        if ($empUID != $this->login->getEmpUID())
        {
            foreach ($backupIds as $row)
            {
                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                {
                    return true;
                }
            }

            return false;
        }

        return true;
    }

    /**
     * Find out if there are any items in the current user's inbox
     * TODO: improve performance of this
     * @return int approximate number of items in inbox
     */
    public function getInboxStatus()
    {
        $vars = array(':userID' => $this->login->getUserID());
        $res = $this->db->prepared_query('SELECT COUNT(*) FROM records_workflow_state
        									  LEFT JOIN step_dependencies USING (stepID)
        									  LEFT JOIN dependency_privs USING (dependencyID)
        									  LEFT JOIN users USING (groupID)
        									  LEFT JOIN records_dependencies USING (recordID, dependencyID)
        									  WHERE userID=:userID
        										AND filled=0', $vars);

        // if the initial search is empty, check for special cases (service chief, quadrad)
        if ($res[0]['COUNT(*)'] == 0)
        {
            $count = 0;
            $vars2 = array();
            $res2 = $this->db->prepared_query('SELECT * FROM records_workflow_state
            									LEFT JOIN records USING (recordID)
            									LEFT JOIN step_dependencies USING (stepID)
                                                LEFT JOIN workflow_steps USING (stepID)
            									LEFT JOIN records_dependencies USING (recordID, dependencyID)
            									WHERE (dependencyID = 1
                                                         OR dependencyID = 8
                                                         OR dependencyID = -1
                                                         OR dependencyID = -2
                                                         OR dependencyID = -3)
            										AND filled = 0', $vars2);

            foreach ($res2 as $record)
            {
                switch ($record['dependencyID']) {
                    case 1: // dependencyID 1 is for a special service chief group
                        if ($this->login->checkService($record['serviceID']))
                        {
                            return 1;
                        }

                        break;
                    case 8: // dependencyID 8 is for a special quadrad group
                        $hash = md5($this->login->getQuadradGroupID() . $record['serviceID']);
                        if (!isset($this->cache["getInboxStatus_{$hash}"]))
                        {
                            $quadGroupIDs = $this->login->getQuadradGroupID();
                            $vars3 = array(':serviceID' => $record['serviceID']);
                            $res3 = $this->db->prepared_query("SELECT * FROM services
                            									WHERE groupID IN ({$quadGroupIDs})
                            										AND serviceID=:serviceID", $vars3);
                            if (isset($res3[0]))
                            {
                                return 1;
                            }
                            $this->cache["getInboxStatus_{$hash}"] = 0;
                        }

                        break;
                    case -1: // dependencyID -1 is for a person designated by the requestor
                        $resEmpUID = $this->form->getIndicator($record['indicatorID_for_assigned_empUID'], 1, $record['recordID']);
                        $empUID = $resEmpUID[$record['indicatorID_for_assigned_empUID']]['value'];

                        //check if the requester has any backups
                        $nexusDB = $this->login->getNexusDB();
                        $vars4 = array(':empId' => $empUID);
                        $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);

                        if ($empUID == $this->login->getEmpUID())
                        {
                            return 1;
                        }
                            //check and provide access to backups
                            foreach ($backupIds as $row)
                            {
                                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                                {
                                    return 1;
                                }
                            }

                        break;
                    case -2: // dependencyID -2 is for requestor followup
                        if ($record['userID'] == $this->login->getUserID())
                        {
                            return 1;
                        }

                        break;
                    case -3: // dependencyID -3 is for a group designated by the requestor
                        $resGroupID = $this->form->getIndicator($record['indicatorID_for_assigned_groupID'], 1, $record['recordID']);
                        $groupID = $resGroupID[$record['indicatorID_for_assigned_groupID']]['value'];

                        if ($this->login->checkGroup($groupID))
                        {
                            return 1;
                        }

                        break;
                    default:
                        break;
                }
            }
        }

        return $res[0]['COUNT(*)'];
    }

    /**
     * Retrieve the number of items in the current user's inbox
     * @return int number
     */
    public function getInboxCount()
    {
        $vars = array(':userID' => $this->login->getUserID());
        $res = $this->db->prepared_query('SELECT COUNT(*) FROM records_workflow_state
        									  LEFT JOIN step_dependencies USING (stepID)
        									  LEFT JOIN dependency_privs USING (dependencyID)
        									  LEFT JOIN users USING (groupID)
        									  WHERE userID=:userID', $vars);

        // if the initial search is empty, check for special cases (service chief, quadrad)
        if ($res[0]['COUNT(*)'] == 0)
        {
            $count = 0;
            $vars2 = array();
            $res2 = $this->db->prepared_query('SELECT * FROM records_workflow_state
            									LEFT JOIN records USING (recordID)
            									LEFT JOIN step_dependencies USING (stepID)
            									WHERE dependencyID = 1
            										OR dependencyID = 8', $vars2);

            foreach ($res2 as $record)
            {
                switch ($record['dependencyID']) {
                    case 1:
                        if ($this->login->checkService($record['serviceID']))
                        {
                            $count++;
                        }

                        break;
                    case 8:
                        $vars3 = array(':quadGroupIDs' => $this->login->getQuadradGroupID(),
                                       ':serviceID' => $record['serviceID'], );
                        $res3 = $this->db->prepared_query('SELECT * FROM services
                        									WHERE groupID IN (:quadGroupIDs)
                        										AND serviceID=:serviceID', $vars2);
                        if (isset($res3[0]))
                        {
                            $count++;
                        }

                        break;
                    default:
                        break;
                }
            }

            return $count;
        }

        return $res[0]['COUNT(*)'];
    }
}
