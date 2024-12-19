<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Group (aka organization, service, section, etc)
    Date: August 30, 2011

*/

namespace Orgchart;

use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;

class Group extends Data
{
    protected $dataTable = 'group_data';

    protected $dataHistoryTable = 'group_data_history';

    protected $dataTagTable = 'group_tags';

    protected $dataTableUID = 'groupID';

    protected $dataTableDescription = 'Group';

    protected $dataTableCategoryID = 3;

    private $tableName = 'groups';      // Table of groups

    private $limit = 'LIMIT 5';       // Limit number of returned results "TOP 100"

    private $sortBy = 'groupTitle';     // Sort by... ?

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
     * Retrieves current user's privileges for the specified groupID
     *
     * @param int $groupID
     */
    public function getUserPrivileges($groupID)
    {
        $cacheHash = 'getUserPrivileges' . $groupID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $data = array();
        $memberships = $this->login->getMembership();

        // start with read-only permissions
        $data[$groupID]['read'] = -1;
        $data[$groupID]['write'] = 0;
        $data[$groupID]['grant'] = 0;

        $var = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM group_privileges
                                            WHERE groupID=:groupID', $var);

        foreach ($res as $item)
        {
            // grant highest available access
            if (isset($memberships[$item['categoryID'] . 'ID'][$item['UID']]))
            {
                if (isset($data[$item['groupID']]['read']) && $data[$item['groupID']]['read'] != 1)
                {
                    $data[$item['groupID']]['read'] = $item['read'];
                }
                if (isset($data[$item['groupID']]['write']) && $data[$item['groupID']]['write'] != 1)
                {
                    $data[$item['groupID']]['write'] = $item['write'];
                }
                if (isset($data[$item['groupID']]['grant']) && $data[$item['groupID']]['grant'] != 1)
                {
                    $data[$item['groupID']]['grant'] = $item['grant'];
                }
            }
        }

        // grant full access if user is part of the special group: System Administrator (groupID 1)
        if (isset($memberships['groupID'][1])
                && $memberships['groupID'][1] == 1)
        {
            $data[$groupID]['read'] = 1;
            $data[$groupID]['write'] = 1;
            $data[$groupID]['grant'] = 1;
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

    /**
     * Add new group, and grant default permissions
     * @param string $groupTitle
     * @param int parentGroupID
     * @throws Exception
     * @return int New employee ID
     */
    public function addNew($groupTitle, $parentGroupID = 0)
    {
        if (!isset($groupTitle) || strlen($groupTitle) == 0)
        {
            throw new Exception('Group title must not be blank');
        }
        if (!is_numeric($parentGroupID))
        {
            throw new Exception('invalid parent group');
        }
        $groupTitle = $this->sanitizeInput($groupTitle);

        $vars = array(':groupTitle' => $groupTitle);
        $res = $this->db->prepared_query('SELECT * FROM `groups`
        							WHERE groupTitle = :groupTitle', $vars);
        if (count($res) > 0)
        {
            throw new Exception('Group title already exists');
        }

        $vars = array(':groupTitle' => $groupTitle,
                      ':parentID' => $parentGroupID,
                      ':phoGroupTitle' => metaphone($groupTitle), );
        $this->db->prepared_query('INSERT INTO `groups` (groupTitle, parentID, phoneticGroupTitle)
               VALUES (:groupTitle, :parentID, :phoGroupTitle)', $vars);

        $groupID = $this->db->getLastInsertID();

        $this->logAction(DataActions::ADD, LoggableTypes::GROUP, [
            new LogItem("groups", "groupID", $groupID),
            new LogItem("groups", "groupTitle", $groupTitle),
            new LogItem("groups", "parentID", $parentGroupID)
        ]);

        // Give admin to the person creating the group
        // If available, add their position instead of empUID
        $vars = array(':empUID' => $this->login->getEmpUID());
        $res = $this->db->prepared_query('SELECT * FROM relation_position_employee
                                            WHERE empUID=:empUID', $vars);

        if (count($res) > 0)
        {
            foreach ($res as $position)
            {
                $vars = array(':groupID' => $groupID,
                              ':categoryID' => 'position',
                              ':UID' => $position['positionID'], );

                $res = $this->db->prepared_query('INSERT INTO group_privileges (groupID, categoryID, UID, `read`, `write`, `grant`)
                                                    VALUES (:groupID, :categoryID, :UID, 1, 1, 1)', $vars);

                $this->logAction(DataActions::MODIFY,LoggableTypes::PRIVILEGES,[
                    new LogItem("group_privileges", "groupID", $groupID, $groupTitle),
                    new LogItem("group_privileges", "UID", $position['positionID'], $this->getPositionDisplay($position['positionID'])),
                    new LogItem("group_privileges", "read", "true"),
                    new LogItem("group_privileges", "write", "true"),
                    new LogItem("group_privileges", "grant", "true")
                ]);
            }
        }
        else
        {
            $vars = array(':groupID' => $groupID,
                          ':categoryID' => 'employee',
                          ':UID' => $this->login->getEmpUID(), );
            $res = $this->db->prepared_query('INSERT INTO group_privileges (groupID, categoryID, UID, `read`, `write`, `grant`)
                                                VALUES (:groupID, :categoryID, :UID, 1, 1, 1)', $vars);

            $this->logAction(DataActions::MODIFY,LoggableTypes::PRIVILEGES,[
                new LogItem("group_privileges", "groupID", $groupID, $groupTitle ),
                new LogItem("group_privileges", "UID", $this->login->getEmpUID(), $this->login->getName()),
                new LogItem("group_privileges", "read", "true"),
                new LogItem("group_privileges", "write", "true"),
                new LogItem("group_privileges", "grant", "true")
            ]);
        }

        // Give admin to admins
        $this->addPermission($groupID, 'group', 1, 'read');
        $this->addPermission($groupID, 'group', 1, 'write');
        $this->addPermission($groupID, 'group', 1, 'grant');

        // Give everyone read access
        $this->addPermission($groupID, 'group', 2, 'read');

        $this->updateLastModified();

        return $groupID;
    }

    /**
     * Deletes a group, including all associated data
     * @param int $groupID
     * @return number
     */
    public function deleteGroup($groupID)
    {
        if (!is_numeric($groupID))
        {
            throw new Exception('invalid group');
        }
        if ($groupID <= 10)
        {
            throw new Exception('Cannot delete system groups.');
        }

        $privs = $this->getUserPrivileges($groupID);
        if ($privs[$groupID]['write'] == 0)
        {
            throw new Exception('You do not have access to delete this group.');
        }
        $groupName = $this->getTitle($groupID);
        $this->db->beginTransaction();
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('DELETE FROM relation_group_employee
                                            WHERE groupID=:groupID', $vars);

        $res = $this->db->prepared_query('DELETE FROM relation_group_position
                                            WHERE groupID=:groupID', $vars);

        $res = $this->db->prepared_query('DELETE FROM group_tags
                                            WHERE groupID=:groupID', $vars);

        $res = $this->db->prepared_query('DELETE FROM group_privileges
                                            WHERE groupID=:groupID', $vars);

        $res = $this->db->prepared_query('DELETE FROM group_data
                                            WHERE groupID=:groupID', $vars);

        $res = $this->db->prepared_query('DELETE FROM `groups`
                                            WHERE groupID=:groupID', $vars);

        $this->db->commitTransaction();
        $this->updateLastModified();

        $this->logAction(DataActions::DELETE, LoggableTypes::GROUP, [
            new LogItem("groups", "groupID", $groupID, $groupName)
        ]);

        return 1;
    }

    /**
     * Get tags associated with a groupID
     * @param int $groupID
     */
    public function getTags($groupID)
    {
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM group_tags
                                              WHERE groupID=:groupID', $vars);
        $out = array();
        foreach ($res as $item)
        {
            $out[$item['tag']] = $item['tag'];
        }

        return $out;
    }

    /**
     * Get an existing group's title
     * @param int $groupID
     */
    public function getTitle($groupID)
    {
        $res = $this->getGroup($groupID);

        return isset($res[0]['groupTitle']) ? $res[0]['groupTitle'] : false;
    }

    /**
     * Edit an existing group's title
     * @param int $groupID
     * @param string $newTitle
     * @param string $abbrTitle
     */
    public function editTitle($groupID, $newTitle, $abbrTitle = null)
    {
        if (!is_numeric($groupID))
        {
            throw new Exception('invalid group');
        }
        $privs = $this->getUserPrivileges($groupID);
        // Don't allow special reserved groups (1-10) to be edited
        if ($privs[$groupID]['write'] == 0
            && $groupID <= 3)
        {
            throw new Exception('Access denied');
        }
        if (!isset($newTitle) || strlen($newTitle) == 0)
        {
            throw new Exception('Group title must not be blank');
        }

        $abbrTitle = $this->sanitizeInput($abbrTitle);
        $abbrTitle = $abbrTitle != '' ? $abbrTitle : null;
        $newTitle = $this->sanitizeInput($newTitle);

        $vars = array(':groupTitle' => $newTitle,
                      ':abbrTitle' => $abbrTitle,
                      ':groupID' => $groupID,
                      ':phoTitle' => metaphone($newTitle), );
        $this->db->prepared_query('UPDATE `groups` SET groupTitle=:groupTitle, groupAbbreviation=:abbrTitle, phoneticGroupTitle=:phoTitle
                                        WHERE groupID=:groupID', $vars);

        $this->logAction(DataActions::MODIFY,LoggableTypes::GROUP,[
            new LogItem("groups", "groupID", $groupID),
            new LogItem("groups", "groupTitle", $newTitle)
        ]);

        $this->updateLastModified();

        return $groupID;
    }

    /**
     * Edit an existing group's parentID
     * @param int $groupID
     * @param int $newParentID
     */
    public function editParentID($groupID, $newParentID)
    {
        $newParentID = (int)$newParentID;

        $vars = array(':groupID' => $groupID,
                      ':parentID' => $newParentID, );
        $this->db->prepared_query('UPDATE `groups` SET parentID=:parentID
                						WHERE groupID=:groupID', $vars);
        $this->updateLastModified();

        $this->logAction(DataActions::MODIFY, LoggableTypes::GROUP, [
            new LogItem("groups", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("groups", "parentID", $newParentID, $this->getTitle($groupID))
        ]);

        return $groupID;
    }

    /**
     * Get a group's parent ID
     * @param int $groupID
     * return int
     */
    public function getParentID($groupID)
    {
        $res = $this->getGroup($groupID);

        return $res[0]['parentID'];
    }

    public function getNumberOfSubgroups($parentID)
    {
        $vars = array(':parentID' => $parentID);
        $res = $this->db->prepared_query('SELECT COUNT(*) FROM `groups` WHERE parentID=:parentID', $vars);

        return $res[0]['COUNT(*)'];
    }

    /**
     * List groups
     * @param int $parentID
     * @param int $offset
     * @param int $quantity
     * @param int $noData If set, summary data will not be pulled
     * @return array
     */
    public function listGroups($parentID = 0, $offset = null, $quantity = null, $noData = null)
    {
        if (!is_numeric($parentID))
        {
            $parentID = 0;
        }

        $this->db->limit($offset, $quantity);
        $vars = array(':parentID' => $parentID);
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE parentID=:parentID
        									ORDER BY groupTitle ASC', $vars);
        if ($noData == null)
        {
            $numRes = count($res);
            for ($i = 0; $i < $numRes; $i++)
            {
                //$res[$i]['numSubgroups'] = $this->getNumberOfSubgroups($res[$i]['groupID']);
                $res[$i]['summary'] = $this->getSummary($res[$i]['groupID']);
            }
        }

        return $res;
    }

    /**
     * List groups by tag
     *
     * @param string $tag
     * @param int|null $offset
     * @param int|null $quantity
     *
     * @return array
     *
     * Created at: 8/29/2023, 7:58:53 AM (America/New_York)
     */
    public function listGroupsByTag(string $tag, ?int $offset = null, ?int $quantity = null): array
    {
        $this->db->limit($offset, $quantity);
        $vars = array(':tag' => $tag);
        $sql = 'SELECT *
                FROM `group_tags`
                RIGHT JOIN `groups` USING (`groupID`)
                WHERE `tag` = :tag
                ORDER BY `groupTitle` ASC';

        $res = $this->db->prepared_query($sql, $vars);

        return $res;
    }

    /**
     * List members of a group
     * @param int $parentID
     * @return array
     */
    public function listMembers($groupID = 0)
    {
        if (!is_numeric($groupID))
        {
            $parentID = 0;
        }

        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE parentID=:groupID', $vars);

        return $res;
    }

    /**
     * List groups and their immediate members
     * @param int $parentID
     * @return array
     */
    public function listGroupsAndMembers($parentID = 0)
    {
        $groups = $this->listGroups();

        $list = array();
        foreach ($groups as $group)
        {
            $group['members'] = $this->listMembers($group['groupID']);
            $list[] = $group;
        }

        return $list;
    }

    /**
     * Retrieves the top-level position in a group, if available
     * @param int $groupID
     * @return int default to 1 if no top level position found
     */
    public function getGroupLeader($groupID)
    {
        $positions = $this->listGroupPositions($groupID);
        $data = array();
        foreach ($positions as $pos)
        {
            $data[$pos['parentID']] = $pos;
        }
        foreach ($positions as $pos)
        {
            unset($data[$pos['positionID']]);
        }

        if (count($data) >= 1)
        {
            $res = array_shift($data);

            return $res['positionID'];
        }

        return 1;
    }

    public function listGroupPositions($groupID)
    {
        if (!is_numeric($groupID))
        {
            return new Exception('invalid group');
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM relation_group_position
        									LEFT JOIN positions USING (positionID)
        									WHERE groupID=:groupID', $vars);

        return $res;
    }

    /**
     * Get all employees explicitly associated with a group
     * @param int $groupID
     *
     */
    public function listGroupEmployees($groupID)
    {
        if (!is_numeric($groupID))
        {
            return new \Exception('invalid group');
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM relation_group_employee
                                            LEFT JOIN employee USING (empUID)
                                            WHERE groupID=:groupID
        										ORDER BY lastName ASC', $vars);

        return $res;
    }

    /**
     * Get all employees explicitly associated with a group with their extended
     * Employee info (data and positions). See Employee->getSummary().
     *
     * @param int       $groupID    the id of the group to retrieve
     * @param int       $offset     sql query offset (default=0)
     * @param int       $limit      sql query limit (default=none)
     */
    public function listGroupEmployeesDetailed($groupID, $offset = 0, $limit = -1)
    {
        // Cannot use $this->listGroupEmployees() since that query does not
        // include Employee position data
        if (!is_numeric($groupID))
        {
            return new Exception('invalid group');
        }
        $vars = array(
            ':groupID' => $groupID,
        );

        $query = '
            FROM relation_group_employee rge
            LEFT JOIN relation_position_employee USING (empUID)
            RIGHT JOIN employee e ON (e.empUID=rge.empUID)
            WHERE groupID=:groupID
            ORDER BY lastName ASC';

        $detailQuery = 'SELECT * ' . $query;

        // used for query metadata, knowing the total number of users is useful for paging results
        $countQuery = 'SELECT COUNT(*) AS totalUsers' . $query;

        // TODO: replace this with keyset pagination. Using LIMIT/OFFSET can be slow on large data sets.
        if ($limit !== -1)
        {
            $this->db->limit($offset, $limit);
        }

        $res = $this->db->prepared_query($detailQuery, $vars);
        $countRes = $this->db->prepared_query($countQuery, $vars);

        // Employee->getAllData() relies on lots of variables defined in that class,
        // so let it do the hard work
        $employee = new Employee($this->db, $this->login);
        foreach ($res as $key => $value)
        {
            $res[$key]['data'] = $employee->getAllData($value['empUID']);
            $res[$key]['positions'] = $employee->getPositions($value['empUID']);
        }

        $result = array(
            'users' => $res,
            'querymeta' => array(
                'totalusers' => $countRes[0]['totalUsers'],
                'limit' => $limit,
                'offset' => $offset,
            ),
        );

        return $result;
    }

    /**
     * Get all employees associated with a group
     * @param int $groupID
     * @return array
     */
    public function listGroupEmployeesAll($groupID)
    {
        $output = array();
        $position = new Position($this->db, $this->login);

        $positions = $this->listGroupPositions($groupID);
        foreach ($positions as $pos)
        {
            $resEmp = $position->getEmployees($pos['positionID']);
            foreach ($resEmp as $employee)
            {
                $output[$employee['empUID']] = $employee;
            }
        }

        $res = $this->listGroupEmployees($groupID);
        foreach ($res as $employee)
        {
            $output[$employee['empUID']] = $employee;
        }

        usort($output, array($this, 'sortEmployees'));

        return $output;
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

    public function search($input, $tag = '')
    {
        $origInput = $input;
        $vars_tag = array();
        $sql_tag = '';
        if ($tag != '')
        {
            $vars_tag[':tag'] = $tag;
            $sql_tag = ' RIGHT JOIN (SELECT * FROM group_tags WHERE tag = :tag) rj1 USING (groupID)';
        }

        $input = $this->parseWildcard(trim($this->cleanWildcards($input)));
        if ($input == '' || $input == '*')
        {
            return array(); // Special case to prevent retrieving entire list in one query
        }

        $sql = "SELECT * FROM `{$this->tableName}`{$sql_tag}
                    WHERE groupTitle LIKE :groupTitle
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

        $vars = array(':groupTitle' => $input);
        $vars = array_merge($vars, $vars_tag);
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $sql = "SELECT * FROM `{$this->tableName}`{$sql_tag}
                        WHERE phoneticGroupTitle LIKE :groupTitle
                        ORDER BY {$this->sortBy} {$this->sortDir}
                        {$this->limit}";

            $vars = array(':groupTitle' => $this->metaphone_query($input));
            $vars = array_merge($vars, $vars_tag);
            $tempResult = $this->db->prepared_query($sql, $vars);

            $tInput = trim(strtolower($input), '*');
            foreach ($tempResult as $res)
            {  // Prune matches
                $prune = 1;
                $words = explode(' ', $res['groupTitle']);
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

        if (count($result) <= $this->deepSearch)
        {
            $sql = "SELECT * FROM `{$this->tableName}`{$sql_tag}
                        WHERE groupAbbreviation LIKE :grpAbbr
                        ORDER BY {$this->sortBy} {$this->sortDir}
                        {$this->limit}";

            $vars = array(':grpAbbr' => $input);
            $vars = array_merge($vars, $vars_tag);
            $tempResult = $this->db->prepared_query($sql, $vars);
            $currGroups = array_column($result, 'groupID');
            foreach ($tempResult as $tmp) {
                $tmpGroupID = $tmp["groupID"];
                if(!in_array($tmpGroupID, $currGroups)) {
                    $result[] = $tmp;
                }
            }
        }

        // search by ID number
        if (substr(strtolower($origInput), 0, 6) == 'group#')
        {
            if (is_numeric(substr($origInput, 6)))
            {
                $gID = substr($origInput, 6);
                $result = $this->getGroup($gID);
            }
        }

        // add org chart data
        $tcount = count($result);
        for ($i = 0; $i < $tcount; $i++)
        {
            $result[$i]['data'] = $this->getAllData($result[$i]['groupID']);
            $result[$i]['tags'] = $this->getTags($result[$i]['groupID']);
        }

        return $result;
    }

    /**
     * Get group summary, including related positions
     * @param int $groupID
     * @return array
     */
    public function getSummary($groupID)
    {
        $data = array();
        $vars = array(':groupID' => $groupID);
        /*$res = $this->db->prepared_query('SELECT * FROM `groups`
                                            LEFT JOIN relation_group_position USING (groupID)
                                            LEFT JOIN positions USING (positionID)
                                            WHERE groupID=:groupID', $vars);*/

        $data['group'] = $this->getGroup($groupID);

        // group data
        $data['groupData'] = $this->getAllData($groupID);

        //$data['subGroups'] = $this->listMembers($groupID);

        return $data;
    }

    public function getGroup($groupID)
    {
        if (isset($this->cache["getGroup_{$groupID}"]))
        {
            return $this->cache["getGroup_{$groupID}"];
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM `groups`
                                            WHERE groupID=:groupID', $vars);
        $this->cache["getGroup_{$groupID}"] = $res;

        return $res;
    }

    /**
     * Add position
     * @param int group
     * @param int $positionID
     * @return string
     */
    public function addPosition($groupID, $positionID)
    {
        if (!is_numeric($positionID) || !is_numeric($groupID))
        {
            return 0;
        }

        $privs = $this->getUserPrivileges($groupID);
        if ($privs[$groupID]['write'] == 0)
        {
            return 0;
        }

        $this->updateLastModified();

        $vars = array(':groupID' => $groupID,
                      ':positionID' => $positionID, );
        $this->db->prepared_query('INSERT INTO relation_group_position (groupID, positionID)
                                    VALUES (:groupID, :positionID)', $vars);

        $newRecordID = $this->db->getLastInsertID();

        $this->logAction(DataActions::ADD, LoggableTypes::POSITION, [
            new LogItem("relation_group_position", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("relation_group_position", "positionID", $positionID, $this->getPositionDisplay($positionID))
        ]);


        return $newRecordID;
    }

    /**
     * Remove position
     * @param int $groupID
     * @param int $positionID
     */
    public function removePosition($groupID, $positionID)
    {
        if (!is_numeric($groupID) || !is_numeric($positionID))
        {
            return 0;
        }
        $privs = $this->getUserPrivileges($groupID);
        if ($privs[$groupID]['write'] == 0)
        {
            return 0;
        }
        $vars = array(':groupID' => $groupID,
                      ':positionID' => $positionID, );
        $this->db->prepared_query('DELETE FROM relation_group_position
                                    WHERE positionID=:positionID AND groupID=:groupID', $vars);
        $this->updateLastModified();

        $this->logAction(DataActions::DELETE, LoggableTypes::POSITION, [
            new LogItem("relation_group_position", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("relation_group_position", "positionID", $positionID, $this->getPositionDisplay($positionID))
        ]);

        return 1;
    }

    /**
     * Add employee
     * @param int group
     * @param int $employeeID
     * @return string
     */
    public function addEmployee($groupID, $employeeID)
    {
        if (!is_numeric($employeeID) || !is_numeric($groupID))
        {
            return 0;
        }
        $privs = $this->getUserPrivileges($groupID);
        if ($privs[$groupID]['write'] == 0)
        {
            return 0;
        }
        $this->updateLastModified();

        $vars = array(':groupID' => $groupID,
                      ':employeeID' => $employeeID, );

        $strSQL = 'INSERT INTO relation_group_employee (groupID, empUID)
            VALUES (:groupID, :employeeID)
            ON DUPLICATE KEY UPDATE groupID=:groupID, empUID=:employeeID';
        $this->db->prepared_query($strSQL, $vars);

        $employeeDisplay = $this->getEmployeeDisplay($employeeID);

        $this->logAction(DataActions::ADD, LoggableTypes::EMPLOYEE, [
            new LogItem("relation_group_employee", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("relation_group_employee", "empUID", $employeeID, $employeeDisplay)
        ]);

        return $employeeID;
    }

    /**
     * Remove employee
     * @param int $groupID
     * @param int $employeeID
     */
    public function removeEmployee($groupID, $empUID)
    {
        if (!is_numeric($groupID) || !is_numeric($empUID))
        {
            return 0;
        }
        $privs = $this->getUserPrivileges($groupID);
        if ($privs[$groupID]['write'] == 0)
        {
            return 0;
        }
        $vars = array(':groupID' => $groupID,
                      ':empUID' => $empUID, );
        $this->db->prepared_query('DELETE FROM relation_group_employee
                                    WHERE empUID=:empUID AND groupID=:groupID', $vars);
        $this->updateLastModified();

        $employeeDisplay = $this->getEmployeeDisplay($empUID);

        $this->logAction(DataActions::DELETE, LoggableTypes::EMPLOYEE, [
            new LogItem("relation_group_employee", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("relation_group_employee", "empUID", $empUID, $employeeDisplay)
        ]);

        return 1;
    }

    public function getPrivileges($groupID)
    {
        $cacheHash = 'getPrivileges' . $groupID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM group_privileges
                WHERE groupID=:groupID', $vars);

        $this->cache[$cacheHash] = $res;

        return $res;
    }

    /**
     * Toggles the permission for a given group and subject
     * @param int $groupID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     */
    public function togglePermission($groupID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($groupID))
        {
            return;
        }
        $priv = $this->getUserPrivileges($groupID);
        if ($priv[$groupID]['grant'] != 0)
        {
            $vars = array(':groupID' => $groupID,
                          ':categoryID' => $categoryID,
                          ':UID' => $UID, );
            $res = $this->db->prepared_query('SELECT * FROM group_privileges
                                                WHERE groupID=:groupID
                                                    AND categoryID=:categoryID
                                                    AND UID=:UID', $vars);
            if ($res[0][$permissionType] == 1)
            {
                return $this->removePermission($groupID, $categoryID, $UID, $permissionType);
            }

            return $this->addPermission($groupID, $categoryID, $UID, $permissionType);
        }
    }

    /**
     * Adds permission entry
     * @param int $groupID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function addPermission($groupID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($groupID))
        {
            return;
        }
        $priv = $this->getUserPrivileges($groupID);
        if ($priv[$groupID]['grant'] == 0)
        {
            return;
        }

        if($permissionType != 'read' && $permissionType != 'write' && $permissionType != 'grant'){
            return false;
        }

        $vars = array(':groupID' => $groupID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO group_privileges (groupID, categoryID, UID)
                                            VALUES (:groupID, :categoryID, :UID)', $vars);

        $vars = array(':groupID' => $groupID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE group_privileges
                                            SET `$permissionType`=1
                                            WHERE groupID=:groupID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);

        $newPermissions = $this->db->prepared_query("SELECT * from group_privileges WHERE groupID=:groupID
                                            AND categoryID=:categoryID
                                            AND UID=:UID", $vars)[0];

        $this->logAction(DataActions::MODIFY,LoggableTypes::PRIVILEGES,[
            new LogItem("group_privileges", "read", ($newPermissions["read"]? "true": "false")),
            new LogItem("group_privileges", "write", ($newPermissions["write"]? "true": "false")),
            new LogItem("group_privileges", "grant", ($newPermissions["grant"]? "true": "false")),
            new LogItem("group_privileges", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("group_privileges", "categoryID", $categoryID),
            new LogItem("group_privileges", "UID", $UID, $this->getUIDDisplay($categoryID, $UID))
        ]);
        return 1;
    }

    /**
     * Removes the specified permission
     * @param int $groupID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function removePermission($groupID, $categoryID, $UID, $permissionType)
    {
        $priv = $this->getUserPrivileges($groupID);
        if ($priv[$groupID]['grant'] == 0)
        {
            return;
        }
        if($permissionType != 'read' && $permissionType != 'write' && $permissionType != 'grant'){
            return false;
        }

        $vars = array(':groupID' => $groupID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO group_privileges (groupID, categoryID, UID)
                                            VALUES (:groupID, :categoryID, :UID)', $vars);

        $vars = array(':groupID' => $groupID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE group_privileges
                                            SET `$permissionType`=0
                                            WHERE groupID=:groupID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);
        $newPermissions = $this->db->prepared_query("SELECT * from group_privileges WHERE groupID=:groupID
                                            AND categoryID=:categoryID
                                            AND UID=:UID", $vars)[0];

        $this->logAction(DataActions::MODIFY, LoggableTypes::PRIVILEGES, [
            new LogItem("group_privileges", "read", ($newPermissions["read"] ? "true" : "false")),
            new LogItem("group_privileges", "write", ($newPermissions["write"] ? "true" : "false")),
            new LogItem("group_privileges", "grant", ($newPermissions["grant"] ? "true" : "false")),
            new LogItem("group_privileges", "groupID", $groupID, $this->getTitle($groupID)),
            new LogItem("group_privileges", "categoryID", $categoryID),
            new LogItem("group_privileges", "UID", $this->getUIDDisplay($categoryID,$UID))
        ]);

        // if subject has all permissions removed, delete the row from the table
        $vars = array(':groupID' => $groupID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('SELECT * FROM group_privileges
                                            WHERE groupID=:groupID
                                                AND categoryID=:categoryID
                                                AND UID=:UID', $vars);
        if ($res[0]['read'] == 0
                && $res[0]['write'] == 0
                && $res[0]['grant'] == 0)
        {
            $res = $this->db->prepared_query('DELETE FROM group_privileges
                                                WHERE groupID=:groupID
                                                    AND categoryID=:categoryID
                                                    AND UID=:UID', $vars);
        }

        return 0;
    }

    /**
     *
     * @param string $tag_name
     * @param int $groupID
     *
     * @return void
     *
     * Created at: 11/1/2022, 11:29:52 AM (America/New_York)
     */
    public function addGroupTag(string $tag_name, int $groupID): void
    {
        $vars = array(':groupID' => $groupID,
                      ':tag' => $tag_name);
        $sql = 'INSERT INTO group_tags (groupID, tag)
                VALUES (:groupID, :tag)';

        $this->db->prepared_query($sql, $vars);
    }

    private function sortEmployees($a, $b)
    {
        $first = substr(strtolower($a['lastName']), 0, 1);
        $second = substr(strtolower($b['lastName']), 0, 1);

        if ($first == $second)
        {
            return 0;
        }

        return ($first < $second) ? -1 : 1;
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

    private function getUIDDisplay($categoryID, $UID){

        switch($categoryID){
            case "employee":
                return $this->getEmployeeDisplay($UID);
            case "group":
                return $this->getTitle($UID);
            case "position":
                return $this->getPositionDisplay($UID);
            default:
                return '';
        }
    }

    private function getPositionDisplay($UID){
        $positionVars = array(':positionId'=> $UID);
        return $this->db->prepared_query('SELECT positionTitle from positions where positionId = :positionId', $positionVars)[0]['positionTitle'];
    }

    private function getEmployeeDisplay($employeeID){
        $employeeVars = array(':employeeId'=> $employeeID);
        return $this->db->prepared_query('SELECT concat(firstName," ",lastName) as user from employee where empUID = :employeeId', $employeeVars)[0]['user'];
    }
}
