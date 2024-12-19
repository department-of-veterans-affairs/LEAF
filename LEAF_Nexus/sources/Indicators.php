<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Indicator and privilege model for employee/position/group access
    Date: December 14, 2012

*/

namespace Orgchart;

class Indicators
{
    protected $db;

    protected $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function getIndicator($indicatorID)
    {
        $vars = array(':indicatorID' => $indicatorID);
        $res = $this->db->prepared_query('SELECT * FROM indicators
                                            WHERE indicatorID=:indicatorID', $vars);

        return isset($res[0]) ? $res[0] : false;
    }

    public function getPrivileges($indicatorID)
    {
        if (!is_numeric($indicatorID))
        {
            return array();
        }
        $vars = array(':indicatorID' => $indicatorID);
        $res = $this->db->prepared_query('SELECT * FROM indicator_privileges
                                            WHERE indicatorID=:indicatorID', $vars);

        return $res;
    }

    /**
     * Toggles the permission for a given indicator and subject
     * @param int $indicatorID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     */
    public function togglePermission($indicatorID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($indicatorID) || !is_numeric($UID))
        {
            return;
        }
        $priv = $this->login->getIndicatorPrivileges(array($indicatorID), $categoryID, $UID);
        if ($priv[$indicatorID]['grant'] != 0)
        {
            $vars = array(':indicatorID' => $indicatorID,
                          ':categoryID' => $categoryID,
                          ':UID' => $UID, );
            $res = $this->db->prepared_query('SELECT * FROM indicator_privileges
                                                WHERE indicatorID=:indicatorID
                                                    AND categoryID=:categoryID
                                                    AND UID=:UID', $vars);
            if ($res[0][$permissionType] == 1)
            {
                return $this->removePermission($indicatorID, $categoryID, $UID, $permissionType);
            }

            return $this->addPermission($indicatorID, $categoryID, $UID, $permissionType);
        }
    }

    /**
     * Adds permission entry
     * @param int $indicatorID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function addPermission($indicatorID, $categoryID, $UID, $permissionType)
    {
        if (!is_numeric($indicatorID) || !is_numeric($UID))
        {
            return;
        }
        $priv = $this->login->getIndicatorPrivileges(array($indicatorID), $categoryID, $UID);
        if ($priv[$indicatorID]['grant'] == 0)
        {
            return;
        }

        switch ($permissionType) {
            case 'read':
                $permissionType = '`read`';

                break;
            case 'write':
                $permissionType = '`write`';

                break;
            case 'grant':
                $permissionType = '`grant`';

                break;
            default:
                return false;

                break;
        }
        $vars = array(':indicatorID' => $indicatorID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO indicator_privileges (indicatorID, categoryID, UID)
                                            VALUES (:indicatorID, :categoryID, :UID)', $vars);

        $vars = array(':indicatorID' => $indicatorID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE indicator_privileges
                                            SET {$permissionType}=1
                                            WHERE indicatorID=:indicatorID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);

        return 1;
    }

    /**
     * Removes the specified permission
     * @param int $indicatorID
     * @param string $categoryID
     * @param int $UID
     * @param string $permissionType
     * @return NULL|boolean|number
     */
    public function removePermission($indicatorID, $categoryID, $UID, $permissionType)
    {
        $priv = $this->login->getIndicatorPrivileges(array($indicatorID), $categoryID, $UID);
        if ($priv[$indicatorID]['grant'] == 0)
        {
            return;
        }

        switch ($permissionType) {
            case 'read':
                $permissionType = '`read`';

                break;
            case 'write':
                $permissionType = '`write`';

                break;
            case 'grant':
                $permissionType = '`grant`';

                break;
            default:
                return false;

                break;
        }

        $vars = array(':indicatorID' => $indicatorID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('INSERT IGNORE INTO indicator_privileges (indicatorID, categoryID, UID)
                                            VALUES (:indicatorID, :categoryID, :UID)', $vars);

        $vars = array(':indicatorID' => $indicatorID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query("UPDATE indicator_privileges
                                            SET {$permissionType}=0
                                            WHERE indicatorID=:indicatorID
                                                AND categoryID=:categoryID
                                                AND UID=:UID", $vars);

        // if subject has all permissions removed, delete the row from the table
        $vars = array(':indicatorID' => $indicatorID,
                      ':categoryID' => $categoryID,
                      ':UID' => $UID, );
        $res = $this->db->prepared_query('SELECT * FROM indicator_privileges
                                            WHERE indicatorID=:indicatorID
                                            AND categoryID=:categoryID
                                            AND UID=:UID', $vars);
        if ($res[0]['read'] == 0
                && $res[0]['write'] == 0
                && $res[0]['grant'] == 0)
        {
            $res = $this->db->prepared_query('DELETE FROM indicator_privileges
                                                WHERE indicatorID=:indicatorID
                                                AND categoryID=:categoryID
                                                AND UID=:UID', $vars);
        }

        return 0;
    }
}
