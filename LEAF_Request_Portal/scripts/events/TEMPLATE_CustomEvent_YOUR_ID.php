<?php
/************************
    Template for custom events
    Date Created: August 12, 2011
    Updated: August 12, 2011

    Description:
    Template for events triggered by RMC workflow actions
*/

namespace Portal;

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

    /**
     * Execute custom action
     * @throws Exception
     */
    public function execute()
    {
        // Your custom event goes here. Below is an example of an email notification

        // Retrieve the service name
        $vars = array(':recordID' => $this->eventInfo['recordID']);
        $record = $this->db->prepared_query('SELECT * FROM records
        											LEFT JOIN services USING (serviceID)
        											WHERE recordID=:recordID', $vars);

        $form = new Form($this->db, $this->login);

        // Get data from a field
        $data_numFTE = $form->getIndicator(230, 1, $this->eventInfo['recordID']);
        $value = $data_numFTE[230]['value'];

        //you can pass whatever you like to the template here
        $this->email->addSmartyVariables(array(
            "truncatedTitle" => $record[0]['title'],
            "fullTitle" => $record[0]['title'],
            "recordID" => $this->eventInfo['recordID'],
            "service" => $record[0]['service'],
            "siteRoot" => $this->siteRoot
        ));
        $this->email->setTemplateByLabel("Custom Template Label");//this string would match to the label in the email table

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

        $this->email->sendMail($this->eventInfo['recordID']);
    }
}
