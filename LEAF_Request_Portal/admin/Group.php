<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Group
    Date Created: April 29, 2010

    Handler for user groups for the resource management web app
*/

if(!class_exists('DataActionLogger'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/dataActionLogger.php';
}

class Group
{
    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new \DataActionLogger($db, $login);
    }

    public function addGroup($groupName, $groupDesc = '', $parentGroupID = null)
    {
        $vars = array(':groupName' => $groupName,
                      ':groupDesc' => $groupDesc,
                      ':parentGroupID' => $parentGroupID, );
        $res = $this->db->prepared_query('INSERT INTO groups (name, groupDescription, parentGroupID)
                                            VALUES (:groupName, :groupDesc, :parentGroupID)', $vars);

        return $this->db->getLastInsertID();
    }

    public function removeGroup($groupID)
    {
        if ($groupID != 1)
        {
            $vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID=:groupID', $vars);

            if (isset($res[0])
                && $res[0]['parentGroupID'] == null)
            {
                $this->db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $vars);
                $this->db->prepared_query('DELETE FROM `groups` WHERE groupID=:groupID', $vars);

                return 1;
            }
        }

        return 'Cannot remove group.';
    }

    // return array of userIDs
    public function getMembers($groupID)
    {
        if (!is_numeric($groupID))
        {
            return;
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM users WHERE groupID=:groupID ORDER BY userID', $vars);

        $members = array();
        if (count($res) > 0)
        {
            require_once '../VAMC_Directory.php';
            $dir = new VAMC_Directory();
            foreach ($res as $member)
            {
                $dirRes = $dir->lookupLogin($member['userID']);

                if (isset($dirRes[0]))
                {
                    if($groupID == 1)
                    {
                      $dirRes[0]['primary_admin'] = $member['primary_admin'];  
                    }
                    $dirRes[0]['locallyManaged'] = $member['locallyManaged'];
                    $dirRes[0]['active'] = $member['active'];
                    
                    $members[] = $dirRes[0];
                }
            }
        }

        return $members;
    }

    public function addMember($member, $groupIDs)
    {
        $groups = array();
        $tmp = explode(',', $groupIDs);
        foreach ($tmp as $group)
        {
            if (is_numeric($group))
            {
                $vars = array(':userID' => $member,
                              ':groupID' => (int)$group, 
                              ':locallyManaged' => 1);
                $res = $this->db->prepared_query('INSERT INTO users (userID, groupID, locallyManaged)
                                                    VALUES (:userID, :groupID, :locallyManaged)', $vars);
                
                $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::EMPLOYEE, [
                    new \LogItem("users","userID", $member, $this->getEmployeeDisplay($member)),
                    new \LogItem("users", "groupID", $group, $this->getGroupName($group)) 
                ]);     
            }
        }
    }

    public function removeMember($member, $groupID)
    {
        if (is_numeric($groupID) && $member != '')
        {
            $vars = array(':userID' => $member,
                          ':groupID' => $groupID, );
            $res = $this->db->prepared_query('SELECT * FROM users WHERE userID=:userID AND groupID=:groupID', $vars);

            if ($res[0]['locallyManaged'] == 1
                || $groupID == 1)
            {
                $res = $this->db->prepared_query('DELETE FROM users WHERE userID=:userID AND groupID=:groupID', $vars);
            }
            else
            {
                $res = $this->db->prepared_query('UPDATE users SET active=0, locallyManaged=1
                                                    WHERE userID=:userID AND groupID=:groupID', $vars);
            }

            $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::EMPLOYEE, [
                new \LogItem("users", "userID", $member, $this->getEmployeeDisplay($member)),
                new \LogItem("users", "groupID", $groupID, $this->getGroupName($groupID)) 
            ]);

            return 1;
        }
    }

    // exclude: 0 (no group), 24, (everyone), 16 (service chief)
    public function getGroups()
    {
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID != 0 ORDER BY name ASC', array());

        return $res;
    }

    public function getGroupsAndMembers()
    {
        $groups = $this->getGroups();

        $list = array();
        foreach ($groups as $group)
        {
            if ($group['groupID'] > 0)
            {
                $group['members'] = $this->getMembers($group['groupID']);
                $list[] = $group;
            }
        }

        return $list;
    }

    /**
     * Returns formatted group name.
     * @param string $groupID       The group id to find the formatted name of
     * @return string 
     */
    public function getGroupName($groupId)
    {
        $vars = array(":groupID" => $groupId);
        $res = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID = :groupID', $vars);
        if($res[0] != null){
            return $res[0]["name"];
        }
        return "";
    }
    
    /**
     * Returns formatted Employee name.
     * @param string $employeeID        The id to create the display name of.
     * @return string 
     */
    private function getEmployeeDisplay($employeeID)
    {
        require_once '../VAMC_Directory.php';
     
        $dir = new VAMC_Directory();
        $dirRes = $dir->lookupLogin($employeeID);

        $empData = $dirRes[0];
        $empDisplay =$empData["firstName"]." ".$empData["lastName"];
        
        return $empDisplay;
    }

    /**
     * Returns Portal Group logs.
     * 
     * @param string $filterById        The id of the Group to find the logs of
     *
     * @return array 
     */
    public function getHistory($filterById)
    {
        return $this->dataActionLogger->getHistory($filterById, "groupID", \LoggableTypes::PORTAL_GROUP);
    }

    /**
     * Returns all history ids for all groups
     * 
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs()
    {
        return $this->dataActionLogger->getAllHistoryIDs("groupID", \LoggableTypes::PORTAL_GROUP);
    }
}
