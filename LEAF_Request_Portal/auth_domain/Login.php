<?php
use App\Leaf\Db;
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Login class and session handler
    Date Created: September 11, 2007

*/

class Login
{
    private $db;

    private $userDB;

    private $isLogin = false;

    private $name = 'default';

    private $userID = 'default';

    private $empUID;

    private $isInDB = true;

    private $baseDir = '';

    private $cache = array();

    public function __construct($phonebookDB, $userDB)
    {
        $this->db = $phonebookDB; //nexus DB
        $this->userDB = $userDB; // portal db

        if (session_id() == '')
        {
            $sessionHandler = new Session($this->db);
            session_set_save_handler($sessionHandler, true);
            session_start();
            $cookie = session_get_cookie_params();
            $id = session_id();

            // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//            $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
            $https = true;
            setcookie('PHPSESSID', $id, time() + 2592000, $cookie['path'], $cookie['domain'], $https, true);
        }
    }

    public function register()
    {
        return false;
    }

    public function getNexusDB()
    {
        return $this->db;
    }

    public function isInDB()
    {
        return $this->isInDB;
    }

    public function getName()
    {
        return $this->name;
    }

    public function getUserID()
    {
        return $this->userID;
    }

    public function getEmpUID()
    {
        return $this->empUID;
    }

    public function setBaseDir($baseDir)
    {
        $this->baseDir = "/{$baseDir}";
    }

    public function parseURL($in)
    {
        $paths = explode('/', $in);
        $out = array();

        foreach ($paths as $path)
        {
            if ($path != '')
            {
                if ($path == '..')
                {
                    array_pop($out);
                }
                else
                {
                    $out[] = $path;
                }
            }
        }
        $buffer = '';
        foreach ($out as $path)
        {
            $buffer .= "/{$path}";
        }

        return $buffer;
    }

    public function loginUser()
    {
        if (isset($_SERVER['REMOTE_USER']))
        {
            list($domain, $user) = explode('\\', $_SERVER['REMOTE_USER']);

            // see if user is valid
            $vars = array(':userName' => $user);
            $res = $this->db->prepared_query('SELECT * FROM employee
            										WHERE userName=:userName
        												AND deleted=0', $vars);

            if (count($res) > 0)
            {
                $_SESSION['userID'] = $user;
            }
            else
            {
                // try searching through national database
                $globalDB = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
                $vars = array(':userName' => $user);
                $res = $globalDB->prepared_query('SELECT * FROM employee
        											LEFT JOIN employee_data USING (empUID)
        											WHERE userName=:userName
            											AND indicatorID = 6
        												AND deleted=0', $vars);
                // add user to local DB
                if (count($res) > 0)
                {
                    $vars = array(':firstName' => $res[0]['firstName'],
                            ':lastName' => $res[0]['lastName'],
                            ':middleName' => $res[0]['middleName'],
                            ':userName' => $res[0]['userName'],
                            ':phoFirstName' => $res[0]['phoneticFirstName'],
                            ':phoLastName' => $res[0]['phoneticLastName'],
                            ':domain' => $res[0]['domain'],
                            ':lastUpdated' => time(),
                            ':new_empUUID' => $res[0]['new_empUUID'] );
                    $this->db->prepared_query('INSERT INTO employee (firstName, lastName, middleName, userName, phoneticFirstName, phoneticLastName, domain, lastUpdated, new_empUUID)
                                          VALUES (:firstName, :lastName, :middleName, :userName, :phoFirstName, :phoLastName, :domain, :lastUpdated, :new_empUUID)
            								ON DUPLICATE KEY UPDATE deleted=0', $vars);
                    $empUID = $this->db->getLastInsertID();

                    if ($empUID == 0)
                    {
                        $vars = array(':userName' => $res[0]['userName']);
                        $empUID = $this->db->prepared_query('SELECT empUID FROM employee
                                                                    WHERE userName=:userName', $vars)[0]['empUID'];
                    }

                    $vars = array(':empUID' => $empUID,
                            ':indicatorID' => 6,
                            ':data' => $res[0]['data'],
                            ':author' => 'viaLogin',
                            ':timestamp' => time(),
                    );
                    $this->db->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, author, timestamp)
        											VALUES (:empUID, :indicatorID, :data, :author, :timestamp)
                                                    ON DUPLICATE KEY UPDATE data=:data', $vars);

                    // redirect as usual
                    $_SESSION['userID'] = $res[0]['userName'];
                }
                else
                {
                    echo 'Unable to log in: User not found in global database.';
                }
            }
        }

        $var = array(':userID' => $_SESSION['userID']);
        $result = $this->db->prepared_query('SELECT * FROM employee WHERE userName=:userID AND deleted = 0', $var);

        if (isset($result[0]['userName']))
        {
            $this->name = "{$result[0]['firstName']} {$result[0]['lastName']}";
            $this->userID = $result[0]['userName'];
            $this->empUID = $result[0]['empUID'];
            $this->setSession();

            $this->isLogin = true;

            return true;
        }
    }

    public function logout()
    {
        $keys = array_keys($_SESSION);
        foreach ($keys as $key)
        {
            unset($_SESSION[$key]);
        }
        $cookie = session_get_cookie_params();
        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
        $https = true;
        setcookie('PHPSESSID', '', time() - 3600, $cookie['path'], $cookie['domain'], $https, true);
    }

    public function isLogin()
    {
        return $this->isLogin;
    }

    /**
     * Checks if the current user is part of a group
     *
     * @param int $groupID Group ID number
     * @return bool True if user is in the group, false otherwise
     */
    public function checkGroup(int $groupID): bool
    {
        $this->cache['checkGroup'] ??= $this->loadUserGroups();

        // Special case for "Everyone" groupID 2, workaround until Orgchart is more integrated
        if ($groupID == 2) {
            $this->cache['checkGroup'][2] = true;
        }

        $isMember = isset($this->cache['checkGroup'][$groupID]);

        return $isMember;
    }

    /**
     * Load all groups for the current user from database
     *
     * @return array Array of groupID => true mappings
     */
    private function loadUserGroups(): array
    {
        $var = [':userID' => $this->userID];
        $sql = 'SELECT `groupID`
                FROM `users`
                WHERE `userID` = :userID
                AND `active` = 1';

        $result = $this->userDB->prepared_query($sql, $var);
        $groups = [];

        foreach ($result as $group) {
            $groups[$group['groupID']] = true;
        }

        return $groups;
    }

    /**
     * Checks if the current user has service chief access for a particular service
     * @param int $groupID Service ID number
     * @return boolean
     */
    public function checkService($groupID)
    {
        if (isset($this->cache["isInService$groupID"]))
        {
            return $this->cache["isInService$groupID"];
        }

        $var = array(':userID' => $this->userID,
                     ':groupID' => $groupID, );
        $result = $this->userDB->prepared_query('SELECT * FROM service_chiefs WHERE userID=:userID
        											AND serviceID=:groupID
        											AND active=1', $var);

        if (isset($result[0]))
        {
            $this->cache["isInService$groupID"] = true;

            return true;
        }
        $this->cache["isInService$groupID"] = false;

        return false;
    }

    public function isServiceChief()
    {
        if (isset($this->cache['isServiceChief']))
        {
            return $this->cache['isServiceChief'];
        }

        $var = array(':userID' => $this->userID);
        $result = $this->userDB->prepared_query('SELECT * FROM service_chiefs
                                            WHERE userID=:userID
        										AND active=1', $var);

        if (isset($result[0]))
        {
            $this->cache['isServiceChief'] = true;

            return true;
        }
        $this->cache['isServiceChief'] = false;

        return false;
    }

    public function getQuadradGroupID()
    {
        if (!isset($this->cache['getQuadradGroupID'])) {
            $result = $this->queryQuadradGroups();

            $buffer = 0;

            if (isset($result[0])) {
                $groupIDs = array_column($result, 'groupID');
                $buffer = implode(',', $groupIDs);
            }

            $this->cache['getQuadradGroupID'] = $buffer;
        }

        return $this->cache['getQuadradGroupID'];
    }

    /**
     * Check if the current user is part of quadrad (executive leadership)
     *
     * @return bool True if user is quadrad, false otherwise
     */
    public function isQuadrad(): bool
    {
        $this->cache['isQuadrad'] ??= $this->checkQuadradMembership();

        return $this->cache['isQuadrad'];
    }

    /**
     * Check quadrad membership by querying groups
     *
     * @return bool True if user has quadrad groups, false otherwise
     */
    private function checkQuadradMembership(): bool
    {
        $result = $this->queryQuadradGroups();
        $isQuadrad = !empty($result);

        return $isQuadrad;
    }

    /**
     * Query database for quadrad groups
     *
     * @return array Array of group records
     */
    private function queryQuadradGroups(): array
    {
        $var = [':userID' => $this->userID];
        $sql = 'SELECT `groupID`
                FROM `groups`
                LEFT JOIN `users` USING (`groupID`)
                WHERE `parentGroupID` = -1
                AND `userID` = :userID
                AND `active` = 1';

        $result = $this->userDB->prepared_query($sql, $var);

        return $result;
    }

    /**
     * Retrieves the positions and groups the current user is a member of
     *
     * @return array Array containing membership information (positionID, empUID, groupID, inheritsFrom)
     */
    public function getMembership(): array
    {
        $empUID = (int)$this->empUID;
        $cacheKey = "getMembership_{$empUID}";

        $this->cache[$cacheKey] ??= $this->buildMembership($empUID);

        return $this->cache[$cacheKey];
    }

    /**
     * Build complete membership information for a user
     *
     * @param int $empUID The employee UID
     * @return array Complete membership information
     */
    private function buildMembership(int $empUID): array
    {
        $membership = [];

        // Get backup relationships and build employee list
        $backupEmployees = $this->getBackupEmployees($empUID);
        $employeeList = $this->buildEmployeeList($empUID, $backupEmployees);

        if (!empty($backupEmployees)) {
            $membership['inheritsFrom'] = $backupEmployees;
        }

        // Get positions for all employees
        $positions = $this->getPositionsForEmployees($employeeList);
        if (!empty($positions)) {
            $membership['positionID'] = $positions;
        }

        // Add current employee
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // Get user groups
        $userGroups = $this->loadUserGroups();
        $membership['groupID'] = $userGroups;

        // Get service chief groups
        $serviceChiefGroups = $this->getServiceChiefGroups();
        foreach ($serviceChiefGroups as $serviceID => $value) {
            $membership['groupID'][$serviceID] = $value;
        }

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        return $membership;
    }

    /**
     * Get employees that the current user is a backup for
     *
     * @param int $empUID The employee UID
     * @return array Array of employee UIDs
     */
    private function getBackupEmployees(int $empUID): array
    {
        $vars = [':empUID' => $empUID];
        $sql = 'SELECT `empUID`
                FROM `relation_employee_backup`
                WHERE `backupEmpUID` = :empUID
                AND `approved` = 1';

        $res = $this->db->prepared_query($sql, $vars);
        $backupEmployees = [];

        foreach ($res as $item) {
            $backupEmployees[] = (int)$item['empUID'];
        }

        return $backupEmployees;
    }

    /**
     * Build comma-separated list of employee UIDs including backups
     *
     * @param int $empUID The primary employee UID
     * @param array $backupEmployees Array of backup employee UIDs
     * @return string Comma-separated employee UIDs
     */
    private function buildEmployeeList(int $empUID, array $backupEmployees): string
    {
        $employeeList = (string)$empUID;

        foreach ($backupEmployees as $backupEmpUID) {
            $employeeList .= ",{$backupEmpUID}";
        }

        return $employeeList;
    }

    /**
     * Get positions for a list of employees
     *
     * @param string $employeeList Comma-separated employee UIDs
     * @return array Array of positionID => 1 mappings
     */
    private function getPositionsForEmployees(string $employeeList): array
    {
        $vars = [];
        $sql = "SELECT `positionID`, `empUID`, `rge`.`groupID` as `employee_groupID`,
                    `rgp`.`groupID` as `position_groupID`
                FROM `employee`
                LEFT JOIN `relation_position_employee` `rpe` USING (`empUID`)
                LEFT JOIN `relation_group_employee` `rge` USING (`empUID`)
                LEFT JOIN `relation_group_position` `rgp` USING (`positionID`)
                WHERE `empUID` IN ({$employeeList})";

        $res = $this->db->prepared_query($sql, $vars);
        $positions = [];

        foreach ($res as $item) {
            if (isset($item['positionID'])) {
                $positions[$item['positionID']] = 1;
            }
        }

        return $positions;
    }

    /**
     * Get service chief groups for the current user
     *
     * @return array Array of serviceID => 1 mappings
     */
    private function getServiceChiefGroups(): array
    {
        $vars = [':userName' => $this->userID];
        $sql = 'SELECT `serviceID`
                FROM `service_chiefs`
                WHERE `userID` = :userName
                AND `active` = 1';

        $res = $this->userDB->prepared_query($sql, $vars);
        $serviceGroups = [];

        foreach ($res as $item) {
            $serviceGroups[$item['serviceID']] = 1;
        }

        return $serviceGroups;
    }

    private function setSession()
    {
        $_SESSION['name'] = $this->name;
        $_SESSION['userID'] = $this->userID;
        $_SESSION['CSRFToken'] = isset($_SESSION['CSRFToken']) ? $_SESSION['CSRFToken'] : bin2hex(random_bytes(32));
    }
}
