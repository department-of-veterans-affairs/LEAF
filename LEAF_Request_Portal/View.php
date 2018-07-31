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
        // indicator 16 for Request Summary
        /*$res = $this->db->prepared_query('SELECT *, approvals.userID FROM records
                                    LEFT JOIN (SELECT data, recordID FROM data
                                                WHERE indicatorID=16
                                                        AND series=1) j0 USING (recordID)
                                    LEFT JOIN approvals USING (recordID)
                                    LEFT JOIN groups USING (groupID)
                                    LEFT JOIN services USING (serviceID)
                                    WHERE records.recordID=:recordID
                                    ORDER BY time', $vars);*/

        $res = $this->db->prepared_query('SELECT * FROM action_history
        									LEFT JOIN dependencies USING (dependencyID)
        									LEFT JOIN actions USING (actionType)
        									WHERE recordID=:recordID
                                            ORDER BY time ASC', $vars);

        foreach ($res as $tmp)
        {
            if ($tmp['userID'] != '')
            {
                $user = $dir->lookupLogin($tmp['userID']);
                $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $tmp['userID'];
                $tmp['userName'] = $name;
            }
            $result[] = $tmp;
        }

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
