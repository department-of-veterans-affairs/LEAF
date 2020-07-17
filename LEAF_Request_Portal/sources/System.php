<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date Created: September 17, 2015

*/

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';

if (!class_exists('XSSHelpers'))
{
    require_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}
if (!class_exists('CommonConfig'))
{
    require_once dirname(__FILE__) . '/../../libs/php-commons/CommonConfig.php';
}

if(!class_exists('DataActionLogger'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/dataActionLogger.php';
}

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

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $commonConfig = new CommonConfig();
        $this->fileExtensionWhitelist = $commonConfig->fileManagerWhitelist;

        $this->dataActionLogger = new \DataActionLogger($db, $login);
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
        $this->db->prepared_query('DELETE FROM service_chiefs WHERE serviceID=:serviceID AND locallyManaged != 1', $vars);

        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Group.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Position.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Employee.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Tag.php';

        $config = new Config();
        $db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $group = new Orgchart\Group($db_phonebook, $this->login);
        $position = new Orgchart\Position($db_phonebook, $this->login);
        $employee = new Orgchart\Employee($db_phonebook, $this->login);
        $tag = new Orgchart\Tag($db_phonebook, $this->login);

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

                $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID)
                                    VALUES (:serviceID, :userID)', $vars);

                // include the backups of employees
                $backups = $employee->getBackups($emp['empUID']);
                foreach ($backups as $backup)
                {
                    $vars = array(':userID' => $backup['userName'],
                            ':serviceID' => $service['groupID'], );

                    $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, userID)
                                    VALUES (:serviceID, :userID)', $vars);
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
        $this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $vars);
        $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $vars);

        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Group.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Position.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Employee.php';
        include_once __DIR__ . '/../' . Config::$orgchartPath . '/sources/Tag.php';

        $config = new Config();
        $db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        $group = new Orgchart\Group($db_phonebook, $this->login);
        $position = new Orgchart\Position($db_phonebook, $this->login);
        $employee = new Orgchart\Employee($db_phonebook, $this->login);
        $tag = new Orgchart\Tag($db_phonebook, $this->login);

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

        $this->db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name, groupDescription)
                    					VALUES (:groupID, :parentGroupID, :name, :groupDescription)', $vars);

        // build list of member employees
        $resEmp = array();
        $positions = $group->listGroupPositions($groupID);
        $resEmp = $group->listGroupEmployees($groupID);
        foreach ($positions as $tposition)
        {
            $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
        }

        foreach ($resEmp as $emp)
        {
            if ($emp['userName'] != '')
            {
                $vars = array(':userID' => $emp['userName'],
                        ':groupID' => $groupID, );

                $this->db->prepared_query('INSERT INTO users (userID, groupID)
										VALUES (:userID, :groupID)', $vars);

                // include the backups of employees
                $backups = $employee->getBackups($emp['empUID']);
                foreach ($backups as $backup)
                {
                    $vars = array(':userID' => $backup['userName'],
                            ':groupID' => $groupID, );

                    $this->db->prepared_query('INSERT INTO users (userID, groupID)
										VALUES (:userID, :groupID)', $vars);
                }
            }
        }

        //if the group is removed, also remove the category_privs
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT *
                                            FROM category_privs
                                            LEFT JOIN groups USING (groupID)
                                            WHERE category_privs.groupID = :groupID
                                            AND groups.groupID is null;', $vars);
        if(count($res) > 0)
        {
            $this->db->prepared_query('DELETE FROM category_privs WHERE groupID=:groupID', $vars);
        }


        return "groupID: {$groupID} updated";
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

    public function getTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $out[] = $item;
            }
        }

        return $out;
    }

    public function getEmailSubjectData($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $data['subjectFileName'] = '';
        $data['subjectFile'] = '';

        if (preg_match('/_body.tpl$/', $template))
        {
            $subject = str_replace("_body.tpl", "_subject.tpl", $template, $count);
            if ($count == 1)
            {
                $data['subjectFileName'] = $subject;

                if (file_exists("../templates/email/custom_override/{$subject}") && !$getStandard)
                    $data['subjectFile'] = file_get_contents("../templates/email/custom_override/{$subject}");          
                else if (file_exists("../templates/email/{$subject}"))
                    $data['subjectFile'] = file_get_contents("../templates/email/{$subject}");
                else
                    $data['subjectFile'] = '';
            }
        }

        return $data;
    }

    public function getEmailAndSubjectTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/email');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $temp =  array();
                preg_match('/subject/', $item, $temp);
                if (count($temp) == 0) 
                {                    
                    $data['fileName'] = $item;
                    $res = $this->getEmailSubjectData($item);
                    $data['subjectFileName'] = $res['subjectFileName'];
                    $out[] = $data;
                }
            }
        }

        return $out;
    }

    public function getEmailTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/email');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $temp =  array();
                preg_match('/subject/', $item, $temp);
                if (count($temp) == 0) 
                {                    
                    $out[] = $item;
                }
            }
        }

        return $out;
    }

    public function getTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/custom_override/{$template}")
                  && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents("../templates/custom_override/{$template}");
            }
            else
            {
                $data['modified'] = 0;
                $data['file'] = file_get_contents("../templates/{$template}");
            }
        }

        return $data;
    }

    public function getEmailTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();
        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/email/custom_override/{$template}")
                  && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents("../templates/email/custom_override/{$template}");
            }
            else
            {
                $data['modified'] = 0;
                $data['file'] = file_get_contents("../templates/email/{$template}");
            }

            $res = $this->getEmailSubjectData($template, $getStandard);
            $data['subjectFile'] = $res['subjectFile'];
        }

        return $data;
    }

    public function setTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/custom_override/{$template}", $_POST['file']);
        }
    }

    public function setEmailTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();
        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/email/custom_override/{$template}", $_POST['file']);
        
            if ($_POST['subjectFileName'] != '')
                file_put_contents("../templates/email/custom_override/" . $_POST['subjectFileName'], $_POST['subjectFile']);
        }
    }

    public function removeCustomTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/custom_override/{$template}"))
            {
                return unlink("../templates/custom_override/{$template}");
            }
        }
    }

    public function removeCustomEmailTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();

        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/email/custom_override/{$template}"))
            {
                unlink("../templates/email/custom_override/{$template}");
            }

            $subjectFileName = $_REQUEST['subjectFileName'];
            if ($subjectFileName != '' && file_exists("../templates/email/custom_override/{$subjectFileName}"))
            {
                unlink("../templates/email/custom_override/{$subjectFileName}");
            }
        }
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

        if (array_search($_POST['timeZone'], DateTimeZone::listIdentifiers(DateTimeZone::PER_COUNTRY, 'US')) === false)
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

    public function getReportTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/reports/');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $out[] = $item;
            }
        }

        return $out;
    }

    public function newReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $template == 'example'
            || $template == ''
            || preg_match('/^LEAF_/i', $template) === 1)
        {
            return 'Invalid or reserved name.';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) === false)
        {
            file_put_contents("../templates/reports/{$template}", '');
        }
        else
        {
            return 'File already exists';
        }

        return 'CreateOK';
    }

    public function getReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in)
        {
            return 0;
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/reports/{$template}"))
            {
                $data['file'] = file_get_contents("../templates/reports/{$template}");
            }
        }

        return $data;
    }

    private function isReservedFilename($file)
    {
        if($file == 'example'
            || substr($file, 0, 5) == 'LEAF_'
        ) {
            return true;
        }
        return false;
    }

    public function setReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $this->isReservedFilename($template))
        {
            return 'Reserved filenames: LEAF_*, example';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/reports/{$template}", $_POST['file']);
        }
    }

    public function removeReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $this->isReservedFilename($template))
        {
            return 0;
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/reports/{$template}"))
            {
                return unlink("../templates/reports/{$template}");
            }
        }
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
            require_once '../VAMC_Directory.php';
            $dir = new VAMC_Directory;
            $user = $dir->lookupLogin($primaryAdminRes[0]['userID']);
            $result = isset($user[0]) ? $user[0] : $primaryAdminRes[0]['userID'];
        }
        return $result;
    }

    /**
     * Set primary admin.
     *
     * @return array array with response array
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

            $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::PRIMARY_ADMIN, [
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

        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::PRIMARY_ADMIN, [
            new LogItem("users", "primary_admin", 1),
            new LogItem("users", "userID", $primary["empUID"], $primary["firstName"].' '.$primary["lastName"])
        ]);

        return $result;
    }

    public function getHistory($filterById)
    {
        return $this->dataActionLogger->getHistory($filterById, null, \LoggableTypes::PRIMARY_ADMIN);
    }
}
