<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Login and session handler
    Date: September 11, 2007

*/

namespace Orgchart;
use App\Leaf\Db;
use App\Leaf\XSSHelpers;

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
      // TODO: Put this in a config var
      $url = str_replace(array('/var/www/html', '/sources'), array('', ''), $in);

      return $url;
    }

    public function generateCSRFToken()
    {
        $_SESSION['CSRFToken'] = bin2hex(random_bytes(32));
    }

    public function loginUser()
    {
        $authType = '/auth_domain/?r=';
        $nonBrowserAuth = '/login/?r=';

        if(defined('AUTH_TYPE') && AUTH_TYPE == 'cookie') {
            $authType = '/auth_cookie/?r=';
            $nonBrowserAuth = '/auth_cookie/?r=';
        }

        if (!isset($_SESSION['userID']) || $_SESSION['userID'] == '')
        {
            if (php_sapi_name() != 'cli')
            {
                // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//                $protocol = 'http://';
//                if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on')
//                {
//                    $protocol = 'https://';
//                }
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

        // try to copy the user from the national DB
        $globalDB = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
        $vars = array(':userName' => $_SESSION['userID']);
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

            $this->name = "{$res[0]['firstName']} {$res[0]['lastName']}";
            $this->userID = $res[0]['userName'];
            $this->empUID = $empUID;
            $this->domain = $res[0]['domain'];
            $this->setSession();

            $this->isLogin = true;
            return true;
        }

        // fallback to guest mode if there's no match
        $this->name = "Guest: {$_SESSION['userID']}";
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
     * Retrieves the positions and groups the current user is a member of
     * @return array
     */
    public function getMembership($empUID = null)
    {
        if ($empUID == null)
        {
            $empUID = (int)$this->empUID;
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
                //casting as an int to prevent sql injection
                $scrubEmpUID = (int)$item['empUID'];
                $temp .= ",{$scrubEmpUID}";
                $membership['inheritsFrom'][] = $scrubEmpUID;
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
            $id = (int)$id;
            $indicatorList .= $id . ',';
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
            $resIndicatorID = (int)$item['indicatorID'];
            $resCategoryID = XSSHelpers::xscrub($item['categoryID']);
            $resUID = (int)$item['UID'];
            $resRead = (int)$item['read'];
            $resWrite = (int)$item['write'];
            $resGrant = (int)$item['grant'];

            // grant highest available access
            if (isset($memberships[$resCategoryID . 'ID'][$resUID]))
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = $resRead;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = $resWrite;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = $resGrant;
                }
            }
            else
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = 0;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = 0;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = 0;
                }
            }

            // apply access levels for special group: Owner (groupID 3)
            if ($resCategoryID == 'group'
                && $resUID == 3
                && isset($data[$resIndicatorID]['isOwner']))
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = $resRead;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = $resWrite;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = $resGrant;
                }
            }
        }

        // allow grant access if user is part of the special group: System Administrator (groupID 1)
        if (isset($memberships['groupID'][1])
                && $memberships['groupID'][1] == 1)
        {
            foreach ($indicatorIDs as $id)
            {
                $id = (int)$id;
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
