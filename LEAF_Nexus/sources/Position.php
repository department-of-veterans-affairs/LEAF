<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Position
    Date: August 30, 2011

*/

namespace Orgchart;

class Position extends Data
{
    protected $dataTable = 'position_data';

    protected $dataHistoryTable = 'position_data_history';

    protected $dataTagTable = 'position_tags';

    protected $dataTableUID = 'positionID';

    protected $dataTableDescription = 'Position';

    protected $dataTableCategoryID = 2;

    private $tableName = 'positions';   // Table of positions

    private $limit = 'LIMIT 5';       // Limit number of returned results "TOP 100"

    private $sortBy = 'positionTitle';     // Sort by... ?

    private $sortDir = 'ASC';           // Sort ascending/descending?

    private $maxStringDiff = 3;         // Max number of letter differences for a name (# of typos allowed)

    private $deepSearch = 10;

    // Threshold for deeper search (min # of results
    //     from main search triggers deep search)

    public function initialize()
    {
        $this->setDataTable($this->dataTable);
        $this->setDataHistoryTable($this->dataHistoryTable);
        $this->setDataTableUID($this->dataTableUID);
        $this->setDataTableDescription($this->dataTableDescription);
        $this->setDataTableCategoryID($this->dataTableCategoryID);
    }

    public function setNoLimit()
    {
        $this->limit = '';
    }

    /**
     * Retrieves current user's privileges for the specified positionID
     *
     * @param int $groupID
     */
    public function getUserPrivileges($positionID)
    {
        $cacheHash = 'getUserPrivileges' . $positionID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $data = array();
        $memberships = $this->login->getMembership();

        // start with read-only permissions
        $data[$positionID]['read'] = -1;
        $data[$positionID]['write'] = 0;
        $data[$positionID]['grant'] = 0;

        $var = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT * FROM position_privileges
                                            WHERE positionID=:positionID', $var);

        foreach ($res as $item)
        {
            // grant highest available access
            if (isset($memberships[$item['categoryID'] . 'ID'][$item['UID']]))
            {
                if (isset($data[$item['positionID']]['read']) && $data[$item['positionID']]['read'] != 1)
                {
                    $data[$item['positionID']]['read'] = $item['read'];
                }
                if (isset($data[$item['positionID']]['write']) && $data[$item['positionID']]['write'] != 1)
                {
                    $data[$item['positionID']]['write'] = $item['write'];
                }
                if (isset($data[$item['positionID']]['grant']) && $data[$item['positionID']]['grant'] != 1)
                {
                    $data[$item['positionID']]['grant'] = $item['grant'];
                }
            }
        }

        // grant full access if user is part of the special group: System Administrator (groupID 1)
        if (isset($memberships['groupID'][1])
                && $memberships['groupID'][1] == 1)
        {
            $data[$positionID]['read'] = 1;
            $data[$positionID]['write'] = 1;
            $data[$positionID]['grant'] = 1;
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

    /**
     * Add new position
     * @param string positionTitle
     * @param int parentID
     * @param int groupID (unused)
     * @throws Exception
     * @return int New employee ID
     */
    public function addNew($positionTitle, $parentID = 0, $groupID = 0)
    {
        $memberships = $this->login->getMembership();
        $groupID = (int)$groupID;
        if (!is_numeric($parentID))
        {
            throw new Exception('Invalid input: parentID');
        }
        if ($parentID == 0
            && (!in_array(1, $memberships['groupID'])))
        {
            throw new Exception('Admin access required to add a position without a supervisor.');
        }

        if ($parentID > 0)
        {
            $privs = $this->getUserPrivileges($parentID);
            if ($privs[$parentID]['write'] == 0)
            {
                throw new Exception('No write access for the supervisor');
            }
        }

        if (strlen($positionTitle) == 0)
        {
            throw new Exception('Position title must not be blank');
        }

        $positionTitle = $this->sanitizeInput($positionTitle);

        $vars = array(':positionTitle' => $positionTitle,
                      ':parentID' => $parentID,
                      ':phoTitle' => metaphone($positionTitle), );
        $this->db->prepared_query('INSERT INTO positions (positionTitle, parentID, phoneticPositionTitle)
               VALUES (:positionTitle, :parentID, :phoTitle)', $vars);

        $positionID = $this->db->getLastInsertID();
        /*
                if(is_numeric($groupID) && $groupID > 0) {
                    $vars = array(':groupID' => $groupID,
                                  ':positionID' => $positionID);
                    $this->db->prepared_query('INSERT INTO relation_group_position (groupID, positionID)
                                   VALUES (:groupID, :positionID)', $vars);
                }*/
        $this->updateLastModified();

        return (int)$positionID;
    }

    /**
     * Edit an existing position's title
     * @param int $positionID
     * @param string $newTitle
     */
    public function editTitle($positionID, $newTitle)
    {
        if (!is_numeric($positionID))
        {
            return 0;
        }
        $privs = $this->getUserPrivileges($positionID);
        if ($privs[$positionID]['write'] == 0)
        {
            return 0;
        }

        if (!isset($newTitle) || strlen($newTitle) == 0)
        {
            throw new Exception('Position title must not be blank');
        }

        $newTitle = $this->sanitizeInput($newTitle);

        $vars = array(':positionTitle' => $newTitle,
                      ':positionID' => $positionID,
                      ':phoTitle' => metaphone($newTitle), );
        $this->db->prepared_query('UPDATE positions SET positionTitle=:positionTitle, phoneticPositionTitle=:phoTitle
            								WHERE positionID=:positionID', $vars);
        $this->updateLastModified();

        return $positionID;
    }

    /**
     * (deprecated) Edit an existing position's number of FTE
     * @param int $positionID
     * @param int $numFTE
     */
    public function editNumFTE($positionID, $numFTE)
    {
        $numFTE = (int)$numFTE;
        $positionID = (int)$positionID;

        $vars = array(':positionID' => $positionID,
                      ':numFTE' => $numFTE, );
        $this->db->prepared_query('UPDATE positions SET numberFTE=:numFTE
                    						WHERE positionID=:positionID', $vars);

        return $positionID;
    }

    /**
     * Get position title
     * @param int $positionID
     * @return string position title / boolean false
     */
    public function getTitle($positionID)
    {
        if (!is_numeric($positionID))
        {
            return false;
        }
        $res = null;
        if (isset($this->cache["res_select_position_{$positionID}"]))
        {
            $res = $this->cache["res_select_position_{$positionID}"];
        }
        else
        {
            $vars = array(':positionID' => $positionID);
            $res = $this->db->prepared_query('SELECT * FROM positions
                                                WHERE positionID=:positionID', $vars);
            $this->cache["res_select_position_{$positionID}"] = $res;
        }

        return isset($res[0]['positionTitle']) ? $res[0]['positionTitle'] : false;
    }

    /**
     * Get employees related to the position
     * @param int $positionID
     * @return array
     */
    public function getEmployees($positionID)
    {
        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT * FROM positions
                                            LEFT JOIN relation_position_employee USING (positionID)
                                            LEFT JOIN employee USING (empUID)
                                            WHERE positionID=:positionID
        									ORDER BY lastName ASC', $vars);

        $employee = new Employee($this->db, $this->login);
        $out = array();
        foreach ($res as $emp)
        {
            if ($emp['empUID'] != null)
            {
                $emp['backups'] = $employee->getBackups($emp['empUID']);
                $out[] = $emp;
            }
        }

        return $out;
    }

    /**
     * Get position summary, including related employee
     * @param int $positionID
     * @return array
     */
    public function getSummary($positionID)
    {
        $data = array();

        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT * FROM positions
                                            WHERE positionID=:positionID', $vars);

        if (isset($res[0]))
        {
            $data['employeeList'] = $this->getEmployees($positionID);

            $data['title'] = $res[0]['positionTitle'];
            $data['positionData'] = $this->getAllData($positionID);
            $data['services'] = $this->getService($positionID);
            $data['supervisor'] = $this->getSupervisor($positionID);
        }

        return $data;
    }

    /**
     * Add employee
     * @param int $positionID
     * @param int $empUID
     * @return string
     */
    public function addEmployee($positionID, $empUID, $isActing = 0)
    {
        if (!is_numeric($positionID) || !is_numeric($empUID))
        {
            return 0;
        }

        $privs = $this->getUserPrivileges($positionID);
        if ($privs[$positionID]['write'] == 0)
        {
            return 0;
        }

        $this->updateLastModified();

        $vars = array(':empUID' => $empUID,
                      ':positionID' => $positionID,
                      ':isActing' => ($isActing ? 1 : 0),
        );
        $strSQL = 'INSERT INTO relation_position_employee (positionID, empUID, isActing)
            VALUES (:positionID, :empUID, :isActing)
            ON DUPLICATE KEY UPDATE positionID=:positionID, empUID=:empUID, isActing=:isActing';
        $this->db->prepared_query($strSQL, $vars);

        return $empUID;
    }

    /**
     * Remove employee
     * @param int $positionID
     * @param int $empUID
     */
    public function removeEmployee($positionID, $empUID)
    {
        if (!is_numeric($positionID) || !is_numeric($empUID))
        {
            return 0;
        }
        $privs = $this->getUserPrivileges($positionID);
        if ($privs[$positionID]['write'] == 0)
        {
            return 0;
        }

        $vars = array(':empUID' => $empUID,
                      ':positionID' => $positionID, );
        $this->db->prepared_query('DELETE FROM relation_position_employee
                                        WHERE positionID=:positionID AND empUID=:empUID', $vars);
        $this->updateLastModified();

        return 1;
    }

    /**
     * Lists groups that the position is a member of
     * @param int $positionID
     * @return array
     */
    public function listGroups($positionID)
    {
        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT * FROM relation_group_position
                                            LEFT JOIN `groups` USING (groupID)
                                            WHERE positionID=:positionID', $vars);

        return $res;
    }

    /**
     * Get position subordinates
     * @param int $positionID
     * @param bool $skipData If true, does not retrieve associated position content
     * @return array
     */
    public function getSubordinates($positionID, $skipData = false)
    {
        if (!is_numeric($positionID))
        {
            return array();
        }
        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT a.*, b.positionID as subPositionID FROM positions a
                                            LEFT JOIN (positions b) ON (a.positionID = b.parentID)
                                            WHERE a.parentID=:positionID
                                            GROUP BY a.positionID', $vars);

        $data = array();
        if (count($res) > 0)
        {
            foreach ($res as $sub)
            {
                if ($skipData == false)
                {
                    $data[$sub['positionID']] = $this->getAllData($sub['positionID']);
                }
                else
                {
                    $data[$sub['positionID']] = array();
                }
                $data[$sub['positionID']]['title'] = $sub['positionTitle'];
                $data[$sub['positionID']]['hasSubordinates'] = ($sub['subPositionID'] != null) ? 1 : 0;
                $data[$sub['positionID']]['parentID'] = $sub['parentID'];
                $data[$sub['positionID']]['positionID'] = $sub['positionID'];
            }
        }

        return $data;
    }

    /**
     * Checks if a position is a subordinate of another
     * @param int $supervisorID
     * @param int $subordinateID
     */
    public function isSubordinate($supervisorID, $subordinateID)
    {
        $res = null;
        $cacheHash = 'table_positions_' . $subordinateID;
        if (isset($this->cache[$cacheHash]))
        {
            $res = $this->cache[$cacheHash];
        }
        else
        {
            $vars = array(':positionID' => $subordinateID);
            $res = $this->db->prepared_query('SELECT * FROM positions
                                            WHERE positionID=:positionID', $vars);
            $this->cache[$cacheHash] = $res;
        }

        if ($res[0]['parentID'] != 0
            && $res[0]['parentID'] != $supervisorID)
        {
            return $this->isSubordinate($supervisorID, $res[0]['parentID']);
        }
        if ($res[0]['parentID'] == $supervisorID)
        {
            return 1;
        }

        return 0;
    }

    /**
     * Get top-most supervisor
     */
    public function getTopSupervisorID($positionID, $prev = null)
    {
        if (isset($this->cache["getTopSupervisorID_{$positionID}"]))
        {
            return $this->cache["getTopSupervisorID_{$positionID}"];
        }

        if ($positionID != $prev)
        {
            $prev = $positionID;
            $super = $this->getSupervisor($positionID);
            if (count($super) == 0)
            {
                $this->cache["getTopSupervisorID_{$positionID}"] = $positionID;

                return $positionID;
            }

            return $this->getTopSupervisorID($super[0]['positionID'], $positionID);
        }

        $this->cache["getTopSupervisorID_{$positionID}"] = $positionID;

        return $positionID;
    }

    /**
     * Get position supervisor
     * @param int $positionID
     * @return array
     */
    public function getSupervisor($positionID)
    {
        if (!is_numeric($positionID))
        {
            return array();
        }
        $res = null;
        $cacheHash = "position_getSupervisor_{$positionID}";
        if (!isset($this->cache[$cacheHash]))
        {
            $vars = array(':positionID' => $positionID);
            $res = $this->db->prepared_query('SELECT * FROM positions
                                                WHERE positionID=:positionID', $vars);
            if (count($res) > 0)
            {
                $vars = array(':positionID' => $res[0]['parentID']);
                $res = $this->db->prepared_query('SELECT * FROM positions
                                                LEFT JOIN relation_position_employee USING (positionID)
                                                LEFT JOIN employee USING (empUID)
                                                WHERE positionID=:positionID', $vars);
                $this->cache[$cacheHash] = $res;
            }
            else
            {
                $this->cache[$cacheHash] = array();
            }
        }

        return $this->cache[$cacheHash];
    }

    /**
     * Set position supervisor
     * @param int $positionID
     * @return array
     * @throws Exception
     */
    public function setSupervisor($positionID, $parentID)
    {
        if (!is_numeric($positionID) || !is_numeric($parentID))
        {
            return array('status' => 0, 'errors' => array('Invalid input'));
        }
        $privs = $this->getUserPrivileges($parentID);
        if ($privs[$parentID]['write'] == 0)
        {
            return array('status' => 0, 'errors' => array('You do not have write access to this position.</br> Please contact your primary admin.'));
        }

        $privs = $this->getUserPrivileges($positionID);
        if ($privs[$positionID]['write'] == 0)
        {
            return array('status' => 0, 'errors' => array('You do not have write access to this position.</br> Please contact your primary admin.'));
        }

        // avoid circular link - make sure we can't set a subordinate as a supervisor
        if ($this->isSubordinate($positionID, $parentID))
        {
            return 0;
        }
        if ($positionID == $parentID)
        {
            return 0;
        }

        $vars = array(':positionID' => $positionID,
                      ':parentID' => $parentID, );
        $this->db->prepared_query('UPDATE positions
                                    SET parentID=:parentID
                                    WHERE positionID=:positionID', $vars);
        $this->updateLastModified();

        return 1;
    }

    public function getParentID($positionID)
    {
        $res = null;
        if (isset($this->cache["table_positions_{$positionID}"]))
        {
            $res = $this->cache["table_positions_{$positionID}"];
        }
        else
        {
            $vars = array(':positionID' => $positionID);
            $res = $this->db->prepared_query('SELECT * FROM positions
                                                WHERE positionID=:positionID', $vars);
            $this->cache["table_positions_{$positionID}"] = $res;
        }

        return isset($res[0]['parentID']) ? $res[0]['parentID'] : null;
    }

    /**
     * Recursively search positions until a matching group is found with the specified tag
     * @param int $positionID
     * @param string $tag
     * @param array $listOfPositionsExamined
     *
     * @return array, null if search is exhausted
     */
    public function findRootPositionByGroupTag($positionID, $tag, $examinedPositions = array()): array
    {
        $positionID = (int)$positionID;
        if ($positionID == 0)
        {
            return array();
        }

        $res = array();
        if (isset($this->cache["findRootPositionByGroupTag_{$positionID}_{$tag}"]))
        {
            $res = $this->cache["findRootPositionByGroupTag_{$positionID}_{$tag}"];
        }
        else
        {
            $vars = array(':positionID' => $positionID,
                            ':tag' => $tag, );
            $res = $this->db->prepared_query('SELECT * FROM relation_group_position
	                                            LEFT JOIN `groups` USING (groupID)
	                                            RIGHT JOIN (SELECT * FROM group_tags
	                                                            WHERE tag=:tag) rj1
	                                                USING (groupID)
	                                            WHERE positionID=:positionID', $vars);
            $this->cache["findRootPositionByGroupTag_{$positionID}_{$tag}"] = $res;
        }

        if (count($res) == 0)
        {
            if (isset($examinedPositions[$positionID]))
            {
                return $res;
            }
            $examinedPositions[$positionID] = 1;

            return $this->findRootPositionByGroupTag($this->getParentID($positionID), $tag, $examinedPositions);
        }

        // only return "closest" result
        return array(0 => array_pop($res));
    }

    /**
     * Find service based on positionID
     * If a sub-section exists, append the subsection to the service
     * @param int $positionID
     */
    public function getService($positionID)
    {
        $res = $this->findRootPositionByGroupTag($positionID, 'section');
        if (count($res) > 0)
        {
            return array_merge($this->findRootPositionByGroupTag($positionID, 'service'), $res);
        }

        return $this->findRootPositionByGroupTag($positionID, 'service');
    }

    /**
     * Find quadrad based on positionID
     * If a sub-section exists, append the subsection to the service
     * @param int $positionID
     */
    public function getQuadrad($positionID)
    {
        return $this->findRootPositionByGroupTag($positionID, 'quadrad');
    }

    /**
     * Clean up all wildcards
     * @param string $input
     * @return string
     */
    public static function cleanWildcards($input)
    {
        $input = str_replace('%', '*', $input);
        $input = str_replace('?', '*', $input);
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\s)+/i', ' ', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    public function searchPDnumber($input)
    {
        $vars = array(':pdNumber' => $input);
        $res = $this->db->prepared_query("SELECT * FROM {$this->dataTable}
											LEFT JOIN {$this->tableName} lj1 USING ({$this->dataTableUID})
    										WHERE indicatorID = 9
    											AND data LIKE :pdNumber
    										ORDER BY {$this->sortBy} {$this->sortDir}
    										{$this->limit}", $vars);

        return $res;
    }

    public function search($input, $tag = '', $searchEmployees = 0)
    {
        $origInput = $input;
        $vars_tag = array();
        $sql_tag = '';
        if ($tag != '')
        {
            $vars_tag[':tag'] = $tag;
            $sql_tag = ' RIGHT JOIN (SELECT * FROM position_tags WHERE tag = :tag) rj0 USING (groupID)';
        }

        $input = $this->parseWildcard(trim($this->cleanWildcards($input)));
        if ($input == '' || $input == '*')
        {
            return array(); // Special case to prevent retrieving entire list in one query
        }

        $sql = "SELECT * FROM {$this->tableName}{$sql_tag}
                    WHERE positionTitle LIKE :positionTitle
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

        $vars = array(':positionTitle' => $input);
        $vars = array_merge($vars, $vars_tag);
        $result = $this->db->prepared_query($sql, $vars);

        // search phonetic position if no result
        if (count($result) == 0)
        {
            $sql = "SELECT * FROM {$this->tableName}{$sql_tag}
                    WHERE phoneticPositionTitle LIKE :positionTitle
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

            $vars = array(':positionTitle' => $this->metaphone_query($input));
            $vars = array_merge($vars, $vars_tag);
            $tempResult = $this->db->prepared_query($sql, $vars);

            $tInput = trim(strtolower($input), '*');
            foreach ($tempResult as $res)
            {  // Prune matches
                $prune = 1;
                $words = explode(' ', $res['positionTitle']);
                foreach ($words as $word)
                {
                    if (levenshtein(strtolower($word), $tInput) <= $this->maxStringDiff)
                    {
                        $prune = 0;
                    }
                }
                if ($prune == 0)
                {
                    $result[] = $res;
                }
            }
        }

        // search for PD number
        if (count($result) == 0)
        {
            $result = array_merge($result, $this->searchPDnumber($input));
        }

        // search for employee name
        if (count($result) == 0
            && $searchEmployees == 1)
        {
            $employee = new Employee($this->db, $this->login);
            $employee->position = $this;
            $employees = $employee->search($origInput);
            $tempResult = array();

            foreach ($employees as $temp)
            {
                if (isset($temp['positionData']) && is_array($temp['positionData'])
                    && $temp['positionData']['positionID'] > 0)
                {
                    $tempResult[] = array('positionID' => $temp['positionData']['positionID'],
                                          'positionTitle' => $temp['positionData']['positionTitle'], );
                }
            }

            $result = array_merge($result, $tempResult);
        }

        // search by ID number
        if (substr($origInput, 0, 1) == '#')
        {
            if (is_numeric(substr($origInput, 1)))
            {
                $vars = array(':PID' => substr($origInput, 1));
                $result = $this->db->prepared_query('SELECT * FROM positions
															WHERE positionID = :PID', $vars);
            }
        }

        // add org chart data
        $tcount = count($result);
        for ($i = 0; $i < $tcount; $i++)
        {
            //$result[$i]['data'] = $this->getAllData($result[$i]['positionID']);
            //$result[$i]['service'] = $this->getService($result[$i]['positionID']);
            $result[$i] = array_merge($result[$i], $this->getSummary($result[$i]['positionID']));
        }

        return $result;
    }

    public function getPrivileges($positionID)
    {
        $cacheHash = 'getPrivileges' . $positionID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('SELECT * FROM position_privileges
                                            WHERE positionID=:positionID', $vars);

        $this->cache[$cacheHash] = $res;

        return $res;
    }

    /**
     * Toggles the permission for a given position and subject
     * @param int $positionID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     */
    public function togglePermission($positionID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($positionID) || !is_numeric($UID))
        {
            return;
        }
        $priv = $this->getUserPrivileges($positionID);
        if ($priv[$positionID]['grant'] != 0)
        {
            $vars = array(':positionID' => $positionID,
                          ':categoryID' => $categoryID,
                          ':UID' => $UID, );
            $res = $this->db->prepared_query('SELECT * FROM position_privileges
                                                WHERE positionID=:positionID
                                                    AND categoryID=:categoryID
                                                    AND UID=:UID', $vars);
            if ($res[0][$permissionType] == 1)
            {
                return $this->removePermission($positionID, $categoryID, $UID, $permissionType);
            }

            return $this->addPermission($positionID, $categoryID, $UID, $permissionType);
        }
    }

    /**
     * Adds permission entry
     * @param int $positionID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function addPermission($positionID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($positionID) || !is_numeric($UID))
        {
            return;
        }
        $priv = $this->getUserPrivileges($positionID);
        if ($priv[$positionID]['grant'] == 0)
        {
            return;
        }

        switch ($permissionType) {
            case 'read':
                $permissionType = '`read`';

                break;
            case 'write':
                $permissionType = '`write`';

                break;
            case 'grant':
                $permissionType = '`grant`';

                break;
            default:
                return false;

                break;
        }
        $vars = array(':positionID' => $positionID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO position_privileges (positionID, categoryID, UID)
                                            VALUES (:positionID, :categoryID, :UID)', $vars);

        $vars = array(':positionID' => $positionID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE position_privileges
                                            SET {$permissionType}=1
                                            WHERE positionID=:positionID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);

        return 1;
    }

    /**
     * Removes the specified permission
     * @param int $positionID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function removePermission($positionID, $categoryID, $UID, $permissionType)
    {
        $priv = $this->getUserPrivileges($positionID);
        if ($priv[$positionID]['grant'] == 0)
        {
            return;
        }

        switch ($permissionType) {
            case 'read':
                $permissionType = '`read`';

                break;
            case 'write':
                $permissionType = '`write`';

                break;
            case 'grant':
                $permissionType = '`grant`';

                break;
            default:
                return false;

                break;
        }

        $vars = array(':positionID' => $positionID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO position_privileges (positionID, categoryID, UID)
                                            VALUES (:positionID, :categoryID, :UID)', $vars);

        $vars = array(':positionID' => $positionID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE position_privileges
                                            SET {$permissionType}=0
                                            WHERE positionID=:positionID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);

        // if subject has all permissions removed, delete the row from the table
        $vars = array(':positionID' => $positionID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('SELECT * FROM position_privileges
                                            WHERE positionID=:positionID
                                                AND categoryID=:categoryID
                                                AND UID=:UID', $vars);
        if ($res[0]['read'] == 0
            && $res[0]['write'] == 0
            && $res[0]['grant'] == 0)
        {
            $res = $this->db->prepared_query('DELETE FROM position_privileges
                                                WHERE positionID=:positionID
                                                    AND categoryID=:categoryID
                                                    AND UID=:UID', $vars);
        }

        return 0;
    }

    /**
     * Deletes a position, including all associated data
     * @param int $positionID
     * @throws Exception
     * @return number
     */
    public function deletePosition($positionID)
    {
        if (!is_numeric($positionID))
        {
            return 0;
        }
        // don't delete if there are subordinates
        if (count($this->getSubordinates($positionID, true)) > 0)
        {
            throw new Exception('You must delete subordinate positions first.');
        }

        $privs = $this->getUserPrivileges($positionID);
        if ($privs[$positionID]['write'] == 0)
        {
            throw new Exception('You do not have access.');
        }

        if ($positionID == 1)
        {
            throw new Exception('This position cannot be deleted.');
        }

        $this->db->beginTransaction();
        $vars = array(':positionID' => $positionID);
        $res = $this->db->prepared_query('DELETE FROM relation_position_employee
                                            WHERE positionID=:positionID', $vars);

        $res = $this->db->prepared_query('DELETE FROM relation_group_position
                                            WHERE positionID=:positionID', $vars);

        $res = $this->db->prepared_query('DELETE FROM position_tags
                                            WHERE positionID=:positionID', $vars);

        $res = $this->db->prepared_query('DELETE FROM position_privileges
                                            WHERE positionID=:positionID', $vars);

        $res = $this->db->prepared_query('DELETE FROM position_data
                                            WHERE positionID=:positionID', $vars);

        $res = $this->db->prepared_query('DELETE FROM positions
                                            WHERE positionID=:positionID', $vars);

        $this->db->commitTransaction();
        $this->updateLastModified();

        return 1;
    }

    // Translates the * wildcard to SQL % wildcard
    private function parseWildcard($query)
    {
        return str_replace('*', '%', '*' . $query . '*');
    }

    private function metaphone_query($in)
    {
        return '%' . metaphone($in) . '%';
    }
}
