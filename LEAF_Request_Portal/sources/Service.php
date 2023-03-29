<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Service controls
    Date Created: September 8, 2016

*/
namespace Portal;

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
        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);

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

    public function addMember($groupID, $member)
    {
        $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \DIRECTORY_DB);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID) && $member != '') {
            $sql_vars = array(':userID' => $member,
                    ':serviceID' => $groupID,);

            // Update on duplicate keys
            $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, backupID, locallyManaged, active)
                                                    VALUES (:serviceID, :userID, null, 1, 1)
                                                    ON DUPLICATE KEY UPDATE serviceID=:serviceID, userID=:userID, backupID=null, locallyManaged=1, active=1', $sql_vars);

            $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::SERVICE_CHIEF, [
                new \Leaf\LogItem("service_chiefs","serviceID", $groupID, $this->getServiceName($groupID)),
                new \Leaf\LogItem("service_chiefs", "userID", $member, $this->getEmployeeDisplay($member)),
                new \Leaf\LogItem("service_chiefs", "locallyManaged", "false")
            ]);

            // check if this service is also an ELT
            $sql_vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM services
   												WHERE serviceID=:groupID', $sql_vars);
            // if so, update groups table
            if ($res[0]['groupID'] == $groupID)
            {
                $sql_vars = array(':userID' => $member,
                              ':groupID' => $groupID, );
                $this->db->prepared_query('INSERT INTO users (userID, groupID)
                                                VALUES (:userID, :groupID)', $sql_vars);
            }

            // include the backups of employees
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $sql_vars = array(':userID' => $backup['userName'],
                    ':serviceID' => $groupID,
                    ':backupID' => $emp[0]['userName'],);

                $res = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE userID=:userID AND serviceID=:serviceID', $sql_vars);

                // Check for locallyManaged users
                if ($res[0]['locallyManaged'] == 1) {
                    $sql_vars[':backupID'] = null;
                } else {
                    $sql_vars[':backupID'] = $emp[0]['userName'];
                }
                // Add backupID check for updates
                $this->db->prepared_query('INSERT INTO service_chiefs (userID, serviceID, backupID)
                                                    VALUES (:userID, :serviceID, :backupID)
                                                    ON DUPLICATE KEY UPDATE userID=:userID, serviceID=:serviceID, backupID=:backupID', $sql_vars);
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
        $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::SERVICE_CHIEF, [
            new \Leaf\LogItem("service_chiefs","serviceID", $serviceID, $this->getServiceName($serviceID)),
            new \Leaf\LogItem("service_chiefs", "userID", $userID, $this->getEmployeeDisplay($userID)),
            new \Leaf\LogItem("service_chiefs", "locallyManaged", "false")
        ]);
        $sql_vars = array(':userID' => $userID,
                    ':serviceID' => $serviceID,
                    ':backupID' => $backupID,);

        return $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, backupID, locallyManaged, active)
                                                    VALUES (:serviceID, :userID, :backupID, 0, 1)
                                                    ON DUPLICATE KEY UPDATE serviceID=:serviceID, userID=:userID, backupID=:backupID, locallyManaged=0, active=1', $sql_vars);
    }

    public function removeMember($groupID, $member)
    {
        $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \DIRECTORY_DB);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        if (is_numeric($groupID) && $member != '') {
            $sql_vars = array(':userID' => $member,
                          ':groupID' => $groupID, );

            $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::SERVICE_CHIEF, [
                new \Leaf\LogItem("service_chiefs", "serviceID", $groupID, $this->getServiceName($groupID)),
                new \Leaf\LogItem("service_chiefs", "userID", $member, $this->getEmployeeDisplay($member))
            ]);

            $sql = 'UPDATE service_chiefs
                    SET active = 0, locallyManaged = 1
                    WHERE userID=:userID
                    AND serviceID=:groupID';

            $this->db->prepared_query($sql, $sql_vars);

            // check if this service is also an ELT
            $sql_vars = array(':groupID' => $groupID);
            $sql = 'SELECT groupID
                    FROM services
                    WHERE serviceID = :groupID
                    AND groupID = :groupID';

            $res = $this->db->prepared_query($sql, $sql_vars);

            // if so, update groups table
            if (is_array($res) && isset($res[0]['groupID'])) {
                $sql_vars = array(':userID' => $member,
                        ':groupID' => $groupID, );

                $sql = 'UPDATE users
                        SET active = 0, locallyManaged = 1
                        WHERE userID=:userID
                        AND groupID=:groupID';

                $this->db->prepared_query($sql, $sql_vars);
            }

            // include the backups of employee
            $emp = $employee->lookupLogin($member);
            $backups = $employee->getBackups($emp[0]['empUID']);
            foreach ($backups as $backup) {
                $sql_vars = array(':userID' => $backup['userName'],
                    ':serviceID' => $groupID,
                    ':backupID' => $member,);

                $sql = 'SELECT locallyManaged
                        FROM service_chiefs
                        WHERE userID=:userID
                        AND serviceID=:serviceID
                        AND backupID=:backupID
                        AND locallyManaged = 0';

                $res = $this->db->prepared_query($sql, $sql_vars);

                // Check for locallyManaged users
                if (isset($res[0]['locallyManaged'])) {
                    $sql2 = 'DELETE
                             FROM service_chiefs
                             WHERE userID=:userID
                             AND serviceID=:serviceID
                             AND backupID=:backupID';

                    $this->db->prepared_query($sql2, $sql_vars);
                }
            }
        }

        return 1;
    }

    /**
     * [Description for removeChief]
     *
     * @param int $serviceID
     * @param string $userID
     * @param string $backupID
     *
     * @return array
     *
     * Created at: 9/14/2022, 11:33:53 AM (America/New_York)
     */
    public function removeChief(int $serviceID, string $userID, string|null $backupID): array
    {
        $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE,\Leaf\LoggableTypes::SERVICE_CHIEF,[
            new \Leaf\LogItem("service_chiefs","serviceID", $serviceID, $this->getServiceName($serviceID)),
            new \Leaf\LogItem("service_chiefs", "userID", $userID, $this->getEmployeeDisplay($userID))
        ]);

        if ($backupID == NULL){
            $sql_vars = array(':userID' => $userID,
                          ':serviceID' => $serviceID,);

            $result = $this->db->prepared_query('DELETE FROM service_chiefs
                                            WHERE userID=:userID
                                            AND serviceID=:serviceID
                                            AND backupID IS NULL',
                                            $sql_vars);
        } else {
            $sql_vars = array(':userID' => $userID,
                          ':serviceID' => $serviceID,
                          ':backupID' => $backupID, );

            $result = $this->db->prepared_query('DELETE FROM service_chiefs
                                            WHERE userID=:userID
                                            AND serviceID=:serviceID
                                            AND backupID=:backupID',
                                            $sql_vars);
        }

        return $result;
    }

    public function getMembers($groupID)
    {
        if (!is_numeric($groupID))
        {
            return;
        }
        $sql_vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE serviceID=:groupID ORDER BY userID', $sql_vars);

        $members = array();
        if (count($res) > 0)
        {
            $dir = new VAMC_Directory();
            foreach ($res as $member)
            {
                $dirRes = $dir->lookupLogin($member['userID']);

                if (isset($dirRes[0]))
                {
                    $temp = $dirRes[0];
                    if($member['locallyManaged'] == 1) {
                        $temp['backupID'] = null;
                    } else {
                        $temp['backupID'] = $member['backupID'];
                    }
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

        if (is_array($dirRes && isset($dirRes[0]))) {
            $empData = $dirRes[0];
            $empDisplay = $empData["firstName"] . " " . $empData["lastName"];
        } else {
            $empDisplay = 'No Employee Found';
        }

        return $empDisplay;
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
        return $this->dataActionLogger->getHistory($filterById, "serviceID", \Leaf\LoggableTypes::SERVICE_CHIEF);
    }
}
