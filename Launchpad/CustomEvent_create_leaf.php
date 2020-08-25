<?php
/************************
    Template for custom events
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: August 12, 2011
    Updated: August 12, 2011

    Description:
    Template for events triggered by RMC workflow actions
 */

set_time_limit(300);

class CustomEvent_create_leaf
{
    private $db;        // Object, Database connection
    private $login;     // Object, Login information for the current user 
    private $dir;       // Object, Phone directory lookup
    private $email;     // Object, Email control
    private $eventInfo; // Array, The event info that triggers this event
                        //   (recordID, workflowID, stepID, actionType, comment) 
    private $siteRoot;  // String, URL to the root directory
    
    private $form;
    private $newDB;

    private static $rootPathID = 22;
    private static $serverID = 17;
    private static $OCpathID = 18;
    private static $pathID = 21;
    private static $coachID = 19;
    private static $projectManagerID = 6;
    private static $member1ID = 43;
    private static $member2ID = 44;
    private static $member3ID = 33;
    private static $member4ID = 42;

    //TODO fill out these config variables
    private static $orgchartConfigTable = '';
    private static $portalConfigTable = '';
    private static $dbHost = '';
    private static $dbUser = '';
    private static $dbPass = '';
    private static $adminLogonName = '';
    private static $leafURL = '';

    function __construct($db, $login, $dir, $email, $siteRoot, $eventInfo)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dir = $dir;
        $this->email = $email;
        $this->siteRoot = $siteRoot;
        $this->eventInfo = $eventInfo;
    }


    private function addAdmin($coach)
    {
        if(!is_numeric($coach)) {
            return false;
        }
        $coachData = $this->form->employee->lookupEmpUID($coach);
	if(count($coachData) > 0) {
            $this->newDB->beginTransaction();		
            $vars = array(':userName' => $coachData[0]['userName']);
            $this->newDB->prepared_query('INSERT INTO users (userID, groupID)
					VALUES (:userName, 1)', $vars);
	    $this->newDB->commitTransaction();
        }
    }

    public function execute()
    {
        include_once __DIR__.'/../../form.php'; // events are invoked from ./api/, so the context is ./api  Except for the submit event
        include_once __DIR__.'/../../../libs/smarty/Smarty.class.php';
        $this->form = new Form($this->db, $this->login);

        $configTpl = new Smarty;
        $configTpl->setTemplateDir(__DIR__.'/');
        $configTpl->setCaching(Smarty::CACHING_OFF);
        $rootPath = $this->form->getIndicator(self::$rootPathID, 1, $this->eventInfo['recordID'])[self::$rootPathID]['value'];
        $server = $this->form->getIndicator(self::$serverID, 1, $this->eventInfo['recordID'])[self::$serverID]['value'];
        $path = $this->form->getIndicator(self::$pathID, 1, $this->eventInfo['recordID'])[self::$pathID]['value'];
        $OCpath = $this->form->getIndicator(self::$OCpathID, 1, $this->eventInfo['recordID'])[self::$OCpathID]['value'];
        $coach = $this->form->getIndicator(self::$coachID, 1, $this->eventInfo['recordID'])[self::$coachID]['value'];
        $projectManager = $this->form->getIndicator(self::$projectManagerID, 1, $this->eventInfo['recordID'])[self::$projectManagerID]['value'];
        $member1 = $this->form->getIndicator(self::$member1ID, 1, $this->eventInfo['recordID'])[self::$member1ID]['value'];
        $member2 = $this->form->getIndicator(self::$member2ID, 1, $this->eventInfo['recordID'])[self::$member2ID]['value'];
        $member3 = $this->form->getIndicator(self::$member3ID, 1, $this->eventInfo['recordID'])[self::$member3ID]['value'];
        $member4 = $this->form->getIndicator(self::$member4ID, 1, $this->eventInfo['recordID'])[self::$member4ID]['value'];
        if($rootPath == ''
            || $OCpath == ''
            || $path == ''
            || $coach == '') {
            exit();
        }
/*        $resOU = explode("\n", $resOU);
        $activeDirOUs = '';
        foreach($resOU as $ou) {
            $ou = trim($ou);
            $activeDirOUs .= "'{$ou}',";
        }
        $activeDirOUs = trim($activeDirOUs, ',');
        */
        // check if site already exists
        $OCpath = trim($OCpath, '/');
        $rootPath = trim($rootPath, '/');
        $path = trim($path, '/');
        $path = '/' . $rootPath . '/' . $path . '/';
        $vars = array(':path' => $path);
        $res = $this->db->prepared_query('SELECT * FROM ' . self::$portalConfigTable . '
                                            WHERE path=:path', $vars);
        if(count($res) > 0) {
            exit();
        }
        // generate and write config file
        $dbName = str_replace('/', '_', trim($path, '/'));

        // make sure db name is a contiguous sting
        if(strpos($dbName, ' ') !== false) {
            return 0;
        }

        $vars = array(':path' => '/' . $rootPath . '/' . $OCpath . '/');
        $res = $this->db->prepared_query('SELECT * FROM ' . self::$orgchartConfigTable . '
                                            WHERE path=:path', $vars);
        $orgchartID = 0;
        if(count($res) > 0) {
            $orgchartID = $res[0]['id'];
        }
        $vars = array(':name' => $path, 
                        ':url' => self::$leafURL . $path,
                        ':database_name' => $dbName,
                        ':path' => $path,
                        ':launchpad_id' => $this->eventInfo['recordID'],
                        ':upload_directory' => $path . 'UPLOADS/',
                        ':active_directory_path' => '',
                        ':title' => 'New LEAF Site',
                        ':city' => '',
                        ':adminLogonName' => self::$adminLogonName,
                        ':libs_path' => '',
                        ':descriptionID' => 16,
                        ':emailPrefix' => 'Resources: ',
                        ':emailCC' => '[]',
                        ':emailBCC' => '[]',
                        ':orgchart_id' => $orgchartID,
                        ':orgchart_tags' => "'{$dbName}'",
                        ':leaf_secure' => 0);
        $this->db->prepared_query('INSERT INTO ' . self::$portalConfigTable . ' 
                                        (name, url, database_name, path, launchpad_id, upload_directory, active_directory_path, title, city, adminLogonName, libs_path, descriptionID, emailPrefix, emailCC, emailBCC, orgchart_id, orgchart_tags, leaf_secure) 
                                        VALUES 
                                        (:name, :url, :database_name, :path, :launchpad_id, :upload_directory, :active_directory_path, :title, :city, :adminLogonName, :libs_path, :descriptionID, :emailPrefix, :emailCC, :emailBCC, :orgchart_id, :orgchart_tags, :leaf_secure);', $vars);
        
        $this->db->query('CREATE DATABASE `' . $dbName . '`');
        $this->db->query('GRANT ALL PRIVILEGES ON ' . $dbName . '.* TO "' . self::$dbUser . '"@"%"');

        $this->newDB = new DB(self::$dbHost, self::$dbUser, self::$dbPass, $dbName);

        // initialize database
        $boilerplate = file_get_contents(__DIR__.'/../../resource_database_boilerplate.sql');
        $this->newDB->query($boilerplate);

        // add initial admin
	$vars = array();

        $this->newDB->beginTransaction();
        $res = $this->newDB->prepared_query('INSERT INTO users (userID, groupID)
                                        VALUES ("' . self::$adminLogonName . '", 1)', $vars);
        //TODO add any extra admins here

	$this->newDB->commitTransaction();
       
	
        // add leaf coach
        $this->addAdmin($coach);
        $this->addAdmin($projectManager);
        $this->addAdmin($member1);
        $this->addAdmin($member2);
        $this->addAdmin($member3);
        $this->addAdmin($member4);

        if(strtoupper(substr(php_uname('s'), 0, 3)) == 'WIN'){
            $shell = new COM('WScript.Shell');
            $shell->Run("php " . __DIR__ . "/../updateDatabase.php " . $path, 0, false);
        }
        else {
            exec("php " . __DIR__ . "/../updateDatabase.php " . $path . " > /dev/null &");
        }
    }
}
