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

class Group
{
    /**
     * @var \Leaf\Db
     */
    private $db;

    /**
     * @var Login
     */
    private $login;

    /**
     * @var \Leaf\DataActionLogger
     */
    private $dataActionLogger;

    /**
     * @param \Leaf\Db $db
     * @param Login $login
     * @param \Leaf\DataActionLogger $dataActionLogger
     */
    public function __construct(\Leaf\Db $db, Login $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);
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
        $this->dataActionLogger->logAction(\Leaf\DataActions::IMPORT, \Leaf\LoggableTypes::PORTAL_GROUP, [
            new \Leaf\LogItem("users", "groupID", $groupName, $groupName)
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
        $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::PORTAL_GROUP, [
            new \Leaf\LogItem("groups", "name", $groupName, $groupName)
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
        $this->dataActionLogger->logAction(\Leaf\DataActions::IMPORT, \Leaf\LoggableTypes::PORTAL_GROUP, [
            new \Leaf\LogItem("users", "groupID", $group['name'], $group['name'])
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
    public function removeGroup($groupID): bool|string
    {
        if ($groupID != 1)
        {
            $sql_vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID=:groupID', $sql_vars);

            if (isset($res[0]) && $res[0]['parentGroupID'] == null)
            {
                // Log group deletes
                $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::PORTAL_GROUP, [
                    new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
                ]);

                $this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $sql_vars);
                $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $sql_vars);

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
    public function removeUser(string $userID, int $groupID, string|null $backupID): array
    {
        $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::EMPLOYEE, [
                new \Leaf\LogItem("users", "userID", $userID, $this->getEmployeeDisplay($userID)),
                new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

        if ($backupID == null) {
            $sql_vars = array(':userID' => $userID,
                            ':groupID' => $groupID,);

            $result = $this->db->prepared_query('DELETE FROM users
                                WHERE userID=:userID
                                AND groupID=:groupID
                                AND backupID IS NULL',
                                $sql_vars);
        } else {
            $sql_vars = array(':userID' => $userID,
                            ':groupID' => $groupID,
                            ':backupID' => $backupID, );

            $result = $this->db->prepared_query('DELETE FROM users
                                WHERE userID=:userID
                                AND groupID=:groupID
                                AND backupID=:backupID',
                                $sql_vars);
        }

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
     * return array of userIDs
     * @param int $groupID
     *
     * @return array|string
     */
    public function getMembers($groupID, bool $searchDeleted = false): array|string
    {
        if (!is_numeric($groupID))
        {
            $return_value = "invalid group ID";
        } else {
            $sql_vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM users WHERE groupID=:groupID ORDER BY userID', $sql_vars);

            $members = array();
            if (count($res) > 0)
            {
                $dir = new VAMC_Directory();
                foreach ($res as $member)
                {
                    $dirRes = $dir->lookupLogin($member['userID'], false, true, $searchDeleted);

                    if (isset($dirRes[0]))
                    {
                        $dirRes[0]['regionallyManaged'] = false;
                        foreach ($dirRes[0]['groups'] as $group)
                        {
                            if ($groupID == $group['groupID']){
                                $dirRes[0]['regionallyManaged'] = true;
                            }
                        }
                        if($groupID == 1)
                        {
                            $dirRes[0]['primary_admin'] = $member['primary_admin'];
                        }
                        if($member['locallyManaged'] == 1) {
                            $dirRes[0]['backupID'] = null;
                        } else {
                            $dirRes[0]['backupID'] = $member['backupID'];
                        }
                        $dirRes[0]['locallyManaged'] = $member['locallyManaged'];
                        $dirRes[0]['active'] = $member['active'];

                        $members[] = $dirRes[0];
                    }
                }
            }

            $col = array_column( $members, "lastName" );
            array_multisort( $col, SORT_ASC, $members );

            $return_value = $members;
        }

        return $return_value;
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return string
     */
    public function addMember($member, $groupID): string
    {
        $config = new Config();
        $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID)) {
            $sql_vars = array(':userID' => $member,
                ':groupID' => $groupID,);

            // Update on duplicate keys
            $res = $this->db->prepared_query('INSERT INTO users (userID, groupID, backupID, locallyManaged, active)
                                                    VALUES (:userID, :groupID, null, 1, 1)
                                                    ON DUPLICATE KEY UPDATE userID=:userID, groupID=:groupID, backupID=null, locallyManaged=1, active=1', $sql_vars);

            $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::EMPLOYEE, [
                new \Leaf\LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            // include the backups of employees
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $sql_vars = array(':userID' => $backup['userName'],
                    ':groupID' => $groupID,
                    ':backupID' => $emp[0]['userName'],);

                $res = $this->db->prepared_query('SELECT * FROM users WHERE userID=:userID AND groupID=:groupID', $sql_vars);

                // Check for locallyManaged users
                if ($res[0]['locallyManaged'] == 1) {
                    $sql_vars[':backupID'] = null;
                } else {
                    $sql_vars[':backupID'] = $emp[0]['userName'];
                }
                // Add backupID check for updates
                $this->db->prepared_query('INSERT INTO users (userID, groupID, backupID)
                                                    VALUES (:userID, :groupID, :backupID)
                                                    ON DUPLICATE KEY UPDATE userID=:userID, groupID=:groupID, backupID=:backupID', $sql_vars);
            }

            return $member;
        }
    }

    /**
     * [Description for importUser]
     *
     * @param string $userID
     * @param int $groupID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/15/2022, 9:30:20 AM (America/New_York)
     */
    public function importUser(string $userID, int $groupID, string|null $backupID): array
    {
        $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::EMPLOYEE, [
            new \Leaf\LogItem("users", "userID", $userID, $this->getEmployeeDisplay($userID)),
            new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
        ]);

        $sql_vars = array(':userID' => $userID,
                        ':groupID' => $groupID,
                        ':backupID' => $backupID,);

        $result = $this->db->prepared_query('INSERT INTO users (groupID, userID, backupID)
                                                    VALUES (:groupID, :userID, :backupID)
                                                    ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);

        return (array) $result;
    }

    /**
     * @param string $member
     * @param int $groupID
     *
     * @return void
     */
    public function deactivateMember($member, $groupID): void
    {
        $config = new Config();
        $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID) && $member != '')
        {
            $sql_vars = array(':userID' => $member,
                          ':groupID' => $groupID, );

            $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY, \Leaf\LoggableTypes::EMPLOYEE, [
                new \Leaf\LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            $this->db->prepared_query('UPDATE users SET active = 0, locallyManaged = 1 WHERE userID=:userID AND groupID=:groupID', $sql_vars);

            // include the backups of employee

            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $sql_vars = array(':userID' => $backup['userName'],
                    ':groupID' => $groupID,
                    ':backupID' => $member,);

                $res = $this->db->prepared_query('SELECT locallyManaged FROM users WHERE userID=:userID AND groupID=:groupID AND backupID=:backupID', $sql_vars);

                // Check for locallyManaged users
                if ($res[0]['locallyManaged'] == 0) {
                    $this->db->prepared_query('DELETE FROM users WHERE userID=:userID AND groupID=:groupID AND backupID=:backupID', $sql_vars);
                }
            }
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
        $config = new Config();
        $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID) && $member != '')
        {
            $sql_vars = array(':userID' => $member,
                          ':groupID' => $groupID, );

            $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::EMPLOYEE, [
                new \Leaf\LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new \Leaf\LogItem("users", "groupID", $groupID, $this->getGroupName($groupID))
            ]);

            $this->db->prepared_query('DELETE FROM users WHERE userID=:userID AND groupID=:groupID', $sql_vars);

            // include the backups of employee
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $sql_vars = array(':userID' => $backup['userName'],
                    ':groupID' => $groupID,
                    ':backupID' => $member,);

                $res = $this->db->prepared_query('SELECT * FROM users WHERE userID=:userID AND groupID=:groupID AND backupID=:backupID', $sql_vars);

                // Check for locallyManaged users
                if ($res[0]['locallyManaged'] == 0) {
                    $this->db->prepared_query('DELETE FROM users WHERE userID=:userID AND groupID=:groupID AND backupID=:backupID', $sql_vars);
                }
            }
        }
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
                $group['members'] = $this->getMembers($group['groupID'], $searchDeleted);
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
        return $this->dataActionLogger->getHistory($filterById, "groupID", \Leaf\LoggableTypes::PORTAL_GROUP);
    }

    /**
     * Returns all history ids for all groups
     *
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs(): array
    {
        // this method doesn't expect any arguments
        //return $this->dataActionLogger->getAllHistoryIDs("groupID", \Leaf\LoggableTypes::PORTAL_GROUP);
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
        return $this->db->prepared_query('SELECT * FROM groups WHERE groupID > 1 ORDER BY groupID', array());
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
