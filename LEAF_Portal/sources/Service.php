<?php
/************************
    Service controls
    Date Created: September 8, 2016

*/

class Service
{
    private $db;
    private $login;
    public $siteRoot = '';

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://{$_SERVER['HTTP_HOST']}" . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    function addService($groupName, $parentGroupID = null)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required';
    	}
    	
    	$groupName = trim($groupName);
    	
    	if($groupName == '') {
    		return 'Name cannot be blank';
    	}
    	$newID = -99;
		$res = $this->db->prepared_query('SELECT * FROM services
											WHERE serviceID < 0
											ORDER BY serviceID ASC', array());
		if(isset($res[0]['serviceID'])) {
			$newID = $res[0]['serviceID'] - 1;
		}
		else {
			$newID = -1;
		}

    	$vars = array(':serviceID' => $newID,
    				  ':service' => $groupName,
    				  ':groupID' => $parentGroupID);
    	$res = $this->db->prepared_query("INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                                            VALUES (:serviceID, :service, '', :groupID)", $vars);
    	return $newID;
    }
    
    function removeService($groupID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required';
    	}
    	$vars = array(':groupID' => $groupID);
    	$this->db->prepared_query("DELETE FROM services WHERE serviceID=:groupID", $vars);
    	$this->db->prepared_query("DELETE FROM service_chiefs WHERE serviceID=:groupID", $vars);
    	
    	return 1;
    }

    function addMember($groupID, $member)
    {
   		if(is_numeric($groupID) && $member != '') {
   			$vars = array(':userID' => $member,
   					':groupID' => $groupID);
   			$res = $this->db->prepared_query("INSERT INTO service_chiefs (serviceID, userID, locallyManaged)
                                                   VALUES (:groupID, :userID, 1)", $vars);
   		}
    	
    	return 1;
    }
    
    function removeMember($groupID, $member)
    {
    	if(is_numeric($groupID) && $member != '') {
    		$vars = array(':userID' => $member,
    					  ':groupID' => $groupID);
    		$res = $this->db->prepared_query("SELECT * FROM service_chiefs WHERE userID=:userID AND serviceID=:groupID", $vars);

    		if($res[0]['locallyManaged'] == 1) {
    			$vars = array(':userID' => $member,
    					':groupID' => $groupID);
    			$res = $this->db->prepared_query("DELETE FROM service_chiefs WHERE userID=:userID AND serviceID=:groupID", $vars);
    		}
    		else {
    			$vars = array(':userID' => $member,
    					':groupID' => $groupID);
    			$res = $this->db->prepared_query("UPDATE service_chiefs SET active=0, locallyManaged=1
    												WHERE userID=:userID AND serviceID=:groupID", $vars);
    		}
    	}
    	
    	return 1;
    }

    function getMembers($groupID)
    {
    	if(!is_numeric($groupID)) {
    		return null;
    	}
    	$vars = array(':groupID' => $groupID);
    	$res = $this->db->prepared_query("SELECT * FROM service_chiefs WHERE serviceID=:groupID ORDER BY userID", $vars);
    
    	$members = array();
    	if(count($res) > 0) {
    		require_once '../VAMC_Directory.php';
    		$dir = new VAMC_Directory();
    		foreach ($res as $member) {
    			$dirRes = $dir->lookupLogin($member['userID']);
    
    			if (isset($dirRes[0])) {
    				$temp = $dirRes[0];
    				$temp['locallyManaged'] = $member['locallyManaged'];
    				$temp['active'] = $member['active'];
    				$members[] = $temp;
    			}
    		}
    	}
    
    	return $members;
    }

    function getQuadrads()
    {
    	$res = $this->db->query('SELECT groupID, name FROM services
    								LEFT JOIN groups USING (groupID)
    								WHERE groupID IS NOT NULL
    								GROUP BY groupID');
    
    	return $res;
    }
    
    function getGroups()
    {
    	$res = $this->db->query('SELECT * FROM services ORDER BY service ASC');
    
    	return $res;
    }
    
    function getGroupsAndMembers()
    {
    	$groups = $this->getGroups();
    
    	$list = array();
    	foreach($groups as $group) {
    		$group['members'] = $this->getMembers($group['serviceID']);
    		$list[] = $group;
    	}
    
    	return $list;
    }
}
