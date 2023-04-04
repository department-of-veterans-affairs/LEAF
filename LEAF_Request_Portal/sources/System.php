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

        $config = new Config();
        $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
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
                $this->db->prepared_query('INSERT INTO users (userID, groupID)
	                                   		 VALUES (:userID, :groupID)', $vars);
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

    public function updateGroup($groupID)
    {
        if (!is_numeric($groupID))
        {
            return 'Invalid Group';
        }
        if ($groupID == 1)
        {
            return 'Cannot update admin group';
        }

        // clear out old data first
        $vars = array(':groupID' => $groupID);
        //$this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID AND backupID IS NULL', $vars);
        $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $vars);

        $config = new Config();
        $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $group = new \Orgchart\Group($oc_db, $this->login);
        $position = new \Orgchart\Position($oc_db, $this->login);
        $employee = new \Orgchart\Employee($oc_db, $this->login);
        $tag = new \Orgchart\Tag($oc_db, $this->login);

        // find quadrad/ELT tag name
        $upperLevelTag = $tag->getParent('service');
        $isQuadrad = false;
        if (array_search($upperLevelTag, $group->getAllTags($groupID)) !== false)
        {
            $isQuadrad = true;
        }

        $resGroup = $group->getGroup($groupID)[0];
        $vars = array(':groupID' => $groupID,
                ':parentGroupID' => ($isQuadrad == true ? -1 : null),
                ':name' => $resGroup['groupTitle'],
                ':groupDescription' => '', );

        $this->db->prepared_query('INSERT INTO `groups` (groupID, parentGroupID, name, groupDescription)
                    					VALUES (:groupID, :parentGroupID, :name, :groupDescription)', $vars);

        // build list of member employees
        $resEmp = array();
        $positions = $group->listGroupPositions($groupID);
        $resEmp = $group->listGroupEmployees($groupID);
        foreach ($positions as $tposition)
        {
            $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
        }

	// clear backups in case of updates
	$vars = array(':groupID' => $groupID);
	$this->db->prepared_query('DELETE FROM users WHERE backupID IS NOT NULL AND groupID=:groupID', $vars);
        foreach ($resEmp as $emp)
        {
            if ($emp['userName'] != '')
            {
                $vars = array(':userID' => $emp['userName'],
                        ':groupID' => $groupID, );

                $this->db->prepared_query('INSERT INTO users (userID, groupID, active)
                                                    VALUES (:userID, :groupID, 0)
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

        //if the group is removed, also remove the category_privs
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT *
                                            FROM category_privs
                                            LEFT JOIN `groups` USING (groupID)
                                            WHERE category_privs.groupID = :groupID
                                            AND groups.groupID is null;', $vars);
        if(count($res) > 0)
        {
            $this->db->prepared_query('DELETE FROM category_privs WHERE groupID=:groupID', $vars);
        }


        return "groupID: {$groupID} updated";
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

            $config = new Config();
            $oc_db = new \Leaf\Db($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
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

                    $this->db->prepared_query('INSERT INTO users (userID, groupID)
                                                        VALUES (:userID, :groupID)
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



    public function addAction()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $alignment = 'right';
        if ($_POST['fillDependency'] < 1)
        {
            $alignment = 'left';
        }

        $vars = array(':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '', strip_tags($_POST['actionText'])),
                ':actionText' => strip_tags($_POST['actionText']),
                ':actionTextPasttense' => strip_tags($_POST['actionTextPasttense']),
                ':actionIcon' => $_POST['actionIcon'],
                ':actionAlignment' => $alignment,
                ':sort' => 0,
                ':fillDependency' => $_POST['fillDependency'],
        );

        $this->db->prepared_query('INSERT INTO actions (actionType, actionText, actionTextPasttense, actionIcon, actionAlignment, sort, fillDependency)
										VALUES (:actionType, :actionText, :actionTextPasttense, :actionIcon, :actionAlignment, :sort, :fillDependency)', $vars);
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
                $nexus_chiefs[$chief_counter]['serviceID'] = $service['groupID'];
                $nexus_chiefs[$chief_counter]['userID'] = $employee['userName'];
                $nexus_chiefs[$chief_counter]['backupID'] = null;

                $chief_counter++;

                if (count($employee['backups']) > 0) {
                    foreach ($employee['backups'] as $backup) {
                        $nexus_chiefs[$chief_counter]['serviceID'] = $service['groupID'];
                        $nexus_chiefs[$chief_counter]['userID'] = $backup['userName'];
                        $nexus_chiefs[$chief_counter]['backupID'] = $employee['userName'];

                        $chief_counter++;
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
                // group exists do nothing
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
