<?php
/************************
    Template for custom events
    Date Created: August 12, 2011
    Updated: August 12, 2011

    Description:
    Template for events triggered by RMC workflow actions
*/

namespace Portal;
use App\Leaf\Db;

class CustomEvent_LeafSecure_DeveloperConsole
{
    private $db;        // Object, Database connection
    private $login;     // Object, Login information for the current user
    private $dir;       // Object, Phone directory lookup
    private $email;     // Object, Email control
    private $eventInfo; // Array, The event info that triggers this event
                        //   (recordID, workflowID, stepID, actionType, comment)
    private $siteRoot;  // String, URL to the root directory

    function __construct($db, $login, $dir, $email, $siteRoot, $eventInfo)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dir = $dir;
        $this->email = $email;
        $this->siteRoot = $siteRoot;
        $this->eventInfo = $eventInfo;
    }

    /**
     * Execute custom action
     * @throws Exception
     */
    public function execute()
    {
        // get the request initiator
        $vars = array(':recordID' => $this->eventInfo['recordID']);
        $res = $this->db->prepared_query('SELECT userID FROM records WHERE recordID=:recordID', $vars);

        // get the initiator's empUID
        $oc_db = OC_DB;
        $login = new \Orgchart\Login($oc_db, $oc_db);
        $employee = new \Orgchart\Employee($oc_db, $login);

        $empData = $employee->lookupLogin($res[0]['userID']);

        // update orgchart
        $vars = array(':UID' => $empData[0]['empUID'],
                    ':indicatorID' => 27,
                    ':data' => 'Yes',
                    ':timestamp' => time(),
                    ':author' => 'DevConsoleWorkflow'
        );

        $oc_db->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, timestamp, author)
                                          VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                                          ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author', $vars);

        $vars = array(':UID' => $empData[0]['empUID'],
                    ':indicatorID' => 28,
                    ':data' => "{$this->siteRoot}?a=printview&recordID={$this->eventInfo['recordID']}",
                    ':timestamp' => time(),
                    ':author' => 'DevConsoleWorkflow'
        );

        $oc_db->prepared_query('INSERT INTO employee_data (empUID, indicatorID, data, timestamp, author)
                              VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                              ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author', $vars);
    }
}
