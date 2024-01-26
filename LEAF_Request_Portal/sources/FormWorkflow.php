<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Workflow
    Date Created: May 25, 2011
*/

namespace Portal;
use App\Leaf\Db;
use App\Leaf\XSSHelpers;

class FormWorkflow
{
    public $siteRoot = '';

    private $db;

    private $oc_db;

    private $login;

    private $recordID;

    private $cache = array();

    private $dir; // employee directory

    // workflow actions are triggered from ./api/ except on submit
    private $eventFolder = '../scripts/events/';

    public function __construct($db, $login, $recordID)
    {
        $this->db = $db;
        $this->login = $login;
        $this->recordID = is_numeric($recordID) ? $recordID : 0;
        $this->oc_db = OC_DB;

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $apiEntry = strpos($this->siteRoot, '/api/');
        if ($apiEntry !== false)
        {
            $this->siteRoot = substr($this->siteRoot, 0, $apiEntry + 1);
        }
    }

    public function initRecordID(int $recordID): void
    {
        $this->recordID = is_numeric($recordID) ? $recordID : 0;
    }

    /**
     * getDirectory initializes and returns an instance of VAMC_Directory
     * @return object
     */
    private function getDirectory(): object
    {
        if (!isset($this->dir))
        {
            $this->dir = new VAMC_Directory;
        }

        return $this->dir;
    }

    /**
     * Checks if the current record has an active workflow
     * @return bool
     */
    public function isActive(): bool
    {
        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT * FROM records_workflow_state WHERE recordID = :recordID';
        $res = $this->db->prepared_query($strSQL, $vars);

        return isset($res[0]);
    }

    /**
     * Retrieve groupIDs associated with the given dependencyID
     * @param int|null $depID dependencyID
     * @return array database result
     */
    private function getDependencyPrivileges(int|null $depID): array {
        if(!isset($this->cache["dependencyID{$depID}"])) {
            $vars = array(':dependencyID' => $depID);
            $strSQL = 'SELECT * FROM dependency_privs WHERE dependencyID = :dependencyID';
            $this->cache["dependencyID{$depID}"] = $this->db->prepared_query($strSQL, $vars);
        }

        return $this->cache["dependencyID{$depID}"];
    }

    /**
     * Determine if the current user is a member of a quadrad for the specified serviceID
     * @param int $serviceID
     * @return bool
     */
    private function checkServiceQuadradAccess(int $serviceID): bool {
        if(!isset($this->cache["serviceQuadrads{$serviceID}"])) {
            $quadGroupIDs = $this->login->getQuadradGroupID(); // get csv of ints
            $vars3 = array(
                ':serviceID' => $serviceID,
            );
            $strSQL = 'SELECT * FROM services
                WHERE groupID IN ('.$quadGroupIDs.')
                AND serviceID = :serviceID';
            $this->cache["serviceQuadrads{$serviceID}"] = isset($this->db->prepared_query($strSQL, $vars3)[0]);
        }

        return $this->cache["serviceQuadrads{$serviceID}"];
    }

    /**
     * Retrieve the group name associated with a groupID
     * @param int|string|null $groupID
     * @return string|null null if no matching groupID
     */
    private function getActionableGroupName(int|string|null $groupID): string|null {
        if(isset($this->cache['getActionableGroupName'.$groupID])) {
            return $this->cache['getActionableGroupName'.$groupID];
        }

        $groupName = 'Warning: Group Name has not been imported in the User Access Group';
        $vars = array(':groupID' => $groupID);
        $strSQL = 'SELECT * FROM `groups` WHERE groupID = :groupID';
        $tGroup = $this->db->prepared_query($strSQL, $vars);
        if (count($tGroup) >= 0)
        {
            $groupName = $tGroup[0]['name'];
        }

        $this->cache['getActionableGroupName'.$groupID] = $groupName;
        return $groupName;
    }

    /**
     * includePersonDesignatedData efficiently merges approver data to $srcRecords, for a
     * given list of $pdRecordList and $pdIndicators.
     * 
     * When $skipNames is false, $srcRecords is expected to contain dependencyIDs
     * 
     * WARNING: This function should only be used to support getRecordsDependencyData() and getActionable().
     *          Usage in other areas must be carefully reviewed as this retrieves data without
     *          checking for valid access. The $pdIndicators variable must only contain indicator IDs
     *          that are related to a "person designated" field AND workflow that utilizes the "person 
     *          designated" feature.
     * @param array $srcRecords list of records
     * @param array $pdRecordsMap map of record IDs => indicatorID that utilize "person designated"
     * @param array $pdIndicator list of indicator IDs mapped to "person designated" fields
     * @param bool $skipNames set true to exclude employee lookups
     * @return array Amended records
     */
    private function includePersonDesignatedData(array $srcRecords, array $pdRecordsMap, array $pdIndicators, bool $skipNames = false): array
    {
        // sanitize for use in query
        $pdIndicators = array_map(function($x) {
                            return (int)$x;
                        }, $pdIndicators);
        $pdIndicators = implode(',', $pdIndicators);

        $pdRecordIDs = array_keys($pdRecordsMap);
        $pdRecordIDs = array_map(function($x) {
                        return (int)$x;
                    }, $pdRecordIDs);

        $pdRecordIDs = implode(',', $pdRecordIDs);

        $query = "SELECT recordID, `data`, `name`, indicatorID FROM `data`
                    LEFT JOIN indicators USING (indicatorID)
                    WHERE indicatorID IN ({$pdIndicators}) 
                        AND recordID IN ({$pdRecordIDs})
                        AND series=1
                        AND `disabled`=0";
        $res = $this->db->prepared_query($query, []);

        // create map of recordIDs with "person designated"
        $dRecords = [];
        foreach($res as $record) {
            if(isset($pdRecordsMap[$record['recordID']][$record['indicatorID']])) {
                $dRecords[$record['recordID']]['data'] = $record['data'];
                $dRecords[$record['recordID']]['name'] = $record['name'];
            }
        }

        $dir = $this->getDirectory();
        // loop through all srcRecords
        foreach($srcRecords as $i => $v) {
            // amend actionable status
            if(isset($dRecords[$v['recordID']])) {
                if($srcRecords[$i]['isActionable'] == 0) {
                    $srcRecords[$i]['isActionable'] = $this->checkEmployeeAccess($dRecords[$v['recordID']]['data']);
                }

                if($skipNames) {
                    continue;
                }

                // Only amend approverName for person designated records
                if($v['dependencyID'] == -1) {
                    $approver = $dir->lookupEmpUID($dRecords[$v['recordID']]['data']);
                    
                    if (empty($approver[0]['Fname']) && empty($approver[0]['Lname'])) {
                        $srcRecords[$i]['description'] = $srcRecords[$i]['stepTitle'] . ' (' . $dRecords[$v['recordID']]['name'] . ')';
                        $srcRecords[$i]['approverName'] = $dRecords[$v['recordID']]['name'];
                        $srcRecords[$i]['approverUID'] = 'indicatorID:' . $res[$i]['indicatorID_for_assigned_empUID'];
                    }
                    else {
                        $srcRecords[$i]['description'] = $srcRecords[$i]['stepTitle'] . ' (' . $approver[0]['Fname'] . ' ' . $approver[0]['Lname'] . ')';
                        $srcRecords[$i]['approverName'] = $approver[0]['Fname'] . ' ' . $approver[0]['Lname'];
                        $srcRecords[$i]['approverUID'] = $approver[0]['Email'];
                    }
                }
            }
        }

        return $srcRecords;
    }

    /**
     * includeGroupDesignatedData efficiently merges approver data to $srcRecords, for a
     * given list of $gdRecordList and $gdIndicators.
     * 
     * When $skipNames is false, $srcRecords is expected to contain dependencyIDs
     * 
     * WARNING: This function should only be used to support getRecordsDependencyData() and getActionable().
     *          Usage in other areas must be carefully reviewed as this retrieves data without
     *          checking for valid access. The $gdIndicators variable must only contain indicator IDs
     *          that are related to a "group designated" field AND workflow that utilizes the "group 
     *          designated" feature.
     * @param array $srcRecords list of records
     * @param array $gdRecordsMap map of record IDs => indicatorID that utilize "group designated"
     * @param array $gdIndicator list of indicator IDs mapped to "group designated" fields
     * @param bool $skipNames set true to exclude employee lookups
     * @return array Amended records
     */
    private function includeGroupDesignatedData(array $srcRecords, array $gdRecordsMap, array $gdIndicators, bool $skipNames = false): array
    {
        // sanitize for use in query
        $gdIndicators = array_map(function($x) {
                            return (int)$x;
                        }, $gdIndicators);
        $gdIndicators = implode(',', $gdIndicators);

        $gdRecordIDs = array_keys($gdRecordsMap);
        $gdRecordIDs = array_map(function($x) {
                        return (int)$x;
                    }, $gdRecordIDs);

        $gdRecordIDs = implode(',', $gdRecordIDs);

        $query = "SELECT recordID, `data`, `name`, indicatorID FROM `data`
                    LEFT JOIN indicators USING (indicatorID)
                    WHERE indicatorID IN ({$gdIndicators}) 
                        AND recordID IN ({$gdRecordIDs})
                        AND series=1
                        AND `disabled`=0";
        $res = $this->db->prepared_query($query, []);

        $groupIDs = [];
        // create map of recordIDs with "group designated"
        $dRecords = [];
        foreach($res as $record) {
            if(isset($gdRecordsMap[$record['recordID']][$record['indicatorID']])) {
                $dRecords[$record['recordID']]['data'] = $record['data'];
                $dRecords[$record['recordID']]['name'] = $record['name'];
                $groupIDs[$record['data']] = 1;
            }
        }

        $groupNames = [];
        if(!$skipNames) {
            $groupIDs = array_keys($groupIDs);
            $groupIDs = array_map(function($x) {
                            return (int)$x;
                        }, $groupIDs);
    
            $groupIDs = implode(',', $groupIDs);
            if($groupIDs != "") {
                $res = $this->db->prepared_query("SELECT groupID, name FROM `groups`
                                                   WHERE groupID IN ({$groupIDs})", []);
                foreach($res as $group) {
                    $groupNames[$group['groupID']] = $group['name'];
                }
            }
        }

        // loop through all srcRecords
        foreach($srcRecords as $i => $v) {
            // amend actionable status
            if(isset($dRecords[$v['recordID']])) {
                if($srcRecords[$i]['isActionable'] == 0) {
                    $srcRecords[$i]['isActionable'] = $this->login->checkGroup($dRecords[$v['recordID']]['data']);
                }

                if($skipNames) {
                    continue;
                }

                // Only amend group name for group designated records
                if($v['dependencyID'] == -3) {      
                    $groupName = isset($groupNames[$group['groupID']]) ? $groupNames[$group['groupID']] : 'Warning: Group has not been imported into the User Access Group';
                    $srcRecords[$i]['description'] = $srcRecords[$i]['stepTitle'] . ' (' . $groupName . ')';
                    $srcRecords[$i]['approverName'] = $groupName;
                    $srcRecords[$i]['approverUID'] = 'groupID:' . $dRecords[$v['recordID']]['data'];
                }
            }
        }

        return $srcRecords;
    }

    /**
     * Adds an "isActionable" parameter for each record within $records
     * @param object $form instance of Form
     * @param array $records result set from a query on db:records. Requires 'recordID'.
     * @return array amended $records
     */
    public function getActionable(object $form, array $records): array {
        $numRecords = count($records);
        if ($numRecords == 0) {
            return $records;
        }

        $recordIDs = '';

        foreach ($records as $item) {
            $recordIDs .= (int)$item['recordID'] . ',';
        }
        $recordIDs = trim($recordIDs, ',');

        $res = null;
        $strSQL = "SELECT dependencyID, recordID, serviceID, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID, userID FROM records_workflow_state
            LEFT JOIN records USING (recordID)
            LEFT JOIN workflow_steps USING (stepID)
            LEFT JOIN step_dependencies USING (stepID)
            LEFT JOIN records_dependencies USING (recordID, dependencyID)
            WHERE recordID IN ({$recordIDs})
                AND filled=0";
        
        $cacheHash = 'unfilledRecordsDependencyData' . sha1($recordIDs); // the data columns must be a superset of the query above
        if(isset($this->cache[$cacheHash])) {
            $res = $this->cache[$cacheHash];
        }
        else {
            $res = $this->db->prepared_query($strSQL, []);
        }

        $personDesignatedRecords = []; // map of records using "person designated" => associated indicatorID
        $personDesignatedIndicators = []; // map of indicators using "person designated"
        $groupDesignatedRecords = []; // map of records using "group designated" => associated indicatorID
        $groupDesignatedIndicators = []; // map of indicators using "group designated"
        foreach ($res as $depRecord) {
            $depRecordID = $depRecord['recordID'];
            if(!isset($records[$depRecordID]['isActionable'])) {
                $records[$depRecordID]['isActionable'] = $this->login->checkGroup(1); // initialize isActionable based on admin status
            }

            $res2 = $this->getDependencyPrivileges($depRecord['dependencyID']);

            if ($records[$depRecordID]['isActionable']) {
                continue;
            }

            // check permissions
            switch($depRecord['dependencyID']) {
                case 1: // dependencyID 1 is for a special service chief group
                    $records[$depRecordID]['isActionable'] = $this->login->checkService($depRecord['serviceID']);
                    break;

                case 8: // dependencyID 8 is for a special quadrad group
                    $records[$depRecordID]['isActionable'] = $this->checkServiceQuadradAccess($depRecord['serviceID']);
                    break;

                case -1: // dependencyID -1 is for a person designated by the requestor
                    $personDesignatedRecords[$depRecord['recordID']][$depRecord['indicatorID_for_assigned_empUID']] = 1;
                    $personDesignatedIndicators[$depRecord['indicatorID_for_assigned_empUID']] = 1;
                    break;

                case -2: // dependencyID -2 is for requestor followup
                    $isActionable = $depRecord['userID'] == $this->login->getUserID();

                    if(!$isActionable){
                        $empUID = $this->getEmpUIDByUserName($depRecord['userID']);
                        $isActionable = $this->checkEmployeeAccess($empUID);
                    }

                    $records[$depRecordID]['isActionable'] = $isActionable;
                    break;

                case -3: // dependencyID -3 is for a group designated by the requestor
                    $groupDesignatedRecords[$depRecord['recordID']][$depRecord['indicatorID_for_assigned_groupID']] = 1;
                    $groupDesignatedIndicators[$depRecord['indicatorID_for_assigned_groupID']] = 1;
                    break;

                default:
                    // check groups associated with dependency privileges
                    foreach ($res2 as $group)
                    {
                        if ($this->login->checkGroup($group['groupID']))
                        {
                            $records[$depRecordID]['isActionable'] = true;

                            break;
                        }
                    }
                    break;
            }
        }

        if(count($personDesignatedRecords) > 0) {
            $records = $this->includePersonDesignatedData($records, $personDesignatedRecords, array_keys($personDesignatedIndicators), true);
        }
        if(count($groupDesignatedRecords) > 0) {
            $records = $this->includeGroupDesignatedData($records, $groupDesignatedRecords, array_keys($groupDesignatedIndicators), true);
        }

        return $records;
    }

    /**
     * getRecordsDependencyData retrieves dependency data related to records
     * @param object $form instance of Form
     * @param array $records result set from a query on db:records. Requires 'recordID'.
     * @param bool optional Only select unfilled dependencies
     * @return array $records list of dependencies * records
     */
    public function getRecordsDependencyData(object $form, array $records, bool $selectUnfilled = false): array {
        $numRecords = count($records);
        if ($numRecords == 0) {
            return $records;
        }

        $recordIDs = '';

        foreach ($records as $item) {
            $recordIDs .= (int)$item['recordID'] . ',';
        }
        $recordIDs = trim($recordIDs, ',');

        $strSQL = "";

        if(!$selectUnfilled) {
            $strSQL = "SELECT dependencyID, recordID, stepID, stepTitle, blockingStepID, workflowID, serviceID, filled, stepBgColor, stepFontColor, stepBorder, `description`, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID, jsSrc, userID, requiresDigitalSignature FROM records_workflow_state
                        LEFT JOIN records USING (recordID)
                        LEFT JOIN workflow_steps USING (stepID)
                        LEFT JOIN step_dependencies USING (stepID)
                        LEFT JOIN dependencies USING (dependencyID)
                        LEFT JOIN records_dependencies USING (recordID, dependencyID)
                        WHERE recordID IN ({$recordIDs})";
        }
        else {
            $strSQL = "SELECT dependencyID, recordID, stepTitle, serviceID, `description`, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID, userID FROM records_workflow_state
                        LEFT JOIN records USING (recordID)
                        LEFT JOIN workflow_steps USING (stepID)
                        LEFT JOIN step_dependencies USING (stepID)
                        LEFT JOIN dependencies USING (dependencyID)
                        LEFT JOIN records_dependencies USING (recordID, dependencyID)
                        WHERE recordID IN ({$recordIDs})
                            AND filled=0";
        }
        $res = $this->db->prepared_query($strSQL, []);

        if($selectUnfilled) {
            $this->cache['unfilledRecordsDependencyData'.sha1($recordIDs)] = $res; // the selected columns must be a superset of the columns in getActionable()
        }

        $personDesignatedRecords = []; // map of records using "person designated"
        $personDesignatedIndicators = []; // map of indicators using "person designated"
        $groupDesignatedRecords = []; // map of records using "group designated"
        $groupDesignatedIndicators = []; // map of indicators using "group designated"
        foreach ($res as $i => $record) {
            // override access if user is in the admin group
            $res[$i]['isActionable'] = $this->login->checkGroup(1); // initialize isActionable

            $res2 = $this->getDependencyPrivileges($res[$i]['dependencyID']);

            // This optimization skips supplemental orgchart info for admins. Include it
            // before skipping the rest of this loop.
            if ($res[$i]['isActionable']) {
                switch($res[$i]['dependencyID']) {
                    case -1: // dependencyID -1 is for a person designated by the requestor
                        $personDesignatedRecords[$res[$i]['recordID']][$res[$i]['indicatorID_for_assigned_empUID']] = 1;
                        $personDesignatedIndicators[$res[$i]['indicatorID_for_assigned_empUID']] = 1;
                        break;
                    case -2: // dependencyID -2 is for requestor followup
                        $dir = $this->getDirectory();
                        $approver = $dir->lookupLogin($res[$i]['userID']);

                        if (empty($approver[0]['Fname']) && empty($approver[0]['Lname'])) {
                            $res[$i]['description'] = $res[$i]['stepTitle'] . ' (Requestor followup)';
                            $res[$i]['approverName'] = '(Requestor followup)';
                            $res[$i]['approverUID'] = $res[$i]['userID'];
                        }
                        else {
                            $res[$i]['description'] = $res[$i]['stepTitle'] . ' (' . $approver[0]['Fname'] . ' ' . $approver[0]['Lname'] . ')';
                            $res[$i]['approverName'] = $approver[0]['Fname'] . ' ' . $approver[0]['Lname'];
                            $res[$i]['approverUID'] = $approver[0]['Email'];
                        }
                        break;
                    case -3: // dependencyID -3 is for a group designated by the requestor
                        $groupDesignatedRecords[$res[$i]['recordID']][$res[$i]['indicatorID_for_assigned_groupID']] = 1;
                        $groupDesignatedIndicators[$res[$i]['indicatorID_for_assigned_groupID']] = 1;
                        break;
                    default:
                        break;
                }

                continue;
            }

            // check permissions
            switch($res[$i]['dependencyID']) {
                case 1: // dependencyID 1 is for a special service chief group
                    $res[$i]['isActionable'] = $this->login->checkService($res[$i]['serviceID']);
                    break;

                case 8: // dependencyID 8 is for a special quadrad group
                    $res[$i]['isActionable'] = $this->checkServiceQuadradAccess($res[$i]['serviceID']);
                    break;

                case -1: // dependencyID -1 is for a person designated by the requestor
                    $personDesignatedRecords[$res[$i]['recordID']][$res[$i]['indicatorID_for_assigned_empUID']] = 1;
                    $personDesignatedIndicators[$res[$i]['indicatorID_for_assigned_empUID']] = 1;
                    break;

                case -2: // dependencyID -2 is for requestor followup
                    $isActionable = $res[$i]['userID'] == $this->login->getUserID();

                    if(!$isActionable){
                        $empUID = $this->getEmpUIDByUserName($res[$i]['userID']);
                        $isActionable = $this->checkEmployeeAccess($empUID);
                    }

                    $res[$i]['isActionable'] = $isActionable;

                    $dir = $this->getDirectory();
                    $approver = $dir->lookupLogin($res[$i]['userID']);
                    if (empty($approver[0]['Fname']) && empty($approver[0]['Lname'])) {
                        $res[$i]['description'] = $res[$i]['stepTitle'] . ' (Requestor followup)';
                        $res[$i]['approverName'] = '(Requestor followup)';
                        $res[$i]['approverUID'] = $res[$i]['userID'];
                    }
                    else {
                        $res[$i]['description'] = $res[$i]['stepTitle'] . ' (' . $approver[0]['Fname'] . ' ' . $approver[0]['Lname'] . ')';
                        $res[$i]['approverName'] = $approver[0]['Fname'] . ' ' . $approver[0]['Lname'];
                        $res[$i]['approverUID'] = $approver[0]['Email'];
                    }
                    break;

                case -3: // dependencyID -3 is for a group designated by the requestor
                    $groupDesignatedRecords[$res[$i]['recordID']][$res[$i]['indicatorID_for_assigned_groupID']] = 1;
                    $groupDesignatedIndicators[$res[$i]['indicatorID_for_assigned_groupID']] = 1;
                    break;

                default:
                    // check groups associated with dependency privileges
                    foreach ($res2 as $group)
                    {
                        if ($this->login->checkGroup($group['groupID']))
                        {
                            $res[$i]['isActionable'] = true;

                            break;
                        }
                    }
                    break;
            }
        }

        if(count($personDesignatedRecords) > 0) {
            $res = $this->includePersonDesignatedData($res, $personDesignatedRecords, array_keys($personDesignatedIndicators));
        }
        if(count($groupDesignatedRecords) > 0) {
            $res = $this->includeGroupDesignatedData($res, $groupDesignatedRecords, array_keys($groupDesignatedIndicators));
        }

        return $res;
    }

    /**
     * Retrieves current steps of a form's workflow, controls access to steps
     * @return array database result
     * @return null if no database result
     */
    public function getCurrentSteps(): array|int|null
    {
        // check privileges
        $form = new Form($this->db, $this->login);
        if (!$form->hasReadAccess($this->recordID))
        {
            return 0;
        }

        $steps = array();
        $res = $this->getRecordsDependencyData($form, [['recordID' => $this->recordID]]);

        $numRes = count($res);
        if ($numRes > 0)
        {
            // Setting filled=0 is a workaround if the workflow is in an inconsistent state.
            // There normally shouldn't be a situation where a record is still on a step even though all
            // dependencies have been fulfilled. This can be removed if there's no way the situation can happen.
            if ($numRes == 1 && $res[0]['filled'] == 1) {
                $res[0]['filled'] = 0;
            }

            for ($i = 0; $i < $numRes; $i++)
            {
                if ($res[$i]['filled'] == 1) {
                    continue;
                }
                $res[$i]['dependencyActions'] = $this->getDependencyActions($res[$i]['workflowID'], $res[$i]['stepID']);

                $res[$i]['hasAccess'] = $res[$i]['isActionable'];


                if (!isset($steps[$res[$i]['dependencyID']]))
                {
                    $steps[$res[$i]['dependencyID']] = $res[$i];
                }

                // load related js assets from shared steps
                if ($res[$i]['jsSrc'] != '' && file_exists(dirname(__FILE__) . '/scripts/custom_js/' . $res[$i]['jsSrc']))
                {
                    $steps[$res[$i]['dependencyID']]['jsSrcList'][] = 'scripts/custom_js/' . $res[$i]['jsSrc'];
                }

                // load step modules
                $varsSm = array(':stepID' => $res[$i]['stepID']);
                $strSQL = 'SELECT moduleName, moduleConfig FROM step_modules
                    WHERE stepID = :stepID';
                $resSm = $this->db->prepared_query($strSQL, $varsSm);
                foreach($resSm as $module) {
                    $steps[$res[$i]['dependencyID']]['stepModules'][] = $module;
                }
            }

            for ($i = 0; $i < $numRes; $i++)
            {
                // block step if there is a blocker
                if ($res[$i]['blockingStepID'] > 0)
                {
                    foreach ($steps as $step)
                    {
                        if ($res[$i]['blockingStepID'] == $step['stepID'])
                        {
                            unset($steps[$res[$i]['dependencyID']]);
                        }
                    }
                }
            }
        }

        return count($steps) > 0 ? $steps : null;
    }

    /**
     * Get the last action made to the request
     */
    public function getLastAction(): array|null|int
    {
        // check privileges
        $form = new Form($this->db, $this->login);
        if (!$form->hasReadAccess($this->recordID))
        {
            return 0;
        }

        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT * FROM action_history
            WHERE recordID = :recordID
            AND actionType IS NOT NULL
            AND dependencyID != 0
            ORDER BY actionID DESC
            LIMIT 1';
        $res = $this->db->prepared_query($strSQL, $vars);

        // backwards compatibility for records where action_history.stepID doesn't exist
        if ($res[0]['stepID'] > 0)
        {
            $vars = array(':actionID' => $res[0]['actionID']);
            $strSQL = 'SELECT * FROM action_history
                LEFT JOIN actions ON actions.actionType = action_history.actionType
                LEFT JOIN category_count USING (recordID)
                LEFT JOIN categories USING (categoryID)
                LEFT JOIN dependencies USING (dependencyID)
                LEFT JOIN step_dependencies USING (stepID)
                LEFT JOIN workflow_steps ON step_dependencies.stepID=workflow_steps.stepID
                WHERE actionID = :actionID
                LIMIT 1';
            $res = $this->db->prepared_query($strSQL, $vars);
        }
        else
        {
            $vars = array(':actionID' => $res[0]['actionID']);
            $strSQL = 'SELECT * FROM action_history
                LEFT JOIN actions ON actions.actionType = action_history.actionType
                LEFT JOIN category_count USING (recordID)
                LEFT JOIN categories USING (categoryID)
                LEFT JOIN dependencies USING (dependencyID)
                LEFT JOIN step_dependencies USING (dependencyID)
                LEFT JOIN workflow_steps ON step_dependencies.stepID=workflow_steps.stepID
                WHERE actionID = :actionID
                LIMIT 1';
            $res = $this->db->prepared_query($strSQL, $vars);
        }

        // dependencyID -1 is for a person designated by the requestor
        if (isset($res[0])
            && $res[0]['dependencyID'] == -1)
        {
            $dir = $this->getDirectory();

            $approver = $dir->lookupLogin($res[0]['userID']);

            $res[0]['description'] = "{$approver[0]['firstName']} {$approver[0]['lastName']}";
        }
        // dependencyID -3 is for a group designated by the requestor
        if (isset($res[0])
                && $res[0]['dependencyID'] == -3)
        {
            $res[0]['description'] = $res[0]['stepTitle'];
        }

        // sanitize the comment on the action
        if (isset($res[0]) && isset($res[0]['comment']))
        {
            $res[0]['comment'] = XSSHelpers::sanitizeHTML($res[0]['comment']);
        }

        return $res[0];
    }

    /**
     * Get the last action made to the request with a summary of events
     */
    public function getLastActionSummary(): array | int
    {
        $lastActionData = $this->getLastAction();
        // check access
        if($lastActionData === 0) {
            return 0;
        }

        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT signatureID, signature, recordID, stepID, dependencyID, userID, timestamp, stepTitle, workflowID FROM signatures
            LEFT JOIN workflow_steps USING (stepID)
            WHERE recordID = :recordID';
        $res = $this->db->prepared_query($strSQL, $vars);

        if(count($res) > 0) {
            $dir = $this->getDirectory();

            $signedSteps = [];
            foreach($res as $key => $sig) {
                $signer = $dir->lookupLogin($sig['userID']);
                $res[$key]['name'] = "{$signer[0]['firstName']} {$signer[0]['lastName']}";
                $signedSteps[$res[$key]['stepID']] = 1;
            }

            $stepsPendingSigs = [];
            $vars = array(':workflowID' => $res[0]['workflowID']);
            $strSQL = 'SELECT * FROM workflow_steps
                WHERE workflowID = :workflowID
                AND requiresDigitalSignature = 1';
            $resWorkflow = $this->db->prepared_query($strSQL, $vars);
            foreach($resWorkflow as $step) {
                if(!isset($signedSteps[$step['stepID']])) {
                    $stepPendingSigs[] = $step['stepTitle'];
                }
            }
        }

        $output = [];
        $output['lastAction'] = $lastActionData;
        $output['signatures'] = $res;
        $output['stepsPendingSignature'] = $stepPendingSigs;
        return $output;
    }

    /**
     * Retrieves actions associated with a dependency
     * @param int $workflowID
     * @param int $stepID
     * @return array database result
     */
    public function getDependencyActions(int $workflowID, int $stepID): array
    {
        $vars = array(
            ':workflowID' => $workflowID,
            ':stepID' => $stepID,
        );
        $strSQL = 'SELECT * FROM workflow_routes
            LEFT JOIN actions USING (actionType)
            WHERE workflowID = :workflowID
            AND stepID = :stepID
            ORDER BY sort ASC';
        $res = $this->db->prepared_query($strSQL, $vars);

        return $res;
    }

    /**
     * Handle an action
     * @param int $dependencyID
     * @param string $actionType
     * @param string (optional) $comment
     * @return array {status(int), errors[string]}
     */
    public function handleAction(int $dependencyID, string $actionType, ?string $comment = ''): array
    {
        if (!is_numeric($dependencyID))
        {
            return array('status' => 0, 'errors' => array('Invalid ID: dependencyID'));
        }

        $errors = array();

        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return array('status' => 0, 'errors' => array('Invalid Token'));
        }

        $comment = XSSHelpers::sanitizeHTML($comment);
        $time = time();

        // first check if the user has access
        $vars = array(
            ':dependencyID' => $dependencyID,
            ':userID' => $this->login->getUserID()
        );
        $strSQL = 'SELECT * FROM dependency_privs
            LEFT JOIN users USING (groupID)
            WHERE dependencyID = :dependencyID
            AND userID = :userID';
        $res = $this->db->prepared_query($strSQL, $vars);


        if (!$this->login->checkGroup(1) && !isset($res[0]['userID']))
        {
            // check special cases
            $vars = array(':recordID' => $this->recordID);
            $strSQL = 'SELECT * FROM records WHERE recordID = :recordID';
            $res = $this->db->prepared_query($strSQL, $vars);

            switch ($dependencyID) {
                case 1: // service chief
                    if (!$this->login->checkService($res[0]['serviceID']))
                    {
                        return array('status' => 0, 'errors' => array('Your account is not registered as a Service Chief'));
                    }

                    break;
                case 8: // quadrad
                    $quadGroupIDs = $this->login->getQuadradGroupID();
                    $varsQuad = array(
                        ':serviceID' => $res[0]['serviceID'],
                    );
                    $strSQL = 'SELECT * FROM services
                        WHERE groupID IN ('.$quadGroupIDs.')
                        AND serviceID = :serviceID';
                    $resQuad = $this->db->prepared_query($strSQL, $varsQuad);

                    if (count($resQuad) == 0)
                    {
                        return array('status' => 0, 'errors' => array('Your account is not registered as an Executive Leadership Team member'));
                    }

                    break;
                case -1: // dependencyID -1 : person designated by requestor
                    $form = new Form($this->db, $this->login);

                    $varsPerson = array(':recordID' => $this->recordID);
                    $strSQL = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        WHERE recordID = :recordID';
                    $resPerson = $this->db->prepared_query($strSQL, $varsPerson);


                    $resEmpUID = $form->getIndicator($resPerson[0]['indicatorID_for_assigned_empUID'], 1, $this->recordID, null, true);
                    $empUID = $resEmpUID[$resPerson[0]['indicatorID_for_assigned_empUID']]['value'];

                    $userAuthorized = $this->checkEmployeeAccess($empUID);

                    if(!$userAuthorized){
                        return array('status' => 0, 'errors' => array('User account does not match'));
                    }

                    break;
                case -2: // dependencyID -2 : requestor followup
                    $form = new Form($this->db, $this->login);

                    $varsPerson = array(':recordID' => $this->recordID);
                    $strSQLPerson = 'SELECT userID FROM records WHERE recordID = :recordID';
                    $resPerson = $this->db->prepared_query($strSQLPerson, $varsPerson);


                    if ($resPerson[0]['userID'] != $this->login->getUserID())
                    {
                        $empUID = $this->getEmpUIDByUserName($resPerson[0]['userID']);

                        $userAuthorized = $this->checkEmployeeAccess($empUID);

                        if (!$userAuthorized)
                        {
                            return array('status' => 0, 'errors' => array('User account does not match'));
                        }
                    }

                    break;
                case -3: // dependencyID -3 : group designated by requestor
                    $form = new Form($this->db, $this->login);

                    $varsGroup = array(':recordID' => $this->recordID);
                    $strSQLGroup = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        WHERE recordID = :recordID';
                    $resGroup = $this->db->prepared_query($strSQLGroup, $varsGroup);


                    $resGroupID = $form->getIndicator($resGroup[0]['indicatorID_for_assigned_groupID'], 1, $this->recordID, null, true);
                    $groupID = $resGroupID[$resGroup[0]['indicatorID_for_assigned_groupID']]['value'];

                    if (!$this->login->checkGroup($groupID))
                    {
                        return array('status' => 0, 'errors' => array('User account is not part of the designated group'));
                    }

                    break;
                default:
                    return array('status' => 0, 'errors' => array('Invalid Operation'));

                    break;
            }
        }

        // get every step associated with dependencyID
        $vars = array(':recordID' => $this->recordID,
                      ':dependencyID' => $dependencyID, );
        $strSQL = 'SELECT * FROM step_dependencies
            RIGHT JOIN records_workflow_state USING (stepID)
            LEFT JOIN workflow_steps USING (stepID)
            LEFT JOIN dependencies USING (dependencyID)
            WHERE recordID = :recordID
            AND dependencyID = :dependencyID';
        $res = $this->db->prepared_query($strSQL, $vars);


        if(count($res) == 0) {
            return array('status' => 0, 'errors' => array('This page is out of date. Please refresh for the latest status.'));
        }

        $logCache = array();
        // iterate through steps
        foreach ($res as $actionable)
        {
            // find out what the action is doing, and what the next step is
            $vars2 = array(
                ':workflowID' => $actionable['workflowID'],
                ':stepID' => $actionable['stepID'],
                ':actionType' => $actionType,
            );
            $strSQL2 = 'SELECT * FROM workflow_routes
                LEFT JOIN actions USING (actionType)
                WHERE workflowID = :workflowID
                AND stepID = :stepID
                AND actionType = :actionType';
            $res2 = $this->db->prepared_query($strSQL2, $vars2);

            // continue if the step and action is valid
            if (isset($res2[0]))
            {
                $this->db->beginTransaction();
                // write dependency information
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':dependencyID' => $dependencyID,
                    ':filled' => $res2[0]['fillDependency'],
                    ':time' => $time, );
                $strSQL2 = 'INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                    VALUES (:recordID, :dependencyID, :filled, :time)
                    ON DUPLICATE KEY
                    UPDATE filled = :filled, time = :time';
                $this->db->prepared_query($strSQL2, $vars2);


                // don't write duplicate log entries
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':userID' => $this->login->getUserID(),
                    ':stepID' => $actionable['stepID'],
                    ':dependencyID' => $dependencyID,
                    ':actionType' => $actionType,
                    ':actionTypeID' => 8,
                    ':time' => $time,
                    ':comment' => $comment,
                );
                $logKey = sha1(serialize($vars2));
                if (!isset($logCache[$logKey]))
                {
                    // write log
                    $logCache[$logKey] = 1;
                    $strSQL2 ='INSERT INTO action_history (recordID, userID, stepID, dependencyID, actionType, actionTypeID, time, comment)
                        VALUES (:recordID, :userID, :stepID, :dependencyID, :actionType, :actionTypeID, :time, :comment)';
                    $this->db->prepared_query($strSQL2, $vars2);

                }

                // get other action data
                $varsAction = array(':actionType' => $actionType);
                $strSQLAction = 'SELECT * FROM actions WHERE actionType = :actionType';
                $resActionData = $this->db->prepared_query($strSQLAction, $varsAction);


                // write current status in main index
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':lastStatus' => $resActionData[0]['actionTextPasttense'],
                );
                $strSQL2 = 'UPDATE records SET lastStatus=:lastStatus
                    WHERE recordID = :recordID';
                $this->db->prepared_query($strSQL2, $vars2);


                $this->db->commitTransaction();

                // see if all dependencies in the step are met
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':stepID' => $actionable['stepID'],
                );
                $strSQL3 = 'SELECT * FROM step_dependencies
                    LEFT JOIN records_dependencies USING (dependencyID)
                    WHERE stepID = :stepID
                    AND recordID = :recordID
                    AND filled = 0';
                $res3 = $this->db->prepared_query($strSQL3, $vars2);

                $numUnfilledDeps = count($res3);

                // Trigger events if the next step is the same as the original step (eg: same-step loop)
                if ($actionable['stepID'] == $res2[0]['nextStepID'])
                {
                    $status = $this->handleEvents($actionable['workflowID'], $actionable['stepID'], $actionType, $comment);
                    if (count($status['errors']) > 0)
                    {
                        $errors = array_merge($errors, $status['errors']);
                    }

                    // clear current dependency since it's a loop
                    $vars_clearDep = array(
                        ':recordID' => $this->recordID,
                        ':dependencyID' => $dependencyID,
                    );
                    $strSQL_clearDep = 'UPDATE records_dependencies SET
                        filled = 0
                        WHERE recordID = :recordID
                        AND dependencyID = :dependencyID';
                    $this->db->prepared_query($strSQL_clearDep, $vars_clearDep);

                    $numUnfilledDeps = 1;
                }

                // if all dependencies are met, update the record's workflow state
                if ($numUnfilledDeps == 0
                    || $actionType == 'sendback')
                {	// handle sendback as a special case, since it doesn't fill any dependencies
                    // log step fulfillment data
                    $vars2 = array(
                        ':recordID' => $this->recordID,
                        ':stepID' => $actionable['stepID'],
                        ':time' => $time,
                    );
                    $strSQL2 = 'INSERT INTO records_step_fulfillment (recordID, stepID, fulfillmentTime)
                        VALUES (:recordID, :stepID, :time)
                        ON DUPLICATE KEY UPDATE fulfillmentTime = :time';
                    $this->db->prepared_query($strSQL2, $vars2);


                    // if the next step is to end it, then update the record's workflow's state
                    if ($res2[0]['nextStepID'] == 0)
                    {
                        $vars2 = array(':recordID' => $this->recordID);
                        $strSQL2 = 'DELETE FROM records_workflow_state
                            WHERE recordID = :recordID';
                        $this->db->prepared_query($strSQL2, $vars2);

                    }
                    else
                    {
                        $vars2 = array(
                            ':recordID' => $this->recordID,
                            ':stepID' => $actionable['stepID'],
                            ':nextStepID' => $res2[0]['nextStepID'],
                            ':lastNotified' => date('Y-m-d H:i:s'),
                            ':initialNotificationSent' => 0,
                            ':blockingStepID' => 0,
                        );
                        $strSQL2 = 'UPDATE records_workflow_state SET
                            stepID = :nextStepID,
                            blockingStepID = :blockingStepID,
                            lastNotified = :lastNotified,
                            initialNotificationSent = :initialNotificationSent
                            WHERE recordID = :recordID
                            AND stepID = :stepID';
                        $this->db->prepared_query($strSQL2, $vars2);


                        // reset records_dependencies for the next step
                        $this->resetRecordsDependency($res2[0]['nextStepID']);
                    }

                    // make sure the step is available
                    $vars2 = array(':recordID' => $this->recordID);
                    $strSQL2 = 'SELECT * FROM category_count
                        LEFT JOIN categories USING (categoryID)
                        LEFT JOIN workflows USING (workflowID)
                        LEFT JOIN workflow_steps USING (workflowID)
                        LEFT JOIN step_dependencies USING (stepID)
                        LEFT JOIN records_dependencies USING (recordID, dependencyID)
                        WHERE category_count.recordID = :recordID
                        AND count > 0
                        AND workflowID > 0
                        AND filled IS NULL';
                    $res3 = $this->db->prepared_query($strSQL2, $vars2);

                    if (count($res3) > 0)
                    {
                        $this->db->beginTransaction();
                        foreach ($res3 as $nextStep)
                        {
                            $vars2 = array(
                                ':recordID' => $this->recordID,
                                ':dependencyID' => $nextStep['dependencyID'],
                                ':filled' => 0,
                            );
                            $strSQL2 = 'INSERT IGNORE INTO records_dependencies (recordID, dependencyID, filled)
                                VALUES (:recordID, :dependencyID, :filled)';
                            $this->db->prepared_query($strSQL2, $vars2);

                        }
                        $this->db->commitTransaction();
                    }

                    // Done with database updates for dependency/state

                    // determine if parallel workflows have shared steps
                    $vars2 = array(':recordID' => $this->recordID);
                    $strSQL3 = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        LEFT JOIN step_dependencies USING (stepID)
                        WHERE recordID = :recordID';
                    $res3 = $this->db->prepared_query($strSQL3, $vars2);

                    // iterate through steps
                    if (count($res3) > 1)
                    {
                        foreach ($res3 as $step)
                        {
                            $conflictID = $this->checkDependencyConflicts($step, $res3);
                            if ($conflictID != 0 && $conflictID != $step['stepID'])
                            {
                                $vars2 = array(
                                    ':recordID' => $this->recordID,
                                    ':stepID' => $step['stepID'],
                                    ':lastNotified' => date('Y-m-d H:i:s'),
                                    ':initialNotificationSent' => 0,
                                    ':blockingStepID' => $conflictID,
                                );
                                $strSQL2 = 'UPDATE records_workflow_state SET
                                    blockingStepID = :blockingStepID,
                                    lastNotified = :lastNotified,
                                    initialNotificationSent = :initialNotificationSent
                                    WHERE recordID = :recordID
                                    AND stepID = :stepID';
                                $this->db->prepared_query($strSQL2, $vars2);

                            }
                        }
                    }

                    // Handle events if all dependencies in the step have been met
                    $status = $this->handleEvents($actionable['workflowID'], $actionable['stepID'], $actionType, $comment);
                    if (count($status['errors']) > 0)
                    {
                        $errors = array_merge($errors, $status['errors']);
                    }
                } // End update the record's workflow state
            }
        }


        $comment_post = array('date' => date('M j', $time), 'user_name' => $this->login->getName(), 'comment' => $comment, 'responder' => $resActionData[0]['actionTextPasttense'], 'nextStep' => $res2[0]['nextStepID']);


        return array('status' => 1, 'errors' => $errors, 'comment' => $comment_post);
    }


     /**
      * Gets empuID for given username
      * @param string $userName Username
      * @return string
      */
    public function getEmpUIDByUserName(string $userName): ?string
    {
        if(isset($this->cache['getEmpUIDByUserName'.$userName])) {
            return $this->cache['getEmpUIDByUserName'.$userName];
        }

        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        $strSQL = 'SELECT * FROM employee WHERE userName = :userName';
        $this->cache['getEmpUIDByUserName'.$userName] = $nexusDB->prepared_query($strSQL, $vars)[0]["empUID"];
        return $this->cache['getEmpUIDByUserName'.$userName];
    }

    /**
     * Checks if logged in user has access to the given empUID
     * Also checks if the current user is a backup of the given empUID
     *
     * $empUID should be an int, if it is not thus method will
     * not return the expected result. setting the type in the method
     * signature to mixed as we currently have string, array and null
     * coming through.
     *
     * @param string $empUID empUID to check
     * @return boolean
     */
    public function checkEmployeeAccess(mixed $empUID): bool
    {
        $empUID = (int)$empUID;
        if ($empUID == $this->login->getEmpUID())
        {
            return true;
        }

        if(isset($this->cache['checkEmployeeAccess'])) {
            return isset($this->cache['checkEmployeeAccess'][$empUID]);
        }

        $nexusDB = $this->login->getNexusDB();
        $vars = array(':currEmpUID' => $this->login->getEmpUID());
        $strSQL = 'SELECT empUID FROM relation_employee_backup
                    WHERE backupEmpUID =:currEmpUID
                        AND approved=1';
        $backupIds = $nexusDB->prepared_query($strSQL, $vars);

        $this->cache['checkEmployeeAccess'] = [];
        foreach ($backupIds as $row)
        {
            $this->cache['checkEmployeeAccess'][$row['empUID']] = true;
        }

        return isset($this->cache['checkEmployeeAccess'][$empUID]);
    }

    /**
     * Handle events tied to actions, if there are any
     * @param int $workflowID
     * @param int $stepID
     * @param string $actionType
     * @param string (optional) $comment
     * @return array {status(int), errors[]}
     * @throws Exception
     */
    public function handleEvents(int $workflowID, int $stepID, string $actionType, ?string $comment = ''): array
    {
        $errors = array();

        // Take care of special events (sendback)
        if ($actionType == 'sendback')
        {
            $vars2 = array(':recordID' => $this->recordID);
            $strSQL2 = 'SELECT * FROM records_workflow_state
                WHERE recordID = :recordID';
            $res = $this->db->prepared_query($strSQL2, $vars2);

            if (count($res) == 0)
            {	// if the workflow state is empty, it means the request has been sent back to the requestor
                $form = new Form($this->db, $this->login);
                $form->openForEditing($this->recordID);
            }

            // Send emails
            $email = new Email();

            $vars = array(':recordID' => $this->recordID);
            $strSQL = 'SELECT rec.title, rec.userID, ser.service FROM records AS rec
                LEFT JOIN services AS ser USING (serviceID)
                WHERE recordID = :recordID';
            $record = $this->db->prepared_query($strSQL, $vars);


            $vars = array(':stepID' => $stepID);
            $strSQL = 'SELECT stepTitle FROM workflow_steps WHERE stepID = :stepID';
            $groupName = $this->db->prepared_query($strSQL, $vars);


            $title = strlen($record[0]['title']) > 45 ? substr($record[0]['title'], 0, 42) . '...' : $record[0]['title'];

            $email->addSmartyVariables(array(
                "truncatedTitle" => $title,
                "fullTitle" => $record[0]['title'],
                "recordID" => $this->recordID,
                "service" => $record[0]['service'],
                "stepTitle" => $groupName[0]['stepTitle'],
                "comment" => $comment,
                "siteRoot" => $this->siteRoot
            ));
            $email->setTemplateByID(Email::SEND_BACK);

            $dir = $this->getDirectory();

            $requester = $dir->lookupLogin($record[0]['userID']);
            $author = $dir->lookupLogin($this->login->getUserID());
            $email->addRecipient($requester[0]['Email']);
            $email->addRecipient($author[0]['Email']);

            // Get backups to requester so they can be notified as well
            $nexusDB = $this->login->getNexusDB();
            $vars = array(
              ':reqEmpUID'  => $requester[0]['empUiD'],
              ':authEmpUID' => $author[0]['empUID']
            );
            $strSQL = 'SELECT DISTINCT backupEmpUID FROM relation_employee_backup
                WHERE empUID IN (:reqEmpUID, :authEmpUID)';
            $backupIds = $nexusDB->prepared_query($strSQL, $vars);


            // Add backups to email recepients
            foreach($backupIds as $backup) {
              // Don't re-email requestor or author if they are backups of each other
              if (($backup['backupEmpUID'] != $author[0]['empUID']) &&
                ($backup['backupEmpUID'] != $requester[0]['empID'])) {
                  $theirBackup = $dir->lookupEmpUID($backup['backupEmpUID']);
                  $email->addRecipient($theirBackup[0]['Email']);
              }
            }

            $email->setSender($author[0]['Email']);
            $email->sendMail($this->recordID);
        }

        // Handle Events
        $varEvents = array(':workflowID' => $workflowID,
                           ':stepID' => $stepID,
                           ':actionType' => $actionType,
        );
        $strSQL = 'SELECT rt.eventID, eventData, eventDescription FROM route_events AS rt
            LEFT JOIN events as et USING (eventID)
            WHERE workflowID = :workflowID
            AND stepID = :stepID
            AND actionType = :actionType
            ORDER BY eventID ASC';
        $res = $this->db->prepared_query($strSQL, $varEvents);

        foreach ($res as $event)
        {
            $customEvent = '';
            if (preg_match('/CustomEvent_/', $event['eventID'])) {
                $customEvent = $event['eventID'];
            }
            $fields = $this->getFields();

            switch ($event['eventID']) {
                case 'std_email_notify_next_approver': // notify next approver
                    $email = new Email();

                    $email->addSmartyVariables(array(
                        "comment" => $comment,
                        "field" => $fields
                    ));

                    $dir = $this->getDirectory();

                    $author = $dir->lookupLogin($this->login->getUserID());
                    $email->setSender($author[0]['Email']);

                    $email->attachApproversAndEmail($this->recordID, Email::NOTIFY_NEXT, $this->login);

                    break;
                case 'std_email_notify_completed': // notify requestor of completed request

                    $vars = array(':recordID' => $this->recordID);

                    // get the record and requestor
                    $strSQL = 'SELECT rec.title, rec.lastStatus, rec.userID, ser.service
                        FROM records AS rec
                        LEFT JOIN services AS ser USING (serviceID)
                        WHERE recordID = :recordID';
                    $requestRecords = $this->db->prepared_query($strSQL, $vars);

                    // get the person that has commited  the action since we would want to send from that email
                    $lastAdctionSql = 'SELECT action_history.actionID, action_history.userID
                        FROM records
                        JOIN action_history USING(recordID)
                        WHERE recordID = :recordID
                        ORDER BY actionID DESC LIMIT 1';

                    $lastActions = $this->db->prepared_query($lastAdctionSql, $vars);

                    if(!empty($requestRecords[0]) && is_array($requestRecords[0]) && !empty($lastActions[0]) && is_array($lastActions[0]) ){

                        $email = new Email();

                        $title = strlen($requestRecords[0]['title']) > 45 ? substr($requestRecords[0]['title'], 0, 42) . '...' : $requestRecords[0]['title'];

                        $email->addSmartyVariables(array(
                            "truncatedTitle" => $title,
                            "fullTitle" => $requestRecords[0]['title'],
                            "recordID" => $this->recordID,
                            "service" => $requestRecords[0]['service'],
                            "lastStatus" => $requestRecords[0]['lastStatus'],
                            "comment" => $comment,
                            "siteRoot" => $this->siteRoot,
                            "field" => $fields
                        ));
                        $email->setTemplateByID(Email::NOTIFY_COMPLETE);

                        $dir = $this->getDirectory();

                        $author = $dir->lookupLogin($requestRecords[0]['userID']);// this is the requestors info

                        // set the sender which should be the last person to take action
                        $lastActionAuthor = $dir->lookupLogin($lastActions[0]['userID']);
                        $email->setSender($lastActionAuthor[0]['Email']);

                        // Get backups to requester so they can be notified as well
                        $nexusDB = $this->login->getNexusDB();
                        $vars = array(':empUID' => $author[0]['empUID']);
                        $strSQL = 'SELECT backupEmpUID FROM relation_employee_backup
                            WHERE empUID = :empUID';
                        $backupIds = $nexusDB->prepared_query($strSQL, $vars);

                        // Add backups to email recepients
                        foreach($backupIds as $backup) {
                        $theirBackup = $dir->lookupEmpUID($backup['backupEmpUID']);
                            $email->addRecipient($theirBackup[0]['Email']);
                        }

                        $tmp = $dir->lookupLogin($requestRecords[0]['userID']);
                        $email->addRecipient($tmp[0]['Email']);

                        $email->sendMail($this->recordID);
                    }
                    break;
                case $customEvent: // For all custom events

                    $vars = array(':recordID' => $this->recordID);

                    // get the record and requestor
                    $strSQL = 'SELECT rec.title, rec.lastStatus, rec.userID, ser.service
                        FROM records AS rec
                        LEFT JOIN services AS ser USING (serviceID)
                        WHERE recordID = :recordID';
                    $requestRecords = $this->db->prepared_query($strSQL, $vars);

                    // get the person that has commited  the action since we would want to send from that email
                    $lastAdctionSql = 'SELECT action_history.actionID, action_history.userID
                        FROM records
                        JOIN action_history USING(recordID)
                        WHERE recordID = :recordID
                        ORDER BY actionID DESC LIMIT 1';

                    $lastActions = $this->db->prepared_query($lastAdctionSql, $vars);

                    if(!empty($requestRecords[0]) && is_array($requestRecords[0]) && !empty($lastActions[0]) && is_array($lastActions[0]) ){

                        $email = new Email();

                        $title = strlen($requestRecords[0]['title']) > 45 ? substr($requestRecords[0]['title'], 0, 42) . '...' : $requestRecords[0]['title'];

                        $email->addSmartyVariables(array(
                            "truncatedTitle" => $title,
                            "fullTitle" => $requestRecords[0]['title'],
                            "recordID" => $this->recordID,
                            "service" => $requestRecords[0]['service'],
                            "lastStatus" => $requestRecords[0]['lastStatus'],
                            "comment" => $comment,
                            "siteRoot" => $this->siteRoot,
                            "field" => $fields
                        ));

                        $emailTemplateID = $email->getTemplateIDByLabel($event['eventDescription']);
                        $email->setTemplateByID($emailTemplateID);

                        $dir = $this->getDirectory();

                        $author = $dir->lookupLogin($requestRecords[0]['userID']);

                        // set the sender which should be the last person to take action
                        $lastActionAuthor = $dir->lookupLogin($lastActions[0]['userID']);
                        $email->setSender($lastActionAuthor[0]['Email']);

                        $eventData = json_decode($event['eventData']);

                        if ($eventData->NotifyRequestor === 'true') {
                            // Get backups to requester so they can be notified as well
                            $nexusDB = $this->login->getNexusDB();
                            $vars = array(':empUID' => $author[0]['empUID']);
                            $strSQL = 'SELECT backupEmpUID FROM relation_employee_backup
                                WHERE empUID = :empUID';
                            $backupIds = $nexusDB->prepared_query($strSQL, $vars);

                            // Add backups to email recepients
                            foreach($backupIds as $backup) {
                                $theirBackup = $dir->lookupEmpUID($backup['backupEmpUID']);
                                $email->addRecipient($theirBackup[0]['Email']);
                            }

                            $tmp = $dir->lookupLogin($requestRecords[0]['userID']);
                            $email->addRecipient($tmp[0]['Email']);
                        }

                        if ($eventData->NotifyGroup !== 'None') {
                            $email->addGroupRecipient($eventData->NotifyGroup);
                        }


                        if ($eventData->NotifyNext === 'true') {
                            $email->attachApproversAndEmail($this->recordID, $emailTemplateID, $this->login);

                        } else {
                            $email->sendMail($this->recordID);
                        }
                    }

                    break;
                default:
                    $eventFile = $this->eventFolder . 'CustomEvent_' . $event['eventID'] . '.php';
                    if (is_file($eventFile))
                    {

                        $dir = $this->getDirectory();
                        $email = new Email();

                        $eventInfo = array('recordID' => $this->recordID,
                                           'workflowID' => $workflowID,
                                           'stepID' => $stepID,
                                           'actionType' => $actionType,
                                           'comment' => $comment,
                                           "field" => $fields
                        );

                        $customClassName = "Portal\\CustomEvent_{$event['eventID']}";

                        try
                        {
                            $event = new $customClassName($this->db, $this->login, $dir, $email, $this->siteRoot, $eventInfo);
                            $event->execute();
                        } catch (Exception $e) {
                            $errors[] = $e->getMessage();
                        }
                    } else {
                        trigger_error('Custom event not found: ' . $eventFile);
                    }

                    break;
            }
        }

        return array('status' => 1, 'errors' => $errors);
    }

    /**
     * Get the field values of the current record
     */
    private function getFields(): array
    {
        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT `data`.`indicatorID`, `data`.`series`, `data`.`data`, `indicators`.`format`, `indicators`.`default`, `indicators`.`is_sensitive` FROM `data`
            JOIN `indicators` USING (`indicatorID`)
            WHERE `recordID` = :recordID';

        $fields = $this->db->prepared_query($strSQL, $vars);

        $formattedFields = array();

        foreach($fields as $field)
        {
            if ($field["is_sensitive"] == 1) {
                $formattedFields[$field['indicatorID']] = "**********";
                continue;
            }

            $format = strtolower($field["format"]);
            $data = $field["data"];

            switch(true) {
                case (str_starts_with($format, "grid") != false):
                    if(!empty($data) && is_array(unserialize($data))){
                        $data = $this->buildGrid(unserialize($data));
                    }
                    break;
                case (str_starts_with($format, "checkboxes") != false):
                case (str_starts_with($format, "multiselect") != false):
                    if(!empty($data) && is_array(unserialize($data))){
                        $data = $this->buildMultiOption(unserialize($data));
                    }
                    break;
                case (str_starts_with($format, "radio") != false):
                case (str_starts_with($format, "checkbox") != false):
                    if ($data == "no") {
                        $data = "";
                    }
                    break;
                case ($format == "fileupload"):
                case ($format == "image"):
                    $data = $this->buildFileLink($data, $field["indicatorID"], $field["series"]);
                    break;
                case ($format == "orgchart_group"):
                    $data = $this->getOrgchartGroup((int) $data);
                    break;
                case ($format == "orgchart_position"):
                    $data = $this->getOrgchartPosition((int) $data);
                    break;
                case ($format == "orgchart_employee"):
                    $data = $this->getOrgchartEmployee((int) $data);
                    break;
            }

            $formattedFields[$field['indicatorID']] = $data !== "" ? $data : $field["default"];
        }

        return $formattedFields;
    }

    private function isJsonString(mixed $data): bool
    {
        json_decode($data);

        return json_last_error() === 0;
    }

    // method for building grid
    private function buildGrid(array $data): string
    {
        // get the grid in the form of array
        $cells = $data['cells'];
        $headers = $data['names'];

        // build the grid
        $grid = "<table><tr>";

        foreach($headers as $header) {
            if ($header !== " ") {
                $grid .= "<th>{$header}</th>";
            }
        }
        $grid .= "</tr>";

        foreach($cells as $row) {
            $grid .= "<tr>";
            foreach($row as $column) {
                $grid .= "<td>{$column}</td>";
            }
            $grid .= "</tr>";
        }
        $grid .= "</table>";

        return $grid;
    }

    private function buildMultiOption(array $data): string
    {
        // filter out non-selected selections
        $data = array_filter($data, function($x) { return $x !== "no"; });
        // list to be readable in email
        $formattedData = "\r\n";
        foreach($data as $item) {
            $formattedData .= "- ".$item."\r\n";
        }
        return $formattedData;
    }

    private function buildFileLink(string $data, string $id, string $series): string
    {
        // split the file names out into an array
        $data = explode("\n", $data);
        $buffer = [];

        // parse together the links to each file
        foreach($data as $index => $file) {
            $buffer[] = "<a href=\"{$this->siteRoot}file.php?form={$this->recordID}&id={$id}&series={$series}&file={$index}\">{$file}</a>";
        }

        // separate the links by comma
        $formattedData = implode(", ", $buffer);
        return $formattedData;
    }

    // method for building orgchart group, position, employee
    private function getOrgchartGroup(int $data): string
    {
        // reference the group by id
        $group = new Group($this->db, $this->login);
        $groupName = $group->getGroupName($data);

        return $groupName;
    }

    private function getOrgchartPosition(int $data): string
    {
        $position = new \Orgchart\Position($this->oc_db, $this->login);
        $positionName = $position->getTitle($data);

        return $positionName;
    }

    private function getOrgchartEmployee(int $data): string
    {
        $employee = new \Orgchart\Employee($this->oc_db, $this->login);
        $employeeData = $employee->lookupEmpUID($data)[0];
        $employeeEmail = $employeeData["email"];

        return $employeeEmail;
    }

    /**
     * Set the the current record to a specific step
     * Require admin access unless bypass is requested
     * Do not use in combination with multiple simultaneous workflows
     */
    public function setStep(int $stepID, bool $bypassAdmin = false, string $comment = ''): bool
    {
        if (!is_numeric($stepID))
        {
            return false;
        }
        $comment = XSSHelpers::sanitizeHTML($comment);

        if ($this->recordID == 0
            || (!$this->login->checkGroup(1) && $bypassAdmin == false))
        {
            return false;
        }

        // make sure the request has been submitted
        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT * FROM records WHERE recordID = :recordID';
        $res = $this->db->prepared_query($strSQL, $vars);
        if ($res[0]['submitted'] == 0)
        {
            $vars = array(
                ':recordID' => $this->recordID,
                ':submitted' => time(),
            );
            $strSQL = 'UPDATE records
                SET submitted = :submitted
                WHERE recordID = :recordID';
            $res = $this->db->prepared_query($strSQL, $vars);
        }

        $vars = array(':stepID' => $stepID);
        $strSQL = 'SELECT * FROM workflow_steps WHERE stepID = :stepID';
        $res = $this->db->prepared_query($strSQL, $vars);
        $stepName = $res[0]['stepTitle'];

        if ($comment != '')
        {
            $comment = "Moved to {$stepName} step. " . $comment;
        }
        else
        {
            $comment = "Moved to {$stepName} step";
        }
        // write log entry
        $vars2 = array(
            ':recordID' => $this->recordID,
            ':userID' => $this->login->getUserID(),
            ':dependencyID' => 0,
            ':actionType' => 'move',
            ':actionTypeID' => 8,
            ':time' => time(),
            ':comment' => $comment,
        );
        $strSQL2 = 'INSERT INTO action_history
            (recordID, userID, dependencyID, actionType, actionTypeID, time, comment)
            VALUES
            (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment)';
        $this->db->prepared_query($strSQL2, $vars2);

        $vars2 = array(':recordID' => $this->recordID);
        $strSQL2 = 'DELETE FROM records_workflow_state
            WHERE recordID = :recordID';
        $this->db->prepared_query($strSQL2, $vars2);
        $this->resetRecordsDependency($stepID);
        $vars = array(
            ':recordID' => $this->recordID,
            ':stepID' => $stepID,
        );
        $strSQL = 'INSERT INTO records_workflow_state (recordID, stepID) VALUES (:recordID, :stepID)';
        $this->db->prepared_query($strSQL, $vars);
        return true;
    }

    public function setEventFolder(string $folder): void
    {
        $this->eventFolder = $folder;
    }

    /**
     * For parallel workflows, check if the current dependency conflicts between workflows
     * @param array $dep
     * @param array $steps
     * @return int conflicting step ID
     */
    private function checkDependencyConflicts(array $dep, array $steps): int
    {
        // iterate through steps
        foreach ($steps as $step)
        {
            // unblock step if prerequisites are met
            if ($dep['blockingStepID'] == $step['stepID'])
            {
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':stepID' => $dep['stepID'],
                    ':lastNotified' => date('Y-m-d H:i:s'),
                    ':initialNotificationSent' => 0,
                    ':blockingStepID' => 0,
                );
                $strSQL = 'UPDATE records_workflow_state SET
                    blockingStepID = :blockingStepID,
                    lastNotified = :lastNotified,
                    initialNotificationSent = :initialNotificationSent
                    WHERE recordID = :recordID
                    AND stepID = :stepID';
                $this->db->prepared_query($strSQL, $vars2);
            }

            // if it's not the same dependency, find out if there are any conflicts
            if ($dep['dependencyID'] != $step['dependencyID']
                && $dep['stepID'] != $step['stepID'])
            {
                // check conflict exclusion for steps with multiple dependencies
                $foundShared = 0;
                foreach ($steps as $step2)
                {
                    if ($dep['dependencyID'] != $step2['dependencyID']
                        && $dep['stepID'] == $step2['stepID'])
                    {
                        $foundShared = 1;
                    }
                }

                if ($foundShared == 0)
                {
                    $vars = array(
                        ':dependencyID' => $dep['dependencyID'],
                        ':workflowID' => $step['workflowID'],
                    );
                    $strSQL = 'SELECT * FROM workflow_routes
                        LEFT JOIN step_dependencies USING (stepID)
                        WHERE dependencyID = :dependencyID
                        AND workflowID = :workflowID';
                    $res = $this->db->prepared_query($strSQL, $vars);

                    if (isset($res[0]))
                    {
                        return $step['stepID'];
                    }
                }
            }
        }

        return 0;
    }

    private function resetRecordsDependency(int $stepID): void
    {
        $vars2 = array(':stepID' => $stepID);
        $strSQL2 = 'SELECT * FROM step_dependencies
            WHERE stepID = :stepID';
        $res3 = $this->db->prepared_query($strSQL2, $vars2);
        if (count($res3) > 0)
        {
            foreach ($res3 as $stepDependency)
            {
                $vars2 = array(':recordID' => $this->recordID,
                        ':dependencyID' => $stepDependency['dependencyID'], );
                $strSQL2 = 'UPDATE records_dependencies SET
                    filled = 0
                    WHERE recordID = :recordID
                    AND dependencyID = :dependencyID';
                $this->db->prepared_query($strSQL2, $vars2);
            }
        }
    }
}
