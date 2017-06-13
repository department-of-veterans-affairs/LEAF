<?php
/************************
    Emailer
    Date Created: September 19, 2008

*/

class Email
{
    private $emailFrom = 'LEAF@localhost';
    private $emailRecipient = '';
    private $emailSubject = '';
    public $emailSender = '';
    public $emailBody = '';
    private $emailCC = array();
    private $emailBCC = array();
    private $position = null;
    private $group = null;
    private $orgchartInitialized = false;

    function __construct()
    {
    }

	private function initOrgchart()
	{
		// set up org chart assets
		if(!class_exists('DB')) {
			include 'db_mysql.php';
		}
		if(!class_exists('Orgchart\Config')) {
			include __DIR__ . '/' . Config::$orgchartPath . '/config.php';
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Group.php';
		}
		if(!class_exists('Orgchart\Login')) {
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
		}
		if(!class_exists('Orgchart\Employee')) {
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
		}
		if(!class_exists('Orgchart\Position')) {
			include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
		}
		if(!class_exists('Orgchart\Group')) {
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

    private function getHeaders()
    {
        $header  = 'MIME-Version: 1.0';
        $header .= "\r\nContent-type: text/html; charset=iso-8859-1";
        if($this->emailSender == '') {
            $header .= "\r\nFrom: {$this->emailFrom}";
        }
        else {
            $header .= "\r\nSender: {$this->emailFrom}";
            $header .= "\r\nFrom: {$this->emailSender}";
            $header .= "\r\nReply-To: {$this->emailSender}";
        }
        if(count($this->emailCC) > 0) {
            $header .= "\r\nCc: ";
            foreach($this->emailCC as $cc) {
                $header .= "$cc, ";
            }
            $header = rtrim($header, ', ');
        }
        if(count($this->emailBCC) > 0) {
            $header .= "\r\nBcc: ";
            foreach($this->emailBCC as $bcc) {
                $header .= "$bcc, ";
            }
            $header = rtrim($header, ', ');
        }

        return $header;
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
        $this->emailBody = '<html><body style="font-family: verdana; font-size: 12px">' . $i . '<br /><br />--- THIS IS AN AUTOMATED MESSAGE ---</body></html>';
    }

    public function addRecipient($i)
    {
        if(preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0) {
            return false;
        }

        if($this->emailRecipient == '') {
            $this->emailRecipient = $i;
        }
        else {
            $this->emailRecipient .= ", $i";
        }
        return true;
    }

    public function addPositionRecipient($positionID)
    {
    	if($this->orgchartInitialized == false) {
    		$this->initOrgchart();    		
    	}
    	$employees = $this->position->getEmployees($positionID);
    	foreach($employees as $emp) {
    		$res = $this->employee->getAllData($emp['empUID'], 6);
    		$this->addRecipient($res[6]['data']);
    	}
    }

    public function addGroupRecipient($groupID)
    {
    	if($this->orgchartInitialized == false) {
    		$this->initOrgchart();    		
    	}
    	$positions = $this->group->listGroupPositions($groupID);
    	foreach($positions as $pos) {
    		$this->addPositionRecipient($pos['positionID']);
    	}

    	$employees = $this->group->listGroupEmployees($groupID);
    	foreach($employees as $emp) {
    		$res = $this->employee->getAllData($emp['empUID'], 6);
    		$this->addRecipient($res[6]['data']);
    	}
    }

    public function addCC($i)
    {
        if(preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0) {
            return false;
        }

        $this->emailCC[] = $i;
        return true;
    }

    public function addBCC($i)
    {
        if(preg_match('/(\w+@[a-zA-Z_)+?\.[a-zA-Z]{2,6})/', $i) == 0) {
            return false;
        }
    
        $this->emailBCC[] = $i;
        return true;
    }

    public function sendMail()
    {
        $currDir = dirname(__FILE__);

        if(isset(Config::$emailCC) && count(Config::$emailCC) > 0) {
            foreach(Config::$emailCC as $recipient) {
                $this->addCC($recipient);
            }
        }
        if(isset(Config::$emailBCC) && count(Config::$emailBCC) > 0) {
            foreach(Config::$emailBCC as $recipient) {
                $this->addBCC($recipient);
            }
        }
        $email['recipient'] = $this->emailRecipient;
        $email['subject'] = $this->emailSubject;
        $email['body'] = $this->emailBody;
        $email['headers'] = $this->getHeaders();

        $emailCache = serialize($email);
        $emailQueueName = sha1($emailCache . mt_rand(0, 9999999));
        if(strlen(trim($emailCache)) == 0) {
            trigger_error('Mail error: ' . $this->emailSubject);
            return false;
        }
        file_put_contents($currDir.'/templates_c/mailer/' . $emailQueueName, $emailCache);

        if(strtoupper(substr(php_uname('s'), 0, 3)) == 'WIN'){
            $shell = new COM('WScript.Shell');
            $shell->Run("php {$currDir}/mailer/mailer.php {$emailQueueName}", 0, false);
        }
        else {
            exec("php mailer/mailer.php {$emailQueueName} > /dev/null &");
        }
    }
}
