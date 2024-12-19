<?php
/************************
    Template for custom events
    Date Created: August 12, 2011
    Updated: August 12, 2011

    Description:
    Template for events triggered by RMC workflow actions
*/

namespace Portal;

class CustomEvent_LeafSecure_Certified
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
        $vars = array(':time' => time());
        $this->db->prepared_query("UPDATE settings SET data = :time WHERE setting = 'leafSecure'", $vars);
    }
}
