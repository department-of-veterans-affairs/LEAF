<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Service controls
    Date Created: September 8, 2016

*/

class Service
{
    public $siteRoot = '';

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://{$_SERVER['HTTP_HOST']}" . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    public function addService($groupName, $parentGroupID = null)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $groupName = trim($groupName);

        if ($groupName == '')
        {
            return 'Name cannot be blank';
        }
        $newID = -99;
        $res = $this->db->prepared_query('SELECT * FROM services
											WHERE serviceID < 0
											ORDER BY serviceID ASC', array());
        if (isset($res[0]['serviceID']))
        {
            $newID = $res[0]['serviceID'] - 1;
        }
        else
        {
            $newID = -1;
        }

        if (!is_null($parentGroupID))
        {
            $parentGroupID = (int)$parentGroupID;
        }
        $vars = array(':serviceID' => (int)$newID,
                      ':service' => $groupName,
                      ':groupID' => $parentGroupID, );
        $res = $this->db->prepared_query("INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                                            VALUES (:serviceID, :service, '', :groupID)", $vars);

        return $newID;
    }

    public function removeService($groupID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $vars = array(':groupID' => $groupID);
        $this->db->prepared_query('DELETE FROM services WHERE serviceID=:groupID', $vars);
        $this->db->prepared_query('DELETE FROM service_chiefs WHERE serviceID=:groupID', $vars);

        return 1;
    }

    public function addMember($groupID, $member)
    {
        if (is_numeric($groupID) && $member != '')
        {
            $vars = array(':empUID' => $member,
                    ':groupID' => $groupID, );
            $this->db->prepared_query('INSERT INTO service_chiefs (serviceID, empUID, locallyManaged)
                                                   VALUES (:groupID, :empUID, 1)', $vars);

            // check if this service is also an ELT
            $vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM services
   												WHERE serviceID=:groupID', $vars);
            // if so, update groups table
            if ($res[0]['groupID'] == $groupID)
            {
                $dir = new VAMC_Directory();
                $empRes = $dir->lookupEmpUID($member);
                $vars = array(':empUID' => $member,
                              ':userID' => $empRes[0]['userID'],
                              ':groupID' => $groupID, );
                $this->db->prepared_query('INSERT INTO users (empUID, userID, groupID)
												VALUES (:empUID, :userID, :groupID)', $vars);
            }
        }

        return 1;
    }

    public function removeMember($groupID, $member)
    {
        if (is_numeric($groupID) && $member != '')
        {
            $vars = array(':empUID' => $member,
                          ':groupID' => $groupID, );
            $res = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE empUID=:empUID AND serviceID=:groupID', $vars);

            if ($res[0]['locallyManaged'] == 1)
            {
                $vars = array(':empUID' => $member,
                        ':groupID' => $groupID, );
                $res = $this->db->prepared_query('DELETE FROM service_chiefs WHERE empUID=:empUID AND serviceID=:groupID', $vars);
            }
            else
            {
                $vars = array(':empUID' => $member,
                        ':groupID' => $groupID, );
                $res = $this->db->prepared_query('UPDATE service_chiefs SET active=0, locallyManaged=1
    												WHERE empUID=:empUID AND serviceID=:groupID', $vars);
            }

            // check if this service is also an ELT
            $vars = array(':groupID' => $groupID);
            $res = $this->db->prepared_query('SELECT * FROM services
   												WHERE serviceID=:groupID', $vars);
            // if so, update groups table
            if ($res[0]['groupID'] == $groupID)
            {
                $vars = array(':empUID' => $member,
                        ':groupID' => $groupID, );
                $this->db->prepared_query('DELETE FROM users
    										WHERE empUID=:empUID
    											AND groupID=:groupID', $vars);
            }
        }

        return 1;
    }

    public function getMembers($groupID)
    {
        if (!is_numeric($groupID))
        {
            return;
        }
        $vars = array(':groupID' => $groupID);
        $res = $this->db->prepared_query('SELECT * FROM service_chiefs WHERE serviceID=:groupID ORDER BY empUID', $vars);

        $members = array();
        if (count($res) > 0)
        {
            require_once '../VAMC_Directory.php';
            $dir = new VAMC_Directory();
            foreach ($res as $member)
            {
                $dirRes = $dir->lookupEmpUID($member['empUID']);

                if (isset($dirRes[0]))
                {
                    $temp = $dirRes[0];
                    $temp['locallyManaged'] = $member['locallyManaged'];
                    $temp['active'] = $member['active'];
                    $members[] = $temp;
                }
            }
        }

        return $members;
    }

    public function getQuadrads()
    {
        $res = $this->db->prepared_query('SELECT groupID, name FROM services
    								LEFT JOIN groups USING (groupID)
    								WHERE groupID IS NOT NULL
    								GROUP BY groupID
    								ORDER BY name', array());

        return $res;
    }

    public function getGroups()
    {
        $res = $this->db->prepared_query('SELECT * FROM services ORDER BY service ASC', array());

        return $res;
    }

    public function getGroupsAndMembers()
    {
        $groups = $this->getGroups();

        $list = array();
        foreach ($groups as $group)
        {
            $group['members'] = $this->getMembers($group['serviceID']);
            $list[] = $group;
        }

        return $list;
    }
}
