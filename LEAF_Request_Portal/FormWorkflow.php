<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Workflow
    Date Created: May 25, 2011
*/

if (!class_exists('XSSHelpers'))
{
    require_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

class FormWorkflow
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $recordID;

    // workflow actions are triggered from ./api/ except on submit
    private $eventFolder = '../scripts/events/';

    public function __construct($db, $login, $recordID)
    {
        $this->db = $db;
        $this->login = $login;
        $this->recordID = is_numeric($recordID) ? $recordID : 0;

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $apiEntry = strpos($this->siteRoot, '/api/');
        if ($apiEntry !== false)
        {
            $this->siteRoot = substr($this->siteRoot, 0, $apiEntry + 1);
        }
    }

    public function initRecordID($recordID)
    {
        $this->recordID = is_numeric($recordID) ? $recordID : 0;
    }

    /**
     * Checks if the current record has an active workflow
     * @return bool
     */
    public function isActive()
    {
        $vars = array(':recordID' => $this->recordID);
        $res = $this->db->prepared_query('SELECT * FROM records_workflow_state
        									WHERE recordID=:recordID', $vars);

        return isset($res[0]);
    }

    /**
     * Retrieves current steps of a form's workflow, controls access to steps
     * @return array database result
     * @return null if no database result
     */
    public function getCurrentSteps()
    {
        // check privileges
        require_once 'form.php';
        $form = new Form($this->db, $this->login);
        if (!$form->hasReadAccess($this->recordID))
        {
            return 0;
        }

        $steps = array();
        $vars = array(':recordID' => $this->recordID);
        $res = $this->db->prepared_query('SELECT dependencyID, recordID, stepID, stepTitle, blockingStepID, workflowID, serviceID, stepBgColor, stepFontColor, stepBorder, description, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID, jsSrc, userID, requiresDigitalSignature FROM records_workflow_state
        									LEFT JOIN records USING (recordID)
        									LEFT JOIN workflow_steps USING (stepID)
        									LEFT JOIN step_dependencies USING (stepID)
        									LEFT JOIN dependencies USING (dependencyID)
        									LEFT JOIN records_dependencies USING (recordID, dependencyID)
        									WHERE recordID=:recordID
        										AND (filled=0 OR filled IS NULL)', $vars);

        $numRes = count($res);
        if ($numRes > 0)
        {
            for ($i = 0; $i < $numRes; $i++)
            {
                $res[$i]['dependencyActions'] = $this->getDependencyActions($res[$i]['workflowID'], $res[$i]['stepID']);
                // override access if user is in the admin group
                $res[$i]['hasAccess'] = $this->login->checkGroup(1); // initialize hasAccess

                // check permissions
                $vars = array(':dependencyID' => $res[$i]['dependencyID']);
                $res2 = $this->db->prepared_query('SELECT * FROM dependency_privs
                									WHERE dependencyID=:dependencyID', $vars);

                // dependencyID 1 is for a special service chief group
                if ($res[$i]['dependencyID'] == 1 && !$res[$i]['hasAccess'])
                {
                    if ($this->login->checkService($res[$i]['serviceID']))
                    {
                        $res[$i]['hasAccess'] = true;
                    }
                }

                // dependencyID 8 is for a special quadrad group
                if ($res[$i]['dependencyID'] == 8 && !$res[$i]['hasAccess'])
                {
                    $quadGroupIDs = $this->login->getQuadradGroupID();
                    $vars3 = array(':serviceID' => $res[$i]['serviceID']);
                    $res3 = $this->db->prepared_query("SELECT * FROM services
                    									WHERE groupID IN ($quadGroupIDs)
                    										AND serviceID=:serviceID", $vars3);

                    if (isset($res3[0]))
                    {
                        $res[$i]['hasAccess'] = true;
                    }
                }

                // dependencyID -1 is for a person designated by the requestor
                if ($res[$i]['dependencyID'] == -1)
                {
                    $resEmpUID = $form->getIndicator($res[$i]['indicatorID_for_assigned_empUID'], 1, $this->recordID);

                    // make sure the right person has access
                    if (!$res[$i]['hasAccess'])
                    {
                        $empUID = $resEmpUID[$res[$i]['indicatorID_for_assigned_empUID']]['value'];

                        //check if the requester has any backups
                        //get nexus db
                        $nexusDB = $this->login->getNexusDB();
                        $vars4 = array(':empId' => $empUID);
                        $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);

                        if ($empUID == $this->login->getEmpUID())
                        {
                            $res[$i]['hasAccess'] = true;
                        }
                        else
                        {
                            //check and provide access to backups
                            foreach ($backupIds as $row)
                            {
                                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                                {
                                    $res[$i]['hasAccess'] = true;
                                }
                            }
                        }
                    }

                    require_once 'VAMC_Directory.php';
                    $dir = new VAMC_Directory;

                    $approver = $dir->lookupEmpUID($resEmpUID[$res[$i]['indicatorID_for_assigned_empUID']]['value']);

                    $res[$i]['description'] = $res[$i]['stepTitle'] . ' (' . $approver[0]['Fname'] . ' ' . $approver[0]['Lname'] . ')';
                    if (trim($res[$i]['description']) == '')
                    {
                        $res[$i]['description'] = $res[$i]['stepTitle'] . ' (' . $resEmpUID[$res[$i]['indicatorID_for_assigned_empUID']]['name'] . ')';
                    }
                }

                // dependencyID -2 is for requestor followup
                if ($res[$i]['dependencyID'] == -2 && !$res[$i]['hasAccess'])
                {
                    $hasAccess = $res[$i]['userID'] == $this->login->getUserID();

                    if(!$hasAccess){
                        $empUID = $this->getEmpUIDByUserName($res[$i]['userID']);
                        $hasAccess = $this->checkIfBackup($empUID);
                    }

                    $res[$i]['hasAccess'] = $hasAccess;
                }

                // dependencyID -3 is for a group designated by the requestor
                if ($res[$i]['dependencyID'] == -3)
                {
                    $resGroupID = $form->getIndicator($res[$i]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
                    $groupID = $resGroupID[$res[$i]['indicatorID_for_assigned_groupID']]['value'];

                    // make sure the right person has access
                    if (!$res[$i]['hasAccess'])
                    {
                        if ($this->login->checkGroup($groupID))
                        {
                            $res[$i]['hasAccess'] = true;
                        }
                    }

                    $res[$i]['description'] = $resGroupID[$res[$i]['indicatorID_for_assigned_groupID']]['name'];

                    // find actual group name
                    $vars = array(':groupID' => $groupID);
                    $tGroup = $this->db->prepared_query('SELECT * FROM `groups` WHERE groupID=:groupID', $vars);
                    if (count($tGroup) >= 0)
                    {
                        $res[$i]['description'] = $tGroup[0]['name'];
                    }

                    $res[$i]['description'] ?? 'Warning: Group Name has not been imported in the User Access Group';
                }

                foreach ($res2 as $group)
                {
                    if ($this->login->checkGroup($group['groupID']))
                    {
                        $res[$i]['hasAccess'] = true;

                        break;
                    }
                }

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
                $resSm = $this->db->prepared_query('SELECT moduleName, moduleConfig FROM step_modules
                                                        WHERE stepID=:stepID', $varsSm);
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
    public function getLastAction()
    {
        // check privileges
        require_once 'form.php';
        $form = new Form($this->db, $this->login);
        if (!$form->hasReadAccess($this->recordID))
        {
            return 0;
        }

        $vars = array(':recordID' => $this->recordID);
        $res = $this->db->prepared_query('SELECT * FROM action_history
	    									WHERE recordID=:recordID
	    										AND actionType IS NOT NULL
    											AND dependencyID != 0
	    									ORDER BY actionID DESC
	    									LIMIT 1', $vars);

        // backwards compatibility for records where action_history.stepID doesn't exist
        if ($res[0]['stepID'] > 0)
        {
            $vars = array(':actionID' => $res[0]['actionID']);
            $res = $this->db->prepared_query('SELECT * FROM action_history
	    									LEFT JOIN actions ON actions.actionType = action_history.actionType
	    									LEFT JOIN category_count USING (recordID)
	    									LEFT JOIN categories USING (categoryID)
	    									LEFT JOIN dependencies USING (dependencyID)
	    									LEFT JOIN step_dependencies USING (stepID)
	    									LEFT JOIN workflow_steps ON step_dependencies.stepID=workflow_steps.stepID
	    									WHERE actionID=:actionID
    											LIMIT 1', $vars);
        }
        else
        {
            $vars = array(':actionID' => $res[0]['actionID']);
            $res = $this->db->prepared_query('SELECT * FROM action_history
	    									LEFT JOIN actions ON actions.actionType = action_history.actionType
	    									LEFT JOIN category_count USING (recordID)
	    									LEFT JOIN categories USING (categoryID)
	    									LEFT JOIN dependencies USING (dependencyID)
	    									LEFT JOIN step_dependencies USING (dependencyID)
	    									LEFT JOIN workflow_steps ON step_dependencies.stepID=workflow_steps.stepID
	    									WHERE actionID=:actionID
    											LIMIT 1', $vars);
        }

        // dependencyID -1 is for a person designated by the requestor
        if (isset($res[0])
            && $res[0]['dependencyID'] == -1)
        {
            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

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
    public function getLastActionSummary()
    {
        $lastActionData = $this->getLastAction();
        // check access
        if($lastActionData === 0) {
            return 0;
        }

        $vars = array(':recordID' => $this->recordID);
        $res = $this->db->prepared_query('SELECT signatureID, signature, recordID, stepID, dependencyID, userID, timestamp, stepTitle, workflowID FROM signatures
                                            LEFT JOIN workflow_steps USING (stepID)
	    									WHERE recordID=:recordID', $vars);

        if(count($res) > 0) {
            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

            $signedSteps = [];
            foreach($res as $key => $sig) {
                $signer = $dir->lookupLogin($sig['userID']);
                $res[$key]['name'] = "{$signer[0]['firstName']} {$signer[0]['lastName']}";
                $signedSteps[$res[$key]['stepID']] = 1;
            }

            $stepsPendingSigs = [];
            $vars = array(':workflowID' => $res[0]['workflowID']);
            $resWorkflow = $this->db->prepared_query('SELECT * FROM workflow_steps
                                                        WHERE workflowID=:workflowID
                                                            AND requiresDigitalSignature = 1', $vars);
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
    public function getDependencyActions($workflowID, $stepID)
    {
        $vars = array(':workflowID' => $workflowID,
                      ':stepID' => $stepID, );
        $res = $this->db->prepared_query('SELECT * FROM workflow_routes
        									LEFT JOIN actions USING (actionType)
        									WHERE workflowID=:workflowID
        										AND stepID=:stepID
        									ORDER BY sort ASC', $vars);

        return $res;
    }

    /**
     * Handle an action
     * @param int $dependencyID
     * @param string $actionType
     * @param string $comment
     * @return array {status(int), errors[string]}
     */
    public function handleAction($dependencyID, $actionType, $comment)
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
        $vars = array(':dependencyID' => $dependencyID,
                      ':userID' => $this->login->getUserID(), );
        $res = $this->db->prepared_query('SELECT * FROM dependency_privs
        									LEFT JOIN users USING (groupID)
        									WHERE dependencyID=:dependencyID
        										AND userID=:userID', $vars);

        if (!$this->login->checkGroup(1) && !isset($res[0]['userID']))
        {
            // check special cases
            $vars = array(':recordID' => $this->recordID);
            $res = $this->db->prepared_query('SELECT * FROM records
            									WHERE recordID=:recordID', $vars);
            switch ($dependencyID) {
                case 1: // service chief
                    if (!$this->login->checkService($res[0]['serviceID']))
                    {
                        return array('status' => 0, 'errors' => array('Your account is not registered as a Service Chief'));
                    }

                    break;
                case 8: // quadrad
                    $quadGroupIDs = $this->login->getQuadradGroupID();
                    $varsQuad = array(':serviceID' => $res[0]['serviceID']);

                       $resQuad = $this->db->prepared_query("SELECT * FROM services
							                				WHERE groupID IN ({$quadGroupIDs})
							                				AND serviceID=:serviceID", $varsQuad);
                    if (count($resQuad) == 0)
                    {
                        return array('status' => 0, 'errors' => array('Your account is not registered as an Executive Leadership Team member'));
                    }

                    break;
                case -1: // dependencyID -1 : person designated by requestor
                    require_once 'form.php';
                    $form = new Form($this->db, $this->login);

                    $varsPerson = array(':recordID' => $this->recordID);

                    $resPerson = $this->db->prepared_query('SELECT * FROM records_workflow_state
									                			LEFT JOIN workflow_steps USING (stepID)
                												WHERE recordID=:recordID', $varsPerson);

                    $resEmpUID = $form->getIndicator($resPerson[0]['indicatorID_for_assigned_empUID'], 1, $this->recordID);
                    $empUID = $resEmpUID[$resPerson[0]['indicatorID_for_assigned_empUID']]['value'];

                    $userAuthorized = $this->checkIfBackup($empUID);

                    if(!$userAuthorized){
                        return array('status' => 0, 'errors' => array('User account does not match'));
                    }

                    break;
                case -2: // dependencyID -2 : requestor followup
                    require_once 'form.php';
                    $form = new Form($this->db, $this->login);

                    $varsPerson = array(':recordID' => $this->recordID);
                    $resPerson = $this->db->prepared_query('SELECT userID FROM records
                                                                WHERE recordID=:recordID', $varsPerson);

                    if ($resPerson[0]['userID'] != $this->login->getUserID())
                    {
                        $empUID = $this->getEmpUIDByUserName($resPerson[0]['userID']);
                                                                
                        $userAuthorized = $this->checkIfBackup($empUID);
    
                        if (!$userAuthorized)
                        {
                            return array('status' => 0, 'errors' => array('User account does not match'));
                        }
                    }

                    break;
                case -3: // dependencyID -3 : group designated by requestor
                    require_once 'form.php';
                    $form = new Form($this->db, $this->login);

                    $varsGroup = array(':recordID' => $this->recordID);

                    $resGroup = $this->db->prepared_query('SELECT * FROM records_workflow_state
								                			LEFT JOIN workflow_steps USING (stepID)
                											WHERE recordID=:recordID', $varsGroup);

                    $resGroupID = $form->getIndicator($resGroup[0]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
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
        $res = $this->db->prepared_query('SELECT * FROM step_dependencies
        									RIGHT JOIN records_workflow_state USING (stepID)
        									LEFT JOIN workflow_steps USING (stepID)
        									LEFT JOIN dependencies USING (dependencyID)
        									WHERE recordID=:recordID
        										AND dependencyID=:dependencyID', $vars);

        if(count($res) == 0) {
            return array('status' => 0, 'errors' => array('This page is out of date. Please refresh for the latest status.'));
        }

        $logCache = array();
        // iterate through steps
        foreach ($res as $actionable)
        {
            // find out what the action is doing, and what the next step is
            $vars2 = array(':workflowID' => $actionable['workflowID'],
                           ':stepID' => $actionable['stepID'],
                           ':actionType' => $actionType, );
            $res2 = $this->db->prepared_query('SELECT * FROM workflow_routes
            									LEFT JOIN actions USING (actionType)
            									WHERE workflowID=:workflowID
            										AND stepID=:stepID
            										AND actionType=:actionType', $vars2);
            // continue if the step and action is valid
            if (isset($res2[0]))
            {
                $this->db->beginTransaction();
                // write dependency information
                $vars2 = array(':recordID' => $this->recordID,
                              ':dependencyID' => $dependencyID,
                              ':filled' => $res2[0]['fillDependency'],
                              ':time' => $time, );
                $this->db->prepared_query('INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                                               VALUES (:recordID, :dependencyID, :filled, :time)
                                               ON DUPLICATE KEY
                                                   UPDATE filled=:filled, time=:time', $vars2);

                // don't write duplicate log entries
                $vars2 = array(':recordID' => $this->recordID,
                               ':userID' => $this->login->getUserID(),
                               ':stepID' => $actionable['stepID'],
                               ':dependencyID' => $dependencyID,
                               ':actionType' => $actionType,
                               ':actionTypeID' => 8,
                               ':time' => $time,
                               ':comment' => $comment, );
                $logKey = sha1(serialize($vars2));
                if (!isset($logCache[$logKey]))
                {
                    // write log
                    $logCache[$logKey] = 1;
                    $this->db->prepared_query('INSERT INTO action_history (recordID, userID, stepID, dependencyID, actionType, actionTypeID, time, comment)
                            VALUES (:recordID, :userID, :stepID, :dependencyID, :actionType, :actionTypeID, :time, :comment)', $vars2);
                }

                // get other action data
                $varsAction = array(':actionType' => $actionType);
                $resActionData = $this->db->prepared_query('SELECT * FROM actions WHERE actionType=:actionType', $varsAction);

                // write current status in main index
                $vars2 = array(':recordID' => $this->recordID,
                              ':lastStatus' => $resActionData[0]['actionTextPasttense'], );
                $this->db->prepared_query('UPDATE records SET lastStatus=:lastStatus
                								WHERE recordID=:recordID', $vars2);

                $this->db->commitTransaction();

                // see if all dependencies in the step are met
                $vars2 = array(':recordID' => $this->recordID,
                               ':stepID' => $actionable['stepID'], );
                $res3 = $this->db->prepared_query('SELECT * FROM step_dependencies
                										LEFT JOIN records_dependencies USING (dependencyID)
                										WHERE stepID=:stepID
                											AND recordID=:recordID
                											AND filled=0', $vars2);
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
                    $vars_clearDep = array(':recordID' => $this->recordID,
                                           ':dependencyID' => $dependencyID, );
                    $this->db->prepared_query('UPDATE records_dependencies SET
                    								filled=0
                    								WHERE recordID=:recordID
                    									AND dependencyID=:dependencyID', $vars_clearDep);
                    $numUnfilledDeps = 1;
                }

                // if all dependencies are met, update the record's workflow state
                if ($numUnfilledDeps == 0
                    || $actionType == 'sendback')
                {	// handle sendback as a special case, since it doesn't fill any dependencies
                    // log step fulfillment data
                    $vars2 = array(':recordID' => $this->recordID,
                                ':stepID' => $actionable['stepID'],
                                ':time' => $time, );
                    $this->db->prepared_query('INSERT INTO records_step_fulfillment (recordID, stepID, fulfillmentTime)
                                                   VALUES (:recordID, :stepID, :time)
                								   ON DUPLICATE KEY UPDATE fulfillmentTime=:time', $vars2);

                    // if the next step is to end it, then update the record's workflow's state
                    if ($res2[0]['nextStepID'] == 0)
                    {
                        $vars2 = array(':recordID' => $this->recordID);
                        $this->db->prepared_query('DELETE FROM records_workflow_state
                                                    WHERE recordID=:recordID', $vars2);
                    }
                    else
                    {
                        $vars2 = array(':recordID' => $this->recordID,
                                       ':stepID' => $actionable['stepID'],
                                       ':nextStepID' => $res2[0]['nextStepID'],
                                       ':blockingStepID' => 0, );
                        $this->db->prepared_query('UPDATE records_workflow_state SET
	                                                    stepID=:nextStepID,
	                                                    blockingStepID=:blockingStepID
	                                                    WHERE recordID=:recordID
	                                                        AND stepID=:stepID', $vars2);

                        // reset records_dependencies for the next step
                        $this->resetRecordsDependency($res2[0]['nextStepID']);
                    }

                    // make sure the step is available
                    $vars2 = array(':recordID' => $this->recordID);
                    $res3 = $this->db->prepared_query('SELECT * FROM category_count
                    										LEFT JOIN categories USING (categoryID)
                                                            LEFT JOIN workflows USING (workflowID)
                                                            LEFT JOIN workflow_steps USING (workflowID)
                                                            LEFT JOIN step_dependencies USING (stepID)
                                                            LEFT JOIN records_dependencies USING (recordID, dependencyID)
                    										WHERE category_count.recordID=:recordID
                    											AND count > 0
                    											AND workflowID > 0
                                                                AND filled IS NULL', $vars2);
                    if (count($res3) > 0)
                    {
                        $this->db->beginTransaction();
                        foreach ($res3 as $nextStep)
                        {
                            $vars2 = array(':recordID' => $this->recordID,
                                          ':dependencyID' => $nextStep['dependencyID'],
                                          ':filled' => 0, );
                            $this->db->prepared_query('INSERT IGNORE INTO records_dependencies (recordID, dependencyID, filled)
                                                           VALUES (:recordID, :dependencyID, :filled)', $vars2);
                        }
                        $this->db->commitTransaction();
                    }

                    // Done with database updates for dependency/state

                    // determine if parallel workflows have shared steps
                    $vars2 = array(':recordID' => $this->recordID);
                    $res3 = $this->db->prepared_query('SELECT * FROM records_workflow_state
                    										LEFT JOIN workflow_steps USING (stepID)
                    										LEFT JOIN step_dependencies USING (stepID)
                    										WHERE recordID=:recordID', $vars2);
                    // iterate through steps
                    if (count($res3) > 1)
                    {
                        foreach ($res3 as $step)
                        {
                            $conflictID = $this->checkDependencyConflicts($step, $res3);
                            if ($conflictID != 0 && $conflictID != $step['stepID'])
                            {
                                $vars2 = array(':recordID' => $this->recordID,
                                               ':stepID' => $step['stepID'],
                                               ':blockingStepID' => $conflictID, );
                                $this->db->prepared_query('UPDATE records_workflow_state SET
                                                                blockingStepID=:blockingStepID
                                                                WHERE recordID=:recordID
                                                                    AND stepID=:stepID', $vars2);
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

        return array('status' => 1, 'errors' => $errors);
    }


     /**
      * Gets empuID for given username
      * @param string $userName Username
      * @return string
      */
    public function getEmpUIDByUserName($userName)
    {
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        return $nexusDB->prepared_query('SELECT * FROM employee WHERE userName =:userName', $vars)[0]["empUID"];
    }

    /**
     * Checks if logged in user serves as a backup for given empUID
     * Also returns true when the logged in user has the same empUID
     * @param string $empUID empUID to check 
     * @return boolean
     */
    public function checkIfBackup($empUID)
    { 

        $nexusDB = $this->login->getNexusDB();
        $vars = array(':empId' => $empUID);
        $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars);

        if ($empUID != $this->login->getEmpUID())
        {
            foreach ($backupIds as $row)
            {
                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                {
                    return true;
                }
            }

            return false;
        }

        return true;
    }

    /**
     * Handle events tied to actions, if there are any
     * @param int $workflowID
     * @param int $stepID
     * @param string $actionType
     * @param string $comment
     * @return array {status(int), errors[]}
     */
    public function handleEvents($workflowID, $stepID, $actionType, $comment)
    {
        $errors = array();

        // Take care of special events (sendback)
        if ($actionType == 'sendback')
        {
            $vars2 = array(':recordID' => $this->recordID);
            $res = $this->db->prepared_query('SELECT * FROM records_workflow_state
                                                  WHERE recordID=:recordID', $vars2);
            if (count($res) == 0)
            {	// if the workflow state is empty, it means the request has been sent back to the requestor
                require_once 'form.php';
                $form = new Form($this->db, $this->login);
                $form->openForEditing($this->recordID);
            }

            // Send emails
            require_once 'Email.php';
            $email = new Email();

            $vars = array(':recordID' => $this->recordID);
            $record = $this->db->prepared_query('SELECT * FROM records
                                                    LEFT JOIN services USING (serviceID)
                                                    WHERE recordID=:recordID', $vars);

            $vars = array(':stepID' => $stepID);
            $groupName = $this->db->prepared_query('SELECT * FROM workflow_steps WHERE stepID=:stepID', $vars);

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
            $email->setTemplateByID(\Email::SEND_BACK);

            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

            $requester = $dir->lookupLogin($record[0]['userID']);
            $author = $dir->lookupLogin($this->login->getUserID());

            $email->addRecipient($requester[0]['Email']);
            $email->addRecipient($author[0]['Email']);
            $email->setSender($author[0]['Email']);

            $email->sendMail();
        }

        // Handle Events
        $vars = array(':workflowID' => $workflowID,
                       ':stepID' => $stepID,
                       ':actionType' => $actionType, );
        $res = $this->db->prepared_query('SELECT * FROM route_events
        									LEFT JOIN events USING (eventID)
        									WHERE workflowID=:workflowID
        										AND stepID=:stepID
        										AND actionType=:actionType
        									ORDER BY eventID ASC', $vars);

        foreach ($res as $event)
        {
            switch ($event['eventID']) {
                case 'std_email_notify_next_approver': // notify next approver
                    require_once 'Email.php';
                    $email = new Email();

                    $vars = array(':recordID' => $this->recordID);
                    $approvers = $this->db->prepared_query('SELECT *, users.userID AS approverID FROM records_workflow_state
                    											LEFT JOIN records USING (recordID)
                    											LEFT JOIN step_dependencies USING (stepID)
                    											LEFT JOIN dependency_privs USING (dependencyID)
                    											LEFT JOIN users USING (groupID)
                    											LEFT JOIN services USING (serviceID)
                    											WHERE recordID=:recordID', $vars);

                    if (count($approvers) > 0)
                    {
                        $title = strlen($approvers[0]['title']) > 45 ? substr($approvers[0]['title'], 0, 42) . '...' : $approvers[0]['title'];

                        $email->addSmartyVariables(array(
                            "truncatedTitle" => $title,
                            "fullTitle" => $approvers[0]['title'],
                            "recordID" => $this->recordID,
                            "service" => $approvers[0]['service'],
                            "lastStatus" => $approvers[0]['lastStatus'],
                            "comment" => $comment,
                            "siteRoot" => $this->siteRoot
                        ));
                        $email->setTemplateByID(\Email::NOTIFY_NEXT);

                        require_once 'VAMC_Directory.php';
                        $dir = new VAMC_Directory;

                        $author = $dir->lookupLogin($this->login->getUserID());
                        $email->setSender($author[0]['Email']);

                        foreach ($approvers as $approver)
                        {
                            if (strlen($approver['approverID']) > 0)
                            {
                                $tmp = $dir->lookupLogin($approver['approverID']);
                                $email->addRecipient($tmp[0]['Email']);
                            }
                        }

                        // special case for service chiefs
                        if ($approvers[0]['dependencyID'] == 1)
                        {
                            $vars = array(':serviceID' => $approvers[0]['serviceID']);
                            $chief = $this->db->prepared_query('SELECT * FROM service_chiefs
                            										WHERE serviceID=:serviceID
                            											AND active=1', $vars);

                            foreach ($chief as $member)
                            {
                                if (strlen($member['userID']) > 0)
                                {
                                    $tmp = $dir->lookupLogin($member['userID']);
                                    $email->addRecipient($tmp[0]['Email']);
                                }
                            }
                        }

                        // special case for quadrads
                        if ($approvers[0]['dependencyID'] == 8)
                        {
                            $vars = array(':groupID' => $approvers[0]['groupID']);
                            $quadrad = $this->db->prepared_query('SELECT * FROM users
                            											WHERE groupID=:groupID', $vars);

                            foreach ($quadrad as $member)
                            {
                                if (strlen($member['userID']) > 0)
                                {
                                    $tmp = $dir->lookupLogin($member['userID']);
                                    $email->addRecipient($tmp[0]['Email']);
                                }
                            }
                        }

                        // dependencyID -1 : special case for a person designated by the requestor
                        if ($approvers[0]['dependencyID'] == -1)
                        {
                            require_once 'form.php';
                            $form = new Form($this->db, $this->login);

                            // find the next step
                            $varsStep = array(':stepID' => $approvers[0]['stepID']);
                            $resStep = $this->db->prepared_query('SELECT * FROM workflow_steps
                													WHERE stepID=:stepID', $varsStep);

                            $resEmpUID = $form->getIndicator($resStep[0]['indicatorID_for_assigned_empUID'], 1, $this->recordID);
                            $empUID = $resEmpUID[$resStep[0]['indicatorID_for_assigned_empUID']]['value'];

                            //check if the requester has any backups
                            $nexusDB = $this->login->getNexusDB();
                            $vars4 = array(':empId' => $empUID);
                            $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);

                            if ($empUID > 0)
                            {
                                $tmp = $dir->lookupEmpUID($empUID);
                                $email->addRecipient($tmp[0]['Email']);
                            }

                            // add for backups
                            foreach ($backupIds as $row)
                            {
                                $tmp = $dir->lookupEmpUID($empUID);
                                if (isset($tmp[0]['Email']) && $tmp[0]['Email'] != '')
                                {
                                    $email->addCC($tmp[0]['Email']);
                                }
                            }
                        }

                        // dependencyID -2 : requestor followup
                        if ($approvers[0]['dependencyID'] == -2)
                        {
                            $vars = array(':recordID' => $this->recordID);
                            $resRequestor = $this->db->prepared_query('SELECT userID FROM records
                    													WHERE recordID=:recordID', $vars);
                            $tmp = $dir->lookupLogin($resRequestor[0]['userID']);
                            $email->addRecipient($tmp[0]['Email']);
                        }

                        // dependencyID -3 : special case for a group designated by the requestor
                        if ($approvers[0]['dependencyID'] == -3)
                        {
                            require_once 'form.php';
                            $form = new Form($this->db, $this->login);

                            // find the next step
                            $varsStep = array(':stepID' => $approvers[0]['stepID']);
                            $resStep = $this->db->prepared_query('SELECT * FROM workflow_steps
                													WHERE stepID=:stepID', $varsStep);

                            $resGroupID = $form->getIndicator($resStep[0]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
                            $groupID = $resGroupID[$resStep[0]['indicatorID_for_assigned_groupID']]['value'];

                            if ($groupID > 0)
                            {
                                $email->addGroupRecipient($groupID);
                            }
                        }

                        $email->sendMail();
                    }

                    break;
                case 'std_email_notify_completed': // notify requestor of completed request
                    require_once 'Email.php';
                    $email = new Email();

                    $vars = array(':recordID' => $this->recordID);
                    $approvers = $this->db->prepared_query('SELECT * FROM records
                    											LEFT JOIN services USING (serviceID)
                    											WHERE recordID=:recordID', $vars);

                    $title = strlen($approvers[0]['title']) > 45 ? substr($approvers[0]['title'], 0, 42) . '...' : $approvers[0]['title'];

                    $email->addSmartyVariables(array(
                        "truncatedTitle" => $title,
                        "fullTitle" => $approvers[0]['title'],
                        "recordID" => $this->recordID,
                        "service" => $approvers[0]['service'],
                        "lastStatus" => $approvers[0]['lastStatus'],
                        "comment" => $comment,
                        "siteRoot" => $this->siteRoot
                    ));
                    $email->setTemplateByID(\Email::NOTIFY_COMPLETE);

                    require_once 'VAMC_Directory.php';
                    $dir = new VAMC_Directory;

                    $author = $dir->lookupLogin($this->login->getUserID());
                    $email->setSender($author[0]['Email']);

                    $tmp = $dir->lookupLogin($approvers[0]['userID']);
                    $email->addRecipient($tmp[0]['Email']);

                    $email->sendMail();

                    break;
                default:
                    $eventFile = $this->eventFolder . 'CustomEvent_' . $event['eventID'] . '.php';
                    if (is_file($eventFile))
                    {
                        require_once $eventFile;
                        require_once 'VAMC_Directory.php';
                        require_once 'Email.php';
                        $dir = new VAMC_Directory;
                        $email = new Email();

                        $eventInfo = array('recordID' => $this->recordID,
                                           'workflowID' => $workflowID,
                                           'stepID' => $stepID,
                                           'actionType' => $actionType,
                                           'comment' => $comment, );

                        $customClassName = "CustomEvent_{$event['eventID']}";

                        try
                        {
                            $event = new $customClassName($this->db, $this->login, $dir, $email, $this->siteRoot, $eventInfo);
                            $event->execute();
                        }
                        catch (Exception $e)
                        {
                            $errors[] = $e->getMessage();
                        }
                    }
                    else
                    {
                        trigger_error('Custom event not found: ' . $eventFile);
                    }

                    break;
            }
        }

        return array('status' => 1, 'errors' => $errors);
    }

    /**
     * Set the the current record to a specific step
     * Require admin access unless bypass is requested
     * Do not use in combination with multiple simultaneous workflows
     */
    public function setStep($stepID, $bypassAdmin = false, $comment = '')
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
        $res = $this->db->prepared_query('SELECT * FROM records
            									WHERE recordID=:recordID', $vars);
        if ($res[0]['submitted'] == 0)
        {
            $vars = array(':recordID' => $this->recordID,
                          ':submitted' => time(),
            );
            $res = $this->db->prepared_query('UPDATE records
												SET submitted=:submitted
            									WHERE recordID=:recordID', $vars);
        }

        $vars = array(':stepID' => $stepID);
        $res = $this->db->prepared_query('SELECT * FROM workflow_steps
            									WHERE stepID=:stepID', $vars);
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
        $vars2 = array(':recordID' => $this->recordID,
                ':userID' => $this->login->getUserID(),
                ':dependencyID' => 0,
                ':actionType' => 'move',
                ':actionTypeID' => 8,
                ':time' => time(),
                ':comment' => $comment, );
        $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time, comment)
                            VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment)', $vars2);

        $vars2 = array(':recordID' => $this->recordID);
        $this->db->prepared_query('DELETE FROM records_workflow_state
										WHERE recordID=:recordID', $vars2);
        $this->resetRecordsDependency($stepID);
        $vars = array(':recordID' => $this->recordID,
                      ':stepID' => $stepID, );
        $this->db->prepared_query('INSERT INTO records_workflow_state (recordID, stepID)
                                             VALUES (:recordID, :stepID)', $vars);

        return true;
    }

    public function setEventFolder($folder)
    {
        $this->eventFolder = $folder;
    }

    /**
     * For parallel workflows, check if the current dependency conflicts between workflows
     * @param array $dep
     * @param array $steps
     * @return int conflicting step ID
     */
    private function checkDependencyConflicts($dep, $steps)
    {
        // iterate through steps
        foreach ($steps as $step)
        {
            // unblock step if prerequisites are met
            if ($dep['blockingStepID'] == $step['stepID'])
            {
                $vars2 = array(':recordID' => $this->recordID,
                               ':stepID' => $dep['stepID'],
                               ':blockingStepID' => 0, );
                $this->db->prepared_query('UPDATE records_workflow_state SET
                                                blockingStepID=:blockingStepID
                                                WHERE recordID=:recordID
                                                    AND stepID=:stepID', $vars2);
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
                    $vars = array(':dependencyID' => $dep['dependencyID'],
                                  ':workflowID' => $step['workflowID'], );
                    $res = $this->db->prepared_query('SELECT * FROM workflow_routes
                    									LEFT JOIN step_dependencies USING (stepID)
                    									WHERE dependencyID=:dependencyID
                    										AND workflowID=:workflowID', $vars);

                    if (isset($res[0]))
                    {
                        return $step['stepID'];
                    }
                }
            }
        }

        return 0;
    }

    private function resetRecordsDependency($stepID)
    {
        $vars2 = array(':stepID' => $stepID);
        $res3 = $this->db->prepared_query('SELECT * FROM step_dependencies
                    										WHERE stepID=:stepID', $vars2);
        if (count($res3) > 0)
        {
            foreach ($res3 as $stepDependency)
            {
                $vars2 = array(':recordID' => $this->recordID,
                        ':dependencyID' => $stepDependency['dependencyID'], );
                $this->db->prepared_query('UPDATE records_dependencies SET
	                    										filled=0
	                    										WHERE recordID=:recordID
	                    											AND dependencyID=:dependencyID', $vars2);
            }
        }
    }
}
