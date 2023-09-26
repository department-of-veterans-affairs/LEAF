<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Group
    Date Created: April 29, 2010

    Handler for user groups for the resource management web app
*/

namespace Portal;

use App\Leaf\Db;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\DataActionLogger;
use App\Leaf\Logger\LogItem;

class Group
{
    /**
     * @var Db
     */
    private $db;

    /**
     * @var Login
     */
    private $login;

    /**
     * @var DataActionLogger
     */
    private $dataActionLogger;

    /**
     * @param Db $db
     * @param Login $login
     * @param DataActionLogger $dataActionLogger
     */
    public function __construct(Db $db, Login $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    /**
     * Logging the imported group
     * @param string $groupName
     *
     * @return void
     */
    public function importGroup($groupName): void
    {
        // Log group imports
        $this->dataActionLogger->logAction(DataActions::IMPORT, LoggableTypes::PORTAL_GROUP, [
            new LogItem("users", "groupID", $groupName, $groupName)
        ]);
    }

    /**
     * Logging the add group
     * @param string $groupName
     *
     * @return void
     */
    public function addGroup($groupName): void
    {
        // Log group creates
        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::PORTAL_GROUP, [
            new LogItem("groups", "name", $groupName, $groupName)
        ]);
    }

    /**
     * [Description for syncImportGroup]
     *
     * @param array $group
     *
     * @return array
     *
     * Created at: 9/15/2022, 8:37:30 AM (America/New_York)
     */
    public function syncImportGroup(array $group): array
    {
        $this->dataActionLogger->logAction(DataActions::IMPORT, LoggableTypes::PORTAL_GROUP, [
            new LogItem("users", "groupID", $group['name'], $group['name'])
        ]);

        $sql_vars = array(':groupID' => $group['groupID'],
                    ':parentGroupID' => $group['parentGroupID'],
                    ':name' => $group['name'],);

        $return_value = $this->db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name)
                                                    VALUES (:groupID, :parentGroupID, :name)
                                                    ON DUPLICATE KEY UPDATE name=:name', $sql_vars);

        return (array) $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return bool|string
     */
    public function removeGroup(int $groupID): bool|string
    {
        if ($groupID != 1) {
            $vars = array(':groupID' => $groupID);
            $sql = 'SELECT `parentGroupID`
                    FROM `groups`
                    WHERE `groupID` = :groupID';

            $res = $this->db->prepared_query($sql, $vars);

            if (isset($res[0]) && $res[0]['parentGroupID'] == null) {
                // Log group deletes
                $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::PORTAL_GROUP, [
                    new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
                ]);

                $sql = 'DELETE
                        FROM `users`
                        WHERE `groupID` = :groupID';

                $this->db->prepared_query($sql, $vars);

                $sql = 'DELETE
                        FROM `groups`
                        WHERE `groupID` = :groupID';

                $this->db->prepared_query($sql, $vars);

                $sql = 'DELETE
                        FROM `dependency_privs`
                        WHERE `groupID` = :groupID';

                $this->db->prepared_query($sql, $vars);

                $return_value = true;
            } else {
                $return_value = false;
            }
        } else {
            $return_value = 'Cannot remove group.';
        }

        return $return_value;
    }

    /**
     * [Description for removeUser]
     *
     * @param string $userID
     * @param int $groupID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/15/2022, 8:51:59 AM (America/New_York)
     */
    public function removeUser(string $userID, int $groupID, string $backupID = ""): array
    {
        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::EMPLOYEE, [
                new LogItem("users", "userID", $userID, $this->getEmployeeDisplay($userID)),
                new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

        $vars = array(':userID' => $userID,
                    ':groupID' => $groupID,
                    ':backupID' => $backupID);
        $sql = 'DELETE
                FROM `users`
                WHERE `userID` = :userID
                AND `groupID` = :groupID
                AND `backupID` = :backupID';

        $result = $this->db->prepared_query($sql, $vars);

        return (array) $result;
    }

    /**
     *
     * @return void
     *
     * Created at: 12/8/2022, 10:45:57 AM (America/New_York)
     */
    public function cleanDb(): void
    {
        $sql_vars = array(':locallyManaged' => 0,
                          ':active' => 0);

        $sql = 'DELETE
                FROM users
                WHERE locallyManaged = :locallyManaged
                AND active = :active';

        $this->db->prepared_query($sql, $sql_vars);
    }

    /**
     * @param int $groupID
     * @param bool $searchDeleted
     * @param bool $all
     *
     * @return array
     *
     * Created at: 7/24/2023, 2:43:20 PM (America/New_York)
     */
    public function getMembers(int $groupID, bool $searchDeleted = false, bool $all = false): array
    {
        if (!is_numeric($groupID)) {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'invalid group ID'
                )
            );
        } else {
            if ($all) {
                $groupBy = '';
            } else {
                $groupBy = 'GROUP BY `userID`';
            }

            $vars = array(':groupID' => $groupID);
            $sql = 'SELECT `userID`, `groupID`, `backupID`, `primary_admin`,
                        `locallyManaged`, `active`
                    FROM `users`
                    WHERE `groupID` = :groupID
                    ' . $groupBy . '
                    ORDER BY `userID`';

            $res = $this->db->pdo_select_query($sql, $vars);

            $members = array();
            if ($res['status']['code'] == 2) {
                $dir = new VAMC_Directory();

               foreach ($res['data'] as $member) {
                    $dirRes = $dir->lookupLogin($member['userID'], false, true, $searchDeleted);

                    if (isset($dirRes[0])) {
                        $dirRes[0]['regionallyManaged'] = false;

                        foreach ($dirRes[0]['groups'] as $group) {
                            if ($groupID == $group['groupID']) {
                                $dirRes[0]['regionallyManaged'] = true;
                            }
                        }

                        if ($groupID == 1) {
                            $dirRes[0]['primary_admin'] = $member['primary_admin'];
                        }

                        $dirRes[0]['backupID'] = $member['backupID'];

                        $dirRes[0]['locallyManaged'] = $member['locallyManaged'];
                        $dirRes[0]['active'] = $member['active'];

                        $members[] = $dirRes[0];
                    }
                }
            }

            $col = array_column( $members, "lastName" );
            array_multisort( $col, SORT_ASC, $members );

            $return_value = array (
                'status' => array (
                    'code' => 2,
                    'message' => ''
                ),
                'data' => $members
            );
        }

        return $return_value;
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return string
     */
    public function addMember(string $member, int $groupID): array
    {
        $oc_db = OC_DB;
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        $vars = array(':userID' => $member,
                    ':groupID' => $groupID);
        $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`,
                    `locallyManaged`, `active`)
                VALUES (:userID, :groupID, "", 1, 1)
                ON DUPLICATE KEY UPDATE `userID` = :userID, `groupID` = :groupID,
                    `backupID` = "", `locallyManaged` = 1, `active` = 1';

        // Update on duplicate keys
        $res = $this->db->pdo_insert_query($sql, $vars);

        if ($res['status']['code'] == 2) {
            $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::EMPLOYEE, [
                new LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            // include the backups of employees
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);

            if (!empty($backups)) {
                foreach ($backups as $backup) {
                    $vars = array(':userID' => $backup['userName'],
                        ':groupID' => $groupID,
                        ':backupID' => $emp[0]['userName']);
                    $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`)
                            VALUES (:userID, :groupID, :backupID)
                            ON DUPLICATE KEY UPDATE `userID` = :userID,
                                `groupID` = :groupID, `backupID` = :backupID';

                    $return_value = $this->db->pdo_insert_query($sql, $vars);
                }

                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => ''
                    )
                );
            } else {
                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => 'No backups to add'
                    )
                );
            }
        } else {
            // If something happened just send the db json response back
            $return_value = $res;
        }

        return $return_value;
    }

    /**
     * @param string $userID
     * @param int $groupID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/15/2022, 9:30:20 AM (America/New_York)
     */
    public function importUser(string $userID, int $groupID, string $backupID): array
    {
        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::EMPLOYEE, [
            new LogItem("users", "userID", $userID, $this->getEmployeeDisplay($userID)),
            new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
        ]);

        $vars = array(':userID' => $userID,
                        ':groupID' => $groupID,
                        ':backupID' => $backupID,);
        $sql = 'INSERT INTO users (groupID, userID, backupID)
                VALUES (:groupID, :userID, :backupID)
                ON DUPLICATE KEY UPDATE userID=:userID';

        $result = $this->db->pdo_insert_query($sql, $vars);

        return (array) $result;
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return void
     *
     * Created at: 8/16/2023, 3:01:10 PM (America/New_York)
     */
    public function deactivateMember($member, $groupID): void
    {
        if (is_numeric($groupID) && $member != '')
        {
            $vars = array(':userID' => $member,
                          ':groupID' => $groupID, );

            $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::EMPLOYEE, [
                new LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            $sql = 'UPDATE `users`
                    SET `active` = 0
                    WHERE `userID` = :userID
                    AND `groupID` = :groupID';

            $this->db->prepared_query($sql, $vars);

            $sql = 'UPDATE `users`
                    SET `active` = 0
                    WHERE `backupID` = :userID
                    AND `groupID` = :groupID';

            $this->db->prepared_query($sql, $vars);
        }
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return void
     */
    public function removeMember($member, $groupID): void
    {
        if (is_numeric($groupID) && $member != '') {
            $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::EMPLOYEE, [
                new LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            $vars = array(':userID' => $member,
                          ':groupID' => $groupID);
            $sql = 'DELETE
                    FROM `users`
                    WHERE (`userID` = :userID
                        AND `groupID` = :groupID
                        AND `backupID` = "")
                    OR (`groupID` = :groupID
                        AND `backupID` = :userID)';

            $this->db->prepared_query($sql, $vars);
        }
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:55:54 AM (America/New_York)
     */
    public function reActivateMember(string $member, int $groupID): array
    {
        if (is_numeric($groupID) && $member != '') {
            $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::EMPLOYEE, [
                new LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            $sql_vars = array(':userID' => $member,
                          ':groupID' => $groupID);
            $sql = 'UPDATE `users`
                    SET `active` = 1
                    WHERE `groupID` = :groupID
                    AND (`userID` = :userID
                        OR `backupID` = :userID)';

            $return_value = $this->db->pdo_update_query($sql, $sql_vars);
        } else {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'Improperly formatted data'
                )
            );
        }

        return $return_value;
    }

    public function getWorkflows(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'SELECT `workflowID`, `stepID`, `groupID`, `stepTitle`, `description`
                FROM `dependency_privs`
                LEFT JOIN `step_dependencies` using (dependencyID)
                LEFT JOIN `workflow_steps` using (stepID)
                LEFT JOIN `workflows` using (workflowID)
                WHERE `groupID` = :groupID
                ORDER BY `workflowID`, `stepID`';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * exclude: 0 (no group), 24, (everyone), 16 (service chief)
     *
     * @return array
     */
    public function getGroups(): array
    {
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID != 0 ORDER BY name ASC', array());

        return $res;
    }

    /**
     * Purpose - Get list of groups for API display
     *
     * @return array
     *
     * Created at: 10/3/2022, 6:54:39 AM (America/New_York)
     */
    public function getGroupsList(): array
    {
        $res = $this->db->query('SELECT groupID, name FROM `groups` WHERE groupID > 1 AND parentGroupID IS NULL ORDER BY name');

        return (array) $res;
    }

    /**
     * @return array
     */
    public function getGroupsAndMembers(bool $searchDeleted = false): array
    {
        $groups = $this->getGroups();

        $list = array();
        foreach ($groups as $group)
        {
            if ($group['groupID'] > 0)
            {
                $group['members'] = $this->getMembers($group['groupID'], $searchDeleted)['data'];
                $list[] = $group;
            }
        }

        return $list;
    }

    /**
     * Returns formatted group name.
     *
     * @param int $groupId
     *
     * @return string
     *
     * Created at: 10/3/2022, 6:55:31 AM (America/New_York)
     */
    public function getGroupName(int $groupId): string
    {
        $sql_vars = array(":groupID" => $groupId);
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID = :groupID', $sql_vars);

        if(!empty($res)){
            $return_value = $res[0]["name"];
        } else {
            $return_value = "";
        }

        return $return_value;
    }

    /**
     * Returns formatted Employee name.
     * @param string $employeeID - The id to create the display name of.
     *
     * @return string
     */
    private function getEmployeeDisplay($employeeID): string
    {
        $dir = new VAMC_Directory();
        $dirRes = $dir->lookupLogin($employeeID);

        if (isset($dirRes[0])) {
            $empData = $dirRes[0];
            $empDisplay =$empData["firstName"]." ".$empData["lastName"];

            return $empDisplay;
        }

        return '';
    }

    /**
     * Returns Employee user ID.
     * @param string $employeeID - The id to create the display name of.
     *
     * @return int
     */
    public function getEmployeeUserID($employeeID): int
    {
        $dir = new VAMC_Directory();
        $dirRes = $dir->lookupLogin($employeeID);
        if (is_array($dirRes) && isset($dirRes[0])) {
            $empData = $dirRes[0];
            $empUserID = $empData["empUID"];
        } else {
            $empUserID = -1;
        }

        return $empUserID;
    }

    /**
     * Returns Portal Group logs.
     *
     * @param int|null $filterById
     *
     * @return array
     *
     * Created at: 12/5/2022, 10:45:23 AM (America/New_York)
     */
    public function getHistory(?int $filterById): array
    {
        return $this->dataActionLogger->getHistory($filterById, "groupID", LoggableTypes::PORTAL_GROUP);
    }

    /**
     * Returns all history ids for all groups
     *
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs(): array
    {
        // this method doesn't expect any arguments
        //return $this->dataActionLogger->getAllHistoryIDs("groupID", LoggableTypes::PORTAL_GROUP);
        return $this->dataActionLogger->getAllHistoryIDs();
    }

    /**
     * retrieve all the groups
     *
     * @return array|false
     *
     * Created at: 9/12/2022, 10:22:25 AM (America/New_York)
     */
    public function getAllGroups(): array|bool
    {
        return $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID > 1 ORDER BY groupID', array());
    }

    /**
     * retrieve all the users
     *
     * @return array|bool
     *
     * Created at: 9/12/2022, 10:21:54 AM (America/New_York)
     */
    public function getAllUsers(): array|bool
    {
        return $this->db->prepared_query('SELECT * FROM users WHERE groupID > 1 ORDER BY userID', array());
    }
}
