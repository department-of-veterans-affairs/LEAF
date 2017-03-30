<?php
/************************
    Template for custom events
    Date Created: August 12, 2011
    Updated: August 12, 2011

    Description:
    Template for events triggered by RMC workflow actions
*/

class CustomEvent_[YOUR EVENT ID]
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

    public function execute()
    {
        // Your custom event goes here. Below is an example of an email notification
        
        // Retrieve the service name
        $vars = array(':recordID' => $this->eventInfo['recordID']);
        $record = $this->db->prepared_query('SELECT * FROM records
        											LEFT JOIN services USING (serviceID)
        											WHERE recordID=:recordID', $vars);

        $this->email->setSubject('Action for #' . $this->eventInfo['recordID'] . ' in ' . $record[0]['service']);

        include_once '../form.php'; // events are invoked from ./api/, so the context is ./api  Except for the submit event
        $form = new Form($this->db, $this->login);
        
        // Get data from a field
        $data_numFTE = $form->getIndicator(230, 1, $this->eventInfo['recordID']);
        $value = $data_numFTE[230]['value'];

        $emailBody = "Request ID#: {$this->eventInfo['recordID']}\r\nRequest title: {$record[0]['title']}\r\nRequest status: {$record[0]['lastStatus']}\r\n\r\n";
        $emailBody .= "View Request: {$this->siteRoot}?a=printview&recordID={$this->eventInfo['recordID']}\r\n\r\n";

        $this->email->setBody($emailBody);

        // CC service chief
        $vars = array(':serviceID' => $record[0]['serviceID']);
        $chiefs = $this->db->prepared_query('SELECT * FROM service_chiefs
                								WHERE serviceID=:serviceID
        											AND active=1', $vars);
        foreach($chiefs as $chief) {
            $dirRes = $this->dir->lookupLogin($chief['userID']);
            $this->email->addRecipient($dirRes[0]['Email']);
        }

        // email original requestor
        $tmp = $this->dir->lookupLogin($record[0]['userID']);
        $this->email->addRecipient($tmp[0]['Email']);

        $this->email->sendMail();
    }
}

?>