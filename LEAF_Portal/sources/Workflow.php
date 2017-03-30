<?php
/************************
    Workflow
    Date Created: December 12, 2011

*/

class Workflow
{
    private $db;
    private $login;
    private $workflowID;
    private $eventFolder = './scripts/events/';
    public $siteRoot = '';

    function __construct($db, $login, $workflowID = 0)
    {
        $this->db = $db;
        $this->login = $login;
        $this->setWorkflowID($workflowID);
        
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://{$_SERVER['HTTP_HOST']}" . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    public function setWorkflowID($workflowID)
    {
        $this->workflowID = is_numeric($workflowID) ? $workflowID : 0;
    }
    
    public function getSteps()
    {
        $vars = array(':workflowID' => $this->workflowID);
        $res = $this->db->prepared_query("SELECT * FROM workflow_steps
                                            LEFT JOIN workflows USING (workflowID)
        									WHERE workflowID=:workflowID", $vars);
        return $res;
    }

    public function deleteStep($stepID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    	
    	$vars = array(':stepID' => $stepID);
    	$res = $this->db->prepared_query('SELECT * FROM records_workflow_state
    										WHERE stepID = :stepID', $vars);
    	if(count($res) > 0) {
    		return 'Requests currently on this step need to be moved first.';
    	}
    	
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
        $res = $this->db->prepared_query("SELECT * FROM workflow_routes
        										LEFT JOIN actions USING (actionType)
            									WHERE workflowID=:workflowID", $vars);
    
        return $res;
    }

    public function getAllUniqueWorkflows()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM workflows', $vars);
    
        return $res;
    }

    public function getCategories()
    {
        $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID>0 AND parentID=''
        											AND disabled = 0
        										ORDER BY categoryName", null);
        return $res;
    }
    
    public function getCategoriesUnabridged()
    {
    	$res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE parentID=''
    												AND disabled = 0
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
        $res = $this->db->prepared_query("SELECT * FROM step_dependencies
                                            LEFT JOIN dependencies USING (dependencyID)
                                            LEFT JOIN dependency_privs USING (dependencyID)
                                            LEFT JOIN groups USING (groupID)
        									LEFT JOIN workflow_steps USING (stepID)
                                            WHERE stepID = :stepID", $vars);
        return $res;
    }

    public function getEvents($stepID, $action)
    {
        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':action' => $action);

        $res = $this->db->prepared_query("SELECT * FROM route_events
                LEFT JOIN events USING (eventID)
                WHERE workflowID = :workflowID
                    AND stepID = :stepID
                    AND actionType = :action", $vars);

        return $res;
    }
    
    public function setEditorPosition($stepID, $x, $y)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    	$vars = array(':workflowID' => $this->workflowID,
    				  ':stepID' => $stepID,
    				  ':x' => $x,
    				  ':y' => $y);
    	$res = $this->db->prepared_query("UPDATE workflow_steps
                                            SET posX=:x, posY=:y
        									WHERE workflowID=:workflowID
    											AND stepID=:stepID", $vars);
    	return true;
    }

    public function deleteAction($stepID, $nextStepID, $action) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    	// clear out route events
    	$vars = array(':workflowID' => $this->workflowID,
    				  ':stepID' => $stepID,
    			      ':action' => $action);
    	$res = $this->db->prepared_query('DELETE FROM route_events
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
    											AND actionType=:action', $vars);

    	// clear out routes
    	$vars = array(':workflowID' => $this->workflowID,
    			':stepID' => $stepID,
    			':nextStepID' => $nextStepID,
    			':action' => $action);
    	$res = $this->db->prepared_query('DELETE FROM workflow_routes
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
    											AND nextStepID=:nextStepID
    											AND actionType=:action', $vars);
    	return true;
    }
    
    public function createAction($stepID, $nextStepID, $action) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}

    	$vars = array(':workflowID' => $this->workflowID,
		    		  ':stepID' => $stepID,
		    		  ':nextStepID' => $nextStepID,
		    		  ':action' => $action,
    			      ':displayConditional' => ''
    	);
    	$res = $this->db->prepared_query('INSERT INTO workflow_routes (workflowID, stepID, nextStepID, actionType, displayConditional)
    										VALUES (:workflowID, :stepID, :nextStepID, :action, :displayConditional)', $vars);
    	return true;
    }

    public function getAllEvents()
    {
    	$vars = array();
    	$res = $this->db->prepared_query("SELECT * FROM events", $vars);
    	return $res;
    }

    public function getActions()
    {
    	$vars = array();
    	$res = $this->db->prepared_query("SELECT * FROM actions ORDER BY actionText", $vars);
    	return $res;
    }

    public function setInitialStep($stepID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':workflowID' => $this->workflowID,
    				  ':stepID' => $stepID
    	);
    	$res = $this->db->prepared_query('UPDATE workflows SET initialStepID=:stepID
    										WHERE workflowID=:workflowID', $vars);
    	return true;
    }

    /**
     * @param string $stepTitle
     * @param string $bgColor
     * @param string $fontColor
     * @return int The newly created stepID
     */
    public function createStep($stepTitle, $bgColor, $fontColor) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}

    	$vars = array(':workflowID' => $this->workflowID,
		    			':stepTitle' => $stepTitle,
    				    ':jsSrc' => ''
    	);
    	$res = $this->db->prepared_query('INSERT INTO workflow_steps (workflowID, stepTitle, jsSrc)
    										VALUES (:workflowID, :stepTitle, :jsSrc)', $vars);
    	return $this->db->getLastInsertID();
    }

    /**
     * @param string $stepTitle
     * @param string $bgColor
     * @param string $fontColor
     * @return int The newly created stepID
     */
    public function updateStep($stepID, $stepTitle, $bgColor = '', $fontColor = '') {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':stepID' => $stepID,
    	    		  ':stepTitle' => $stepTitle
    	);
    	$res = $this->db->prepared_query('UPDATE workflow_steps
    										SET stepTitle=:stepTitle
    										WHERE stepID=:stepID', $vars);
    	return 1;
    }

    public function linkDependency($stepID, $dependencyID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':stepID' => $stepID,
    				  ':dependencyID' => $dependencyID
    	);
    	$res = $this->db->prepared_query('INSERT INTO step_dependencies (stepID, dependencyID)
    										VALUES (:stepID, :dependencyID)', $vars);

    	// populate records_dependencies so we can filter on items immediately
    	$this->db->prepared_query('INSERT IGNORE INTO records_dependencies (recordID, dependencyID, filled)
    									SELECT recordID, :dependencyID as dependencyID, 0 as filled FROM workflow_steps
    										LEFT JOIN categories USING (workflowID)
    										LEFT JOIN category_count USING (categoryID)
    										WHERE stepID=:stepID AND count > 0', $vars);
    	
    	return true;
    }

    public function unlinkDependency($stepID, $dependencyID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':stepID' => $stepID,
    				  ':dependencyID' => $dependencyID
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
    	
    	return true;
    }

    public function updateDependency($dependencyID, $description) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':dependencyID' => $dependencyID,
    			      ':description' => $description
    	);
    	$res = $this->db->prepared_query('UPDATE dependencies
    										SET description=:description
    										WHERE dependencyID=:dependencyID', $vars);
    	return 1;
    }

    public function addDependency($description) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':description' => $description
    	);
    	$res = $this->db->prepared_query('INSERT INTO dependencies (description)
    										VALUES (:description)', $vars);
    	return $this->db->getLastInsertID();
    }

    public function grantDependencyPrivs($dependencyID, $groupID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':dependencyID' => $dependencyID,
    				  ':groupID' => $groupID
    	);
    	$res = $this->db->prepared_query('INSERT INTO dependency_privs (dependencyID, groupID)
    										VALUES (:dependencyID, :groupID)', $vars);
    	return true;
    }

    public function revokeDependencyPrivs($dependencyID, $groupID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':dependencyID' => $dependencyID,
    				  ':groupID' => $groupID
    	);
    	$res = $this->db->prepared_query('DELETE FROM dependency_privs
    										WHERE dependencyID=:dependencyID
    											AND groupID=:groupID', $vars);
    	return true;
    }

    public function linkEvent($stepID, $actionType, $eventID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
        $vars = array(':workflowID' => $this->workflowID,
                      ':stepID' => $stepID,
                      ':actionType' => $actionType,
        		      ':eventID' => $eventID
        );
    	$res = $this->db->prepared_query('INSERT INTO route_events (workflowID, stepID, actionType, eventID)
    										VALUES (:workflowID, :stepID, :actionType, :eventID)', $vars);
    	return true;
    }

    public function unlinkEvent($stepID, $actionType, $eventID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':workflowID' => $this->workflowID,
    			':stepID' => $stepID,
    			':actionType' => $actionType,
    			':eventID' => $eventID
    	);
    	$res = $this->db->prepared_query('DELETE FROM route_events
    										WHERE workflowID=:workflowID
    											AND stepID=:stepID
    											AND actionType=:actionType
    											AND eventID=:eventID', $vars);
    	return true;
    }

    public function deleteWorkflow($workflowID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}

    	$vars = array(':workflowID' => $workflowID);
    	$res = $this->db->prepared_query('SELECT * FROM workflow_steps
    										WHERE workflowID = :workflowID', $vars);
    	if(count($res) > 0) {
    		return 'Steps within the workflow must be deleted first.';
    	}

    	$res = $this->db->prepared_query('SELECT * FROM categories
    										WHERE workflowID = :workflowID', $vars);
    	if(count($res) > 0) {
    		return 'Forms must be disconnected from this workflow first.';
    	}

    	$res = $this->db->prepared_query('DELETE FROM workflows
    										WHERE workflowID = :workflowID', $vars);
    	return true;
    }

    public function newWorkflow($description)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    
    	$vars = array(':description' => $description
    	);
    	$res = $this->db->prepared_query('INSERT INTO workflows (description)
    										VALUES (:description)', $vars);

    	return $this->db->getLastInsertID();
    }

    public function setDynamicApprover($stepID, $indicatorID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    	$vars = array(':stepID' => $stepID,
    				  ':indicatorID' => $indicatorID);
    	$this->db->prepared_query('UPDATE workflow_steps
                                            SET indicatorID_for_assigned_empUID=:indicatorID
        									WHERE stepID=:stepID', $vars);

    	$vars = array(':indicatorID' => $indicatorID);
    	$this->db->prepared_query('UPDATE indicators
    										SET required=1
    										WHERE indicatorID=:indicatorID', $vars);
    	return true;
    }

    public function setDynamicGroupApprover($stepID, $indicatorID)
    {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required.';
    	}
    	$vars = array(':stepID' => $stepID,
    			':indicatorID' => $indicatorID);
    	$this->db->prepared_query('UPDATE workflow_steps
                                            SET indicatorID_for_assigned_groupID=:indicatorID
        									WHERE stepID=:stepID', $vars);
    
    	$vars = array(':indicatorID' => $indicatorID);
    	$this->db->prepared_query('UPDATE indicators
    										SET required=1
    										WHERE indicatorID=:indicatorID', $vars);
    	return true;
    }
}
