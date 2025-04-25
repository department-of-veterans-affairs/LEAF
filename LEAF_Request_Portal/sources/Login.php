<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Login class and session handler
    Date Created: September 11, 2007

*/

namespace Portal;

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

    // getUserID returns NT Username
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
      $url = str_replace('/var/www/html', '', $in);

      return $url;
    }

    /**
     * requestAuthentication redirects users to an authentication endpoint, which performs authentication
     * and imports employee contact information from the national employee DB, into the local DB
     * @param int $userID Only used in command-line contexts
     */
    public function requestAuthentication($userID = 'SYSTEM')
    {
        $authType = '/../auth_domain/?r=';
        $nonBrowserAuth = '/../login/?r=';

        if(defined('AUTH_TYPE') && AUTH_TYPE == 'cookie') {
            $authType = '/../auth_cookie/?r=';
            $nonBrowserAuth = '/../auth_cert/?r=';
        }

        if (php_sapi_name() != 'cli')
        {
            $protocol = 'https://';

            // try to browser detect, since SSO implementation varies
            if (strpos($_SERVER['HTTP_USER_AGENT'], 'Trident') > 0
                || strpos($_SERVER['HTTP_USER_AGENT'], 'Firefox') > 0
                || strpos($_SERVER['HTTP_USER_AGENT'], 'Chrome') > 0
                || strpos($_SERVER['HTTP_USER_AGENT'], 'CriOS') > 0
                || strpos($_SERVER['HTTP_USER_AGENT'], 'Edge') > 0)
            {
                header('Location: ' . $protocol . $_SERVER['SERVER_NAME'] . $this->parseURL(dirname(__FILE__)) . $authType . base64_encode($_SERVER['REQUEST_URI']));
                exit();
            }

            header('Location: ' . $protocol . $_SERVER['SERVER_NAME'] . $this->parseURL(dirname(__FILE__)) . $nonBrowserAuth . base64_encode($_SERVER['REQUEST_URI']));
            exit();
        }
        // else lets login via user id since this is a cli process that needs specific user (think forms/groups/emails)
        else{
            $_SESSION['userID'] = $userID;
        }
    }

    public function loginUser($userID = 'SYSTEM')
    {
        // Check bearer token if it exists
        // Currently only used for LEAF Agent
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $token = trim(str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']));
            if(hash_equals(getenv('AGENT_TOKEN'), $token)) {
                $_SESSION['CSRFToken'] = "";
                // This must never intersect with a real user account. *LEAF Agent* uses invalid Active Directory characters
                $_SESSION['userID'] = getenv('APP_AGENT_USERNAME');
                $this->name = "Account: {$_SESSION['userID']}";
                $this->userID = $_SESSION['userID'];
                $this->empUID = -1; // This must never intersect with a real user account
                $this->isLogin = true;
                $this->isInDB = false;
                $this->setSession();
                return true;
            }
            exit();
        }

        if (!isset($_SESSION['userID']) || $_SESSION['userID'] == '')
        {
            $this->requestAuthentication($userID);
        }

        // Check local database for employee info
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

        // Since the local database doesn't contain employee info, populate the local db by going through
        // authentication
        $this->requestAuthentication($userID);

        $this->name = "Account: {$_SESSION['userID']}";
        $this->userID = $_SESSION['userID'];
        $this->isLogin = true;
        $this->isInDB = false;
        $this->setSession();

        return true;
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
        setcookie('REMOTE_USER', '', time() - 3600, $cookie['path'], $cookie['domain'], $https, true);
    }

    public function isLogin()
    {
        return $this->isLogin;
    }

    /**
     * Checks if the current user is part of a group
     * Magic variable $_GET['masquerade'] = nonAdmin enables admins to view content as non-admins
     * @param int $groupID Group ID number
     * @return boolean
     */
    public function checkGroup($groupID)
    {
        if (!isset($this->cache['checkGroup']))
        {
            $var = array(':userID' => $this->userID);
            $result = $this->userDB->prepared_query('SELECT * FROM users WHERE userID=:userID
                                                        AND active=1', $var);

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

        if($groupID == 1 && isset($_GET['masquerade']) && $_GET['masquerade'] == 'nonAdmin') {
            return false;
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
        $res = $this->userDB->prepared_query('SELECT * FROM users WHERE userID = :userName AND active=1', $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                $membership['groupID'][$item['groupID']] = 1;
            }
        }
        $vars = array(':userName' => $this->userID);
        $res = $this->userDB->prepared_query('SELECT * FROM service_chiefs WHERE userID = :userName AND active=1', $vars);
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
