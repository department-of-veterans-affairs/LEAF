<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Inbox
    Date Created: June 1, 2011

*/

namespace Portal;

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
                                                                        AND data.data REGEXP '^[0-9]+$'
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

                    // Initialize to no access to everything by default, unless the user is an admin
                    $res[$i]['hasAccess'] = $this->login->checkGroup(1);

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
                                $this->dir = new VAMC_Directory;
                            }
                            $user = $this->dir->lookupEmpUID($empUID);

                            $approverName = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : "Unknown User";
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
                                    $this->dir = new VAMC_Directory;
                                }

                                $user = $this->dir->lookupEmpUID($empUID);

                                $approverName = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : "Unknown User";

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
     *
     * @return int Approximate number of items in inbox
     */
    public function getInboxStatus(): int
    {
        $inboxCount = $this->getDirectInboxCount();

        if ($inboxCount == 0) {
            $inboxCount = $this->checkSpecialCaseInboxItems();
        }

        return $inboxCount;
    }

    /**
     * Get count of items directly assigned to the user via dependency privileges
     *
     * @return int Count of direct inbox items
     */
    private function getDirectInboxCount(): int
    {
        $vars = [':userID' => $this->login->getUserID()];
        $sql = 'SELECT COUNT(*) as count
                FROM `records_workflow_state`
                LEFT JOIN `step_dependencies` USING (`stepID`)
                LEFT JOIN `dependency_privs` USING (`dependencyID`)
                LEFT JOIN `users` USING (`groupID`)
                LEFT JOIN `records_dependencies` USING (`recordID`, `dependencyID`)
                WHERE `userID` = :userID
                AND `filled` = 0
                AND `active` = 1';

        $res = $this->db->prepared_query($sql, $vars);
        $count = (int)$res[0]['count'];

        return $count;
    }

    /**
     * Check for special case inbox items (service chief, quadrad, designated person, etc.)
     *
     * @return int Returns 1 if any special case items found, 0 otherwise
     */
    private function checkSpecialCaseInboxItems(): int
    {
        $specialRecords = $this->getSpecialCaseRecords();
        $inboxCount = 0;

        foreach ($specialRecords as $record) {
            $hasSpecialAccess = $this->checkRecordAccess($record);

            if ($hasSpecialAccess) {
                $inboxCount = 1;
                break;
            }
        }

        return $inboxCount;
    }

    /**
     * Get records with special case dependencies
     *
     * @return array Array of special case records
     */
    private function getSpecialCaseRecords(): array
    {
        $vars = [];
        $sql = 'SELECT `dependencyID`, `recordID`, `serviceID`, `userID`,
                    `indicatorID_for_assigned_empUID`, `indicatorID_for_assigned_groupID`
                FROM `records_workflow_state`
                LEFT JOIN `records` USING (`recordID`)
                LEFT JOIN `step_dependencies` USING (`stepID`)
                LEFT JOIN `workflow_steps` USING (`stepID`)
                LEFT JOIN `records_dependencies` USING (`recordID`, `dependencyID`)
                WHERE `dependencyID` IN (1, 8, -1, -2, -3)
                AND `filled` = 0';

        $records = $this->db->prepared_query($sql, $vars);

        return $records;
    }

    /**
     * Check if user has access to a record based on dependency type
     *
     * @param array $record The record data
     * @return bool True if user has access, false otherwise
     */
    private function checkRecordAccess(array $record): bool
    {
        $hasAccess = false;

        if ($record['dependencyID'] == 1) {
            $hasAccess = $this->checkServiceChiefInbox($record['serviceID']);
        } elseif ($record['dependencyID'] == 8) {
            $hasAccess = $this->checkQuadradInbox($record['serviceID']);
        } elseif ($record['dependencyID'] == -1) {
            $hasAccess = $this->checkDesignatedPersonInbox($record);
        } elseif ($record['dependencyID'] == -2) {
            $hasAccess = $this->checkRequestorFollowupInbox($record['userID']);
        } elseif ($record['dependencyID'] == -3) {
            $hasAccess = $this->checkDesignatedGroupInbox($record);
        }

        return $hasAccess;
    }

    /**
     * Check if user is a service chief for the given service
     *
     * @param int $serviceID The service ID
     * @return bool True if user is service chief, false otherwise
     */
    private function checkServiceChiefInbox(int $serviceID): bool
    {
        $hasAccess = $this->login->checkService($serviceID);

        return $hasAccess;
    }

    /**
     * Check if user has quadrad (executive leadership) access for the service
     *
     * @param int $serviceID The service ID
     * @return bool True if user has quadrad access, false otherwise
     */
    private function checkQuadradInbox(int $serviceID): bool
    {
        $hasAccess = false;
        $hash = md5($this->login->getQuadradGroupID() . $serviceID);

        if (!isset($this->cache["getInboxStatus_{$hash}"])) {
            $hasAccess = $this->hasQuadradServiceAccess($serviceID);
            $this->cache["getInboxStatus_{$hash}"] = $hasAccess ? 1 : 0;
        } else {
            $hasAccess = ($this->cache["getInboxStatus_{$hash}"] == 1);
        }

        return $hasAccess;
    }

    /**
     * Check if user's quadrad groups have access to the service
     *
     * @param int $serviceID The service ID
     * @return bool True if quadrad has access, false otherwise
     */
    private function hasQuadradServiceAccess(int $serviceID): bool
    {
        $quadGroupIDs = $this->login->getQuadradGroupID();
        $vars = [':serviceID' => $serviceID];
        $sql = "SELECT `serviceID`
                FROM `services`
                WHERE `groupID` IN ({$quadGroupIDs})
                AND `serviceID` = :serviceID";

        $res = $this->db->prepared_query($sql, $vars);
        $hasAccess = isset($res[0]);

        return $hasAccess;
    }

    /**
     * Check if user is the designated person or backup for the record
     *
     * @param array $record The record data
     * @return bool True if user is designated person or backup, false otherwise
     */
    private function checkDesignatedPersonInbox(array $record): bool
    {
        $resEmpUID = $this->form->getIndicator($record['indicatorID_for_assigned_empUID'], 1, $record['recordID']);
        $empUID = $resEmpUID[$record['indicatorID_for_assigned_empUID']]['value'];
        $currentEmpUID = $this->login->getEmpUID();

        $hasAccess = false;

        if ($empUID == $currentEmpUID) {
            $hasAccess = true;
        } else {
            $hasAccess = $this->isBackupForEmployee($empUID);
        }

        return $hasAccess;
    }

    /**
     * Check if current user is a backup for the given employee
     *
     * @param string $empUID The employee UID to check backup for
     * @return bool True if current user is backup, false otherwise
     */
    private function isBackupForEmployee(string $empUID): bool
    {
        $nexusDB = $this->login->getNexusDB();
        $vars = [':empId' => $empUID];
        $sql = 'SELECT `backupEmpUID`
                FROM `relation_employee_backup`
                WHERE `empUID` = :empId';

        $backupIds = $nexusDB->prepared_query($sql, $vars);
        $currentEmpUID = $this->login->getEmpUID();
        $isBackup = false;

        foreach ($backupIds as $row) {
            if ($row['backupEmpUID'] == $currentEmpUID) {
                $isBackup = true;
                break;
            }
        }

        return $isBackup;
    }

    /**
     * Check if user is the requestor for followup
     *
     * @param string $recordUserID The record's user ID
     * @return bool True if user is the requestor, false otherwise
     */
    private function checkRequestorFollowupInbox(string $recordUserID): bool
    {
        $hasAccess = ($recordUserID == $this->login->getUserID());

        return $hasAccess;
    }

    /**
     * Check if user is in the designated group for the record
     *
     * @param array $record The record data
     * @return bool True if user is in designated group, false otherwise
     */
    private function checkDesignatedGroupInbox(array $record): bool
    {
        $resGroupID = $this->form->getIndicator($record['indicatorID_for_assigned_groupID'], 1, $record['recordID']);
        $groupID = $resGroupID[$record['indicatorID_for_assigned_groupID']]['value'];
        $hasAccess = $this->login->checkGroup($groupID);

        return $hasAccess;
    }

    /**
     * Retrieve the number of items in the current user's inbox
     * @return int number
     */
    public function getInboxCount(): int
    {
        $count = $this->getDirectInboxItemCount();

        if ($count == 0) {
            $count = $this->getSpecialCaseInboxItemCount();
        }

        return $count;
    }

    /**
     * Get count of items directly assigned to the user via dependency privileges
     *
     * @return int Count of direct inbox items
     */
    private function getDirectInboxItemCount(): int
    {
        $vars = [':userID' => $this->login->getUserID()];
        $sql = 'SELECT COUNT(*) as count
                FROM `records_workflow_state`
                LEFT JOIN `step_dependencies` USING (`stepID`)
                LEFT JOIN `dependency_privs` USING (`dependencyID`)
                LEFT JOIN `users` USING (`groupID`)
                WHERE `userID` = :userID
                AND `active` = 1';

        $res = $this->db->prepared_query($sql, $vars);
        $count = (int)$res[0]['count'];

        return $count;
    }

    /**
     * Get count of special case inbox items (service chief, quadrad)
     *
     * @return int Count of special case inbox items
     */
    private function getSpecialCaseInboxItemCount(): int
    {
        $specialRecords = $this->getSpecialCaseInboxRecords();
        $count = 0;

        foreach ($specialRecords as $record) {
            $shouldCount = $this->shouldCountSpecialRecord($record);

            if ($shouldCount) {
                $count++;
            }
        }

        return $count;
    }

    /**
     * Get records with special case dependencies (service chief, quadrad)
     *
     * @return array Array of special case records
     */
    private function getSpecialCaseInboxRecords(): array
    {
        $vars = [];
        $sql = 'SELECT `dependencyID`, `serviceID`
                FROM `records_workflow_state`
                LEFT JOIN `records` USING (`recordID`)
                LEFT JOIN `step_dependencies` USING (`stepID`)
                WHERE `dependencyID` IN (1, 8)';

        $records = $this->db->prepared_query($sql, $vars);

        return $records;
    }

    /**
     * Determine if a special case record should be counted for the user
     *
     * @param array $record The record data
     * @return bool True if record should be counted, false otherwise
     */
    private function shouldCountSpecialRecord(array $record): bool
    {
        $shouldCount = false;

        if ($record['dependencyID'] == 1) {
            $shouldCount = $this->checkServiceChiefInboxCount($record['serviceID']);
        } elseif ($record['dependencyID'] == 8) {
            $shouldCount = $this->checkQuadradInboxCount($record['serviceID']);
        }

        return $shouldCount;
    }

    /**
     * Check if user is a service chief for the given service
     *
     * @param int $serviceID The service ID
     * @return bool True if user is service chief, false otherwise
     */
    private function checkServiceChiefInboxCount(int $serviceID): bool
    {
        $shouldCount = $this->login->checkService($serviceID);

        return $shouldCount;
    }

    /**
     * Check if user has quadrad (executive leadership) access for the service
     *
     * @param int $serviceID The service ID
     * @return bool True if user has quadrad access, false otherwise
     */
    private function checkQuadradInboxCount(int $serviceID): bool
    {
        $quadGroupIDs = $this->login->getQuadradGroupID();
        $vars = [
            ':quadGroupIDs' => $quadGroupIDs,
            ':serviceID' => $serviceID
        ];
        $sql = 'SELECT `serviceID`
                FROM `services`
                WHERE `groupID` IN (:quadGroupIDs)
                AND `serviceID` = :serviceID';

        $res = $this->db->prepared_query($sql, $vars);
        $shouldCount = isset($res[0]);

        return $shouldCount;
    }
}
