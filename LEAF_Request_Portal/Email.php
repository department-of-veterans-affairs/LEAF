<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Emailer
    Date Created: September 19, 2008

*/
include_once __DIR__ . '/../libs/smarty/Smarty.class.php';

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

    public $smartyVariables = array();

    const SEND_BACK = -1;
    const NOTIFY_NEXT = -2;
    const NOTIFY_COMPLETE = -3;

    public function __construct()
    {
        $this->initPortalDB();
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

    public function clearRecipients()
    {
        $this->emailRecipient = '';
    }

    public function setSender($i)
    {
        $this->emailSender = $i;
    }

    public function setSubject($i)
    {
        $prefix = isset(Config::$emailPrefix) ? Config::$emailPrefix : 'Resources: ';
        $this->emailSubject = $prefix . strip_tags($i);
    }

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

    public function addRecipient($i)
    {
        if (preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0)
        {
            return false;
        }

        if ($this->emailRecipient == '')
        {
            $this->emailRecipient = $i;
        }
        else
        {
            $this->emailRecipient .= ", $i";
        }

        return true;
    }

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

    public function addGroupRecipient($groupID)
    {
        require_once 'VAMC_Directory.php';
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

    public function addCC($i)
    {
        if (preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0)
        {
            return false;
        }

        $this->emailCC[] = $i;

        return true;
    }

    public function addBCC($i)
    {
        if (preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0)
        {
            return false;
        }

        $this->emailBCC[] = $i;

        return true;
    }

    public function sendMail()
    {
        $currDir = dirname(__FILE__);

        if (isset(Config::$emailCC) && count(Config::$emailCC) > 0)
        {
            foreach (Config::$emailCC as $recipient)
            {
                $this->addCC($recipient);
            }
        }
        if (isset(Config::$emailBCC) && count(Config::$emailBCC) > 0)
        {
            foreach (Config::$emailBCC as $recipient)
            {
                $this->addBCC($recipient);
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
        $res = $this->portal_db->prepared_query("SELECT `subject`, `body` 
                                                 FROM `email_templates` 
                                                 WHERE emailTemplateID = :emailTemplateID;", 
                                                array(':emailTemplateID' => $emailTemplateID));
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
        $res = $this->portal_db->prepared_query("SELECT `subject`, `body` 
                                                 FROM `email_templates` 
                                                 WHERE label = :emailTemplateLabel;", 
                                                array(':emailTemplateLabel' => $emailTemplateLabel));
        $this->setSubjectWithTemplate(XSSHelpers::xscrub($res[0]['subject']));
        $this->setBodyWithTemplate(XSSHelpers::xscrub($res[0]['body']));
    }

    /**
     * Sets the subject based on the given smarty template
     * @param string $subjectTemplate the filename of the template for the subject
     * @return void
     */
    function setSubjectWithTemplate($subjectTemplate)
    {
        $smartySubject = new Smarty;
        $smartySubject->template_dir = __DIR__ . '/templates/email/';
        $smartySubject->compile_dir = __DIR__ . '/templates_c/';
        $smartySubject->left_delimiter = '{{';
        $smartySubject->right_delimiter = '}}';
        $smartySubject->assign($this->smartyVariables);
        $htmlOutput = $smartySubject->fetch($this->getFilepath($subjectTemplate));
        $this->setSubject($htmlOutput);
    }

    /**
     * Sets the body based on the given smarty template
     * @param string $bodyTemplate the filename of the template for the body
     * @return void
     */
    function setBodyWithTemplate($bodyTemplate)
    {
        $smartyBody = new Smarty;
        $smartyBody->template_dir = __DIR__ . '/templates/email/';
        $smartyBody->compile_dir = __DIR__ . '/templates_c/';
        $smartyBody->left_delimiter = '{{';
        $smartyBody->right_delimiter = '}}';
        $smartyBody->assign($this->smartyVariables);
        $htmlOutput = $smartyBody->fetch($this->getFilepath($bodyTemplate));
        $this->setBody($htmlOutput);
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
