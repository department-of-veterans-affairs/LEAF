<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Views for forms
    Date Created: September 25, 2008

*/

class View
{
    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function buildViewStatus($recordID)
    {
        // check privileges
        require_once 'form.php';
        $form = new Form($this->db, $this->login);
        if (!$form->hasReadAccess($recordID))
        {
            return 0;
        }

        $result = array();
        require_once 'VAMC_Directory.php';
        $dir = new VAMC_Directory;

        $vars = array(':recordID' => $recordID);

        $res = $this->db->prepared_query('SELECT * FROM action_history
        									LEFT JOIN dependencies USING (dependencyID)
                                            LEFT JOIN workflow_steps USING (stepID)
        									LEFT JOIN actions USING (actionType)
        									WHERE recordID=:recordID
                                            ORDER BY time ASC', $vars);

        foreach ($res as $tmp)
        {
            $packet = [];
            $packet['time'] = $tmp['time'];
            if($tmp['stepTitle'] != ''
                && $tmp['dependencyID'] < 0) {
                $packet['description'] = $tmp['stepTitle'] . ': ' . $tmp['actionText'];
            }
            else {
                $packet['description'] = $tmp['description'] . ': ' . $tmp['actionText'];
            }
            if($tmp['description'] == ''
                && $tmp['actionText'] == ''
            ) {
                $packet['description'] = 'Action';
            }
            $packet['comment'] = $tmp['comment'];
            if ($tmp['userID'] != '')
            {
                $user = $dir->lookupLogin($tmp['userID']);
                $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $tmp['userID'];
                $packet['userName'] = $name;
            }
            $result[] = $packet;
        }

        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT signatureID, signature, recordID, stepID, dependencyID, userID, timestamp, stepTitle FROM signatures
                                            LEFT JOIN workflow_steps USING (stepID)
	    									WHERE recordID=:recordID', $vars);

        foreach ($res as $tmp)
        {
            $packet = [];
            $packet['time'] = $tmp['timestamp'];
            $packet['description'] = $tmp['stepTitle'] . ': Digitally Signed';
            $packet['comment'] = 'Signature Hash: ' . $tmp['signature'];

            if ($tmp['userID'] != '')
            {
                $user = $dir->lookupLogin($tmp['userID']);
                $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $tmp['userID'];
                $packet['userName'] = $name;
            }
            $result[] = $packet;
        }

        usort($result, function($a, $b) {
            if($a['time'] == $b['time']) {
                return 0;
            }
            else if($a['time'] > $b['time']) {
                return 1;
            }
            else {
                return -1;
            }
        });
        return $result;
    }

    public function buildViewBookmarks($userID)
    {
        $var = array(':bookmarkID' => 'bookmark_' . $userID);

        $res = $this->db->prepared_query('SELECT * FROM tags
        									LEFT JOIN records USING (recordID)
        									LEFT JOIN (SELECT recordID, actionType, dependencyID FROM action_history
        												ORDER BY actionID DESC) lj1 USING (recordID)
        									LEFT JOIN actions USING (actionType)
        									LEFT JOIN step_dependencies USING (dependencyID)
        									LEFT JOIN workflow_steps USING (stepID)
        									WHERE tag = :bookmarkID
        									GROUP BY recordID', $var);

        return $res;
    }
}
