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

class CustomEvent_check_orgchart_exists
{
    private $db;        // Object, Database connection
    private $login;     // Object, Login information for the current user 
    private $dir;       // Object, Phone directory lookup
    private $email;     // Object, Email control
    private $eventInfo; // Array, The event info that triggers this event
                        //   (recordID, workflowID, stepID, actionType, comment) 
    private $siteRoot;  // String, URL to the root directory
    
    private $form;
    private $formWorkflow;
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

    function __construct($db, $login, $dir, $email, $siteRoot, $eventInfo)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dir = $dir;
        $this->email = $email;
        $this->siteRoot = $siteRoot;
        $this->eventInfo = $eventInfo;
    }


    public function execute()
    {
        include_once __DIR__.'/../../form.php'; // events are invoked from ./api/, so the context is ./api  Except for the submit event
        include_once __DIR__.'/../../FormWorkflow.php'; // events are invoked from ./api/, so the context is ./api  Except for the submit event
        $this->form = new Form($this->db, $this->login);
        $this->formWorkflow = new FormWorkflow($this->db, $this->login, $this->eventInfo['recordID']);

        $rootPath = $this->form->getIndicator(self::$rootPathID, 1, $this->eventInfo['recordID'])[self::$rootPathID]['value'];
        $server = $this->form->getIndicator(self::$serverID, 1, $this->eventInfo['recordID'])[self::$serverID]['value'];
        $path = $this->form->getIndicator(self::$pathID, 1, $this->eventInfo['recordID'])[self::$pathID]['value'];
        $coach = $this->form->getIndicator(self::$coachID, 1, $this->eventInfo['recordID'])[self::$coachID]['value'];
        $projectManager = $this->form->getIndicator(self::$projectManagerID, 1, $this->eventInfo['recordID'])[self::$projectManagerID]['value'];
        $member1 = $this->form->getIndicator(self::$member1ID, 1, $this->eventInfo['recordID'])[self::$member1ID]['value'];
        $member2 = $this->form->getIndicator(self::$member2ID, 1, $this->eventInfo['recordID'])[self::$member2ID]['value'];
        $member3 = $this->form->getIndicator(self::$member3ID, 1, $this->eventInfo['recordID'])[self::$member3ID]['value'];
        $member4 = $this->form->getIndicator(self::$member4ID, 1, $this->eventInfo['recordID'])[self::$member4ID]['value'];
        if($server == ''
            || $rootPath == ''
            || $path == ''
//            || $resOU == ''
            || $coach == '') {
            $this->formWorkflow->setStep(1, true);
            throw new Exception('Please make sure all fields in the technical setup area are filled out.');
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
            $this->formWorkflow->setStep(3, true);
        }

    }
}
