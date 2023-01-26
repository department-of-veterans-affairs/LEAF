<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Workflow
    Date Created: May 25, 2011
*/

namespace Portal;

class FormWorkflow
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $recordID;

    private $email;

    private $form;

    private $vamc;

    // workflow actions are triggered from ./api/ except on submit
    private $eventFolder = '../scripts/events/';

    /**
     *
     * @param \Leaf\Db $db
     * @param Login $login
     * @param int $recordID
     * @param Email|null $email
     *
     * Created at: 12/15/2022, 7:53:32 AM (America/New_York)
     */
    public function __construct(\Leaf\Db $db, Login $login, int $recordID, Form $form, VAMC_Directory $vamc, ?Email $email = null)
    {
        $this->db = $db;
        $this->login = $login;
        $this->email = $email;
        $this->form = $form;
        $this->vamc = $vamc;
        $this->recordID = is_numeric($recordID) ? $recordID : 0;

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
     * Retrieves current steps of a form's workflow, controls access to steps
     * @return array database result
     * @return array|int|null if no database result
     */
    public function getCurrentSteps(): array|int|null
    {
        // check privileges
        if (!$this->form->hasReadAccess($this->recordID))
        {
            return 0;
        }

        $steps = array();
        $vars = array(':recordID' => $this->recordID);
        $strSQL = 'SELECT dependencyID, recordID, stepID, stepTitle, blockingStepID, workflowID, serviceID, filled, stepBgColor, stepFontColor, stepBorder, description, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID, jsSrc, userID, requiresDigitalSignature FROM records_workflow_state
            LEFT JOIN records USING (recordID)
            LEFT JOIN workflow_steps USING (stepID)
            LEFT JOIN step_dependencies USING (stepID)
            LEFT JOIN dependencies USING (dependencyID)
            LEFT JOIN records_dependencies USING (recordID, dependencyID)
            WHERE recordID = :recordID';
        $res = $this->db->prepared_query($strSQL, $vars);

        $numRes = count($res);
        if ($numRes > 0)
        {
            if ($numRes == 1 && $res[0]['filled'] == 1) {
                $res[0]['filled'] = 0;
            }

            for ($i = 0; $i < $numRes; $i++)
            {
                if ($res[$i]['filled'] == 1) {
                    continue;
                }
                $res[$i]['dependencyActions'] = $this->getDependencyActions($res[$i]['workflowID'], $res[$i]['stepID']);
                // override access if user is in the admin group
                $res[$i]['hasAccess'] = $this->login->checkGroup(1); // initialize hasAccess

                // check permissions
                $vars = array(':dependencyID' => $res[$i]['dependencyID']);
                $strSQL = 'SELECT * FROM dependency_privs WHERE dependencyID = :dependencyID';
                $res2 = $this->db->prepared_query($strSQL, $vars);

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
                    $vars3 = array(
                        ':serviceID' => $res[$i]['serviceID'],
                    );
                    $strSQL = 'SELECT * FROM services
                        WHERE groupID IN ('.$quadGroupIDs.')
                        AND serviceID = :serviceID';
                    $res3 = $this->db->prepared_query($strSQL, $vars3);

                    if (isset($res3[0]))
                    {
                        $res[$i]['hasAccess'] = true;
                    }
                }

                // dependencyID -1 is for a person designated by the requestor
                if ($res[$i]['dependencyID'] == -1)
                {
                    $resEmpUID = $this->form->getIndicator($res[$i]['indicatorID_for_assigned_empUID'], 1, $this->recordID);

                    // make sure the right person has access
                    if (!$res[$i]['hasAccess'])
                    {
                        $empUID = $resEmpUID[$res[$i]['indicatorID_for_assigned_empUID']]['value'];

                        //check if the requester has any backups
                        //get nexus db
                        $nexusDB = $this->login->getNexusDB();
                        $vars4 = array(':empID' => $empUID);
                        $strSQL = 'SELECT * FROM relation_employee_backup WHERE empUID = :empID';
                        $backupIds = $nexusDB->prepared_query($strSQL, $vars4);

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

                    $approver = $this->vamc->lookupEmpUID($resEmpUID[$res[$i]['indicatorID_for_assigned_empUID']]['value']);

                    $res[$i]['description'] = $res[$i]['stepTitle'] . ' (' . $approver[0]['Fname'] . ' ' . $approver[0]['Lname'] . ')';

                    if (empty($approver[0]['Fname']) && empty($approver[0]['Lname'])) {
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
                    $resGroupID = $this->form->getIndicator($res[$i]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
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
                    $strSQL = 'SELECT * FROM `groups` WHERE groupID = :groupID';
                    $tGroup = $this->db->prepared_query($strSQL, $vars);
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
        if (!$this->form->hasReadAccess($this->recordID))
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
            $approver = $this->vamc->lookupLogin($res[0]['userID']);

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
            $res[0]['comment'] = \Leaf\XSSHelpers::sanitizeHTML($res[0]['comment']);
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
            $signedSteps = [];
            foreach($res as $key => $sig) {
                $signer = $this->vamc->lookupLogin($sig['userID']);
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
     *
     * @param int $dependencyID
     * @param string $actionType
     * @param string $comment
     * @param string|null $emailPrefix
     *
     * @return array
     *
     * Created at: 12/22/2022, 10:09:48 AM (America/New_York)
     */
    public function handleAction(int $dependencyID, string $actionType, string $comment, ?string $emailPrefix): array
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
        $comment = \Leaf\XSSHelpers::sanitizeHTML($comment);
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
                    $varsPerson = array(':recordID' => $this->recordID);
                    $strSQL = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        WHERE recordID = :recordID';
                    $resPerson = $this->db->prepared_query($strSQL, $varsPerson);

                    $resEmpUID = $this->form->getIndicator($resPerson[0]['indicatorID_for_assigned_empUID'], 1, $this->recordID);
                    $empUID = $resEmpUID[$resPerson[0]['indicatorID_for_assigned_empUID']]['value'];

                    $userAuthorized = $this->checkIfBackup($empUID);

                    if(!$userAuthorized){
                        return array('status' => 0, 'errors' => array('User account does not match'));
                    }

                    break;
                case -2: // dependencyID -2 : requestor followup
                    $varsPerson = array(':recordID' => $this->recordID);
                    $strSQLPerson = 'SELECT userID FROM records WHERE recordID = :recordID';
                    $resPerson = $this->db->prepared_query($strSQLPerson, $varsPerson);

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
                    $varsGroup = array(':recordID' => $this->recordID);
                    $strSQLGroup = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        WHERE recordID = :recordID';
                    $resGroup = $this->db->prepared_query($strSQLGroup, $varsGroup);

                    $resGroupID = $this->form->getIndicator($resGroup[0]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
                    $groupID = $resGroupID[$resGroup[0]['indicatorID_for_assigned_groupID']]['value'];

                    if (!$this->login->checkGroup($groupID))
                    {
                        return array('status' => 0, 'errors' => array('User account is not part of the designated group'));
                    }

                    break;
                default:
                    return array('status' => 0, 'errors' => array('Invalid Operation'));
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
        error_log(print_r($res, true));
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
                error_log(print_r('line 586', true));
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
                error_log('line 599');
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
error_log('line 620');
                // get other action data
                $varsAction = array(':actionType' => $actionType);
                $strSQLAction = 'SELECT * FROM actions WHERE actionType = :actionType';
                $resActionData = $this->db->prepared_query($strSQLAction, $varsAction);
error_log('line 625');
                // write current status in main index
                $vars2 = array(
                    ':recordID' => $this->recordID,
                    ':lastStatus' => $resActionData[0]['actionTextPasttense'],
                );
                $strSQL2 = 'UPDATE records SET lastStatus=:lastStatus
                    WHERE recordID = :recordID';
                $this->db->prepared_query($strSQL2, $vars2);
error_log('line 634');
                $this->db->commitTransaction();
error_log('transaction committed');
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
                error_log('line 648');
                $numUnfilledDeps = count($res3);

                // Trigger events if the next step is the same as the original step (eg: same-step loop)
                if ($actionable['stepID'] == $res2[0]['nextStepID'])
                {
                    $status = $this->handleEvents($actionable['workflowID'], $actionable['stepID'], $actionType, $comment, $emailPrefix);
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
error_log('line 672');
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
error_log('line 687');
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
                            ':blockingStepID' => 0,
                        );
                        $strSQL2 = 'UPDATE records_workflow_state SET
                            stepID = :nextStepID,
                            blockingStepID = :blockingStepID
                            WHERE recordID = :recordID
                            AND stepID = :stepID';
                        $this->db->prepared_query($strSQL2, $vars2);

                        // reset records_dependencies for the next step
                        $this->resetRecordsDependency($res2[0]['nextStepID']);
                    }
error_log('line 714');
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
                    error_log('line 728');
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
error_log('line 745');
                    // Done with database updates for dependency/state

                    // determine if parallel workflows have shared steps
                    $vars2 = array(':recordID' => $this->recordID);
                    $strSQL3 = 'SELECT * FROM records_workflow_state
                        LEFT JOIN workflow_steps USING (stepID)
                        LEFT JOIN step_dependencies USING (stepID)
                        WHERE recordID = :recordID';
                    $res3 = $this->db->prepared_query($strSQL2, $vars2);
                    error_log('line 755');
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
                                    ':blockingStepID' => $conflictID,
                                );
                                $strSQL2 = 'UPDATE records_workflow_state SET
                                    blockingStepID = :blockingStepID
                                    WHERE recordID = :recordID
                                    AND stepID = :stepID';
                                $this->db->prepared_query($strSQL2, $vars2);
                            }
                        }
                    }
error_log('line 777');
                    // Handle events if all dependencies in the step have been met
                    $status = $this->handleEvents($actionable['workflowID'], $actionable['stepID'], $actionType, $comment, $emailPrefix);
                    if (count($status['errors']) > 0)
                    {
                        $errors = array_merge($errors, $status['errors']);
                    }
                } // End update the record's workflow state
            }
        }
error_log('line 787');
        $comment_post = array('date' => date('M j', $time), 'user_name' => $this->login->getName(), 'comment' => $comment, 'responder' => $resActionData[0]['actionTextPasttense'], 'nextStep' => $res2[0]['nextStepID']);
error_log(print_r($comment_post, true));
        return array('status' => 1, 'errors' => $errors, 'comment' => $comment_post);
    }


     /**
      * Gets empuID for given username
      * @param string $userName Username
      * @return string
      */
    public function getEmpUIDByUserName(string $userName): string
    {
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        $strSQL = 'SELECT * FROM employee WHERE userName = :userName';
        return $nexusDB->prepared_query($strSQL, $vars)[0]["empUID"];
    }

    /**
     * Checks if logged in user serves as a backup for given empUID
     * Also returns true when the logged in user has the same empUID
     * @param string $empUID empUID to check
     * @return boolean
     */
    public function checkIfBackup(string $empUID): bool
    {

        $nexusDB = $this->login->getNexusDB();
        $vars = array(':empID' => $empUID);
        $strSQL = 'SELECT * FROM relation_employee_backup WHERE empUID =:empID';
        $backupIds = $nexusDB->prepared_query($strSQL, $vars);

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
     * @throws Exception
     */
    public function handleEvents(int $workflowID, int $stepID, string $actionType, string $comment, ?string $emailPrefix): array
    {
        error_log('line 848');
        $errors = array();

        // Take care of special events (sendback)
        if ($actionType == 'sendback')
        {
            $vars2 = array(':recordID' => $this->recordID);
            $strSQL2 = 'SELECT * FROM records_workflow_state
                WHERE recordID = :recordID';
            $res = $this->db->prepared_query($strSQL2, $vars2);
            error_log('line 858');
            if (count($res) == 0)
            {	// if the workflow state is empty, it means the request has been sent back to the requestor
                $this->form->openForEditing($this->recordID);
            }

            // Send emails
            $vars = array(':recordID' => $this->recordID);
            $strSQL = 'SELECT rec.title, rec.userID, ser.service FROM records AS rec
                LEFT JOIN services AS ser USING (serviceID)
                WHERE recordID = :recordID';
            $record = $this->db->prepared_query($strSQL, $vars);
            error_log('line 870');

            $vars = array(':stepID' => $stepID);
            $strSQL = 'SELECT stepTitle FROM workflow_steps WHERE stepID = :stepID';
            $groupName = $this->db->prepared_query($strSQL, $vars);
            error_log('line 875');

            $title = strlen($record[0]['title']) > 45 ? substr($record[0]['title'], 0, 42) . '...' : $record[0]['title'];

            $this->email->addSmartyVariables(array(
                "truncatedTitle" => $title,
                "fullTitle" => $record[0]['title'],
                "recordID" => $this->recordID,
                "service" => $record[0]['service'],
                "stepTitle" => $groupName[0]['stepTitle'],
                "comment" => $comment,
                "siteRoot" => $this->siteRoot
            ));
            error_log('line 888');
            $this->email->setTemplateByID(Email::SEND_BACK, $emailPrefix);
            error_log('line 890');

            $requester = $this->vamc->lookupLogin($record[0]['userID']);
            $author = $this->vamc->lookupLogin($this->login->getUserID());
            $this->email->addRecipient($requester[0]['Email']);
            $this->email->addRecipient($author[0]['Email']);

            // Get backups to requester so they can be notified as well
            $nexusDB = $this->login->getNexusDB();
            $vars = array(
              ':reqEmpUID'  => $requester[0]['empUiD'],
              ':authEmpUID' => $author[0]['empUID']
            );
            $strSQL = 'SELECT DISTINCT backupEmpUID FROM relation_employee_backup
                WHERE empUID IN (:reqEmpUID, :authEmpUID)';
            $backupIds = $nexusDB->prepared_query($strSQL, $vars);
error_log('before backups');
            // Add backups to email recepients
            foreach($backupIds as $backup) {
              // Don't re-email requestor or author if they are backups of each other
              if (($backup['backupEmpUID'] != $author[0]['empUID']) &&
                ($backup['backupEmpUID'] != $requester[0]['empID'])) {
                  $theirBackup = $this->vamc->lookupEmpUID($backup['backupEmpUID']);
                  $this->email->addRecipient($theirBackup[0]['Email']);
              }
            }
error_log('after backups');
            $this->email->setSender($author[0]['Email']);

            $this->email->sendMail();
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
        error_log(print_r('line 934', true));
error_log(print_r($res, true));
        foreach ($res as $event)
        {
            $customEvent = '';
            if (preg_match('/CustomEvent_/', $event['eventID'])) {
                $customEvent = $event['eventID'];
            }
            error_log(print_r('line 942', true));
            error_log($customEvent);
            switch ($event['eventID']) {
                case 'std_email_notify_next_approver': // notify next approver
                    $this->email->addSmartyVariables(array(
                        "comment" => $comment
                    ));

                    $author = $this->vamc->lookupLogin($this->login->getUserID());
                    $this->email->setSender($author[0]['Email']);

                    $this->email->attachApproversAndEmail($this->recordID, Email::NOTIFY_NEXT, $this->login, $emailPrefix);

                    break;
                case 'std_email_notify_completed': // notify requestor of completed request
                    $vars = array(':recordID' => $this->recordID);
                    $strSQL = 'SELECT rec.title, rec.lastStatus, rec.userID, ser.service
                        FROM records AS rec
                        LEFT JOIN services AS ser USING (serviceID)
                        WHERE recordID = :recordID';
                    $approvers = $this->db->prepared_query($strSQL, $vars);

                    $title = strlen($approvers[0]['title']) > 45 ? substr($approvers[0]['title'], 0, 42) . '...' : $approvers[0]['title'];

                    $this->email->addSmartyVariables(array(
                        "truncatedTitle" => $title,
                        "fullTitle" => $approvers[0]['title'],
                        "recordID" => $this->recordID,
                        "service" => $approvers[0]['service'],
                        "lastStatus" => $approvers[0]['lastStatus'],
                        "comment" => $comment,
                        "siteRoot" => $this->siteRoot
                    ));
                    $this->email->setTemplateByID(Email::NOTIFY_COMPLETE, $emailPrefix);

                    $author = $this->vamc->lookupLogin($this->login->getUserID());
                    $this->email->setSender($author[0]['Email']);

                    // Get backups to requester so they can be notified as well
                    $nexusDB = $this->login->getNexusDB();
                    $vars = array(':empUID' => $author[0]['empUID']);
                    $strSQL = 'SELECT backupEmpUID FROM relation_employee_backup
                        WHERE empUID = :empUID';
                    $backupIds = $nexusDB->prepared_query($strSQL, $vars);

                    // Add backups to email recepients
                    foreach($backupIds as $backup) {
                      $theirBackup = $this->vamc->lookupEmpUID($backup['backupEmpUID']);
                      $this->email->addRecipient($theirBackup[0]['Email']);
                    }

                    $tmp = $this->vamc->lookupLogin($approvers[0]['userID']);
                    $this->email->addRecipient($tmp[0]['Email']);

                    $this->email->sendMail();

                    break;
                case $customEvent: // For all custom events
                    $vars = array(':recordID' => $this->recordID);
                    $strSQL = 'SELECT rec.title, rec.lastStatus, rec.userID, ser.service
                        FROM records AS rec
                        LEFT JOIN services AS ser USING (serviceID)
                        WHERE recordID = :recordID';
                    $approvers = $this->db->prepared_query($strSQL, $vars);

                    $title = strlen($approvers[0]['title']) > 45 ? substr($approvers[0]['title'], 0, 42) . '...' : $approvers[0]['title'];

                    $this->email->addSmartyVariables(array(
                        "truncatedTitle" => $title,
                        "fullTitle" => $approvers[0]['title'],
                        "recordID" => $this->recordID,
                        "service" => $approvers[0]['service'],
                        "lastStatus" => $approvers[0]['lastStatus'],
                        "comment" => $comment,
                        "siteRoot" => $this->siteRoot
                    ));

                    $emailTemplateID = $this->email->getTemplateIDByLabel($event['eventDescription']);
                    $this->email->setTemplateByID($emailTemplateID, $emailPrefix);

                    $author = $this->vamc->lookupLogin($this->login->getUserID());
                    $this->email->setSender($author[0]['Email']);

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
                            $theirBackup = $this->vamc->lookupEmpUID($backup['backupEmpUID']);
                            $this->email->addRecipient($theirBackup[0]['Email']);
                        }

                        $tmp = $this->vamc->lookupLogin($approvers[0]['userID']);
                        $this->email->addRecipient($tmp[0]['Email']);
                    }

                    if ($eventData->NotifyGroup !== 'None') {
                        $this->email->addGroupRecipient($eventData->NotifyGroup);
                    }

                    if ($eventData->NotifyNext === 'true')
                        $this->email->attachApproversAndEmail($this->recordID, $emailTemplateID, $this->login, $emailPrefix);
                    else
                        $this->email->sendMail();

                    break;
                default:
                    $eventFile = $this->eventFolder . 'CustomEvent_' . $event['eventID'] . '.php';
                    if (is_file($eventFile))
                    {
                        $eventInfo = array('recordID' => $this->recordID,
                                           'workflowID' => $workflowID,
                                           'stepID' => $stepID,
                                           'actionType' => $actionType,
                                           'comment' => $comment, );

                        $customClassName = "\Portal\CustomEvent_{$event['eventID']}";

                        try
                        {
                            $event = new $customClassName($this->db, $this->login, $this->vamc, $this->email, $this->siteRoot, $eventInfo);
                            error_log(print_r('line 1070', true));
                            error_log(print_r($event, true));
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

        $return_value = array('status' => 1, 'errors' => $errors);
        error_log(print_r('line 1089', true));
        error_log(print_r($return_value, true));
        return $return_value;
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
        $comment = \Leaf\XSSHelpers::sanitizeHTML($comment);

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
                    ':blockingStepID' => 0,
                );
                $strSQL = 'UPDATE records_workflow_state SET
                    blockingStepID = :blockingStepID
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
