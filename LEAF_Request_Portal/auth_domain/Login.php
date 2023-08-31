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
     * @param int $groupID Group ID number
     * @return boolean
     */
    public function checkGroup($groupID)
    {
        if (!isset($this->cache['checkGroup']))
        {
            $var = array(':userID' => $this->userID);
            $result = $this->userDB->prepared_query('SELECT * FROM users WHERE userID=:userID', $var);

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
        if (isset($this->cache['getQuadradGroupID']))
        {
            return $this->cache['getQuadradGroupID'];
        }
        $var = array(':userID' => $this->userID);
        $result = $this->userDB->prepared_query('SELECT * FROM `groups`
                                            LEFT JOIN users USING (groupID)
                                            WHERE parentGroupID=-1
                                                AND userID=:userID', $var);

        $buffer = '';
        foreach ($result as $group)
        {
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

    // quadrad groupID = -1
    public function isQuadrad()
    {
        if (isset($this->cache['isQuadrad']))
        {
            return $this->cache['isQuadrad'];
        }

        $var = array(':userID' => $this->userID);
        $result = $this->userDB->prepared_query('SELECT * FROM `groups`
                                            LEFT JOIN users USING (groupID)
                                            WHERE parentGroupID=-1
                                                AND userID=:userID', $var);

        if (isset($result[0]))
        {
            $this->cache['isQuadrad'] = true;

            return true;
        }
        $this->cache['isQuadrad'] = false;

        return false;
    }

    /**
     * Retrieves the positions and groups the current user is a member of
     * @return array
     */
    public function getMembership()
    {
        $empUID = (int)$this->empUID;

        if (isset($this->cache['getMembership_' . $empUID]))
        {
            return $this->cache['getMembership_' . $empUID];
        }

        $membership = array();
        // inherit permissions if employee is a backup for someone else
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM relation_employee_backup
                                            WHERE backupEmpUID=:empUID
        										AND approved=1', $vars);
        $temp = (int)$empUID;
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $var = (int)$item['empUID'];
                $temp .= ",{$var}";
                $membership['inheritsFrom'][] = $var;
            }
            $vars = array(':empUID' => $temp);
        }

        $res = $this->db->prepared_query("SELECT positionID, empUID,
                                                relation_group_employee.groupID as employee_groupID,
                                                relation_group_position.groupID as position_groupID FROM employee
                                            LEFT JOIN relation_position_employee USING (empUID)
                                            LEFT JOIN relation_group_employee USING (empUID)
                                            LEFT JOIN relation_group_position USING (positionID)
                                            WHERE empUID IN ({$temp})", array());
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                if (isset($item['positionID']))
                {
                    $membership['positionID'][$item['positionID']] = 1;
                }
                /*	            if(isset($item['employee_groupID'])) {
                                    $membership['groupID'][$item['employee_groupID']] = 1;
                                }
                                if(isset($item['position_groupID'])) {
                                    $membership['groupID'][$item['position_groupID']] = 1;
                                }*/
            }
        }
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // incorporate groups from local DB
        $vars = array(':userName' => $this->userID);
        $res = $this->userDB->prepared_query('SELECT * FROM users
												WHERE userID = :userName', $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $membership['groupID'][$item['groupID']] = 1;
            }
        }
        $vars = array(':userName' => $this->userID);
        $res = $this->userDB->prepared_query('SELECT * FROM service_chiefs
												WHERE userID = :userName
													AND active=1', $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $membership['groupID'][$item['serviceID']] = 1;
            }
        }

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        $this->cache['getMembership_' . $empUID] = $membership;

        return $this->cache['getMembership_' . $empUID];
    }

    private function setSession()
    {
        $_SESSION['name'] = $this->name;
        $_SESSION['userID'] = $this->userID;
        $_SESSION['CSRFToken'] = isset($_SESSION['CSRFToken']) ? $_SESSION['CSRFToken'] : bin2hex(random_bytes(32));
    }
}
