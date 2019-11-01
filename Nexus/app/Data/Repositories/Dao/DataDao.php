<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Nexus\Data\Repositories\Contracts\DataRepository;

class DataDao extends CachedDbDao implements DataRepository
{
    protected $connectionName = "nexus";

    protected $dataTable = '';

    protected $dataHistoryTable = '';

    protected $dataTagTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    private $cache = array();

    /**
     * Retrieve all data if no indicatorID is given
     * @param int $UID
     * @param int $indicatorID
     * @return array
     */
    public function getAllData($UID, $indicatorID = 0)
    {
        if (!is_numeric($indicatorID))
        {
            return array();
        }

        $vars = array();
        $res = array();

        $cacheHash = "getAllData_{$UID}_{$indicatorID}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        if (!isset($this->cache["getAllData_{$indicatorID}"]))
        {
            if ($indicatorID != 0)
            {
                $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $this->dataTableCategoryID],['disabled', 0],['indicatorID', $indicatorID]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            }
            else
            {
                $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $this->dataTableCategoryID],['disabled', 0]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            }
            $this->cache["getAllData_{$indicatorID}"] = $res;
        }
        else
        {
            $res = $this->cache["getAllData_{$indicatorID}"];
        }

        $data = array();

        foreach ($res as $item)
        {
            $idx = $item['indicatorID'];
            $data[$idx]['indicatorID'] = $item['indicatorID'];
            $data[$idx]['name'] = isset($item['name']) ? $item['name'] : '';
            $data[$idx]['format'] = isset($item['format']) ? $item['format'] : '';
            if (isset($item['description']))
            {
                $data[$idx]['description'] = $item['description'];
            }
            if (isset($item['default']))
            {
                $data[$idx]['default'] = $item['default'];
            }
            if (isset($item['html']))
            {
                $data[$idx]['html'] = $item['html'];
            }
            $data[$idx]['required'] = $item['required'];
            if ($item['encrypted'] != 0)
            {
                $data[$idx]['encrypted'] = $item['encrypted'];
            }
            $data[$idx]['data'] = '';
            $data[$idx]['isWritable'] = 0; //temp
            //$data[$idx]['author'] = '';
            //$data[$idx]['timestamp'] = 0;

            // handle checkboxes/radio buttons
            $inputType = explode("\n", $item['format']);
            $numOptions = count($inputType) > 1 ? count($inputType) : 2;
            if (count($inputType) != 1)
            {
                for ($i = 1; $i < $numOptions; $i++)
                {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    $data[$idx]['options'][] = $inputType[$i];
                }
            }

            $data[$idx]['format'] = trim($inputType[0]);
        }

        if (count($res) > 0)
        {
            $indicatorArray = array();
            foreach ($res as $field)
            {
                if (is_numeric($field['indicatorID']))
                {
                    $indicatorArray[] = $field['indicatorID'];
                }
            }
            $res2 = $this->getConnForTable($this->dataTable)
            ->select('data', 'timestamp', 'indicatorID')
            ->whereIn('indicatorID', $indicatorArray)
            ->where([[$this->dataTableUID, $UID]])
            ->get()
            ->toArray();

            foreach ($res2 as $resIn)
            {
                $idx = $resIn['indicatorID'];
                $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                $data[$idx]['data'] = @unserialize($data[$idx]['data']) === false ? $data[$idx]['data'] : unserialize($data[$idx]['data']);
                if ($data[$idx]['format'] == 'json')
                {
                    $data[$idx]['data'] = html_entity_decode($data[$idx]['data']);
                }
                if ($data[$idx]['format'] == 'fileupload')
                {
                    $tmpFileNames = explode("\n", $data[$idx]['data']);
                    $data[$idx]['data'] = array();
                    foreach ($tmpFileNames as $tmpFileName)
                    {
                        if (trim($tmpFileName) != '')
                        {
                            $data[$idx]['data'][] = $tmpFileName;
                        }
                    }
                }
                if (isset($resIn['author']))
                {
                    $data[$idx]['author'] = $resIn['author'];
                }
                if (isset($resIn['timestamp']))
                {
                    $data[$idx]['timestamp'] = $resIn['timestamp'];
                }
            }

            // // apply access privileges
            // $privilegesData = $this->login->getIndicatorPrivileges(array_keys($data), $this->dataTableUID, $UID);//TODO find a good way o make this work
            // $privileges = array_keys($privilegesData);
            // foreach ($privileges as $id)
            // {
            //     if ($privilegesData[$id]['read'] == 0
            //         && $data[$id]['data'] != '')
            //     {
            //         $data[$id]['data'] = '[protected data]';
            //     }
            //     if ($privilegesData[$id]['write'] != 0)
            //     {
            //         $data[$id]['isWritable'] = 1;
            //     }
            // }
            
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

        /**
     * Retrieves current user's privileges for the specified indicatorIDs
     * The default behavior is to grant full access if the user "owns" the data
     * eg: Users have access to their own employee information by default
     * Non-owners by default only have read access
     * Any privilege setting will override all default behaviors
     *
     * @param array $indicatorIDs
     * @param string $dataTableUID is either 'empUID', 'positionID', 'groupID', 'employee', 'position', or 'group'
     * @param int $UID. This could be a empUID, positionID, or groupID.
     */
    public function getIndicatorPrivileges($indicatorIDs, $dataTableUID = '', $UID = 0)
    {
        $UID = \XSSHelpers::xscrub($UID);
        $cacheHash = 'getIndicatorPrivileges' . implode('-', $indicatorIDs) . $dataTableUID . $UID;
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        switch ($dataTableUID) {
            case 'employee':
                $dataTableUID = 'empUID';

                break;
            case 'position':
                $dataTableUID = 'positionID';

                break;
            case 'group':
                $dataTableUID = 'groupID';

                break;
            default:
                break;
        }
        $data = array();
        $memberships = $this->getMembership();

        $indicatorList = '';
        foreach ($indicatorIDs as $id)
        {
            $id = (int)$id;
            $indicatorList .= $id . ',';
            // grant by default if user is the owner, or is a member of a group who has ownership
            if (isset($memberships[$dataTableUID][$UID]))
            {
                $data[$id]['read'] = -1;
                $data[$id]['write'] = -1;
                $data[$id]['grant'] = 0;
                $data[$id]['isOwner'] = 1;
            }
            // otherwise deny write/grant
            else
            {
                $data[$id]['read'] = -1;
                $data[$id]['write'] = 0;
                $data[$id]['grant'] = 0;
            }
        }
        $indicatorList = trim($indicatorList, ',');

        $cacheHash2 = 'getIndicatorPrivileges2' . $indicatorList;
        $res = null;
        if (isset($this->cache[$cacheHash2]))
        {
            $res = $this->cache[$cacheHash2];
        }
        else
        {
            $var = array();
            $res = $this->db->prepared_query("SELECT * FROM indicator_privileges
                                            	WHERE indicatorID IN ({$indicatorList})", $var);
            $this->cache[$cacheHash2] = $res;
        }

        foreach ($res as $item)
        {
            $resIndicatorID = (int)$item['indicatorID'];
            $resCategoryID = \XSSHelpers::xscrub($item['categoryID']);
            $resUID = \XSSHelpers::xscrub($item['UID']);
            $resRead = (int)$item['read'];
            $resWrite = (int)$item['write'];
            $resGrant = (int)$item['grant'];

            // grant highest available access
            if (isset($memberships[$resCategoryID . 'ID'][$resUID]))
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = $resRead;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = $resWrite;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = $resGrant;
                }
            }
            else
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = 0;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = 0;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = 0;
                }
            }

            // apply access levels for special group: Owner (groupID 3)
            if ($resCategoryID == 'group'
                && $resUID == 3
                && isset($data[$resIndicatorID]['isOwner']))
            {
                if (isset($data[$resIndicatorID]['read']) && $data[$resIndicatorID]['read'] != 1)
                {
                    $data[$resIndicatorID]['read'] = $resRead;
                }
                if (isset($data[$resIndicatorID]['write']) && $data[$resIndicatorID]['write'] != 1)
                {
                    $data[$resIndicatorID]['write'] = $resWrite;
                }
                if (isset($data[$resIndicatorID]['grant']) && $data[$resIndicatorID]['grant'] != 1)
                {
                    $data[$resIndicatorID]['grant'] = $resGrant;
                }
            }
        }

        // allow grant access if user is part of the special group: System Administrator (groupID 1)
        if (isset($memberships['groupID'][1])
                && $memberships['groupID'][1] == 1)
        {
            foreach ($indicatorIDs as $id)
            {
                $id = (int)$id;
                $data[$id]['grant'] = 1;
            }
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

        /**
     * Retrieves the positions and groups the current user is a member of
     * @return array
     */
    public function getMembership($empUID = null)
    {
        if ($empUID == null)
        {
            $empUID = \XSSHelpers::xscrub($this->empUID);
        }

        if (isset($this->cache['getMembership_' . $empUID]))
        {
            return $this->cache['getMembership_' . $empUID];
        }

        $membership = array();
        // inherit permissions if employee is a backup for someone else
        $vars = array(':empUID' => \XSSHelpers::xscrub($empUID));
        $res = $this->db->prepared_query('SELECT * FROM relation_employee_backup
                                            WHERE backupEmpUID=:empUID
        										AND approved=1', $vars);
        $temp = \XSSHelpers::xscrub($empUID);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                //casting as an int to prevent sql injection
                $scrubEmpUID = \XSSHelpers::xscrub($item['empUID']);
                $temp .= ",{$scrubEmpUID}";
                $membership['inheritsFrom'][] = $scrubEmpUID;
            }
            $vars = array(':empUID' => $temp);
        }

        $res = $this->db->prepared_query("SELECT positionID, empUID,
                                                relation_group_employee.groupID as employee_groupID,
                                                relation_group_position.groupID as position_groupID FROM employee
                                            LEFT JOIN relation_position_employee USING (empUID)
                                            LEFT JOIN relation_group_employee USING (empUID)
                                            LEFT JOIN relation_group_position USING (positionID)
                                            WHERE empUID IN (:empUID)", $vars);
        if (count($res) > 0)
        {
            foreach ($res as $item)
            {
                if (isset($item['positionID']))
                {
                    $membership['positionID'][$item['positionID']] = 1;
                }
                if (isset($item['employee_groupID']))
                {
                    $membership['groupID'][$item['employee_groupID']] = 1;
                }
                if (isset($item['position_groupID']))
                {
                    $membership['groupID'][$item['position_groupID']] = 1;
                }
            }
        }
        $membership['employeeID'][$empUID] = 1;
        $membership['empUID'][$empUID] = 1;

        // Add special membership groups
        $membership['groupID'][2] = 1;    // groupID 2 = "Everyone"

        $this->cache['getMembership_' . $empUID] = $membership;

        return $this->cache['getMembership_' . $empUID];
    }

}
