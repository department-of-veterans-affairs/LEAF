<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date Created: September 17, 2015

*/

namespace Portal;

class System
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $fileExtensionWhitelist;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $commonConfig = new \Leaf\CommonConfig();
        $this->fileExtensionWhitelist = $commonConfig->fileManagerWhitelist;

        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);
    }

    public function updateService($serviceID)
    {
        if (!is_numeric($serviceID))
        {
            return 'Invalid Service';
        }
        // clear out old data first
        $vars = array(':serviceID' => $serviceID);
        $this->db->prepared_query('DELETE FROM services WHERE serviceID=:serviceID AND serviceID > 0', $vars);
        //$this->db->prepared_query('DELETE FROM service_chiefs WHERE serviceID=:serviceID AND locallyManaged != 1', $vars); // Skip Local

        $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \ORGCHART_DB);
        $group = new \Orgchart\Group($oc_db, $this->login);
        $position = new \Orgchart\Position($oc_db, $this->login);
        $employee = new \Orgchart\Employee($oc_db, $this->login);
        $tag = new \Orgchart\Tag($oc_db, $this->login);

        // find quadrad/ELT tag name, and find groupID
        $leader = $position->findRootPositionByGroupTag($group->getGroupLeader($serviceID), $tag->getParent('service'));
        $quadID = $leader[0]['groupID'];

        //echo "Synching Service: {$service['groupTitle']}<br />";
        $service = $group->getGroup($serviceID)[0];
        $abbrService = isset($service['groupAbbreviation']) ? $service['groupAbbreviation'] : '';
        $vars = array(':serviceID' => $service['groupID'],
                ':service' => $service['groupTitle'],
                ':abbrService' => $abbrService,
                ':groupID' => $quadID, );

        $this->db->prepared_query('INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                            VALUES (:serviceID, :service, :abbrService, :groupID)', $vars);

        $leaderGroupID = $group->getGroupLeader($service['groupID']);
        $resEmp = $position->getEmployees($leaderGroupID);
        foreach ($resEmp as $emp)
        {
            if ($emp['userName'] != '')
            {
                $vars = array(':userID' => $emp['userName'],
                        ':serviceID' => $service['groupID'], );

                $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, active)
                                                    VALUES (:serviceID, :userID, 0)
                                                    ON DUPLICATE KEY UPDATE serviceID=:serviceID, userID=:userID', $vars);

                // include the backups of employees
                $res = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE userID=:userID AND serviceID=:serviceID', $vars);
                if ($res[0]['active'] == 1) {
                    $backups = $employee->getBackups($emp['empUID']);
                    foreach ($backups as $backup) {
                        $vars = array(':userID' => $backup['userName'],
                            ':serviceID' => $service['groupID'],
                            ':backupID' => $emp['userName'],);

                        // Add backupID check for updates
                        $this->db->prepared_query('INSERT INTO service_chiefs (userID, serviceID, backupID)
                                                    VALUES (:userID, :serviceID, :backupID)
                                                    ON DUPLICATE KEY UPDATE userID=:userID, serviceID=:groupID', $vars);
                    }
                }
            }
        }

        // check if this service is also an ELT
        // if so, update groups table
        if ($serviceID == $quadID)
        {
            $vars = array(':groupID' => $quadID);

            $this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $vars);

            $resChief = $this->db->prepared_query('SELECT * FROM service_chiefs
		    											WHERE serviceID=:groupID
		    												AND active=1', $vars);
            foreach ($resChief as $chief)
            {
                $vars = array(':userID' => $chief['userID'],
                              ':groupID' => $quadID, );
                $this->db->prepared_query('INSERT INTO users (userID, groupID, backupID)
	                                   		 VALUES (:userID, :groupID, "")', $vars);
            }
        }

        //refresh request portal members backups
        $vars = array(':serviceID' => $service['groupID'],);

        $resRP = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE serviceID=:serviceID', $vars);

        foreach ($resRP as $empRP) {
            if ($empRP['active'] == 1) {
                $empID = $employee->lookupLogin($empRP['userID']);
                $backups = $employee->getBackups($empID[0]['empUID']);
                foreach ($backups as $backup) {
                    $vars = array(':userID' => $backup['userName'],
                        ':serviceID' => $service['groupID'],
                        ':backupID' => $empRP['userID'],);

                    // Add backupID check for updates
                    $this->db->prepared_query('INSERT INTO service_chiefs (userID, serviceID, backupID)
                                                    VALUES (:userID, :serviceID, :backupID)
                                                    ON DUPLICATE KEY UPDATE userID=:userID, serviceID=:serviceID, backupID=:backupID', $vars);
                }
            }
        }

        return "groupID: {$serviceID} updated";
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:24:51 PM (America/New_York)
     */
    public function updateGroup(int $groupID): array
    {
        if (!is_numeric($groupID)) {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'Invalid Group Id.'
                )
            );
        } elseif ($groupID == 1) {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'You are not authorized to update admin groups.'
                )
            );
        } else {
            $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \ORGCHART_DB);
            $group = new \Orgchart\Group($oc_db, $this->login);
            $position = new \Orgchart\Position($oc_db, $this->login);
            $employee = new \Orgchart\Employee($oc_db, $this->login);
            $tag = new \Orgchart\Tag($oc_db, $this->login);

            // clear out old data first
            //$delete_groups = $this->clearGroups($groupID);

            //if ($delete_groups['status']['code'] == 2) {
                    // find quadrad/ELT tag name
                $upperLevelTag = $tag->getParent('service');
                $isQuadrad = false;

                if (array_search($upperLevelTag, $group->getAllTags($groupID)) !== false) {
                    $isQuadrad = true;
                }

                $resGroup = $group->getGroup($groupID)[0];

                $insert_group = $this->insertGroup($groupID, $isQuadrad, $resGroup['groupTitle']);

                if ($insert_group['status']['code'] == 2) {
                    $delete_user_backups = $this->deleteUserBackups($groupID);

                    if ($delete_user_backups['status']['code'] == 2) {
                        $resEmp = array();
                        $positions = $group->listGroupPositions($groupID);
                        $resEmp = $group->listGroupEmployees($groupID);

                        if (!empty($positions) && is_array($positions)){
                            foreach ($positions as $tposition) {
                                $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
                            }
                        }

                        if (!empty($resEmp) && is_array($resEmp)) {
                            foreach ($resEmp as $emp) {
                                $insert_user = $this->insertUser($groupID, $emp);

                                if ($insert_user['status']['code'] == 2) {
                                    // nothing to be done, all is good
                                } else {
                                    $return_value = array (
                                        'status' => array (
                                            'code' => 4,
                                            'message' => 'Action failed to add users.'
                                        )
                                    );
                                    break;
                                }
                            }
                        }

                        $backups = $this->addBackups($groupID);

                        if ($backups['status']['code'] == 2) {
                            $privs = $this->updateCatPrivs($groupID);

                            if ($privs['status']['code'] == 2) {
                                // at this point everything updated as expected
                                $return_value = array (
                                    'status' => array (
                                        'code' => 2,
                                        'message' => 'Everything updated as expected.'
                                    )
                                );
                            } else {
                                // something happened updating category privs
                                $return_value = array (
                                    'status' => array (
                                        'code' => 4,
                                        'message' => 'There was an error updating category privs.'
                                    )
                                );
                            }
                        } else {
                            $return_value = array (
                                'status' => array (
                                    'code' => 4,
                                    'message' => 'There was an arror adding backups.'
                                )
                            );
                        }
                    } else {
                        // something happened deleting user backups
                        $return_value = array (
                            'status' => array (
                                'code' => 4,
                                'message' => 'There was an error deleting user backups.'
                            )
                        );
                    }
                } else {
                    // something happened with the inserting of groups
                    $return_value = array (
                        'status' => array (
                            'code' => 4,
                            'message' => 'There was an error inserting groups.'
                        )
                    );
                }
            /* } else {
                // something happened with the delete groups
                $return_value = array (
                    'status' => array (
                        'code' => 4,
                        'message' => 'There was an error when deleting groups.'
                    )
                );
            } */
        }

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:25:07 PM (America/New_York)
     */
    private function updateCatPrivs(int $groupID): array
    {
        $cat_privs = $this->getCatPrivs($groupID);

        if ($cat_privs['status']['code'] == 2 && !empty($cat_privs['data'])) {
            $return_value = $this->deleteCatPrivs($groupID);
        } else {
            $return_value = array (
                'status' => array (
                    'code' => 2,
                    'message' => 'Nothing to be done with category_privs'
                )
            );
        }

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:25:25 PM (America/New_York)
     */
    private function deleteCatPrivs(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'DELETE
                FROM `category_privs`
                WHERE `groupID` = :groupID';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:25:38 PM (America/New_York)
     */
    private function getCatPrivs(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'SELECT `categoryID`
                FROM `category_privs`
                LEFT JOIN `groups` USING (`groupID`)
                WHERE `category_privs`.`groupID` = :groupID
                AND `groups`.`groupID` IS NULL';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:25:53 PM (America/New_York)
     */
    private function addBackups(int $groupID): array
    {
        $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \ORGCHART_DB);
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        // get all users for this group
        $group_users = $this->getGroupUsers($groupID);

        // loop through group_users to add backups
        if ($group_users['status']['code'] == 2){
            $userNames = array();

            foreach ($group_users['data'] as $user) {
                $userNames[] = $user['userID'];
            }

            $employee_list = $employee->getEmployeeByUserName($userNames, $oc_db);
            foreach ($employee_list['data'] as $user) {
                // if active user, then get backups and add them
                if ($user['deleted'] == 0) {
                    $backups = $employee->getBackups($user['empUID']);

                    if (!empty($backups)) {
                        foreach ($backups as $backup) {
                            $backup_added = $this->addBackup($groupID, $backup['userName'], $user['userName']);

                            if ($backup_added['status']['code'] == 2) {
                                continue;
                            } else {
                                $return_value = array (
                                    'status' => array (
                                        'code' => 4,
                                        'message' => 'Action failed to add backups.'
                                    )
                                );
                                break;
                            }
                        }
                    }
                }
            }
            $return_value = array (
                'status' => array (
                    'code' => 2,
                    'message' => ''
                )
            );
        } else {
            $return_value = $group_users;
        }

        return $return_value;
    }

    /**
     * @param int $groupID
     * @param string $backup_user
     * @param string $user
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:26:30 PM (America/New_York)
     */
    private function addBackup(int $groupID, string $backup_user, string $user): array
    {
        $vars = array(':userID' => $backup_user,
                    ':groupID' => $groupID,
                    ':backupID' => $user);
        $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`)
                VALUES (:userID, :groupID, :backupID)
                ON DUPLICATE KEY UPDATE `userID` = :userID, `groupID` = :groupID';

        $return_value = $this->db->pdo_insert_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:26:53 PM (America/New_York)
     */
    private function getGroupUsers(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'SELECT `userID`
                FROM `users`
                WHERE `groupID` = :groupID';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     * @param array $emp
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:27:17 PM (America/New_York)
     */
    private function insertUser(int $groupID, array $emp): array
    {
        if (!empty($emp['userName'])) {
            $vars = array(':userID' => $emp['userName'],
                    ':groupID' => $groupID, );
            $sql = 'INSERT INTO `users` (`userID`, `groupID`, `backupID`, `active`)
                    VALUES (:userID, :groupID, "", 0)
                    ON DUPLICATE KEY UPDATE `userID` = :userID, `groupID` = :groupID';

            $return_value = $this->db->pdo_insert_query($sql, $vars);
        } else {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'Improperly formatted data.'
                )
            );
        }

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:27:47 PM (America/New_York)
     */
    private function deleteUserBackups(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'DELETE
                FROM `users`
                WHERE `backupID` <> ""
                AND `groupID` = :groupID';

        $return_value = $this->db->pdo_delete_query($sql , $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     * @param bool $isQuadrad
     * @param string $title
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:28:03 PM (America/New_York)
     */
    private function insertGroup(int $groupID, bool $isQuadrad, string $title): array
    {
        $vars = array(':groupID' => $groupID,
                ':parentGroupID' => ($isQuadrad == true ? -1 : null),
                ':name' => $title,
                ':groupDescription' => '', );
        $sql = 'INSERT INTO `groups` (`groupID`, `parentGroupID`, `name`,
                    `groupDescription`)
                VALUES (:groupID, :parentGroupID, :name, :groupDescription)
                ON DUPLICATE KEY UPDATE `parentGroupID` = :parentGroupID, `name` = :name,
                    `groupDescription` = :groupDescription';

        $return_value = $this->db->pdo_insert_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:28:34 PM (America/New_York)
     */
    private function clearGroups(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'DELETE
                FROM `groups`
                WHERE `groupID` = :groupID';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return string
     */
    public function importGroup($groupID): string
    {
        if (!is_numeric($groupID)) {
            $return_value = 'Invalid Group';
        } else if ($groupID == 1) {
            $return_value = 'Cannot update admin group';
        } else {
            // clear out old data first
            $vars = array(':groupID' => $groupID);
            //$this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID AND backupID IS NULL', $vars);
            $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $vars);

            $oc_db = new \Leaf\Db(\DIRECTORY_HOST, \DIRECTORY_USER, \DIRECTORY_PASS, \ORGCHART_DB);
            $group = new \Orgchart\Group($oc_db, $this->login);
            $position = new \Orgchart\Position($oc_db, $this->login);
            $employee = new \Orgchart\Employee($oc_db, $this->login);
            $tag = new \Orgchart\Tag($oc_db, $this->login);

            // find quadrad/ELT tag name
            $upperLevelTag = $tag->getParent('service');
            $isQuadrad = false;
            if (array_search($upperLevelTag, $group->getAllTags($groupID)) !== false) {
                $isQuadrad = true;
            }

            $resGroup = $group->getGroup($groupID)[0];
            $vars = array(':groupID' => $groupID,
                ':parentGroupID' => ($isQuadrad == true ? -1 : null),
                ':name' => $resGroup['groupTitle'],
                ':groupDescription' => '',);

            $this->db->prepared_query('INSERT INTO `groups` (groupID, parentGroupID, name, groupDescription)
                    					VALUES (:groupID, :parentGroupID, :name, :groupDescription)', $vars);

            // build list of member employees
            $resEmp = array();
            $positions = $group->listGroupPositions($groupID);
            $resEmp = $group->listGroupEmployees($groupID);
            foreach ($positions as $tposition) {
                $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
            }

	    // clear backups in case of updates
	    $vars = array(':groupID' => $groupID);
	    $this->db->prepared_query('DELETE FROM users WHERE backupID IS NOT NULL AND groupID=:groupID', $vars);
            foreach ($resEmp as $emp) {
                if ($emp['userName'] != '') {
                    $vars = array(':userID' => $emp['userName'],
                        ':groupID' => $groupID,);

                    $this->db->prepared_query('INSERT INTO users (userID, groupID, backupID)
                                                        VALUES (:userID, :groupID, "")
                                                        ON DUPLICATE KEY UPDATE userID=:userID, groupID=:groupID', $vars);

                    // include the backups of employees
                    $res = $this->db->prepared_query('SELECT * FROM users WHERE userID=:userID AND groupID=:groupID', $vars);
                    if ($res[0]['active'] == 1) {
                        $backups = $employee->getBackups($emp['empUID']);
                        foreach ($backups as $backup) {
                            $vars = array(':userID' => $backup['userName'],
                                ':groupID' => $groupID,
                                ':backupID' => $emp['userName'],);

                            // Add backupID check for updates
                            $this->db->prepared_query('INSERT INTO users (userID, groupID, backupID)
                                                        VALUES (:userID, :groupID, :backupID)
                                                        ON DUPLICATE KEY UPDATE userID=:userID, groupID=:groupID', $vars);
                        }
                    }
                }
            }
            $return_value = "groupID: {$groupID} imported";
        }

        return $return_value;
    }

    public function getServices()
    {
        return $this->db->prepared_query('SELECT groupID as parentID,
        							serviceID as groupID,
        							service as groupTitle,
        							abbreviatedService as groupAbbreviation
        							FROM services
        							ORDER BY groupTitle ASC', array());
    }

    /**
     * Get the current database version
     *
     * @return string the current database version
     */
    public function getDatabaseVersion()
    {
        $version = $this->db->prepared_query('SELECT data FROM settings WHERE setting = "dbVersion"', array());
        if (count($version) > 0 && $version[0]['data'] !== null)
        {
            return $version[0]['data'];
        }

        return 'unknown';
    }

    public function getGroups()
    {
        return $this->db->prepared_query('SELECT * FROM `groups`
    								WHERE groupID > 1
        							ORDER BY name ASC', array());
    }



    /**
     * @return array
     *
     * Created at: 7/31/2023, 7:41:43 AM (America/New_York)
     */
    public function addAction(): array
    {
        if (!$this->login->checkGroup(1)) {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'Admin access required'
                )
            );
        } else {
            $vars = array(':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '',  strip_tags($_POST['actionText'])));
            $sql = 'SELECT `deleted`
                    FROM `actions`
                    WHERE `actionType` = :actionType';

            $res = $this->db->pdo_select_query($sql, $vars);
            error_log(print_r($res, true));

            if (
                $res['status']['code'] == 2
                && ((!empty($res['data'])
                    && $res['data'][0]['deleted'] != 0)
                || empty($res['data']))
            ) {
                $alignment = 'right';

                if ($_POST['fillDependency'] < 1) {
                    $alignment = 'left';
                }

                $vars = array(':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '',  strip_tags($_POST['actionText'])),
                        ':actionText' => strip_tags($_POST['actionText']),
                        ':actionTextPasttense' => strip_tags($_POST['actionTextPasttense']),
                        ':actionIcon' => $_POST['actionIcon'],
                        ':actionAlignment' => $alignment,
                        ':sort' => 0,
                        ':fillDependency' => $_POST['fillDependency'],
                );

                $sql = 'INSERT INTO `actions` (`actionType`, `actionText`,
                            `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`)
                        VALUES (:actionType, :actionText, :actionTextPasttense, :actionIcon, :actionAlignment, :sort, :fillDependency)
                        ON DUPLICATE KEY UPDATE `actionText` = :actionText,
                            `actionTextPasttense` = :actionTextPasttense,
                            `actionIcon` = :actionIcon,
                            `actionAlignment` = :actionAlignment, `sort` = :sort,
                            `fillDependency` = :fillDependency, `deleted` = 0';

                $return_value = $this->db->pdo_insert_query($sql, $vars);
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 3,
                        'message' => 'This action already exists'
                    )
                );
            }
        }

        return $return_value;
    }

    public function setHeading()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $in = preg_replace('/[^\040-\176]/', '', $_POST['heading']);
        $vars = array(':input' => $in);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="heading"', $vars);

        return 1;
    }

    public function setSubHeading()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $in = preg_replace('/[^\040-\176]/', '', $_POST['subHeading']);
        $vars = array(':input' => $in);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="subheading"', $vars);

        return 1;
    }

    public function setRequestLabel()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $in = preg_replace('/[^\040-\176]/', '', $_POST['requestLabel']);
        $vars = array(':input' => $in);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="requestLabel"', $vars);

        return 1;
    }

    public function setTimeZone()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        if (array_search($_POST['timeZone'], \DateTimeZone::listIdentifiers(\DateTimeZone::PER_COUNTRY, 'US')) === false)
        {
            return 'Invalid timezone';
        }

        $vars = array(':input' => $_POST['timeZone']);

        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="timeZone"', $vars);

        return 1;
    }

    public function setSiteType()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $type = 'standard';
        switch($_POST['siteType'])
        {
            case 'national_primary':
                $type = 'national_primary';
                break;
            case 'national_subordinate':
                $type = 'national_subordinate';
                break;
            default:
                break;
        }

        $vars = array(':input' => $type);
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="siteType"', $vars);

        return 1;
    }

    public function setNationalLinkedSubordinateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $vars = array(':input' => \Leaf\XSSHelpers::xscrub($_POST['national_linkedSubordinateList']));
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="national_linkedSubordinateList"', $vars);

        return 1;
    }

    public function setNationalLinkedPrimary()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $vars = array(':input' => \Leaf\XSSHelpers::xscrub($_POST['national_linkedPrimary']));
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="national_linkedPrimary"', $vars);

        return 1;
    }


    public function getFileList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $list = scandir('../files/');
        $out = array();
        foreach ($list as $item)
        {
            $ext = substr($item, strrpos($item, '.') + 1);
            if (in_array(strtolower($ext), $this->fileExtensionWhitelist)
                && $item != 'index.html')
            {
                $out[] = $item;
            }
        }

        return $out;
    }

    public function newFile()
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 'Invalid Token.';
        }
        $in = $_FILES['file']['name'];
        $fileName = \Leaf\XSSHelpers::scrubFilename($in);
        $fileName = \Leaf\XSSHelpers::xscrub($fileName);
        if ($fileName != $in
                || $fileName == 'index.html'
                || $fileName == '')
        {
            echo $fileName;

            return 'Invalid filename. Must only contain alphanumeric characters.';
        }

        $ext = substr($fileName, strrpos($fileName, '.') + 1);
        if (!in_array(strtolower($ext), $this->fileExtensionWhitelist))//case insensitive
        {
            return 'Unsupported file type.';
        }

        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        move_uploaded_file($_FILES['file']['tmp_name'], __DIR__ . '/../files/' . $fileName);

        return true;
    }

    public function removeFile($in)
    {
        if ($in == 'index.html')
        {
            return 0;
        }

        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $list = $this->getFileList();

        if (array_search($in, $list) !== false)
        {
            if (file_exists(__DIR__ . '/../files/' . $in)
                && $in != 'index.html')
            {
                return unlink(__DIR__ . '/../files/' . $in);
            }
        }
    }

    public function getSettings()
    {
        return $this->db->query_kv('SELECT * FROM settings', 'setting', 'data');
    }

    /**
     * Get primary admin.
     *
     * @return array array with primary admin's info
     */
    public function getPrimaryAdmin()
    {
        $primaryAdminRes = $this->db->prepared_query('SELECT * FROM `users`
                                    WHERE `primary_admin` = 1', array());
        $result = array();
        if(count($primaryAdminRes))
        {
            $dir = new VAMC_Directory;
            $user = $dir->lookupLogin($primaryAdminRes[0]['userID']);
            $result = isset($user[0]) ? $user[0] : $primaryAdminRes[0]['userID'];
        }
        return $result;
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
     * Set primary admin.
     *
     * @return string json is string
     */
    public function setPrimaryAdmin()
    {
        $vars = array(':userID' => \Leaf\XSSHelpers::xscrub($_POST['userID']));
        //check if user is system admin
        $res = $this->db->prepared_query('SELECT *
                                            FROM `users`
                                            WHERE `userID` = :userID
                                            AND `groupID` = 1', $vars);
        $resultArray = array();
        if(count($res))
        {
            $this->db->prepared_query('UPDATE `users`
    								        SET `primary_admin` = 0', array());
            $res = $this->db->prepared_query('UPDATE `users`
                                                SET `primary_admin` = 1
                                                WHERE `userID` = :userID;', $vars);
            $resultArray = array('success' => true, 'response' => $res);

            $primary = $this->getPrimaryAdmin();

            $this->dataActionLogger->logAction(\Leaf\DataActions::ADD, \Leaf\LoggableTypes::PRIMARY_ADMIN, [
                new \Leaf\LogItem("users", "primary_admin", 1),
                new \Leaf\LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
            ]);
        }
        else
        {
            $resultArray = array('success' => false, 'response' => $res);
        }

        return json_encode($resultArray);
    }

    /**
     * Unset primary admin.
     *
     * @return array array with query response
     */
    public function unsetPrimaryAdmin()
    {

        $primary = $this->getPrimaryAdmin();

        $result = $this->db->prepared_query('UPDATE `users` SET `primary_admin` = 0', array());

        $this->dataActionLogger->logAction(\Leaf\DataActions::DELETE, \Leaf\LoggableTypes::PRIMARY_ADMIN, [
            new \Leaf\LogItem("users", "primary_admin", 1),
            new \Leaf\LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
        ]);

        return $result;
    }

    public function getHistory($filterById)
    {
        return $this->dataActionLogger->getHistory($filterById, null, \Leaf\LoggableTypes::PRIMARY_ADMIN);
    }

    /**
     *
     * @param Group $org_group
     * @param Service $org_service
     * @param \Orgchart\Group $nexus_group
     * @param \Orgchart\Employee $nexus_employee
     * @param \Orgchart\Tag $nexus_tag
     * @param \Orgchart\Position $nexus_position
     *
     * @return string
     *
     * Created at: 10/3/2022, 6:59:30 AM (America/New_York)
     */
    public function syncSystem(Group $org_group, Service $org_service, \Orgchart\Group $nexus_group, \Orgchart\Employee $nexus_employee, \Orgchart\Tag $nexus_tag, \Orgchart\Position $nexus_position): string
    {
        // this is needed to clean up some databases where a user is currently not
        // locally managed and they are also not active
        $org_group->cleanDb();

        $nexus_services = array();
        $nexus_chiefs = array();
        $nexus_groups = array();
        $nexus_users = array();
        $counter = 0;
        $group_counter = 0;
        $chief_counter = 0;

        // update services and service chiefs
        $services = $nexus_group->listGroupsByTag('service');

        foreach ($services as $service) {
            $leader = $nexus_position->findRootPositionByGroupTag($nexus_group->getGroupLeader($service['groupID']), $nexus_tag->getParent('service'));

            $nexus_services[$counter]['serviceID'] = $service['groupID'];
            $nexus_services[$counter]['service'] = $service['groupTitle'];
            $nexus_services[$counter]['abbreviatedService'] = isset($service['groupAbbreviation']) ? $service['groupAbbreviation'] : '';
            $nexus_services[$counter]['groupID'] = is_array($leader) && isset($leader[0]['groupID']) ? $leader[0]['groupID'] : null;

            $leaderGroupID = $nexus_group->getGroupLeader($service['groupID']);
            $serviceEmployee = $nexus_position->getEmployees($leaderGroupID);

            foreach($serviceEmployee as $employee){
                if (is_numeric($service['groupID']) && !empty($employee['userName'])) {
                    $nexus_chiefs[$chief_counter]['serviceID'] = $service['groupID'];
                    $nexus_chiefs[$chief_counter]['userID'] = $employee['userName'];
                    $nexus_chiefs[$chief_counter]['backupID'] = null;

                    $chief_counter++;
                }

                if (count($employee['backups']) > 0) {
                    foreach ($employee['backups'] as $backup) {
                        if (is_numeric($service['groupID']) && !empty($backup['userName'])) {
                            $nexus_chiefs[$chief_counter]['serviceID'] = $service['groupID'];
                            $nexus_chiefs[$chief_counter]['userID'] = $backup['userName'];
                            $nexus_chiefs[$chief_counter]['backupID'] = $employee['userName'];

                            $chief_counter++;
                        }
                    }
                }
            }

            if ($service['groupID'] == $nexus_services[$counter]['groupID']) {
                $chiefs = $org_service->getChiefs($service['groupID']);

                foreach ($chiefs as $chief) {
                    $nexus_users[$group_counter]['userID'] = $chief['userID'];
                    $nexus_users[$group_counter]['groupID'] = $nexus_services[$counter]['groupID'];
                    $nexus_users[$group_counter]['backupID'] = $chief['backupID'];
                }

                $group_counter++;
            }

            $counter++;
        }

        $portal_services = $org_service->getAllQuadrads();
        $portal_chiefs = $org_service->getAllChiefs();

        $this->processServices($portal_services, $portal_chiefs, $nexus_services, $nexus_chiefs, $org_service);

        // update groups and users
        $groups = $nexus_group->listGroupsByTag($nexus_tag->getParent('service'));
        $counter = 0;

        foreach ($groups as $group) {
            $nexus_groups[$counter]['groupID'] = $group['groupID'];
            $nexus_groups[$counter]['parentGroupID'] = -1;
            $nexus_groups[$counter]['name'] = $group['groupTitle'];

            $leaderGroupID = $nexus_group->getGroupLeader($group['groupID']);

            $employees = array_merge($nexus_position->getEmployees($leaderGroupID), $nexus_group->listGroupEmployees($group['groupID']));

            foreach ($employees as $employee) {
                if ($employee['userName'] != '') {
                    $nexus_users[$group_counter]['userID'] = $employee['userName'];
                    $nexus_users[$group_counter]['groupID'] = $group['groupID'];
                    $nexus_users[$group_counter]['backupID'] = null;

                    $group_counter++;

                    if (isset($employee['backups'])) {
                        foreach ($employee['backups'] as $backup) {
                            if ($backup['userName'] != '') {
                                $nexus_users[$group_counter]['userID'] = $backup['userName'];
                                $nexus_users[$group_counter]['groupID'] = $group['groupID'];
                                $nexus_users[$group_counter]['backupID'] = $employee['userName'];
                                $group_counter++;
                            }
                        }
                    }
                }
            }


            $counter++;
        }

        // update Nexus with portal groups
        $portal_groups = $org_group->getAllGroups();

        $this->updateNexusWithPortalGroups($portal_groups, $nexus_group);

        $groups = $this->getOrgchartImportTags($nexus_group);

        foreach ($groups as $group) {
            $nexus_groups[$counter]['groupID'] = $group['groupID'];
            $nexus_groups[$counter]['parentGroupID'] = null;
            $nexus_groups[$counter]['name'] = $group['groupTitle'];

            $positions = $nexus_group->listGroupPositions($group['groupID']);
            $employees = $nexus_group->listGroupEmployees($group['groupID']);

            foreach ($positions as $position) {
                $employees = array_merge($employees, $nexus_position->getEmployees($position['positionID']));
            }

            foreach ($employees as $employee) {
                if (!empty($employee['userName'])) {
                    $nexus_users[$group_counter]['userID'] = $employee['userName'];
                    $nexus_users[$group_counter]['groupID'] = $group['groupID'];
                    $nexus_users[$group_counter]['backupID'] = null;

                    $group_counter++;

                    $backups = $nexus_employee->getBackups($employee['empUID']);

                    foreach ($backups as $backup) {
                        if (isset($backup['userName']) && !empty($backup['userName'])) {
                            $nexus_users[$group_counter]['userID'] = $backup['userName'];
                            $nexus_users[$group_counter]['groupID'] = $group['groupID'];
                            $nexus_users[$group_counter]['backupID'] = $employee['userName'];
                            $group_counter++;
                        }
                    }
                }
            }

            $counter++;
        }

        $portal_users = $org_group->getAllUsers();

        $this->processGroups($portal_groups, $portal_users, $nexus_groups, $nexus_users, $org_group);

        return 'Syncing has finished. You are set to go.';
    }

    /**
     * [Description for processServices]
     *
     * @param array $portal_services
     * @param array $portal_chiefs
     * @param array $nexus_services
     * @param array $nexus_chiefs
     * @param Service $org_service
     *
     * @return void
     *
     * Created at: 9/14/2022, 4:12:49 PM (America/New_York)
     */
    private function processServices(array $portal_services, array $portal_chiefs, array $nexus_services, array $nexus_chiefs, Service $org_service): void
    {
        // find service records to delete on portal side
        foreach($portal_services as $service) {
            if ($this->searchArray($nexus_services, $service)) {
                // service exists do nothing
            } else {
                // service does not exist remove from portal db
                //echo 'The service \'' . $service['service'] . '\' has been removed.<br/>';
                $org_service->removeSyncService($service['serviceID']);
            }
        }

        // add service records that do not exist yet
        foreach($nexus_services as $service) {
            if ($this->searchArray($portal_services, $service)) {
                // service exists do nothing
            } else {
                // service does not exist add it to the portal db
                //echo 'The service \'' . $service['service'] . '\' was added.<br/>';
                if(is_numeric($service['serviceID']) && !empty($service['service']) && (is_numeric($service['groupID']) || is_null($service['groupID']))) {
                    $org_service->importService($service['serviceID'], $service['service'], $service['abbreviatedService'], $service['groupID']);
                }
            }
        }

        // find chiefs that need to be removed from portal
        foreach($portal_chiefs as $chief) {
            if ($this->searchArray($nexus_chiefs, $chief, false, 3)) {
                // chief exists do nothing
            } else {
                // chief does not exist at nexus check for locallyManaged and active
                // remove if locallyManaged and inactive
                // remove if not locallyManaged
                if ($chief['locallyManaged'] && $chief['active']) {
                    // this chief is locally managed and is active leave it here, do nothing
                } else {
                    //echo 'The Service Chief with an userID of \'' . $chief['serviceID'] . '-' . $chief['userID'] . '\' was removed.<br/>';
                    $org_service->removeChief($chief['serviceID'], $chief['userID'], $chief['backupID']);
                }
            }
        }

        // add chief records that do not exist yet
        foreach ($nexus_chiefs as $chief) {
            if ($this->searchArray($portal_chiefs, $chief, false, 3)) {
                // chief exists do nothing
            } else {
                // chief does not exist add them now
                //echo 'The Service Chief with userID of \'' . $chief['userID']. '\' was added.<br/>';
                $org_service->importChief($chief['serviceID'], $chief['userID'], $chief['backupID']);
            }
        }
    }

    /**
     * [Description for processGroups]
     *
     * @param array $portal_groups
     * @param array $portal_users
     * @param array $nexus_groups
     * @param array $nexus_users
     * @param Group $org_group
     *
     * @return void
     *
     * Created at: 10/3/2022, 7:02:32 AM (America/New_York)
     */
    private function processGroups(array $portal_groups, array $portal_users, array $nexus_groups, array $nexus_users, Group $org_group): void
    {
        // find group records to delete on portal side
        foreach($portal_groups as $group) {
            if ($this->searchArray($nexus_groups, $group, false)) {
                // group exists check in on backups
                $this->updateGroup($group['groupID']);
            } else {
                // group does not exist remove from portal db
                //echo 'The group \'' . $group['name'] . '\' has been removed<br/>';
                // groups should never be deleted if on the portal side. No matter what Nexus says
                // $org_group->removeSyncGroup($group['groupID']);
            }
        }

        // add group records that do not exist yet
        foreach($nexus_groups as $group) {
            if ($this->searchArray($portal_groups, $group, false)) {
                // group exists do nothing
            } else {
                // group does not exist add it to the portal db
                //echo 'The group \'' . $group['name'] . '\' has been added<br/>';
                $org_group->syncImportGroup($group);
            }
        }

        // find users that need to be removed from portal
        foreach($portal_users as $user) {
            if ($this->searchArray($nexus_users, $user, false, 3)) {
                // user exists do nothing
                //echo 'User \'' . $user['groupID'] . '-' .$user['userID'] . '\' remained.<br/>';
            } else {
                // user does not exist check for locallyManaged and active
                // remove if locallyManaged and inactive
                // remove if not locallyManaged
                if ($user['locallyManaged'] && $user['active']) {
                    // user is locally managed and active level them alone.
                } else if (!$user['locallyManaged'] || ($user['locallyManaged']) && !$user['active']) {
                    // check one more thing, is this user a backup to a locally managed user
                    if ($user['backupID'] != '' && $this->imABackup($portal_users, $user)) {
                        // I'm a backup, do nothing
                    } else {
                        //echo 'User with userID of \'' . $user['userID'] . '\' and a groupID of ' . $user['groupID'] . ' has been removed.<br/>';
                        $org_group->removeUser($user['userID'], $user['groupID'], $user['backupID']);
                    }

                } else {
                    // this user is locally managed and is active leave it here, do nothing
                }
            }
        }

        // add user records that do not exist yet
        foreach ($nexus_users as $user) {
            if ($this->searchArray($portal_users, $user, false, 3)) {
                // user exists do nothing
            } else {
                // user does not exist add them now
                //echo 'User with userID \'' . $user['userID'] . '\' was added.<br/>';
                //echo 'User with userID \'' . $user['groupID'] . '-' .$user['userID'] . '\' was added.<br/>';
                if ($user['backupID'] == null) {
                    $user['backupID'] = '';
                }

                $org_group->importUser($user['userID'], $user['groupID'], $user['backupID']);
            }
        }
    }

    /**
     * getOrgchartImportTags retrieves
     *
     * @param \Orgchart\Group $group
     *
     * @return array
     *
     * Created at: 9/14/2022, 7:35:53 AM (America/New_York)
     */
    private function getOrgchartImportTags(\Orgchart\Group $group): array
    {
        $groups = array();
        $tags = Config::$orgchartImportTags;
        $tags[] = 'Pentad';

        foreach ($tags as $tag)
        {
            $groups = array_merge($groups, $group->listGroupsByTag($tag));
        }

        return $groups;
    }

    /**
     * Search multidimensional arrays for matches
     *
     * @param array $search
     * @param array $criteria
     * @param bool $whole_array - matching a whole array or just partial
     * @param int $index - the number of associative array columns to match.
     *      must be the first ones listed.
     *
     * @return bool
     *
     * Created at: 9/13/2022, 7:56:52 AM (America/New_York)
     */
    private function searchArray($search, $criteria, $whole_array = true, $index = 3): bool
    {
        $exists = false;

        if ($whole_array) {
            foreach($search as $value) {
                if ($value == $criteria) {
                    $exists = true;
                    break;
                }
            }
        } else {
            foreach($search as $value) {
                $keys = array_keys($value);

                for($x = 0; $x < $index; $x++) {
                    if ($value[$keys[$x]] == $criteria[$keys[$x]]) {
                        // so far so good, check the next
                    } else {
                        // we don't have a match continue the search with the next array
                        break;
                    }

                    if (($x + 1) == $index) {
                        $exists = true;

                        break 2;
                    }
                }
            }
        }

        return $exists;
    }

    public function imABackup(array $portal_users, array $user): bool
    {
        $backup = false;

        foreach ($portal_users as $portal) {
            if ($portal['groupID'] == $user['groupID'] and $portal['userID'] == $user['backupID']) {
                $backup = true;
                break;
            }
        }

        return $backup;
    }

    private function updateNexusWithPortalGroups(array $portal_groups, \Orgchart\Group $nexus_group): void
    {
        $nexus_groups = $nexus_group->listGroupsByTag(Config::$orgchartImportTags[0]);

        foreach ($portal_groups as $group) {
            if ($this->searchArray($nexus_groups, $group, false, 1)) {
                // this group is already tagged.
            } else {
                // not tagged, add it now.
                $nexus_group->addGroupTag(Config::$orgchartImportTags[0], $group['groupID']);
            }
        }

    }
}
