<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Login and session handler
    Date: September 11, 2007

*/

namespace Orgchart;

// Sanitize all $_GET input
if (count($_GET) > 0)
{
    $keys = array_keys($_GET);
    foreach ($keys as $key)
    {
        if (is_string($_GET[$key]))
        {
            $_GET[$key] = htmlentities($_GET[$key], ENT_QUOTES);
        }
    }
}

class Session implements \SessionHandlerInterface
{
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    public function close()
    {
        return true;
    }

    public function destroy($sessionID)
    {
        $vars = array(':sessionID' => $sessionID);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);

        return true;
    }

    public function gc($maxLifetime)
    {
        $vars = array(':time' => time() - $maxLifetime);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE lastModified < :time', $vars);

        return true;
    }

    public function open($savePath, $sessionID)
    {
        return true;
    }

    public function read($sessionID)
    {
        $vars = array(':sessionID' => $sessionID);
        $res = $this->db->prepared_query('SELECT * FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);

        return isset($res[0]['data']) ? $res[0]['data'] : '';
    }

    public function write($sessionID, $data)
    {
        $vars = array(':sessionID' => $sessionID,
                      ':data' => $data,
                      ':time' => time(), );
        $this->db->prepared_query('INSERT INTO sessions (sessionKey, data, lastModified)
                                            VALUES (:sessionID, :data, :time)
                                            ON DUPLICATE KEY UPDATE data=:data, lastModified=:time', $vars);

        return true;
    }
}

class Login
{
    public $MIN_NAME_LENGTH = 1;

    public $MIN_PASS_LENGTH = 3;

    private $db;

    private $userDB;

    private $isLogin = false;

    private $name = 'default';

    private $userID = 'default';

    private $empUID;

    private $domain = '';

    private $isInDB = true;

    private $baseDir = '';

    private $cache = array();

    public function __construct($phonebookDB, $userDB)
    {
        $this->db = $phonebookDB;
        $this->userDB = $userDB;

        if (session_id() == '')
        {
            ini_set('session.gc_maxlifetime', 2592000);
            $sessionHandler = new Session($this->userDB);
            session_set_save_handler($sessionHandler, true);
            session_start();
            $cookie = session_get_cookie_params();
            $id = session_id();

            $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
            setcookie('PHPSESSID', $id, time() + 2592000, $cookie['path'], $cookie['domain'], $https, true);
        }
    }

    public function register()
    {
        return false;
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

    public function getDomain()
    {
        return $this->domain;
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

    public function generateCSRFToken()
    {
        $_SESSION['CSRFToken'] = bin2hex(random_bytes(32));
    }

    public function loginUser()
    {
        if (!isset($_SESSION['userID']) || $_SESSION['userID'] == '')
        {
            if (php_sapi_name() != 'cli')
            {
                $protocol = 'http://';
                if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on')
                {
                    $protocol = 'https://';
                }

                // try to browser detect, since SSO implementation varies
                if (strpos($_SERVER['HTTP_USER_AGENT'], 'Trident') > 0
                    || strpos($_SERVER['HTTP_USER_AGENT'], 'Firefox') > 0)
                {
                    header('Location: ' . $protocol . $_SERVER['SERVER_NAME'] . $this->parseURL(dirname($_SERVER['PHP_SELF']) . $this->baseDir) . '/auth_domain/?r=' . base64_encode($_SERVER['REQUEST_URI']));
                    exit();
                }

                header('Location: ' . $protocol . $_SERVER['SERVER_NAME'] . $this->parseURL(dirname($_SERVER['PHP_SELF']) . $this->baseDir) . '/login/?r=' . base64_encode($_SERVER['REQUEST_URI']));
                exit();
            }

            $_SESSION['userID'] = 'SYSTEM';
        }

        $var = array(':userID' => $_SESSION['userID']);
        $result = $this->db->prepared_query('SELECT * FROM employee WHERE userName=:userID AND deleted = 0', $var);

//            echo "Logged in as: {$result[0]['userName']} ({$result[0]['firstName']} {$result[0]['lastName']}, {$result[0]['Title']} {$result[0]['Phone']})";
        if (isset($result[0]['userName']))
        {
            $this->name = "{$result[0]['firstName']} {$result[0]['lastName']}";
            $this->userID = $result[0]['userName'];
            $this->empUID = $result[0]['empUID'];
            $this->domain = $result[0]['domain'];
            $this->setSession();

            $this->isLogin = true;

            return true;
        }

        $this->name = "Guest: {$_SESSION['userID']}";
        $this->userID = $_SESSION['userID'];
        $this->isLogin = true;
        $this->isInDB = false;
        $this->setSession();

        return true;

        return false;
    }

    public function logout()
    {
        $keys = array_keys($_SESSION);
        foreach ($keys as $key)
        {
            unset($_SESSION[$key]);
        }
    }

    public function isLogin()
    {
        return $this->isLogin;
    }

    /**
     * Retrieves the positions and groups the current user is a member of
     * @return array
     */
    public function getMembership($empUID = null)
    {
        if ($empUID == null)
        {
            $empUID = $this->empUID;
        }

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
                $temp .= ",{$item['empUID']}";
                $membership['inheritsFrom'][] = $item['empUID'];
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
                if (isset($item['employee_groupID']))
                {
                    $membership['groupID'][$item['employee_groupID']] = 1;
                }
                if (isset($item['position_groupID']))
                {
                    $membership['groupID'][$item['position_groupID']] = 1;
                }
            }
        }
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        $this->cache['getMembership_' . $empUID] = $membership;

        return $this->cache['getMembership_' . $empUID];
    }

    /**
     * Retrieves current user's privileges for the specified indicatorIDs
     * The default behavior is to grant full access if the user "owns" the data
     * eg: Users have access to their own employee information by default
     * Non-owners by default only have read access
     * Any privilege setting will override all default behaviors
     *
     * @param array $indicatorIDs
     * @param string $dataTableUID is either 'empUID', 'positionID', 'groupID', 'employee', 'position', or 'group'
     * @param int $UID. This could be a empUID, positionID, or groupID.
     */
    public function getIndicatorPrivileges($indicatorIDs, $dataTableUID = '', $UID = 0)
    {
        $UID = (int)$UID;
        $cacheHash = 'getIndicatorPrivileges' . implode('-', $indicatorIDs) . $dataTableUID . $UID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        switch ($dataTableUID) {
            case 'employee':
                $dataTableUID = 'empUID';

                break;
            case 'position':
                $dataTableUID = 'positionID';

                break;
            case 'group':
                $dataTableUID = 'groupID';

                break;
            default:
                break;
        }
        $data = array();
        $memberships = $this->getMembership();

        $indicatorList = '';
        foreach ($indicatorIDs as $id)
        {
            $indicatorList .= (int)$id . ',';
            // grant by default if user is the owner, or is a member of a group who has ownership
            if (isset($memberships[$dataTableUID][$UID]))
            {
                $data[$id]['read'] = -1;
                $data[$id]['write'] = -1;
                $data[$id]['grant'] = 0;
                $data[$id]['isOwner'] = 1;
            }
            // otherwise deny write/grant
            else
            {
                $data[$id]['read'] = -1;
                $data[$id]['write'] = 0;
                $data[$id]['grant'] = 0;
            }
        }
        $indicatorList = trim($indicatorList, ',');

        $cacheHash2 = 'getIndicatorPrivileges2' . $indicatorList;
        $res = null;
        if (isset($this->cache[$cacheHash2]))
        {
            $res = $this->cache[$cacheHash2];
        }
        else
        {
            $var = array();
            $res = $this->db->prepared_query("SELECT * FROM indicator_privileges
                                            	WHERE indicatorID IN ({$indicatorList})", $var);
            $this->cache[$cacheHash2] = $res;
        }

        foreach ($res as $item)
        {
            // grant highest available access
            if (isset($memberships[$item['categoryID'] . 'ID'][$item['UID']]))
            {
                if (isset($data[$item['indicatorID']]['read']) && $data[$item['indicatorID']]['read'] != 1)
                {
                    $data[$item['indicatorID']]['read'] = $item['read'];
                }
                if (isset($data[$item['indicatorID']]['write']) && $data[$item['indicatorID']]['write'] != 1)
                {
                    $data[$item['indicatorID']]['write'] = $item['write'];
                }
                if (isset($data[$item['indicatorID']]['grant']) && $data[$item['indicatorID']]['grant'] != 1)
                {
                    $data[$item['indicatorID']]['grant'] = $item['grant'];
                }
            }
            else
            {
                if (isset($data[$item['indicatorID']]['read']) && $data[$item['indicatorID']]['read'] != 1)
                {
                    $data[$item['indicatorID']]['read'] = 0;
                }
                if (isset($data[$item['indicatorID']]['write']) && $data[$item['indicatorID']]['write'] != 1)
                {
                    $data[$item['indicatorID']]['write'] = 0;
                }
                if (isset($data[$item['indicatorID']]['grant']) && $data[$item['indicatorID']]['grant'] != 1)
                {
                    $data[$item['indicatorID']]['grant'] = 0;
                }
            }

            // apply access levels for special group: Owner (groupID 3)
            if ($item['categoryID'] == 'group'
                && $item['UID'] == 3
                && isset($data[$item['indicatorID']]['isOwner']))
            {
                if (isset($data[$item['indicatorID']]['read']) && $data[$item['indicatorID']]['read'] != 1)
                {
                    $data[$item['indicatorID']]['read'] = $item['read'];
                }
                if (isset($data[$item['indicatorID']]['write']) && $data[$item['indicatorID']]['write'] != 1)
                {
                    $data[$item['indicatorID']]['write'] = $item['write'];
                }
                if (isset($data[$item['indicatorID']]['grant']) && $data[$item['indicatorID']]['grant'] != 1)
                {
                    $data[$item['indicatorID']]['grant'] = $item['grant'];
                }
            }
        }

        // allow grant access if user is part of the special group: System Administrator (groupID 1)
        if (isset($memberships['groupID'][1])
                && $memberships['groupID'][1] == 1)
        {
            foreach ($indicatorIDs as $id)
            {
                $data[$id]['grant'] = 1;
            }
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

    private function setSession()
    {
        $_SESSION['name'] = $this->name;
        $_SESSION['userID'] = $this->userID;
        $_SESSION['CSRFToken'] = isset($_SESSION['CSRFToken']) ? $_SESSION['CSRFToken'] : bin2hex(random_bytes(32));
    }
}
