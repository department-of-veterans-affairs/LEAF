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
include_once __DIR__ . "/../../libs/php-commons/aws/AWSUtil.php";

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

    private $awsUtil;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $commonConfig = new CommonConfig();
        $this->fileExtensionWhitelist = $commonConfig->fileManagerWhitelist;
        $this->awsUtil = new AWSUtil();
        $this->awsUtil->s3registerStreamWrapper();

        $this->dataActionLogger = new \DataActionLogger($db, $login);
    }

    public function updateService($serviceID)
    {
        global $config;
        if (!is_numeric($serviceID))
        {
            return 'Invalid Service';
        }
        // clear out old data first
        $vars = array(':serviceID' => $serviceID);
        $this->db->prepared_query('DELETE FROM services WHERE serviceID=:serviceID AND serviceID > 0', $vars);
        $this->db->prepared_query('DELETE FROM service_chiefs WHERE serviceID=:serviceID AND locallyManaged != 1', $vars);

        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Group.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Position.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Employee.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Tag.php';

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
        global $config;
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
        $this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID AND locallyManaged != 1', $vars);
        $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $vars);

        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Group.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Position.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Employee.php';
        include_once __DIR__ . '/../' . $config->orgchartPath . '/sources/Tag.php';

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
        $list = scandir(__DIR__.'/../templates/');
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
        global $config;

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
                $cleanPortalPath = str_replace("/", "_", $config->portalPath);
                $portalTplPath = __DIR__ ."/../templates/email/custom_override/" . $cleanPortalPath . "_{$subject}";
                $defaultTplPath = __DIR__ ."/../templates/email/{$subject}";

                if (file_exists($portalTplPath) && !$getStandard) 
                    $data['subjectFile'] = file_get_contents($portalTplPath);
                else if (file_exists($defaultTplPath))
                    $data['subjectFile'] = file_get_contents($defaultTplPath);
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
        $list = scandir(__DIR__ .'/../templates/email');
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
        $list = scandir(__DIR__ .'/../templates/email');
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
        global $config;
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);

            if (file_exists(__DIR__."/../templates/custom_override/" . $cleanPortalPath . "_{$template}")
                && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents(__DIR__."/../templates/custom_override/" . $cleanPortalPath . "_{$template}");
            }
            else
            {
                $data['modified'] = 0;
                $data['file'] = file_get_contents(__DIR__."/../templates/{$template}");
            }
        }

        return $data;
    }

    public function getEmailTemplate($template, $getStandard = false)
    {
        global $config;

        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();
        $data = array();
        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ ."/../templates/email/custom_override/" . $cleanPortalPath . "_{$template}";
            $defaultTplPath = __DIR__ ."/../templates/email/{$template}";

            if (file_exists($portalTplPath) && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents($portalTplPath);
            }
            else
            {
                $data['modified'] = 0;
                $data['file'] = file_get_contents($defaultTplPath);
            }

            $res = $this->getEmailSubjectData($template, $getStandard);
            $data['subjectFile'] = $res['subjectFile'];
        }

        return $data;
    }

    public function setTemplate($template)
    {
        global $config;
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            file_put_contents(__DIR__ . "/../templates/custom_override/" . $cleanPortalPath . "_{$template}", $_POST['file']);
        }
    }

    public function setEmailTemplate($template)
    {
        global $config;

        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();
        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ ."/../templates/email/custom_override/" . $cleanPortalPath;

            file_put_contents($portalTplPath . "_{$template}", $_POST['file']);
        
            if ($_POST['subjectFileName'] != '')
                file_put_contents($portalTplPath . '_' . $_POST['subjectFileName'], $_POST['subjectFile']);
        }
    }

    public function removeCustomTemplate($template)
    {
        global $config;
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            if (file_exists(__DIR__ . "/../templates/custom_override/" . $cleanPortalPath . "_{$template}"))
            {
                return unlink(__DIR__ . "/../templates/custom_override/" . $cleanPortalPath . "_{$template}");
            }
        }
    }

    public function removeCustomEmailTemplate($template)
    {
        global $config;

        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailTemplateList();

        if (array_search($template, $list) !== false)
        {
            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ . "/../templates/email/custom_override/" . $cleanPortalPath;

            if (file_exists($portalTplPath . "_{$template}"))
            {
                unlink($portalTplPath . "_{$template}"); 
            }

            $subjectFileName = $_REQUEST['subjectFileName'];
            if ($subjectFileName != '' && file_exists($portalTplPath . "_{$subjectFileName}"))
            {
                unlink($portalTplPath . "_{$subjectFileName}");
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
        $list = scandir(__DIR__.'/../templates/reports/');
        $out = array();

        // adds defaults;
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $out[] = $item;
            }
        };

        // adds custom reports
        global $config;

        $list = scandir(__DIR__ . "/../templates/reports/custom_override");
        $cleanPortalPath = str_replace("/", "_", $config->portalPath);

        foreach ($list as $item)
        {
            if (preg_match('/^' . $cleanPortalPath . '{1}/', $item))
            {
                $fileName = str_replace($cleanPortalPath . '_', "", $item);
                $out[] = $fileName;
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
            global $config;

            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ . "/../templates/reports/custom_override/" . $cleanPortalPath . "_{$template}";

            if (!file_exists($portalPath)) 
            {
                file_put_contents($portalTplPath, '');
            } 
            else
            {
                return 'File already exists';
            }
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
            global $config;

            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ . "/../templates/reports/custom_override/" . $cleanPortalPath . "_{$template}";
            $defaultTplPath = __DIR__ . "/../templates/reports/{$template}";

            if (file_exists($portalTplPath))
            {
                $data['file'] = file_get_contents($portalTplPath);
            }
            else
            {
                if (file_exists($defaultTplPath))
                {
                    $data['file'] = file_get_contents($defaultTplPath);
                }
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
            global $config;

            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ . "/../templates/reports/custom_override/" . $cleanPortalPath . "_{$template}";
            file_put_contents($portalTplPath, $_POST['file']);
        }
    }

    public function removeReportTemplate($in)
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

        if (array_search($template, $list) !== false)
        {
            global $config;

            $cleanPortalPath = str_replace("/", "_", $config->portalPath);
            $portalTplPath = __DIR__ . "/../templates/reports/custom_override/" . $cleanPortalPath . "_{$template}";

            if (file_exists($portalTplPath))
            {
                return unlink($portalTplPath);
            }
        }
    }

    public function getFileList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        global $config;

        $s3directoryKey = "s3://" . $this->awsUtil->s3getBucketName() . "/" . $config->fileManagerDir;
        $list = scandir($s3directoryKey);
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
        global $config;

        $s3objectKey = "s3://" . $this->awsUtil->s3getBucketName() . "/" . $config->fileManagerDir . $fileName;
        move_uploaded_file($_FILES['file']['tmp_name'], $s3objectKey);

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
        global $config;

        $s3dirKey = "s3://" . $this->awsUtil->s3getBucketName() . "/" . $config->fileManagerDir;

        if (array_search($in, $list) !== false)
        {
            if (file_exists($s3dirKey . $in)
                && $in != 'index.html')
            {
                return unlink($s3dirKey . $in);
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
            require_once __DIR__ . '/../VAMC_Directory.php';
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

    /**
     * Returns every customization in the following categories:
     * 1.) template editor
     * 2.) indictor html field (form editor)
     * 3.) indicator html print field (form editor)
     * 4.) email editor
     *
     * @return array array with site customizations broken up into four sub arrays: 
     * 'templateEditor', 'formIndicatorHtml', 'formIndicatorHtmlPrint', 'emailEditor'
     */
    public function getCustomizations()
    {
        $templateEditor = array();
        $formIndicatorHtml = array();
        $formIndicatorHtmlPrint = array();
        $emailEditor = array();

        $result = [
            'templateEditor' => $this->getTemplateEditorCustomizations(),
            'formIndicatorHtml' => $this->getFormIndicatorHtmlCustomizations(),
            'formIndicatorHtmlPrint' => $this->getFormIndicatorHtmlPrintCustomizations(),
            'emailEditor' => $this->getEmailEditorCustomizations(),
        ];

        return $result;
    }

    /**
     * Returns array of template editor customization descriptions.
     *
     * @return array array of template editor customization descriptions
     */
    private function getTemplateEditorCustomizations()
    {
        $result = array('one', 'two');

        return $result;
    }

    /**
     * Return array of indicator html field customization descriptions.
     *
     * @return array array of indicator html field customization descriptions
     */
    private function getFormIndicatorHtmlCustomizations()
    {
        $result = array('three', 'four');

        return $result;
    }

    /**
     * Return array of indicator html print field customization descriptions.
     *
     * @return array array of indicator html print field customization descriptions
     */
    private function getFormIndicatorHtmlPrintCustomizations()
    {
        $result = array('five', 'six');

        return $result;
    }

    /**
     * Return array of email editor customization descriptions.
     *
     * @return array array of email editor customization descriptions
     */
    private function getEmailEditorCustomizations()
    {
        $result = array('seven', 'eight');

        return $result;
    }
}
