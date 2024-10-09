<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date Created: September 17, 2015

*/

namespace Portal;

use App\Leaf\CommonConfig;
use App\Leaf\Db;
use App\Leaf\Logger\DataActionLogger;
use App\Leaf\XSSHelpers;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;

class System
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $fileExtensionWhitelist;

    private $site_data;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $commonConfig = new CommonConfig();
        $this->fileExtensionWhitelist = $commonConfig->fileManagerWhitelist;

        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    /**
     * @param int $serviceID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:27:47 AM (America/New_York)
     */
    public function updateService(int $serviceID): array
    {
        if (!is_numeric($serviceID)) {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'Invalid Service Id.'
                )
            );
        } else {
            $oc_db = OC_DB;
            $group = new \Orgchart\Group($oc_db, $this->login);
            $position = new \Orgchart\Position($oc_db, $this->login);
            $tag = new \Orgchart\Tag($oc_db, $this->login);

            $removeServices = $this->removeService($serviceID);

            if ($removeServices['status']['code'] == 2) {
                $leader_id = $group->getGroupLeader($serviceID);
                $tag_parent = $tag->getParent('service');

                $leader = $position->findRootPositionByGroupTag($leader_id, $tag_parent);

                if (isset($leader[0])) {
                    $quadID = $leader[0]['groupID'];

                    $service = $group->getGroup($serviceID)[0];

                    $abbrService = isset($service['groupAbbreviation']) ? $service['groupAbbreviation'] : '';

                    $insert_service = $this->insertService($service['groupID'], $service['groupTitle'], $abbrService, $quadID);

                    if ($insert_service['status']['code'] == 2) {
                        $leaderGroupID = $group->getGroupLeader($service['groupID']);

                        $resEmp = $position->getEmployees($leaderGroupID);

                        $return_value = array(
                            'status' => array(
                                'code' => 2,
                                'message' => ''
                            )
                        );

                        foreach ($resEmp as $emp) {
                            if ($emp['userName'] != '') {
                                $insert_chief = $this->insertChief($emp['userName'], $service['groupID']);

                                if ($insert_chief['status']['code'] == 2) {
                                    // nothing to do here, just keep going
                                } else {
                                    $return_value = array(
                                        'status' => array(
                                            'code' => 4,
                                            'message' => 'Chief unable to be added'
                                        )
                                    );

                                    break;
                                }
                            }
                        }

                        if ($return_value['status']['code'] == 2) {
                            $backups = $this->addBackups($service['groupID'], false);

                            if ($backups['status']['code'] == 2) {
                                // check if this service is also an ELT
                                // if so, update groups table
                                if ($serviceID == $quadID) {
                                    $this->updateGroup($serviceID, $oc_db);
                                } else {
                                    // make sure this is not in the groups table?
                                    $this->removeGroup($serviceID);
                                }
                            } else {
                                $return_value = $backups;
                            }
                        }
                    } else {
                        $return_value = $insert_service;
                    }
                } else {
                    $return_value = array(
                        'status' => array(
                            'code' => 4,
                            'message' => 'Chief unable to be added'
                        )
                    );
                }
            } else {
                $return_value = $removeServices;
            }



        }

        return $return_value;
    }

    /**
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 6/30/2023, 1:24:51 PM (America/New_York)
     */
    public function updateGroup(int $groupID, ?Db $oc_db = null): array
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
            if ($oc_db === null) {
                $oc_db = OC_DB;
            }

            $group = new \Orgchart\Group($oc_db, $this->login);
            $position = new \Orgchart\Position($oc_db, $this->login);
            $tag = new \Orgchart\Tag($oc_db, $this->login);

            $upperLevelTag = $tag->getParent('service');
            $isQuadrad = false;

            if (array_search($upperLevelTag, $group->getAllTags($groupID)) !== false) {
                $isQuadrad = true;
            }

            $resGroup = $group->getGroup($groupID)[0];

            $insert_group = $this->insertGroup($groupID, $isQuadrad, $resGroup['groupTitle']);

            if ($insert_group['status']['code'] == 2) {
                $delete_user_backups = $this->deleteUsers($groupID);

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
        }

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

            $oc_db = OC_DB;
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
            $sql = 'DELETE
                    FROM `users`
                    WHERE `backupID` <> ""
                    AND `groupID` = :groupID';

            $this->db->prepared_query($sql, $vars);

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

    public function getServices(): array
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
    public function getDatabaseVersion(): string
    {
        $version = $this->db->prepared_query('SELECT data FROM settings WHERE setting = "dbVersion"', array());
        if (count($version) > 0 && $version[0]['data'] !== null)
        {
            return $version[0]['data'];
        }

        return 'unknown';
    }

    public function getGroups(): array
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

        $tz_additional = array(
            "America/Puerto_Rico",
            "Pacific/Guam",
            "Pacific/Saipan",
            "Pacific/Pago_Pago",
            "Asia/Manila",
        );
        $tzones = array_merge(\DateTimeZone::listIdentifiers(\DateTimeZone::PER_COUNTRY, 'US'), $tz_additional);
        if (array_search($_POST['timeZone'], $tzones) === false)
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

        $vars = array(':input' => XSSHelpers::xscrub($_POST['national_linkedSubordinateList']));
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="national_linkedSubordinateList"', $vars);

        return 1;
    }

    public function setNationalLinkedPrimary()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $vars = array(':input' => XSSHelpers::xscrub($_POST['national_linkedPrimary']));
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="national_linkedPrimary"', $vars);

        return 1;
    }

    /**
     * getFileList retrieves filenames uploaded via Admin Panel -> File Manager
     *
     * @param bool getLastModified If set to true, the returned elements within the array include [file, modifiedTime]
     *
     * @return array
     */
    public function getFileList(?bool $getLastModified = false): array
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
                if($getLastModified == false) {
                    $out[] = $item;
                }
                else {
                    $out[] = ['file' => $item, 'modifiedTime' => filemtime('../files/' . $item)];
                }
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
        $fileName = XSSHelpers::scrubFilename($in);
        $fileName = XSSHelpers::xscrub($fileName);
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
        $vars = array(':userID' => XSSHelpers::xscrub($_POST['userID']));
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

            $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::PRIMARY_ADMIN, [
                new LogItem("users", "primary_admin", 1),
                new LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
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

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::PRIMARY_ADMIN, [
            new LogItem("users", "primary_admin", 1),
            new LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
        ]);

        return $result;
    }

    public function getHistory($filterById)
    {
        return $this->dataActionLogger->getHistory($filterById, null, LoggableTypes::PRIMARY_ADMIN);
    }

    /**
     * @param \Orgchart\Group $nexus_group
     *
     * @return string
     *
     * Created at: 10/3/2022, 6:59:30 AM (America/New_York)
     */
    public function syncSystem(\Orgchart\Group $nexus_group, array $site_data = null): string
    {
        // update services and service chiefs
        $this->removeServices();
        $services = $nexus_group->listGroupsByTag('service');

        foreach ($services as $service) {
            $this->updateService($service['groupID']);
        }

        $this->removeGroups();
        $groups = $this->getOrgchartImportTags($nexus_group);
        $oc_db = OC_DB;

        foreach ($groups as $group) {
            $this->updateGroup($group['groupID'], $oc_db);
        }

        $this->cleanupSystemAdmin();
        $this->cleanupUsers();

        if ($site_data !== null) {
            $this->site_data = $site_data;
            $this->cleanupPortalGroups();
        }


        return 'Syncing has finished. You are set to go.';
    }

    private function cleanupPortalGroups(): void
    {
        $vars = array();
        $sql = "DELETE
                FROM `{$this->site_data['portal_database']}`.`groups` `db1`
                WHERE `groupID` NOT IN (
                    SELECT `db2`.`groupID`
                    FROM `{$this->site_data['orgchart_database']}`.`groups` `db2`)
                AND `groupID` > 0";

        $this->db->prepared_query($sql, $vars);
    }

    private function cleanupUsers(): void
    {
        $groups = new Group($this->db, $this->login);
        $services = new Service($this->db, $this->login);

        // Get all users with a backupID
        $backupList = $this->getAllBackups('users', 'groupID');

        // loop through this list and check for a user with the same userID without a backupID
        foreach($backupList as $backup) {
            $user = $this->getUserNoBackup($backup['groupID'], $backup['backupID'], 'users', 'groupID');

            if (empty($user)) {
                $groups->removeMember($backup['userID'], $backup['groupID'], $backup['backupID']);
            }
        }

        // Get all service chiefs with a backupID
        $backupList = $this->getAllBackups('service_chiefs', 'serviceID');

        // loop through this list and check for a user with the same userID without a backupID
        foreach($backupList as $backup) {
            $user = $this->getUserNoBackup($backup['serviceID'], $backup['backupID'], 'service_chiefs', 'serviceID');

            if (empty($user)) {
                $services->removeChief($backup['serviceID'], $backup['userID'], $backup['backupID']);
            }
        }

        // Or is there an easier query to do this in one step.
    }

    private function getUserNoBackup(int $serviceGroup, string $backup, string $table, string $id): array
    {
        $vars = array(':userID' => $backup,
                      ':serviceGroup' => $serviceGroup);
        $sql = "SELECT `userID`, {$id}, `backupID`
                FROM {$table}
                WHERE `userID` = :userID
                AND {$id} = :serviceGroup
                AND `backupID` = ''";

        $user = $this->db->prepared_query($sql, $vars);

        return $user;
    }

    private function getAllBackups(string $table, string $id): array
    {
        $vars = array();
        $sql = "SELECT `userID`, {$id}, `backupID`
                FROM {$table}
                WHERE `backupID` != ''";

        $backupList = $this->db->prepared_query($sql, $vars);

        return $backupList;
    }

    /**
     *
     * @return void
     *
     */
    private function cleanupSystemAdmin(): void
    {
        // get all portal users with groupID = 1
        $groups = new Group($this->db, $this->login);

        $admins = $groups->getMembers(1);

        // create an array of users with their backups
        $admin_list = array();

        foreach ($admins['data'] as $admin) {
            if ($admin['backupID'] != '') {
                $admin_list[$admin['backupID']]['backup'][] = $admin['userName'];
            }
        }

        // get all primary users from nexus with their backups
        $dir = new VAMC_Directory();
        $oc_db = OC_DB;
        $employee = new \Orgchart\Employee($oc_db, $this->login);
        $check_list = array();

        foreach ($admin_list as $key => $admin) {
            $nexus_user = $dir->lookupLogin($key, false, true, false);
            $backups = $employee->getBackups($nexus_user[0]['empUID']);
            $check_list[$key]['backup'] = array();

            foreach ($backups as $backup) {
                $check_list[$key]['backup'][] = $backup['userName'];
            }
        }

        // check that all the backups are still there, if not remove them from portal

        foreach ($admin_list as $key => $user) {
            foreach ($user['backup'] as $backup) {
                if (!in_array($backup, $check_list[$key]['backup'])) {
                    $groups->removeMember($backup, 1, $key);
                }
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

    private function removeService(int $serviceID): array
    {
        $vars = array(':serviceID' => $serviceID);
        $sql = 'DELETE
                FROM `services`
                WHERE `serviceID` = :serviceID';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `service_chiefs`
                WHERE `serviceID` = :serviceID
                AND `locallyManaged` = 0';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        return $return_value;
    }

    private function removeServices(): array
    {
        $vars = array();
        $sql = 'DELETE
                FROM `services`';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `service_chiefs`
                WHERE `locallyManaged` = 0';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `groups`
                WHERE `parentGroupID` = -1';

        $return_value = $this->db->pdo_delete_query($sql, $vars);


        return $return_value;
    }

    private function removeGroup(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'DELETE
                FROM `groups`
                WHERE `groupID` = :groupID';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `users`
                WHERE `groupID` = :groupID';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        return $return_value;
    }

    private function removeGroups(): array
    {
        $vars = array();
        $sql = 'DELETE
                FROM `groups`
                WHERE `groupID` > 1
                AND parentGroupID <> -1';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

        $sql = 'DELETE
                FROM `users`
                WHERE `locallyManaged` = 0
                AND `groupID` <> 1';

        $return_value = $this->db->pdo_delete_query($sql, $vars);

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
     * @param int $serviceID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:39:33 AM (America/New_York)
     */
    private function deleteChiefs(int $serviceID): array
    {
        $vars = array(':serviceID' => $serviceID);
        $sql = 'DELETE
                FROM `service_chiefs`
                WHERE `serviceID` = :serviceID
                AND `locallyManaged` = 0
                AND `active` = 1';

        $return_value = $this->db->pdo_delete_query($sql , $vars);

        return $return_value;
    }

    /**
     * @param string $userName
     * @param int $serviceID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:41:14 AM (America/New_York)
     */
    private function insertChief(string $userName, int $serviceID): array
    {
        $vars = array(':userID' => $userName,
                    ':serviceID' => $serviceID);
        $sql = 'INSERT INTO `service_chiefs` (`serviceID`, `userID`, `active`)
                VALUES (:serviceID, :userID, 1)
                ON DUPLICATE KEY UPDATE `serviceID` = :serviceID, `userID` = :userID';

        $return_value = $this->db->pdo_insert_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $serviceID
     * @param string $title
     * @param string $abbr
     * @param int $groupID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:41:30 AM (America/New_York)
     */
    private function insertService(int $serviceID, string $title, string $abbr, int $groupID): array
    {
        $vars = array(':serviceID' => $serviceID,
                        ':service' => $title,
                        ':abbrService' => $abbr,
                        ':groupID' => $groupID );
        $sql = 'INSERT INTO `services` (`serviceID`, `service`,
                    `abbreviatedService`, `groupID`)
                VALUES (:serviceID, :service, :abbrService, :groupID)
                ON DUPLICATE KEY UPDATE `service` = :service, `groupID` = :groupID,
                    `abbreviatedService` = :abbrService';

        $return_value = $this->db->pdo_insert_query($sql, $vars);

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
     * @param bool $group
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:32:46 AM (America/New_York)
     */
    private function addBackups(int $groupID, bool $group = true): array
    {
        $oc_db = OC_DB;
        $employee = new \Orgchart\Employee($oc_db, $this->login);

        // get all users for this group
        if ($group) {
            $group_users = $this->getGroupUsers($groupID);
        } else {
            $group_users = $this->getServiceUsers($groupID);
        }

        // loop through group_users to add backups
        if ($group_users['status']['code'] == 2){
            $userNames = array();

            foreach ($group_users['data'] as $user) {
                $userNames[] = $user['userID'];
            }

            $return_value = array (
                'status' => array (
                    'code' => 2,
                    'message' => ''
                )
            );

            $employee_list = $employee->getEmployeeByUserName($userNames, $oc_db);
            foreach ($employee_list['data'] as $user) {
                // if active user, then get backups and add them
                if ($user['deleted'] == 0) {
                    $backups = $employee->getBackups($user['empUID']);

                    if (!empty($backups)) {
                        foreach ($backups as $backup) {
                            if ($group) {
                                $backup_added = $this->addBackup($groupID, $backup['userName'], $user['userName']);
                            } else {
                                $backup_added = $this->addServiceBackup($groupID, $backup['userName'], $user['userName']);
                            }


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
        } else {
            $return_value = $group_users;
        }

        return $return_value;
    }

    /**
     * @param int $serviceID
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:42:10 AM (America/New_York)
     */
    private function getServiceUsers(int $serviceID): array
    {
        $vars = array(':serviceID' => $serviceID);
        $sql = 'SELECT `userID`
                FROM `service_chiefs`
                WHERE `serviceID` = :serviceID
                AND `backupID` = ""';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $serviceID
     * @param string $backup_user
     * @param string $user
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:42:47 AM (America/New_York)
     */
    private function addServiceBackup(int $serviceID, string $backup_user, string $user): array
    {
        $vars = array(':userID' => $backup_user,
                    ':serviceID' => $serviceID,
                    ':backupID' => $user);
        $sql = 'INSERT INTO `service_chiefs` (`userID`, `serviceID`,
                    `backupID`)
                VALUES (:userID, :serviceID, :backupID)
                ON DUPLICATE KEY UPDATE `userID` = :userID,
                    `serviceID` = :serviceID';

        $return_value = $this->db->pdo_insert_query($sql, $vars);

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
                WHERE `groupID` = :groupID
                AND `backupID` = ""';

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
                    VALUES (:userID, :groupID, "", 1)
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
    private function deleteUsers(int $groupID): array
    {
        $vars = array(':groupID' => $groupID);
        $sql = 'DELETE
                FROM `users`
                WHERE `groupID` = :groupID
                AND `locallyManaged` = 0
                AND `active` = 1';

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

    // removeLeafSecure removes the LEAF secure status of the current site
    public function removeLeafSecure()
    {
        $this->db->prepared_query("UPDATE settings SET data = 0 WHERE setting = 'leafSecure'", []);
    }
}
