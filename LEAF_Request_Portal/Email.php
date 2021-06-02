<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Emailer
    Date Created: September 19, 2008

*/
include_once __DIR__ . '/../libs/smarty/Smarty.class.php';
require_once 'VAMC_Directory.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

class Email
{
    public $emailSender = '';

    public $emailBody = '';

    private $emailFrom = 'LEAF@localhost';

    private $emailRecipient = '';

    private $emailSubject = '';

    private $emailCC = array();

    private $emailBCC = array();

    private $position;

    private $group;

    private $orgchartInitialized = false;

    private $portal_db;
    private $nexus_db;

    public $smartyVariables = array();

    const SEND_BACK = -1;
    const NOTIFY_NEXT = -2;
    const NOTIFY_COMPLETE = -3;

    public function __construct()
    {
        $this->initPortalDB();
        $this->initNexusDB();
    }

    /**
     * Checks for custom templates and returns the filepath if so. Otherwise returns the regular filepath.
     * @param string $tpl the filename of the template
     * @return string The filepath of the template passed
     */
    function getFilepath($tpl)
    {
        return file_exists(__DIR__ . "/templates/email/custom_override/{$tpl}") ? "custom_override/{$tpl}" : "{$tpl}";
    }

    /**
     * Removes all email addresses from object recipient variable
     */
    public function clearRecipients()
    {
        $this->emailRecipient = '';
    }

    /**
     * Set email sender object variable
     * @param $strAddress
     */
    public function setSender($strAddress)
    {
        $this->emailSender = $strAddress;
    }

    /**
     * Clean and Set subject of email object variable
     * @param $strSubject
     */
    public function setSubject($strSubject)
    {
        $prefix = isset(Config::$emailPrefix) ? Config::$emailPrefix : 'Resources: ';
        $this->emailSubject = $prefix . strip_tags($strSubject);
    }

    /**
     * Add content into template variable then into template file
     * This result will then be added into the object variable as HTML output
     * @param $objVar       - private variable in Email object
     * @param $strContent   - content to add to template
     * @param $tplVar       - variable within template
     * @param $tplFile      = template file name
     */
    public function setContent($tplFile, $tplVar = '', $strContent = '') {
        if($tplVar != '') {
            $strContent = str_replace("\r\n", '<br />', $strContent);
        }
        $smarty = new Smarty;
        $smarty->template_dir = __DIR__ . '/templates/email/';
        $smarty->compile_dir = __DIR__ . '/templates_c/';
        $smarty->left_delimiter = '{{';
        $smarty->right_delimiter = '}}';
        if (($tplVar != '') && ($strContent != '')) {
            $smarty->assign($tplVar, $strContent);
        } else {
            $smarty->assign($this->smartyVariables);
        }
        $htmlOutput = $smarty->fetch($tplFile);
        return $htmlOutput;
    }

    /**
     * Purpose: To check that email address is not already attached to this email send
     * @param $address
     * @return bool
     */
    public function emailActiveNotAlreadyAdded($address) {

        if ( ( strpos($this->emailRecipient, $address) === false  )
            && (!in_array($address, $this->emailCC) )
            && (!in_array($address ,$this->emailBCC) ) ) {

            $dir = new VAMC_Directory;

            // Check that email address is active in Nexus
            $res = $this->nexus_db->prepared_query(
                "SELECT e.deleted 
                    FROM employee as e
                        INNER JOIN employee_data ed on e.empUID = ed.empUID
                    WHERE e.deleted = 0 
                        AND ed.data=:emailAddress ;",
                array(':emailAddress' => $address));
            return ( (!empty($res)) ? true : false );
        }
        return false;
    }

    /**
     * Purpose: Add Receipient to email
     * @param $address
     * @return bool
     */
    public function addRecipient($address, $requiredAddress = false)
    {
        if (preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $address) == 0)
        {
            return false;
        }

        if ($this->emailRecipient == '')
        {
            $this->emailRecipient = $address;
        }
        else
        {
            if ( $this->emailActiveNotAlreadyAdded($address) || $requiredAddress ) {
                $this->emailRecipient .= ", " . $address;
            }
        }

        // Returning true because either added here or already added
        return true;
    }

    /**
     * Adds all users in a given Position to the receipient object variable list
     * @param $positionID
     */
    public function addPositionRecipient($positionID)
    {
        if ($this->orgchartInitialized == false)
        {
            $this->initOrgchart();
        }
        $employees = $this->position->getEmployees($positionID);
        foreach ($employees as $emp)
        {
            $res = $this->employee->getAllData($emp['empUID'], 6);
            $this->addRecipient($res[6]['data']);
        }
    }

    /**
     * Adds all users in a given Group to the reeeipient object variable list
     * @param $groupID
     */
    public function addGroupRecipient($groupID)
    {
        $dir = new VAMC_Directory;

        $res = $this->portal_db->prepared_query("SELECT `userID`
                                                 FROM `users` 
                                                 WHERE groupID=:groupID
                                                    AND active=1", 
                                                array(':groupID' => $groupID));
        foreach($res as $user) {
            $tmp = $dir->lookupLogin($user['userID']);
            $this->addRecipient($tmp[0]['Email']);
        }
    }

    /**
     * Scrubs email address and adds to object email CC array if valid
     * @param $strEmailAddress
     * @return bool
     */

    public function addCcBcc($address, $requiredAddress = false, $isBcc = false)
    {
        if (preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $address) == 0)
        {
            return false;
        }

        if ( $this->emailActiveNotAlreadyAdded($address) || ($requiredAddress)  ) {
          if (!$isBcc) {
              $this->emailCC[] = $address;
          } else {
              $this->emailBCC[] = $address;
          }
        }

        return true;
    }

    /**
     * Assign email variables to email send and perform Send
     * Will throw exception if Send not completed and then return false
     * @return false
     * @throws Exception
     */
    public function sendMail()
    {
        $currDir = dirname(__FILE__);

        if (isset(Config::$emailCC) && count(Config::$emailCC) > 0)
        {
            foreach (Config::$emailCC as $recipient)
            {
                $this->addCcBcc($recipient);
            }
        }
        if (isset(Config::$emailBCC) && count(Config::$emailBCC) > 0)
        {
            foreach (Config::$emailBCC as $recipient)
            {
                $this->addCcBcc($recipient, false,true);
            }
        }
        $email['recipient'] = html_entity_decode($this->emailRecipient, ENT_QUOTES);
        $email['subject'] = $this->emailSubject;
        $email['body'] = $this->emailBody;
        $email['headers'] = html_entity_decode($this->getHeaders(), ENT_QUOTES);

        $emailCache = serialize($email);
        $emailQueueName = sha1($emailCache . random_int(0, 99999999));
        if (strlen(trim($emailCache)) == 0)
        {
            trigger_error('Mail error: ' . $this->emailSubject);

            return false;
        }
        file_put_contents($currDir . '/templates_c/mailer/' . $emailQueueName, $emailCache);

        if (strtoupper(substr(php_uname('s'), 0, 3)) == 'WIN')
        {
            $shell = new COM('WScript.Shell');
            $shell->Run("php {$currDir}/mailer/mailer.php {$emailQueueName}", 0, false);
        }
        else
        {
            exec("php {$currDir}/mailer/mailer.php {$emailQueueName} > /dev/null &");
        }
    }

    /**
     * Gets current user's employeeID, positionID, groupID
     * and assigns them to email object variables
     */
    private function initOrgchart()
    {
        // set up org chart assets
        if (!class_exists('DB'))
        {
            include 'db_mysql.php';
        }
        if (!class_exists('Orgchart\Config'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/config.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Group.php';
        }
        if (!class_exists('Orgchart\Login'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
        }
        if (!class_exists('Orgchart\Employee'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
        }
        if (!class_exists('Orgchart\Position'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
        }
        if (!class_exists('Orgchart\Group'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Group.php';
        }
        $config = new Orgchart\Config;
        $oc_db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
        $oc_login = new OrgChart\Login($oc_db, $oc_db);
        $oc_login->loginUser();
        $this->employee = new OrgChart\Employee($oc_db, $oc_login);
        $this->position = new OrgChart\Position($oc_db, $oc_login);
        $this->group = new OrgChart\Group($oc_db, $oc_login);
        $this->orgchartInitialized = true;
    }

    /**
     * Initialize portal db object 
     * @return void
     */
    function initPortalDB()
    {
        // set up org chart assets
        if (!class_exists('DB'))
        {
            include 'db_mysql.php';
        }
        if (!class_exists('DB_Config'))
        {
            include 'db_config.php';
        }

        $db_config = new DB_Config;
        $this->portal_db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
    }

    /**
     * Initialize Nexus db object
     * @return void
     */
    function initNexusDB()
    {
        // set up org chart assets
        if (!class_exists('DB'))
        {
            include 'db_mysql.php';
        }
        if (!class_exists('DB_Config'))
        {
            include 'db_config.php';
        }

        $nexus_config = new Config;
        $this->nexus_db = new DB($nexus_config->phonedbHost, $nexus_config->phonedbUser, $nexus_config->phonedbPass, $nexus_config->phonedbName);
    }

    private function getHeaders()
    {
        $header = 'MIME-Version: 1.0';
        $header .= "\r\nContent-type: text/html; charset=iso-8859-1";
        if ($this->emailSender == '')
        {
            $header .= "\r\nFrom: {$this->emailFrom}";
        }
        else
        {
            $header .= "\r\nSender: {$this->emailFrom}";
            $header .= "\r\nFrom: {$this->emailSender}";
            $header .= "\r\nReply-To: {$this->emailSender}";
        }
        if (count($this->emailCC) > 0)
        {
            $header .= "\r\nCc: ";
            foreach ($this->emailCC as $cc)
            {
                $header .= "$cc, ";
            }
            $header = rtrim($header, ', ');
        }
        if (count($this->emailBCC) > 0)
        {
            $header .= "\r\nBcc: ";
            foreach ($this->emailBCC as $bcc)
            {
                $header .= "$bcc, ";
            }
            $header = rtrim($header, ', ');
        }

        return $header;
    }

    /**
     * Gets template filenames from the db based on emailTemplateID and sets the properties
     * @param int $emailTemplateID emailTemplateID from email_templates table
     * @return void
     */
    function setTemplateByID($emailTemplateID)
    {
        $res = $this->portal_db->prepared_query("SELECT `emailTo`, `emailCc`,`subject`, `body` 
                                                 FROM `email_templates` 
                                                 WHERE emailTemplateID = :emailTemplateID;", 
                                                array(':emailTemplateID' => $emailTemplateID));
        $this->setEmailToCcWithTemplate(XSSHelpers::xscrub($res[0]['emailTo']));
        $this->setEmailToCcWithTemplate(XSSHelpers::xscrub($res[0]['emailCc']), true);
        $this->setSubjectWithTemplate(XSSHelpers::xscrub($res[0]['subject']));
        $this->setBodyWithTemplate(XSSHelpers::xscrub($res[0]['body']));
    }

    /**
     * Gets template filenames from the db based on label and sets the properties
     * @param string $emailTemplateLabel label from email_templates table
     * @return void
     */
    function setTemplateByLabel($emailTemplateLabel)
    {
        $res = $this->portal_db->prepared_query("SELECT `emailTo`,`emailCc`,`subject`, `body` 
                                                 FROM `email_templates` 
                                                 WHERE label = :emailTemplateLabel;", 
                                                array(':emailTemplateLabel' => $emailTemplateLabel));
        $this->setEmailToCcWithTemplate(XSSHelpers::xscrub($res[0]['emailTo']));
        $this->setEmailToCcWithTemplate(XSSHelpers::xscrub($res[0]['emailCc']), true);
        $this->setSubjectWithTemplate(XSSHelpers::xscrub($res[0]['subject']));
        $this->setBodyWithTemplate(XSSHelpers::xscrub($res[0]['body']));
    }

    /**
     * Given email template location where email addresses are stored
     * Get the email addresses, line by line, and add them if valid to CC or BCC
     * @param $tplLocation
     * @param false $isBcc
     */
    function setEmailToCcWithTemplate($tplLocation, $isCc = false)
    {
        // Determine if template currently has any email addresses saved
        $tplLocation = str_replace(array('email_to', 'email_cc'), array('emailTo', 'emailCC'), $tplLocation);
        $hasEmailTemplate = $this->getFilepath($tplLocation);
        $emailTemplate = __DIR__ . '/templates/email/' . $hasEmailTemplate;
        if (file_exists($emailTemplate)) {
            $emailList = file($emailTemplate, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES );
            // For each line in template, add that email address, if valid
            foreach($emailList as $emailAddress) {
                if ($isCc) {
                    $this->addCcBcc(XSSHelpers::xscrub($emailAddress), true);
                } else {
                    $this->addRecipient(XSSHelpers::xscrub($emailAddress), true);
                }
            }
        }

    }

    /**
     * Sets the subject based on the given smarty template
     * @param string $subjectTemplate the filename of the template for the subject
     * @return void
     */
    function setSubjectWithTemplate($subjectTemplate)
    {
        $htmlOutput = $this->setContent($this->getFilepath($subjectTemplate));
        $this->setSubject($htmlOutput);
    }

    /**
     * Purpose (deprecated): set email body directly from passed in HTML
     * LEGACY: Included as scripts created by portal uses that implement sends using this feature
     * @param $i
     * @throws SmartyException
     */
    public function setBody($i)
    {
        $i = str_replace("\r\n", '<br />', $i);
        $smarty = new Smarty;
        $smarty->template_dir = __DIR__ . '/templates/email/';
        $smarty->compile_dir = __DIR__ . '/templates_c/';
        $smarty->left_delimiter = '{{';
        $smarty->right_delimiter = '}}';
        $smarty->assign('emailBody', $i);
        $htmlOutput = $smarty->fetch('LEAF_main_email_template.tpl');
        $this->emailBody = $htmlOutput;
    }

    /**
     * Sets the body based on the given smarty template
     * @param string $bodyTemplate the filename of the template for the body
     * @return void
     */
    function setBodyWithTemplate($bodyTemplate)
    {
        $htmlOutput = $this->setContent($this->getFilepath($bodyTemplate));
        $this->emailBody = $this->setContent(
            'LEAF_main_email_template.tpl',
            'emailBody',
            $htmlOutput
        );
    }

    /**
     * Performs array_merge on the current smartyVariables, adding the passed in variables.
     * If there are any repeated keys, the new values will override the old
     * @param array $newVariables associative array where the keys are the variable names and the values are the variable values
     * @return void
     */
    function addSmartyVariables($newVariables)
    {
        $this->smartyVariables = array_merge($this->smartyVariables, $newVariables);
    }

}
