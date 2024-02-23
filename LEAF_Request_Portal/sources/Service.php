<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Service controls
    Date Created: September 8, 2016

*/
namespace Portal;
use App\Leaf\Db;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\DataActionLogger;
use App\Leaf\Logger\LogItem;

class Service
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    /**
     * [Description for addService]
     *
     * @param mixed $groupName
     * @param int $parentGroupID
     *
     * @return int|string
     *
     * Created at: 9/14/2022, 11:07:39 AM (America/New_York)
     */
    public function addService(string $groupName, int $parentGroupID = null): int|string
    {
        $groupName = trim($groupName);

        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else if ($groupName == '') {
            $return_value = 'Name cannot be blank';
        } else {
                $newID = -99;
            $res = $this->db->prepared_query('SELECT * FROM services
                                                WHERE serviceID < 0
                                                ORDER BY serviceID ASC', array());

            if (isset($res[0]['serviceID'])) {
                $newID = $res[0]['serviceID'] - 1;
            } else {
                $newID = -1;
            }

            if (!is_null($parentGroupID)) {
                $parentGroupID = (int)$parentGroupID;
            }

            $sql_vars = array(':serviceID' => (int)$newID,
                        ':service' => $groupName,
                        ':groupID' => $parentGroupID, );

            $res = $this->db->prepared_query("INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                                                VALUES (:serviceID, :service, '', :groupID)", $sql_vars);

            $return_value = $newID;
        }

        return $return_value;
    }

    /**
     *
     * @param int $serviceID
     * @param string $service
     * @param string|null $abbrService
     * @param int|null $groupID
     *
     * @return void
     *
     * Created at: 11/2/2022, 7:04:44 AM (America/New_York)
     */
    public function importService(int $serviceID, string $service, string|null $abbrService, int|null $groupID): void
    {
        $sql_vars = array(':serviceID' => $serviceID,
                  ':service' => $service,
                  ':abbrService' => $abbrService,
                  ':groupID' => $groupID, );
        $sql = 'INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                VALUES (:serviceID, :service, :abbrService, :groupID)
    			ON DUPLICATE KEY UPDATE service=:service, groupID=:groupID';

        $this->db->prepared_query($sql, $sql_vars);
    }

    /**
     * [Description for removeService]
     *
     * @param int $groupID
     *
     * @return bool|string
     *
     * Created at: 9/14/2022, 11:36:25 AM (America/New_York)
     */
    public function removeService(int $groupID): bool|string
    {
        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $sql_vars = array(':groupID' => $groupID);
            $this->db->prepared_query('DELETE FROM services WHERE serviceID=:groupID', $sql_vars);
            $this->db->prepared_query('DELETE FROM service_chiefs WHERE serviceID=:groupID', $sql_vars);

            $return_value = 1;
        }

        return $return_value;
    }

    /**
     * [Description for removeSyncService]
     *
     * @param int $groupID
     *
     * @return bool
     *
     * Created at: 9/16/2022, 7:06:55 AM (America/New_York)
     */
    public function removeSyncService(int $groupID): bool
    {
        $sql_vars = array(':groupID' => $groupID);
        $this->db->prepared_query('DELETE FROM services WHERE serviceID=:groupID', $sql_vars);

        return true;
    }

    /**
     * @param int $groupID
     * @param string $member
     *
     * @return bool
     *
     * Created at: 8/16/2023, 8:45:10 AM (America/New_York)
     */
    public function addMember($groupID, $member)
    {
        $oc_db = OC_DB;
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID) && $member != '') {
            $vars = array(':userID' => $member,
                        ':serviceID' => $groupID);
            $sql = 'INSERT INTO `service_chiefs` (
                        `serviceID`, `userID`, `backupID`, `locallyManaged`, `active`)
                    VALUES (:serviceID, :userID, "", 1, 1)
                    ON DUPLICATE KEY UPDATE `locallyManaged` = 1, `active` = 1';

            // Update on duplicate keys
            $this->db->prepared_query($sql, $vars);

            $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::SERVICE_CHIEF, [
                new LogItem("service_chiefs","serviceID", $groupID, $this->getServiceName($groupID)),
                new LogItem("service_chiefs", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("service_chiefs", "locallyManaged", "false")
            ]);

            // check if this service is also an ELT
            $vars = array(':groupID' => $groupID);
            $sql = 'SELECT `groupID`
                    FROM `services`
   					WHERE `serviceID` = :groupID';
            $res = $this->db->prepared_query($sql, $vars);


            if ($res[0]['groupID'] == $groupID) {
                $vars = array(':userID' => $member,
                            ':serviceID' => $groupID);
                $sql = 'INSERT INTO `users` (
                            `groupID`, `userID`, `backupID`, `locallyManaged`, `active`)
                        VALUES (:serviceID, :userID, "", 1, 1)
                        ON DUPLICATE KEY UPDATE `locallyManaged` = 1, `active` = 1';

                $this->db->prepared_query($sql, $vars);
            }

            // include the backups of employees
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $vars = array(':userID' => $backup['userName'],
                        ':serviceID' => $groupID,
                        ':backupID' => $emp[0]['userName']);
                $sql = 'INSERT INTO `service_chiefs` (`userID`, `serviceID`, `backupID`)
                        VALUES (:userID, :serviceID, :backupID)
                        ON DUPLICATE KEY UPDATE `userID` = :userID, `serviceID` = :serviceID,
                            `backupID` = :backupID';

                $this->db->prepared_query($sql, $vars);

                $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`)
                        VALUES (:userID, :serviceID, :backupID)
                        ON DUPLICATE KEY UPDATE `userID` = :userID, `groupID` = :serviceID,
                            `backupID` = :backupID';

                $this->db->prepared_query($sql, $vars);
            }
        }

        return 1;
    }

    /**
     * [Description for importChief]
     *
     * @param int $serviceID
     * @param string $userID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/14/2022, 11:57:18 AM (America/New_York)
     */
    public function importChief(int $serviceID, string $userID, string|null $backupID): array
    {
        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::SERVICE_CHIEF, [
            new LogItem("service_chiefs","serviceID", $serviceID, $this->getServiceName($serviceID)),
            new LogItem("service_chiefs", "userID", $userID, $this->getEmployeeDisplay($userID)),
            new LogItem("service_chiefs", "locallyManaged", "false")
        ]);
        $sql_vars = array(':userID' => $userID,
                    ':serviceID' => $serviceID,
                    ':backupID' => $backupID,);

        return $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, backupID, locallyManaged, active)
                                                    VALUES (:serviceID, :userID, :backupID, 0, 1)
                                                    ON DUPLICATE KEY UPDATE serviceID=:serviceID, userID=:userID, backupID=:backupID', $sql_vars);
    }

    /**
     * @param int $groupID
     * @param string $member
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:46:21 AM (America/New_York)
     */
    public function deactivateChief(int $groupID, string $member): array
    {
        if (is_numeric($groupID) && $member != '') {
            $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::SERVICE_CHIEF, [
                new LogItem("service_chiefs", "userID", $member, $this->getEmployeeDisplay($member)),
                new LogItem("service_chiefs", "serviceID", $groupID, $this->getServiceName($groupID))
            ]);

            $vars = array(':userID' => $member,
                          ':serviceID' => $groupID, );

            $sql = 'SELECT userID, serviceID, locallyManaged FROM `service_chiefs`
                    WHERE `userID` = :userID
                        AND `serviceID` = :serviceID
                        AND locallyManaged = 1';

            $res = $this->db->prepared_query($sql, $vars);
            // If the users are locally managed, we can simply delete them
            if(count($res) > 0) {
                $sql = 'DELETE FROM `service_chiefs`
                        WHERE `serviceID` = :serviceID
                        AND (`userID` = :userID
                            OR `backupID` = :userID)';

                $this->db->prepared_query($sql, $vars);

                $sql = 'DELETE FROM `users`
                        WHERE `groupID` = :serviceID
                        AND (`userID` = :userID
                            OR `backupID` = :userID)';

                $this->db->prepared_query($sql, $vars);
            }
            // otherwise we flag it as a local override
            else {
                $sql = 'UPDATE `service_chiefs`
                        SET `active` = 0,
                        `locallyManaged` = 1
                        WHERE `serviceID` = :serviceID
                        AND (`userID` = :userID
                            OR `backupID` = :userID)';

                $this->db->prepared_query($sql, $vars);

                $sql = 'UPDATE `users`
                        SET `active` = 0,
                        `locallyManaged` = 1
                        WHERE `groupID` = :serviceID
                        AND (`userID` = :userID
                            OR `backupID` = :userID)';

                $this->db->prepared_query($sql, $vars);
            }

            $return_value = array(
                'status' => array(
                    'code' => 2,
                    'message' => 'All processed properly'
                )
            );
        } else {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'data formatted incorrectly'
                )
            );
        }

        return $return_value;
    }

    /**
     * @param int $serviceID
     * @param string $userName
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:46:50 AM (America/New_York)
     */
    public function pruneChief(int $serviceID, string $userName): array
    {
        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::SERVICE_CHIEF, [
            new LogItem("service_chiefs", "userID", $userName, $this->getEmployeeDisplay($userName)),
            new LogItem("service_chiefs", "serviceID", $serviceID, $this->getServiceName($serviceID))
        ]);

        $vars = array(':serviceID' => $serviceID,
                ':userID' => $userName);
        $sql = 'DELETE
                FROM `service_chiefs`
                WHERE `serviceID` = :serviceID
                AND ((`userID` = :userID
                    AND `backupID` = "")
                    OR `backupID` = :userID)';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `users`
                WHERE `groupID` = :serviceID
                AND ((`userID` = :userID
                    AND `backupID` = "")
                    OR `backupID` = :userID)';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param string $member
     * @param int $serviceID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:47:05 AM (America/New_York)
     */
    public function reactivateChief(string $member, int $serviceID): array
    {
        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::EMPLOYEE, [
            new LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
            new LogItem("users", "groupID", $serviceID, $this->getServiceName($serviceID))
        ]);

        $vars = array(':serviceID' => $serviceID,
                ':userID' => $member);
        $sql = 'UPDATE `service_chiefs`
                SET `active` = 1,
                    locallyManaged = 0
                WHERE `serviceID` = :serviceID
                AND (`userID` = :userID
                    OR `backupID` = :userID)';

        $return_value = $this->db->pdo_update_query($sql, $vars);

        $vars = array(':serviceID' => $serviceID,
                ':userID' => $member);
        $sql = 'UPDATE `users`
                SET `active` = 1,
                    locallyManaged = 0
                WHERE `groupID` = :serviceID
                AND (`userID` = :userID
                    OR `backupID` = :userID)';

        $return_value = $this->db->pdo_update_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $serviceID
     * @param string $userID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/14/2022, 11:33:53 AM (America/New_York)
     */
    public function removeChief(int $serviceID, string $userID, string $backupID = ""): array
    {
        $this->dataActionLogger->logAction(DataActions::DELETE,LoggableTypes::SERVICE_CHIEF,[
            new LogItem("service_chiefs","serviceID", $serviceID, $this->getServiceName($serviceID)),
            new LogItem("service_chiefs", "userID", $userID, $this->getEmployeeDisplay($userID))
        ]);

        $vars = array(':userID' => $userID,
                    ':serviceID' => $serviceID,
                    ':backupID' => $backupID);
        $sql = 'DELETE
                FROM `service_chiefs`
                WHERE `userID` = :userID
                AND `serviceID` = :serviceID
                AND `backupID` = :backupID';

        $result = $this->db->prepared_query($sql, $vars);

        return $result;
    }

    public function getMembers($groupID)
    {
        if (!is_numeric($groupID)) {
            return;
        }

        $sql_vars = array(':groupID' => $groupID);
        $sql = 'SELECT `userID`, `backupID`, `locallyManaged`, `active`
                FROM `service_chiefs`
                WHERE `serviceID` = :groupID
                ORDER BY `userID`';

        $res = $this->db->prepared_query($sql, $sql_vars);

        $members = array();
        $dir = new VAMC_Directory();

        if (count($res) > 0) {
            foreach ($res as $member) {
                $dirRes = $dir->lookupLogin($member['userID'], true, false);

                if (isset($dirRes[0])) {
                    $temp = $dirRes[0];

                    $temp['backupID'] = $member['backupID'];
                    $temp['locallyManaged'] = $member['locallyManaged'];
                    $temp['active'] = $member['active'];
                    $members[] = $temp;
                }
            }
        }

        return $members;
    }

    public function getChiefs(int $serviceID, bool $active = true): array
    {
        $sql_vars = array(':serviceID' => $serviceID,
                          ':active' => $active,);

        return $this->db->prepared_query('SELECT * FROM service_chiefs
    										WHERE serviceID=:serviceID
    										AND active=:active', $sql_vars);
    }

    public function getQuadrads()
    {
        $res = $this->db->prepared_query('SELECT groupID, name FROM services
    								LEFT JOIN `groups` USING (groupID)
    								WHERE groupID IS NOT NULL
    								GROUP BY groupID
    								ORDER BY name', array());

        return $res;
    }

    public function getAllQuadrads()
    {
        return $this->db->prepared_query('SELECT * FROM services', array());
    }

    public function getAllChiefs()
    {
        return $this->db->prepared_query('SELECT * FROM service_chiefs', array());
    }

    public function getGroups()
    {
        $res = $this->db->prepared_query('SELECT * FROM services ORDER BY service ASC', array());

        return $res;
    }

    public function getGroupsAndMembers()
    {
        $groups = $this->getGroups();

        $list = array();
        foreach ($groups as $group)
        {
            $group['members'] = $this->getMembers($group['serviceID']);
            $list[] = $group;
        }

        return $list;
    }

    /**
     * Gets Employee name formatted for display
     * @param string $employeeID 	the id of the employee to retrieve display name
     * @return string
     */
    private function getEmployeeDisplay($employeeID)
    {
        $dir = new VAMC_Directory();
        $dirRes = $dir->lookupLogin($employeeID);

        if (is_array($dirRes) && isset($dirRes[0])) {
            $empData = $dirRes[0];
            $empDisplay = $empData["firstName"] . " " . $empData["lastName"];
        } else {
            $empDisplay = 'No Employee Found';
        }

        return $empDisplay;
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
     * Gets display name for Service.
     * @param int $serviceID 	the id of the service to find display name for.
     * @return string
     */
    public function getServiceName($serviceID)
    {
        $vars = array(':serviceID' => $serviceID);
        $sql = 'SELECT `service`
                FROM services
                WHERE serviceid=:serviceID';

        $name = $this->db->prepared_query($sql, $vars);

        return !empty($name) ? $name[0]['service'] : 'Service Not Found';
    }

    /**
     * Gets history for given serviceID.
     *
     * @param int|null $filterById
     *
     * @return array
     *
     * Created at: 12/5/2022, 10:45:11 AM (America/New_York)
     */
    public function getHistory(?int $filterById): array
    {
        return $this->dataActionLogger->getHistory($filterById, "serviceID", LoggableTypes::SERVICE_CHIEF);
    }
}
