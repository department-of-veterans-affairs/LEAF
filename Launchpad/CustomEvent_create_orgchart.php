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

class CustomEvent_create_orgchart
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
    private static $pathID = 18;
    private static $coachID = 19;
    private static $projectManagerID = 6;
    private static $member1ID = 43;
    private static $member2ID = 44;
    private static $member3ID = 33;
    private static $member4ID = 42;

    //TODO fill out these config variables
    private static $orgchartConfigTable = '';
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

    private function addAdmin($empUID)
    {
        if(!is_numeric($empUID)) {
            return false;
        }
        $coachData = $this->form->employee->lookupEmpUID($empUID);
        $coachEmail = $this->form->employee->getAllData($empUID, 6)[6]['data'];
        if(count($coachData) > 0) {
            $vars = array(':userName' => $coachData[0]['userName'],
                          ':lastName' => $coachData[0]['lastName'],
                          ':firstName' => $coachData[0]['firstName'],
                          ':middleName' => $coachData[0]['middleName']);
            $this->newDB->prepared_query('INSERT INTO employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, AD_objectGUID)
                                        VALUES (null, :userName, :lastName, :firstName, :middleName, "", "", "")', $vars);
            $lastEmpUID = $this->newDB->getLastInsertID();

            $res = $this->newDB->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, author)
                                            VALUES (:empUID, :indicatorID, :data, "system")
                                            ON DUPLICATE KEY UPDATE data=:data', array(':empUID' => $lastEmpUID, ':indicatorID' => 6, ':data' => $coachEmail));

            $vars = array(':userName' => $coachData[0]['userName']);
            $res = $this->newDB->prepared_query('SELECT * FROM employee
                                                WHERE userName=:userName', $vars);
            $varsEmp = array(':empUID' => $res[0]['empUID']);
            $this->newDB->prepared_query('INSERT INTO relation_group_employee (groupID, empUID)
                                        VALUES (1, :empUID)', $varsEmp);
        }
    }

    public function execute()
    {
        include_once __DIR__.'/../../form.php'; // events are invoked from ./api/, so the context is ./api  Except for the submit event
        $this->form = new Form($this->db, $this->login);
        
        $rootPath = $this->form->getIndicator(self::$rootPathID, 1, $this->eventInfo['recordID'])[self::$rootPathID]['value'];
        $server = $this->form->getIndicator(self::$serverID, 1, $this->eventInfo['recordID'])[self::$serverID]['value'];
        $path = $this->form->getIndicator(self::$pathID, 1, $this->eventInfo['recordID'])[self::$pathID]['value'];
        $coach = $this->form->getIndicator(self::$coachID, 1, $this->eventInfo['recordID'])[self::$coachID]['value'];
        $projectManager = $this->form->getIndicator(self::$projectManagerID, 1, $this->eventInfo['recordID'])[self::$projectManagerID]['value'];
        $member1 = $this->form->getIndicator(self::$member1ID, 1, $this->eventInfo['recordID'])[self::$member1ID]['value'];
        $member2 = $this->form->getIndicator(self::$member2ID, 1, $this->eventInfo['recordID'])[self::$member2ID]['value'];
        $member3 = $this->form->getIndicator(self::$member3ID, 1, $this->eventInfo['recordID'])[self::$member3ID]['value'];
        $member4 = $this->form->getIndicator(self::$member4ID, 1, $this->eventInfo['recordID'])[self::$member4ID]['value'];
        
        if($rootPath == ''
            || $path == ''
//            || $resOU == ''
            || $coach == '') {
            exit();
        }
        
        // check if site already exists
        $rootPath = trim($rootPath, '/');
        $path = trim($path, '/');
        $path = '/' . $rootPath . '/' . $path . '/';
        $vars = array(':path' => $path);
        $res = $this->db->prepared_query('SELECT * FROM ' . self::$orgchartConfigTable . '
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
        $vars = array(':name' => $path, 
                        ':url' => self::$leafURL . $path, 
                        ':database_name' => $dbName, 
                        ':path' => $path, 
                        ':launchpad_id' => $this->eventInfo['recordID'], 
                        ':upload_directory' => $path . 'UPLOADS/', 
                        ':active_directory_path' => '[]', 
                        ':title' => 'Organizational Chart', 
                        ':city' => '', 
                        ':adminLogonName' => self::$adminLogonName, 
                        ':libs_path' => '',
                        ':leaf_secure' => 0);
        $this->db->prepared_query('INSERT INTO ' . self::$orgchartConfigTable . ' 
                                        (name, url, database_name, path, launchpad_id, upload_directory, active_directory_path, title, city, adminLogonName, libs_path, leaf_secure) 
                                        VALUES 
                                        (:name, :url, :database_name, :path, :launchpad_id, :upload_directory, :active_directory_path, :title, :city, :adminLogonName, :libs_path, :leaf_secure);', $vars);
        $this->db->query('CREATE DATABASE `' . $dbName . '`');
        $this->db->query('GRANT ALL PRIVILEGES ON ' . $dbName . '.* TO "' . self::$dbUser . '"@"%"');
        
        $this->newDB = new DB(self::$dbHost, self::$dbUser, self::$dbPass, $dbName);
        // initialize database
        $boilerplate = file_get_contents(__DIR__.'/../../../LEAF_Nexus/orgchart_boilerplate_empty.sql');
        $this->newDB->query($boilerplate);
        // add initial admin
        
        $res = $this->newDB->prepared_query('INSERT INTO employee (empUID, userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, AD_objectGUID)
                                        VALUES (1, "' . self::$adminLogonName . '", "", "", "", "", "", "")', array());//TODO fill in name
        $res = $this->newDB->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, author)
                                        VALUES (:empUID, :indicatorID, :data, "system")
                                            ON DUPLICATE KEY UPDATE data=:data', array(':empUID' => 1, ':indicatorID' => 6, ':data' => ''));//TODO fill in email
        $res = $this->newDB->prepared_query('INSERT INTO relation_group_employee (groupID, empUID)
                                        VALUES (1, 1)', array());
        //TODO add any extra admins here
        $res = $this->newDB->prepared_query('UPDATE SETTINGS SET DATA=RAND() WHERE SETTING="salt"', array());

        // add leaf coach and team members as admins
        $this->addAdmin($coach);
        $this->addAdmin($projectManager);
        $this->addAdmin($member1);
        $this->addAdmin($member2);
        $this->addAdmin($member3);
        $this->addAdmin($member4);

        if(strtoupper(substr(php_uname('s'), 0, 3)) == 'WIN'){
            $shell = new COM('WScript.Shell');
            $shell->Run("php " . __DIR__ . "/../../../LEAF_Nexus/scripts/updateDatabase.php", 0, false);
            $shell->Run("php " . __DIR__ . "/../../../LEAF_Nexus/scripts/maintenance.php", 0, false);
        }
        else {
            exec("php " . __DIR__ . "/../../../LEAF_Nexus/scripts/updateDatabase.php > /dev/null &");
            exec("php " . __DIR__ . "/../../../LEAF_Nexus/scripts/maintenance.php > /dev/null &");
        }
    }
}

