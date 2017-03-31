<?php
/************************
    Group
    Date Created: April 29, 2010

    Handler for user groups for the resource management web app
*/

class Group
{
    private $db;
    private $login;

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }
    
    function addGroup($groupName, $groupDesc = '', $parentGroupID = null)
    {
        $vars = array(':groupName' => $groupName,
                      ':groupDesc' => $groupDesc,
                      ':parentGroupID' => $parentGroupID);
        $res = $this->db->prepared_query("INSERT INTO groups (name, groupDescription, parentGroupID)
                                            VALUES (:groupName, :groupDesc, :parentGroupID)", $vars);
        return $this->db->getLastInsertID();
    }

    function removeGroup($groupID)
    {
        if($groupID != 1) {
            $vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query("SELECT * FROM groups WHERE groupID=:groupID", $vars);
            
            if(isset($res[0])
                && $res[0]['parentGroupID'] != null) {
                $this->db->prepared_query("DELETE FROM users WHERE groupID=:groupID", $vars);
                $this->db->prepared_query("DELETE FROM groups WHERE groupID=:groupID", $vars);
    
                return 1;
            }
        }

        return 'Cannot remove group.';
    }
    
    // return array of userIDs 
    function getMembers($groupID)
    {
        if(!is_numeric($groupID)) {
            return null;
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query("SELECT * FROM users WHERE groupID=:groupID ORDER BY userID", $vars);

        $members = array();
        if(count($res) > 0) {
            require_once '../VAMC_Directory.php';
            $dir = new VAMC_Directory();
            foreach ($res as $member) {
                $dirRes = $dir->lookupLogin($member['userID']);

                if (isset($dirRes[0])) {
                    $members[] = $dirRes[0];
                }
            }            
        }

        return $members;
    }

    function addMember($member, $groupIDs)
    {
        $groups = array();
        $tmp = explode(',', $groupIDs);
        foreach($tmp as $group) {
            if(is_numeric($group)) {
                $vars = array(':userID' => $member,
                              ':groupID' => $group);
                $res = $this->db->prepared_query("INSERT INTO users (userID, groupID)
                                                    VALUES (:userID, :groupID)", $vars);
            }
        }

    }

    function removeMember($member, $groupID)
    {
        if(is_numeric($groupID) && $member != '') {
            $vars = array(':userID' => $member,
                          ':groupID' => $groupID);
            $res = $this->db->prepared_query("DELETE FROM users WHERE userID=:userID AND groupID=:groupID", $vars);
            return 1;
        }
    }

    // exclude: 0 (no group), 24, (everyone), 16 (service chief)
    function getGroups()
    {
        $res = $this->db->query('SELECT * FROM groups WHERE groupID != 0 ORDER BY name ASC');
        
        return $res;
    }
    
    function getGroupsAndMembers()
    {
        $groups = $this->getGroups();
        
        $list = array();
        foreach($groups as $group) {
        	if($group['groupID'] > 0) {
        		$group['members'] = $this->getMembers($group['groupID']);
        		$list[] = $group;
        	}
        }

        return $list;
    }
}
