<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Workflow
    Date Created: December 12, 2011

*/


$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';

if(!class_exists('DataActionLogger'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/dataActionLogger.php';
}

class Workflow
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $workflowID;

    private $eventFolder = './scripts/events/';

    public function __construct($db, $login, $workflowID = 0)
    {
        $this->db = $db;
        $this->login = $login;
        $this->setWorkflowID($workflowID);

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $this->dataActionLogger = new \DataActionLogger($db, $login);
    }

    public function setWorkflowID($workflowID)
    {
        $this->workflowID = is_numeric($workflowID) ? $workflowID : 0;
    }

    public function getSteps()
    {
        $vars = array(':workflowID' => $this->workflowID);
        $res = $this->db->prepared_query('SELECT * FROM workflow_steps
                                            LEFT JOIN workflows USING (workflowID)
                                            LEFT JOIN step_modules USING (stepID)
        									WHERE workflowID=:workflowID', $vars);

        $out = [];
        foreach($res as $item) {
            $out[$item['stepID']] = $item;
            unset($out[$item['stepID']]['moduleName']);
            unset($out[$item['stepID']]['moduleConfig']);
            if($item['moduleName'] != '') {
                $out[$item['stepID']]['stepModules'][] = array('moduleName' => $item['moduleName'],
                                                               'moduleConfig' => $item['moduleConfig']);
            }
        }

        return $out;
    }

    public function deleteStep($stepID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID);
        $res = $this->db->prepared_query('SELECT * FROM records_workflow_state
    										WHERE stepID = :stepID', $vars);
        if (count($res) > 0)
        {
            return 'Requests currently on this step need to be moved first.';
        }

        $workflowID = $this->getWorkflowIDFromStep($stepID);

        $res = $this->db->prepared_query('DELETE FROM step_dependencies
    										WHERE stepID = :stepID', $vars);
        $res = $this->db->prepared_query('DELETE FROM route_events
    										WHERE stepID = :stepID', $vars);
        $res = $this->db->prepared_query('DELETE FROM workflow_routes
    										WHERE stepID = :stepID', $vars);
        $res = $this->db->prepared_query('DELETE FROM workflow_routes
    										WHERE nextStepID = :stepID', $vars);
        $res = $this->db->prepared_query('DELETE FROM workflow_steps
                                            WHERE stepID = :stepID', $vars);
                                            
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "stepID", $stepID),
            new LogItem("workflow_steps", "workflowID", $workflowID)
        ]);  

        return 1;
    }

    public function getAllSteps()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM workflow_steps
    										LEFT JOIN workflows USING (workflowID)
    										ORDER BY description, stepTitle', $vars);

        return $res;
    }

    public function getRoutes()
    {
        $vars = array(':workflowID' => $this->workflowID);
        $res = $this->db->prepared_query('SELECT * FROM workflow_routes
        										LEFT JOIN actions USING (actionType)
            									WHERE workflowID=:workflowID', $vars);

        return $res;
    }

    public function getAllUniqueWorkflows()
    {
        $vars = array();
        /*$res = $this->db->prepared_query('SELECT * FROM workflows
                                            WHERE workflowID > 0
                                            ORDER BY description ASC', $vars);*/
        $res = $this->db->prepared_query('SELECT * FROM workflows ORDER BY description ASC', $vars);

        return $res;
    }

    public function getCategories()
    {
        $vars = array(':workflowID' => $this->workflowID);
        $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID = :workflowID
        										ORDER BY categoryName", $vars);

        return $res;
    }

    public function getAllCategories()
    {
        $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID>0 AND parentID=''
        											AND disabled = 0
        										ORDER BY categoryName", null);

        return $res;
    }

    public function getAllCategoriesUnabridged()
    {
        $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE parentID=''
    												AND disabled = 0
                                                    AND workflowID >= 0
    											ORDER BY categoryName", null);

        return $res;
    }

    public function getAllDependencies()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM dependencies ORDER BY description', $vars);

        return $res;
    }

    public function getDependencies($stepID)
    {
        $vars = array(':stepID' => $stepID);
        $res = $this->db->prepared_query('SELECT * FROM step_dependencies
                                            LEFT JOIN dependencies USING (dependencyID)
                                            LEFT JOIN dependency_privs USING (dependencyID)
                                            LEFT JOIN groups USING (groupID)
        									LEFT JOIN workflow_steps USING (stepID)
                                            WHERE stepID = :stepID', $vars);

        return $res;
    }

    public function getEvents($stepID, $action)
    {
        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':action' => $action, );

        $res = $this->db->prepared_query('SELECT * FROM route_events
                LEFT JOIN events USING (eventID)
                WHERE workflowID = :workflowID
                    AND stepID = :stepID
                    AND actionType = :action', $vars);

        return $res;
    }

    public function setEditorPosition($stepID, $x, $y)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':x' => $x,
                      ':y' => $y, );
        $res = $this->db->prepared_query('UPDATE workflow_steps
                                            SET posX=:x, posY=:y
        									WHERE workflowID=:workflowID
                                                AND stepID=:stepID', $vars);

        return true;
    }

    public function deleteAction($stepID, $nextStepID, $action)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        // Exclude stepID -1 since it's the requestor
        if($stepID < -1) {
            return 'Restricted command.';
        }

        // clear out route events
        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':action' => $action, );
        $res = $this->db->prepared_query('DELETE FROM route_events
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
                                                AND actionType=:action', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::ROUTE_EVENTS, [
            new LogItem("route_events", "workflowID", $this->workflowID),
            new LogItem("route_events", "stepID", $stepID),
            new LogItem("route_events", "action", $action)
        ]);          

        // clear out routes
        $vars = array(':workflowID' => $this->workflowID,
                ':stepID' => $stepID,
                ':nextStepID' => $nextStepID,
                ':action' => $action, );
        $res = $this->db->prepared_query('DELETE FROM workflow_routes
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
    											AND nextStepID=:nextStepID
                                                AND actionType=:action', $vars);
                                                
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::WORKFLOW_ROUTE, [
            new LogItem("workflow_routes", "workflowID", $this->workflowID),
            new LogItem("workflow_routes", "stepID", $stepID),
            new LogItem("workflow_routes", "nextStepID", $nextStepID),
            new LogItem("workflow_routes", "actionType", $action)
        ]);  

        return true;
    }

    public function createAction($stepID, $nextStepID, $action)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        // Exclude stepID -1 since it's the requestor
        if($stepID < -1) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':nextStepID' => $nextStepID,
                      ':action' => $action,
                      ':displayConditional' => '',
        );
        $res = $this->db->prepared_query('INSERT INTO workflow_routes (workflowID, stepID, nextStepID, actionType, displayConditional)
    										VALUES (:workflowID, :stepID, :nextStepID, :action, :displayConditional)', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::WORKFLOW_ROUTE, [
            new LogItem("workflow_routes", "workflowID", $this->workflowID),
            new LogItem("workflow_routes", "stepID", $stepID),
            new LogItem("workflow_routes", "nextStepID", $nextStepID),
            new LogItem("workflow_routes", "actionType", $action),
            new LogItem("workflow_routes", "displayConditional", "")
        ]);  

        return true;
    }

    public function getAllEvents()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM events
                                            WHERE eventID NOT LIKE "LeafSecure_%"', $vars);

        return $res;
    }

    public function getActions()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM actions WHERE deleted=0 ORDER BY actionText', $vars);

        return $res;
    }

    public function setInitialStep($stepID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
        );
        $res = $this->db->prepared_query('UPDATE workflows SET initialStepID=:stepID
                                            WHERE workflowID=:workflowID', $vars);
                                            
        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::WORKFLOW, [
            new LogItem("workflows", "initialStepID",  $stepID),
            new LogItem("workflows", "workflowID",  $this->workflowID)
        ]);  

        if ($stepID != 0)
        {
            $this->deleteAction(-1, 0, 'submit');
        }

        return true;
    }

    /**
     * @param string $stepTitle
     * @param string $bgColor
     * @param string $fontColor
     * @return int The newly created stepID
     */
    public function createStep($stepTitle, $bgColor, $fontColor)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($this->workflowID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                        ':stepTitle' => $stepTitle,
                        ':jsSrc' => '',
        );
        $res = $this->db->prepared_query('INSERT INTO workflow_steps (workflowID, stepTitle, jsSrc)
                                            VALUES (:workflowID, :stepTitle, :jsSrc)', $vars);

        $stepId = $this->db->getLastInsertID();
        
        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "stepID",  $stepId),
            new LogItem("workflow_steps", "stepTitle",  $stepTitle),
            new LogItem("workflow_steps", "jsSrc",  "", "empty"),
            new LogItem("workflow_steps", "workflowID",  $this->workflowID)
        ]);          
        

        return $stepId;
    }

    /**
     * @param string $stepTitle
     * @param string $bgColor
     * @param string $fontColor
     * @return int The newly created stepID
     */
    public function updateStep($stepID, $stepTitle, $bgColor = '', $fontColor = '')
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID,
                      ':stepTitle' => $stepTitle,
        );
        $res = $this->db->prepared_query('UPDATE workflow_steps
    										SET stepTitle=:stepTitle
    										WHERE stepID=:stepID', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflows", "stepID", $stepID),
            new LogItem("workflows", "stepTitle",  $stepTitle),
            new LogItem("workflows", "jsSrc",  "", "empty"),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]);    

        return 1;
    }

    /**
     * Set an inline indicator for a particular step
     *
     * @param int $stepID
     * @param int $indicatorID
     *
     * @return int
     */
    public function setStepInlineIndicator($stepID, $indicatorID) {
        $indicatorID = (int)$indicatorID;
        if(!$this->login->checkGroup(1)) {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        if($indicatorID < 1) {
            $vars = array(
                ':stepID' => (int)$stepID
            );
            $res = $this->db->prepared_query(
                'DELETE FROM step_modules
                    WHERE stepID = :stepID
                        AND moduleName="LEAF_workflow_indicator"',
                $vars);
        }
        else {
            $vars = array(
                ':stepID' => (int)$stepID,
                ':config' => json_encode(array('indicatorID' => $indicatorID))
            );
            $res = $this->db->prepared_query(
                'INSERT INTO step_modules (stepID, moduleName, moduleConfig)
                    VALUES (:stepID, "LEAF_workflow_indicator", :config)
                    ON DUPLICATE KEY UPDATE moduleConfig=:config',
                $vars);
        }

        return 1;
    }

    /**
     * --- BETA ---
     * Set whether the specified step for the current Workflow requires a digital signature.
     * Uses the workflowID that was set with setWorkflowID(workflowID).
     *
     * @param int $stepID 				the step id to require a signature for
     * @param int $requiresSignature 	whether a signature is required
     *
     * @return int if the query was successful
     */
    public function requireDigitalSignature($stepID, $requireSignature) {
        if(!$this->login->checkGroup(1)) {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(
            ':stepID' => (int)$stepID,
            ':requiresSignature' => $requireSignature
        );

        $res = $this->db->prepared_query(
            'UPDATE `workflow_steps` SET `requiresDigitalSignature` = :requiresSignature WHERE `stepID` = :stepID',
            $vars);

        return $res > 0;
    }

    public function linkDependency($stepID, $dependencyID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID,
                      ':dependencyID' => $dependencyID,
        );
        $res = $this->db->prepared_query('INSERT INTO step_dependencies (stepID, dependencyID)
                                            VALUES (:stepID, :dependencyID)', $vars);
                                            
        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::STEP_DEPENDENCY, [
            new LogItem("step_dependencies", "stepID",  $stepID),
            new LogItem("step_dependencies", "dependencyID",  $dependencyID)
        ]);   

        // populate records_dependencies so we can filter on items immediately
        $this->db->prepared_query('INSERT IGNORE INTO records_dependencies (recordID, dependencyID, filled)
    									SELECT recordID, :dependencyID as dependencyID, 0 as filled FROM workflow_steps
    										LEFT JOIN categories USING (workflowID)
    										LEFT JOIN category_count USING (categoryID)
    										WHERE stepID=:stepID AND count > 0', $vars);

        return true;
    }

    public function unlinkDependency($stepID, $dependencyID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID,
                      ':dependencyID' => $dependencyID,
        );
        $res = $this->db->prepared_query('DELETE FROM step_dependencies
    										WHERE stepID=:stepID
    											AND dependencyID=:dependencyID', $vars);

        // clean up database
        $this->db->prepared_query('DELETE records_dependencies FROM records_dependencies
    								INNER JOIN category_count USING (recordID)
    								INNER JOIN categories USING (categoryID)
    								INNER JOIN workflow_steps USING (workflowID)
    								WHERE stepID=:stepID
    									AND dependencyID=:dependencyID
    									AND filled=0
                                        AND records_dependencies.time IS NULL', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::STEP_DEPENDENCY, [
            new LogItem("step_dependencies", "stepID",  $stepID),
            new LogItem("step_dependencies", "dependencyID",  $dependencyID)
        ]); 
        
        return true;
    }

    public function updateDependency($dependencyID, $description)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        $vars = array(':dependencyID' => $dependencyID,
                      ':description' => $description,
        );
        $res = $this->db->prepared_query('UPDATE dependencies
    										SET description=:description
    										WHERE dependencyID=:dependencyID', $vars);

        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::DEPENDENCY, [
            new LogItem("dependencies", "description",  $description),
            new LogItem("dependencies", "dependencyID",  $dependencyID)
        ]); 

        return 1;
    }

    public function addDependency($description)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        $vars = array(':description' => $description,
        );
        $res = $this->db->prepared_query('INSERT INTO dependencies (description)
    										VALUES (:description)', $vars);

        $insertedID = $this->db->getLastInsertID();

        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::DEPENDENCY, [
            new LogItem("dependencies", "description",  $description),
            new LogItem("dependencies", "dependencyID",  $insertedID)
        ]); 

        return $insertedID;
    }

    public function grantDependencyPrivs($dependencyID, $groupID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        $vars = array(':dependencyID' => $dependencyID,
                      ':groupID' => $groupID,
        );
        $res = $this->db->prepared_query('INSERT INTO dependency_privs (dependencyID, groupID)
                                            VALUES (:dependencyID, :groupID)', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::DEPENDENCY_PRIVS, [
            new LogItem("dependency_privs", "groupID",  $groupID),
            new LogItem("dependency_privs", "dependencyID",  $dependencyID)
        ]); 

        return true;
    }

    public function revokeDependencyPrivs($dependencyID, $groupID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        $vars = array(':dependencyID' => $dependencyID,
                      ':groupID' => $groupID,
        );
        $res = $this->db->prepared_query('DELETE FROM dependency_privs
    										WHERE dependencyID=:dependencyID
    											AND groupID=:groupID', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::DEPENDENCY_PRIVS, [
            new LogItem("dependency_privs", "groupID",  $groupID),
            new LogItem("dependency_privs", "dependencyID",  $dependencyID)
        ]); 
        
        return true;
    }

    public function linkEvent($stepID, $actionType, $eventID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        if(strpos($eventID, 'LeafSecure_') !== false) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':actionType' => $actionType,
                      ':eventID' => $eventID,
        );
        $res = $this->db->prepared_query('INSERT INTO route_events (workflowID, stepID, actionType, eventID)
    										VALUES (:workflowID, :stepID, :actionType, :eventID)', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::ROUTE_EVENTS, [
            new LogItem("route_events", "workflowID",  $this->workflowID),
            new LogItem("route_events", "actionType",  $actionType),
            new LogItem("route_events", "eventID",  $eventID),
            new LogItem("route_events", "stepID",  $stepID)
        ]); 
        
        return true;
    }

    public function unlinkEvent($stepID, $actionType, $eventID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        if(strpos($eventID, 'LeafSecure_') !== false) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                ':stepID' => $stepID,
                ':actionType' => $actionType,
                ':eventID' => $eventID,
        );
        $res = $this->db->prepared_query('DELETE FROM route_events
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
    											AND actionType=:actionType
    											AND eventID=:eventID', $vars);
       
       $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::ROUTE_EVENTS, [
            new LogItem("route_events", "workflowID",  $this->workflowID),
            new LogItem("route_events", "actionType",  $actionType),
            new LogItem("route_events", "eventID",  $eventID),
            new LogItem("route_events", "stepID",  $stepID)
        ]); 

        return true;
    }

    public function deleteWorkflow($workflowID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($workflowID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $workflowID);
        $res = $this->db->prepared_query('SELECT * FROM workflow_steps
    										WHERE workflowID = :workflowID', $vars);
        if (count($res) > 0)
        {
            return 'Steps within the workflow must be deleted first.';
        }

        $res = $this->db->prepared_query('SELECT * FROM categories
    										WHERE workflowID = :workflowID
    											AND disabled=0', $vars);
        if (count($res) > 0)
        {
            return 'Forms must be disconnected from this workflow first.';
        }

        $res = $this->db->prepared_query('DELETE FROM workflows
    										WHERE workflowID = :workflowID', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::WORKFLOW, [
            new LogItem("workflows", "workflowID",  $this->workflowID)
        ]); 
        
        return true;
    }

    public function newWorkflow($description)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        $vars = array(':description' => $description,
        );
        $res = $this->db->prepared_query('INSERT INTO workflows (description)
    										VALUES (:description)', $vars);

        $workflowID = $this->db->getLastInsertID();

        $this->dataActionLogger->logAction(\DataActions::ADD, \LoggableTypes::WORKFLOW, [
            new LogItem("workflows", "workflowID",  $workflowID)
        ]); 

        return $workflowID;
    }

    public function setDynamicApprover($stepID, $indicatorID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID,
                      ':indicatorID' => $indicatorID, );
        $this->db->prepared_query('UPDATE workflow_steps
                                            SET indicatorID_for_assigned_empUID=:indicatorID
                                            WHERE stepID=:stepID', $vars);
                                            
        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "stepID",  $stepID),
            new LogItem("workflow_steps", "indicatorID_for_assigned_empUID",  $indicatorID),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]); 

        $vars = array(':indicatorID' => $indicatorID);
        $this->db->prepared_query('UPDATE indicators
    										SET required=1
                                            WHERE indicatorID=:indicatorID', $vars);
       
       $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::INDICATOR, [
            new LogItem("indicators", "required",  1, "True"),
            new LogItem("indicators", "indicatorID",  $indicatorID)
        ]);        

        return true;
    }

    public function setDynamicGroupApprover($stepID, $indicatorID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':stepID' => $stepID,
                ':indicatorID' => $indicatorID, );
        $this->db->prepared_query('UPDATE workflow_steps
                                            SET indicatorID_for_assigned_groupID=:indicatorID
        									WHERE stepID=:stepID', $vars);
        
        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "indicatorID_for_assigned_groupID",  $indicatorID),
            new LogItem("workflow_steps", "stepID",  $stepID),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]);   

        $vars = array(':indicatorID' => $indicatorID);
        $this->db->prepared_query('UPDATE indicators
    										SET required=1
    										WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::INDICATOR, [
            new LogItem("indicators", "required",  1, "True"),
            new LogItem("indicators", "indicatorID",  $indicatorID)
        ]);     

        return true;
    }

    /**
     * Retrieve a high level map of the workflow (if valid) to show how steps are routed forwards
     * (a valid workflow is one that has an end)
     * @return array In-order steps of a workflow
     */
    public function getSummaryMap()
    {
        $summary = array();
        $steps = $this->getSteps();
        $firstElement = array_slice($steps, 0, 1)[0];
        if (count($steps) == 0)
        {
            return 0;
        }
        $initialStepID = $firstElement['initialStepID'];

        $stepData = array();
        foreach ($steps as $step)
        {
            $stepData[$step['stepID']] = $step['stepTitle'];
        }

        $routes = $this->getRoutes();
        $routeData = array();
        foreach ($routes as $route)
        {
            if ($route['fillDependency'] != 0)
            {
                $routeData[$route['stepID']]['routes'][]['nextStepID'] = $route['nextStepID'];
                $routeData[$route['stepID']]['stepTitle'] = $stepData[$route['stepID']];
                if ($initialStepID == $route['stepID'])
                {
                    $routeData[$route['stepID']]['isInitialStep'] = 1;
                }
            }
        }

        $routeData = $this->pruneRoutes($initialStepID, $routeData);
        $stepIDs = implode(',', array_keys($routeData));

        $resStepDependencies = $this->db->prepared_query("SELECT * FROM step_dependencies
    												LEFT JOIN dependencies USING (dependencyID)
    												WHERE stepID IN ({$stepIDs})", array());

        if ($resStepDependencies != null)
        {
            foreach ($resStepDependencies as $stepDependency)
            {
                $routeData[$stepDependency['stepID']]['dependencies'][$stepDependency['dependencyID']] = $stepDependency['description'];
            }
        }

        $routeData[0]['routes'][0]['nextStepID'] = $initialStepID;
        $routeData[0]['stepTitle'] = 'Request Submitted';
        $routeData[0]['dependencies'][5] = 'Request Submitted';

        return $routeData;
    }

    // traverses routes to the end of a workflow, deletes dead ends
    // $routePath tracks routes that have already been checked
    private function checkRoute($stepID, $originStepID, &$routeData, $routePath = array())
    {
        if (!isset($routeData[$stepID]))
        {
            return 0;
        }
        foreach ($routeData[$stepID]['routes'] as $key => $route)
        {
            if ($route['nextStepID'] == $stepID
                || $routePath[$route['nextStepID']] == 1)
            {
                unset($routeData[$stepID]['routes'][$key]);
                continue;
            }

            $routeData[$stepID]['triggerCount']++;
            if ($route['nextStepID'] != 0)
            {
                if ($originStepID == $route['nextStepID'])
                {
                    unset($routeData[$stepID]['routes'][$key]);
                    continue;
                }
                if (!isset($routeData[$route['nextStepID']]['triggerCount']))
                {
                    if ($originStepID != 0)
                    {
                        $routePath[$originStepID] = 1;
                    }
                    $this->checkRoute($route['nextStepID'], $stepID, $routeData, $routePath);
                }
            }
        }
    }

    // removes routes that don't lead to the end
    private function pruneRoutes($initialStepID, &$routeData)
    {
        $this->checkRoute($initialStepID, 0, $routeData);
        $hasEnd = false;
        foreach ($routeData as $key => $route)
        {
            if (!isset($route['triggerCount']))
            {
                unset($routeData[$key]);
            }
            else
            {
                if (!isset($route['routes']))
                {
                    unset($routeData[$key]);
                }
            }
        }

        foreach ($routeData as $key => $route)
        {
            foreach ($route['routes'] as $stepKey => $step)
            {
                if ($step['nextStepID'] == 0)
                {
                    $hasEnd = true;
                }
                if (!isset($routeData[$step['nextStepID']])
                        && $step['nextStepID'] != 0)
                {
                    unset($routeData[$key]['routes'][$stepKey]);
                }
            }
        }
        if ($hasEnd == false)
        {
            return array();
        }

        return $routeData;
    }

    //returns user created actions
    public function getUserActions()
    {
        $vars = array();
        $res = $this->db->prepared_query("SELECT * FROM actions WHERE actionType NOT IN ('approve', 'concur', 'defer', 'disapprove', 'sendback', 'submit') AND NOT (deleted = 1)", $vars);

        return $res;
    }

    //returns action
    public function getAction($actionType)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $vars = array(':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '', strip_tags($actionType)));

        $action = $this->db->prepared_query('SELECT * FROM actions WHERE actionType=:actionType AND NOT (deleted = 1)', $vars);
        return $action;
    }

    //edit action
    public function editAction($actionType)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $systemAction = array('approve', 'concur', 'defer', 'disapprove', 'sendback', 'submit', 'sign');

        if (in_array($actionType, $systemAction))
        {
            return 'System Actions cannot be edited.';
        }

        $alignment = 'right';
        if ($_POST['fillDependency'] < 1)
        {
            $alignment = 'left';
        }

        $vars = array(
                ':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '', strip_tags($actionType)),
                ':actionText' => strip_tags($_POST['actionText']),
                ':actionTextPasttense' => strip_tags($_POST['actionTextPasttense']),
                ':actionIcon' => $_POST['actionIcon'],
                ':actionAlignment' => $alignment,
                ':sort' => 0,
                ':fillDependency' => $_POST['fillDependency'],
        );

        $this->db->prepared_query('UPDATE actions SET actionText=:actionText, actionTextPasttense=:actionTextPasttense, actionIcon=:actionIcon, actionAlignment=:actionAlignment, sort=:sort, fillDependency=:fillDependency WHERE actionType=:actionType AND NOT (deleted = 1)', $vars);

        $this->dataActionLogger->logAction(\DataActions::MODIFY, \LoggableTypes::ACTIONS, [
            new LogItem("actions", "actionText",  strip_tags($_POST['actionText'])),
            new LogItem("actions", "actionIcon",  $_POST['actionIcon']),
            new LogItem("actions", "actionAlignment",  $alignment),
            new LogItem("actions", "sort",  0),
            new LogItem("actions", "fillDependency",  $_POST['fillDependency']),
            new LogItem("actions", "actionTextPasttense",   strip_tags($_POST['actionTextPasttense']))
        ]); 

        return 1;
    }

    //removes an action
    public function removeAction($actionType)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $systemAction = array('approve', 'concur', 'defer', 'disapprove', 'sendback', 'submit', 'sign');

        if (in_array($actionType, $systemAction))
        {
            return 'System Actions cannot be removed.';
        }

        $vars = array(':actionType' => strip_tags($actionType), ':deleted' => 1);

        $this->db->prepared_query('UPDATE actions SET deleted=:deleted WHERE actionType=:actionType', $vars);

        $this->dataActionLogger->logAction(\DataActions::DELETE, \LoggableTypes::ACTIONS, [
            new LogItem("actions", "actionType",  strip_tags($actionType)),
            new LogItem("actions", "deleted",  1, true)
        ]); 

        return 1;
    }

    public function getWorkflowIDFromStep($stepID){
        $vars = array(':stepID' => $stepID);

        return $this->db->prepared_query('SELECT * FROM workflow_steps
    										WHERE stepID=:stepID', $vars)[0]['workflowID'];

    }

    public function getDescription($workflowID){
        $vars = array(':workflowID' => $workflowID);

        return $this->db->prepared_query('SELECT * FROM workflows
    										WHERE workflowID=:workflowID', $vars)[0]['description'];

    }

    public function getHistory($filterById)
    {
        return $this->dataActionLogger->getHistory($filterById, "workflowID", \LoggableTypes::WORKFLOW);
    }

    public function setEmailReminderData($stepID, $actionType, $frequency, $recipientGroupID, $emailTemplate, $startDateIndicatorID)
    {
        $vars = array(
            ':workflowID' => $this->workflowID,
            ':stepID' => (int)$stepID,
            ':actionType' => $actionType,
            ':frequency' => (int)$frequency,
            ':recipientGroupID' => (int)$recipientGroupID,
            ':emailTemplate' => $emailTemplate,
            ':startDateIndicatorID' => (int)$startDateIndicatorID
        );
        
        $res = $this->db->prepared_query(
            'INSERT INTO email_reminders (workflowID, stepID, actionType, frequency, recipientGroupID, emailTemplate, startDateIndicatorID)
            VALUES (:workflowID, :stepID, :actionType, :frequency, :recipientGroupID, :emailTemplate, :startDateIndicatorID)
            ON DUPLICATE KEY UPDATE frequency = :frequency, recipientGroupID = :recipientGroupID, emailTemplate = :emailTemplate, startDateIndicatorID = :startDateIndicatorID;',
            $vars);
            
        return 1;
    }

    public function getEmailReminderData($stepID, $actionType)
    {
        $vars = array(
            ':workflowID' => $this->workflowID,
            ':stepID' => (int)$stepID,
            ':actionType' => $actionType
        );
        $res = $this->db->prepared_query(
            'SELECT frequency, recipientGroupID, emailTemplate, startDateIndicatorID FROM email_reminders WHERE (workflowID = :workflowID AND stepID = :stepID AND actionType = :actionType);',
            $vars);

        return $res;
    }

    public function deleteEmailReminderData($stepID, $actionType)
    {
        $vars = array(
            ':workflowID' => $this->workflowID,
            ':stepID' => (int)$stepID,
            ':actionType' => $actionType
        );
        
        $res = $this->db->prepared_query(
            'DELETE FROM email_reminders WHERE (workflowID = :workflowID AND stepID = :stepID AND actionType = :actionType);',
            $vars);

        return 1;
    }

}
