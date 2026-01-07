<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Workflow
    Date Created: December 12, 2011

*/

namespace Portal;

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;
use App\Leaf\XSSHelpers;

class Workflow
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $workflowID;

    private $eventFolder = './scripts/events/';

    private $dataActionLogger;

    private $systemAction = array(
        'approve',
        'concur',
        'defer',
        'disapprove',
        'sendback',
        'submit',
        'sign',
        'deleted',
        'changeInitiator',
        'move',
    );
    //request cancel, change initiator, change step
    private $nonWorkflowActions = array(
        'deleted',
        'changeInitiator',
        'move',
    );

    public function __construct($db, $login, $workflowID = 0)
    {
        $this->db = $db;
        $this->login = $login;
        $this->setWorkflowID($workflowID);

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
        $this->dataActionLogger = new DataActionLogger($db, $login);
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

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "stepID", $stepID),
            new LogItem("workflow_steps", "workflowID", $workflowID)
        ]);

        return 1;
    }

    public function getStep(int $stepID): array
    {
        $workflowStepsVars = array(':stepID' => $stepID);
        $workflowStepsSQL = 'SELECT
            workflowID,stepID,stepTitle,stepBgColor,stepFontColor,stepBorder,jsSrc,posX,posY,
            indicatorID_for_assigned_empUID,indicatorID_for_assigned_groupID,requiresDigitalSignature,stepData
            FROM workflow_steps
            WHERE stepID=:stepID;';
        $workflowStepsRes = $this->db->prepared_query($workflowStepsSQL, $workflowStepsVars);

        $workflowStep = [];

        // all I want is the first item, we are grabbing it by its primary key
        if (!empty($workflowStepsRes)) {
            $workflowStep = current($workflowStepsRes);
        }

        return $workflowStep;
    }

    public function getAllSteps()
    {
        $vars = [];
        $query = 'SELECT * FROM `workflow_steps`
                  LEFT JOIN `workflows` USING (`workflowID`)
                  ORDER BY `description`, `stepTitle`';
        $res = $this->db->prepared_query($query, $vars); // The response from Db.php is properly formatted using pdo_select_query.
        return $res;
    }

    public function getStepActions(int $stepID): array
    {
        $vars = array(':stepID' => $stepID);
        $sql = 'SELECT actionType, actionText FROM `workflow_routes`
                    LEFT JOIN actions USING (actionType)
                    WHERE stepID=:stepID';

        $res = $this->db->prepared_query($sql, $vars);

        return $res;
    }

    public function getAllWorkflowSteps()
    {
        $vars = [];
        $query = 'SELECT * FROM `workflow_steps`
                  LEFT JOIN `workflows` USING (`workflowID`)
                  LEFT JOIN `step_modules` USING (`stepID`)
                  ORDER BY `description`, `stepTitle`';
        $res = $this->db->pdo_select_query($query, $vars); // The response from Db.php is properly formatted using pdo_select_query.
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

    // getAllCategories returns all active user-created forms
    // Optional GET parameter "includeStandardLEAF" also returns built-in standardized LEAF forms
    public function getAllCategories()
    {
        if(!isset($_GET['includeStandardLEAF'])) {
            $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID > 0 AND parentID=''
                                                    AND disabled = 0
                                                ORDER BY categoryName", null);
        }
        else {
            $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID != 0 AND parentID=''
                                                    AND disabled = 0
                                                ORDER BY categoryName", null);
        }

        return $res;
    }

    // getAllCategories returns all user-created forms, including ones without an assigned workflow
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

    // retrieve a list of user-generate dependencies and their associated groups
    public function getCustomDependenciesAndGroups()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM `dependencies`
                                            LEFT JOIN `dependency_privs` USING (`dependencyID`)
                                            LEFT JOIN `groups` USING (`groupID`)
                                            ORDER BY description', $vars);

        $result = [];
        foreach($res as $dep) {
            $depID = $dep['dependencyID'];

            // skip non-user generated dependencyIDs
            switch($depID) {
                case $depID < 0:
                case 1: // service chief
                case 5: // request submitted
                case 8: // quadrad
                    continue 2;
                default:
                    break;
            }

            if(!isset($result[$depID])) {
                $result[$depID]['dependencyID'] = $dep['dependencyID'];
                $result[$depID]['description'] = $dep['description'];
            }

            if($dep['groupID'] != null) {
                $result[$depID]['groups'][] = array(
                    'groupID' => $dep['groupID'],
                    'name' => $dep['name'],
                    'groupDescription' => $dep['groupDescription']
                );
            }
        }

        return $result;
    }

    public function getDependencies($stepID)
    {
        $vars = array(':stepID' => $stepID);
        $res = $this->db->prepared_query('SELECT * FROM step_dependencies
                                            LEFT JOIN dependencies USING (dependencyID)
                                            LEFT JOIN dependency_privs USING (dependencyID)
                                            LEFT JOIN `groups` USING (groupID)
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

        $vars = array(
            ':workflowID' => $this->workflowID,
            ':stepID' => $stepID,
            ':x' => max(0, $x),
            ':y' => max(0, $y),
        );
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
        if($this->workflowID < 0 || $stepID < -1) {
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

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::ROUTE_EVENTS, [
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

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::WORKFLOW_ROUTE, [
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
        if($this->workflowID < 0 || $stepID < -1) {
            return 'Restricted command.';
        }

        if ($action === 'sendback') {
            $required = json_encode(array ('required' => false));
        } else {
            $required = '';
        }


        $this->postRoute($this->workflowID, $stepID, $nextStepID, $action, $required);

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::WORKFLOW_ROUTE, [
            new LogItem("workflow_routes", "workflowID", $this->workflowID),
            new LogItem("workflow_routes", "stepID", $stepID),
            new LogItem("workflow_routes", "nextStepID", $nextStepID),
            new LogItem("workflow_routes", "actionType", $action),
            new LogItem("workflow_routes", "displayConditional", $required)
        ]);

        return true;
    }

    /**
     * @param int $workflowID
     * @param int $stepID
     * @param int $nextStepID
     * @param string $action
     * @param string $conditional
     *
     * The db method being used is returning a properly formatted json response
     * @return array
     *
     * Created at: 7/26/2023, 7:59:46 AM (America/New_York)
     */
    public function postRoute(int $workflowID, int $stepID, int $nextStepID, string $action, string $conditional): array
    {
        $vars = array(':workflowID' => $workflowID,
            ':stepID' => $stepID,
            ':nextStepID' => $nextStepID,
            ':action' => $action,
            ':displayConditional' => $conditional,
        );
        $sql = 'INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`,
                    `actionType`, `displayConditional`)
                VALUES (:workflowID, :stepID, :nextStepID, :action,
                    :displayConditional)
                ON DUPLICATE KEY UPDATE `nextStepID` = :nextStepID,
                    `displayConditional` = :displayConditional';

        $res = $this->db->pdo_insert_query($sql, $vars);

        return $res;
    }

    public function getAllEvents()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM events
                                            WHERE eventID NOT LIKE "LeafSecure_%"', $vars);

        return $res;
    }

    /**
     * @param int $workflowID
     *
     * @return array
     *
     * Created at: 7/26/2023, 8:00:08 AM (America/New_York)
     */
    public function getWorkflowEvents(int $workflowID): array
    {
        $vars = array(':workflowID' => $workflowID);
        $sql = 'SELECT `workflowID`, `stepID`, `actionType`, `eventID`
                FROM `route_events`
                WHERE `workflowID` = :workflowID';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * Purpose: Populate list with all Custom Events
     * @return array Custom Events list
     */
    public function getCustomEvents()
    {
        $strSQL = "SELECT eventID, eventDescription, eventType, eventData FROM events WHERE eventID LIKE 'CustomEvent_%'";

        $res = $this->db->query($strSQL);

        return $res;
    }

    /**
     * Purpose: Populate information on specific event
     * @param string $event string EventID being passed through
     * @return object|string Event information (Check for Admin Access and Event pass-through)
     */
    public function getEvent($event = null)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        if ($event === null)
        {
            return 'Event not found, please try again.';
        }

        $vars = array(':eventID' => $event);

        $strSQL = 'SELECT * FROM events WHERE eventID=:eventID';

        $res = $this->db->prepared_query($strSQL, $vars);

        return $res;
    }

    /**
     * Purpose: Edit event information
     * @param string $name Name of event being passed through
     * @param string $newName New Name of event being passed through
     * @param string $desc New Description of the event being passed through
     * @param string $type New Type of the event being passed through
     * @param array $data New Data being passed through
     * @return int|string Successful Edit = 1 (Check for Admin Access, System Event, and Name pass-through)
     */
    public function editEvent($name = null, $newName = null, $desc = '', $type = null, $data = array())
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        if ($this->isSystemEventName($name)) {
            return 'System Events Cannot Be Modified.';
        }

        $newName = XSSHelpers::scrubFilename($newName);
        $name = XSSHelpers::scrubFilename($name);

        if ($name === null || $newName === null || $type === null) {
            return 'Event not found, please try again.';
        }
        $desc = trim($desc);

        //Check for other existing email_templates records with a label that matches desc to avoid inconsistencies.
        //Return information for user if a match is found.  Trim for back compat.
        $vars = array(
            ':label' => $desc,
            ':body' => $name . "_body.tpl",
        );
        $strSQL = "SELECT `label` FROM `email_templates` WHERE TRIM(`label`) = :label AND `body` != :body";
        $res = $this->db->prepared_query($strSQL, $vars);
        if(count($res) > 0) {
            return 'This description has already been used, please use another one.';
        }

        //Update events record
        $vars = array(
            ':eventID' => $name,
            ':eventDescription' => $desc,
            ':newEventID' => $newName,
            ':eventType' => $type,
            ':eventData' => json_encode(
                    array(
                        'NotifyRequestor' => $data['Notify Requestor'],
                        'NotifyNext' => $data['Notify Next'],
                        'NotifyGroup' => $data['Notify Group'],
                )
            )
        );
        $strSQL = "UPDATE events
            SET eventID=:newEventID, eventDescription=:eventDescription, eventType=:eventType, eventData=:eventData
            WHERE eventID=:eventID";
        $this->db->prepared_query($strSQL, $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::EVENTS, [
            new LogItem("events", "eventDescription",  $desc),
            new LogItem("events", "eventID",  $name)
        ]);

        //check for corresponding non-system email template record before updating and renaming files
        $vars = array(':oldBody' => $name . "_body.tpl");
        $strSQL = "SELECT emailTemplateID FROM `email_templates` WHERE body=:oldBody AND emailTemplateID > 1";
        $res = $this->db->prepared_query($strSQL, $vars);

        if(count($res) === 1) {
            //update email_templates record
            $vars = array(
                ':emailTo' => "{$newName}_emailTo.tpl",
                ':emailCc' => "{$newName}_emailCc.tpl",
                ':subject' => "{$newName}_subject.tpl",
                ':oldBody' => "{$name}_body.tpl",
                ':body' => "{$newName}_body.tpl",
                ':newLabel' => $desc);

            $strSQL = "UPDATE email_templates
                SET label=:newLabel, emailTo=:emailTo, emailCc=:emailCc, subject=:subject, body=:body
                WHERE body=:oldBody AND emailTemplateID > 1";

            $this->db->prepared_query($strSQL, $vars);

            //rename files
            if (file_exists("../templates/email/custom_override/{$name}_body.tpl")) {
                rename("../templates/email/custom_override/{$name}_body.tpl", "../templates/email/custom_override/{$newName}_body.tpl");
                rename("../templates/email/custom_override/{$name}_subject.tpl", "../templates/email/custom_override/{$newName}_subject.tpl");
                rename("../templates/email/custom_override/{$name}_emailTo.tpl", "../templates/email/custom_override/{$newName}_emailTo.tpl");
                rename("../templates/email/custom_override/{$name}_emailCc.tpl", "../templates/email/custom_override/{$newName}_emailCc.tpl");
            }
        }
        return 1;
    }

    public function getActions()
    {
        $vars = array(
            ':nonWorkflowActions' => implode(",", $this->nonWorkflowActions)
        );
        $qSQL = "SELECT `actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`, `deleted`
            FROM actions WHERE NOT FIND_IN_SET(actionType, :nonWorkflowActions) AND deleted=0 ORDER BY actionText";
        $res = $this->db->prepared_query($qSQL, $vars);

        return $res;
    }

    public function setInitialStep($stepID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if($this->workflowID < 0 || $stepID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
            ':stepID' => $stepID,
        );
        $res = $this->db->prepared_query('UPDATE workflows SET initialStepID=:stepID
                                            WHERE workflowID=:workflowID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::WORKFLOW, [
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
     * @return int|string The newly created stepID
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

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::WORKFLOW_STEP, [
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
     * @return int|string The newly created stepID
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

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflows", "stepID", $stepID),
            new LogItem("workflows", "stepTitle",  $stepTitle),
            new LogItem("workflows", "jsSrc",  "", "empty"),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]);

        return 1;
    }

    public function saveStepData(int $stepID, array $data) : bool{

        $validSaveStep = TRUE;

        // everything that seems to modify this stuff is run through here.
        if (!$this->login->checkGroup(1))
        {
            $validSaveStep = FALSE;
        }
        // Don't allow changes to standardized components
        if($stepID < 0) {
            $validSaveStep = FALSE;
        }

        if( $validSaveStep === TRUE ){
            $vars = [
                ':stepID' => $stepID,
                ':stepData' => json_encode(['AutomatedEmailReminders' => [
                        'AutomateEmailGroup' => $data['AutomatedEmailReminders']['Automate Email Group'],
                        'DaysSelected' => $data['AutomatedEmailReminders']['Days Selected'],
                        'DateSelected' => $data['AutomatedEmailReminders']['Date Selected'],
                        'AdditionalDaysSelected' => $data['AutomatedEmailReminders']['Additional Days Selected']
                    ]
                ])
            ];

            $strSQL = "UPDATE workflow_steps SET stepData=:stepData WHERE stepID=:stepID";

            $this->db->prepared_query($strSQL, $vars);
        }

        return $validSaveStep;

    }

    /**
     * Set an inline indicator for a particular step
     *
     * @param int $stepID
     * @param int $indicatorID
     *
     * @return int|string
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
        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::STEP_MODULE, [
            new LogItem("workflows", "stepID", $stepID),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID)),
            new LogItem("step_modules", "moduleConfig", $indicatorID)
        ]);
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
     * @return int|string if the query was successful
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

        $depVars = array(':dependencyID' => $dependencyID);
        $dep = $this->db->prepared_query("SELECT `description` FROM dependencies WHERE dependencyID=:dependencyID", $depVars)[0];
        $depDescr = $dep["description"];

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::STEP_DEPENDENCY, [
            new LogItem("workflows", "workflowID", $this->workflowID),
            new LogItem("step_dependencies", "stepID",  $stepID),
            new LogItem("step_dependencies", "dependencyID",  $dependencyID, $depDescr." (#".$dependencyID.")")
        ]);

        // populate records_dependencies so we can filter on items immediately
        $this->db->prepared_query('INSERT IGNORE INTO records_dependencies (recordID, dependencyID, filled)
    									SELECT recordID, :dependencyID as dependencyID, 0 as filled FROM workflow_steps
    										LEFT JOIN categories USING (workflowID)
    										LEFT JOIN category_count USING (categoryID)
    										WHERE stepID=:stepID AND count > 0', $vars);

        return true;
    }

    /**
     * @param mixed $stepID
     * @param mixed $dependencyID
     *
     * @return bool|string
     *
     */
    public function unlinkDependency($stepID, $dependencyID): bool|string
    {
        $return_value = true;

        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required.';
        } else if ($stepID < 0) {
            $return_value = 'Restricted command.';
        } else {
            $this->deleteStepDependency($stepID, $dependencyID);
            $this->cleanUpDbAfterDependencyDelete($stepID, $dependencyID);

            $depVars = array(':dependencyID' => $dependencyID);
            $dep = $this->db->prepared_query("SELECT `description` FROM dependencies WHERE dependencyID=:dependencyID", $depVars)[0];
            $depDescr = $dep["description"];

            $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::STEP_DEPENDENCY, [
                new LogItem("workflows", "workflowID", $this->workflowID),
                new LogItem("step_dependencies", "stepID",  $stepID),
                new LogItem("step_dependencies", "dependencyID",  $dependencyID, $depDescr." (#".$dependencyID.")")
            ]);
        }

        return $return_value;
    }

    // updateDependency updates the description associated with $dependencyID
    public function updateDependency($dependencyID, $description)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized dependencies
        if($dependencyID < 0) {
            http_response_code(400);
            return 'description may not be updated for this requirement';
        }

        $vars = array(':dependencyID' => $dependencyID,
            ':description' => $description,
        );
        $res = $this->db->prepared_query('UPDATE dependencies
    										SET description=:description
    										WHERE dependencyID=:dependencyID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::DEPENDENCY, [
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

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::DEPENDENCY, [
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

        $reservedDependencyIDs = [
            1, // Service Chief
            8 // Quadrad
        ];
        if($dependencyID < 0 || in_array($dependencyID, $reservedDependencyIDs)) {
            http_response_code(400);
            return 'groups may not be added to this requirement';
        }

        $vars = array(':dependencyID' => $dependencyID,
            ':groupID' => $groupID,
        );
        $res = $this->db->prepared_query('INSERT INTO dependency_privs (dependencyID, groupID)
                                            VALUES (:dependencyID, :groupID)', $vars);

        $vars = array(':dependencyID' => $dependencyID);
        $strSQL = "SELECT `description` FROM dependencies WHERE dependencyID=:dependencyID";
        $depDescr = $this->db->prepared_query($strSQL, $vars)[0]["description"] ?? "";

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::DEPENDENCY_PRIVS, [
            new LogItem("dependency_privs", "groupID",  $groupID),
            new LogItem("dependency_privs", "dependencyID",  $dependencyID, $depDescr." (#".$dependencyID.")")
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

        $vars = array(':dependencyID' => $dependencyID);
        $strSQL = "SELECT `description` FROM dependencies WHERE dependencyID=:dependencyID";
        $depDescr = $this->db->prepared_query($strSQL, $vars)[0]["description"] ?? "";

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::DEPENDENCY_PRIVS, [
            new LogItem("dependency_privs", "groupID",  $groupID),
            new LogItem("dependency_privs", "dependencyID", $dependencyID, $depDescr." (#".$dependencyID.")")
        ]);

        return true;
    }

    private function isSystemEventName(?string $name) :bool
    {
        $txt = $name ?? '';
        return preg_match("/^std_email/i", $txt) || preg_match("/^LeafSecure/i", $txt);
    }

    /**
     * Purpose: Create a new Custom Event
     * @param string $name Custom Event Name
     * @param string $desc Custom Event Description
     * @param string $type Custom Event Type (Email, Script, etc...)
     * @param array $data Custom Event Data
     * @return bool|string If the event was created successful true/false (Check for Admin Access, System Event, and Name pass-through)
     */
    public function createEvent($name = null, $desc = '', $type = null, $data = array())
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        if ($this->isSystemEventName($name)) {
            return 'Event Already Exists.';
        }

        if ($name === null || $type === null) {
            return 'Error creating event, please try again.';
        }
        $desc = trim($desc);

        //Check for an existing email_templates record with a label that matches desc to avoid inconsistencies.
        //Return information for user if a match is found.  Trim for back compat.
        $vars = array(
            ':label' => $desc,
            ':body' => $name . "_body.tpl",
        );
        $strSQL = "SELECT `label` FROM `email_templates` WHERE TRIM(`label`) = :label AND `body` != :body";
        $res = $this->db->prepared_query($strSQL, $vars);
        if(count($res) > 0) {
            return 'This description has already been used, please use another one.';
        }

        //insert events record
        $vars = array(
            ':eventID' => $name,
            ':description' => $desc,
            ':eventType' => $type,
            ':eventData' => json_encode(
                array(
                    'NotifyRequestor' => $data['Notify Requestor'],
                    'NotifyNext' => $data['Notify Next'],
                    'NotifyGroup' => $data['Notify Group'],
                )
            )
        );

        $strSQL = "INSERT INTO events (eventID, eventDescription, eventType, eventData) VALUES (:eventID, :description, :eventType, :eventData)";

        $this->db->prepared_query($strSQL, $vars);

        //insert email_templates record
        $vars = array(':description' => $desc,
            ':emailTo' => $name . '_emailTo.tpl',
            ':emailCc' => $name . '_emailCc.tpl',
            ':subject' => $name . '_subject.tpl',
            ':body' => $name . '_body.tpl');

        $strSQL = 'INSERT INTO email_templates (label, emailTo, emailCc, subject, body) VALUES (:description, :emailTo, :emailCc, :subject, :body)';

        $this->db->prepared_query($strSQL, $vars);

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::EVENTS, [
            new LogItem("events", "eventDescription",  $desc),
            new LogItem("events", "eventID",  $name)
        ]);

        return true;
    }

    /**
     * Purpose: Delete a Custom Event
     * @param string $event EventID that is being deleted
     * @return int|string Successful Delete = 1 (Check for Admin Access, System Event, and Name pass-through)
     */
    public function removeEvent($event)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        if ($this->isSystemEventName($event)) {
            return 'System Events cannot be removed.';
        }

        //Delete events record
        $vars = array(':eventID' => $event);
        $strSQL = 'DELETE FROM events WHERE eventID=:eventID';
        $this->db->prepared_query($strSQL, $vars);

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::EVENTS, [
            new LogItem("events", "eventID",  $event)
        ]);

        //check for corresponding non-system email template record before deleting email_templates record and unlinking templates
        $vars = array(':oldBody' => $event . "_body.tpl");
        $strSQL = "SELECT emailTemplateID FROM `email_templates` WHERE body=:oldBody AND emailTemplateID > 1";
        $res = $this->db->prepared_query($strSQL, $vars);

        if(count($res) === 1) {
            //Delete corresponding email_templates record
            $vars = array(':body' => $event."_body.tpl");
            $strSQL = 'DELETE FROM email_templates WHERE body=:body AND emailTemplateID > 1';
            $this->db->prepared_query($strSQL, $vars);

            // Delete Custom Email Templates
            if (file_exists("../templates/email/custom_override/{$event}_body.tpl"))
                unlink("../templates/email/custom_override/{$event}_body.tpl");
            if (file_exists("../templates/email/custom_override/{$event}_subject.tpl"))
                unlink("../templates/email/custom_override/{$event}_subject.tpl");
            if (file_exists("../templates/email/custom_override/{$event}_emailTo.tpl"))
                unlink("../templates/email/custom_override/{$event}_emailTo.tpl");
            if (file_exists("../templates/email/custom_override/{$event}_emailCc.tpl"))
                unlink("../templates/email/custom_override/{$event}_emailCc.tpl");
        }

        return 1;
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

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::ROUTE_EVENTS, [
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

       $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::ROUTE_EVENTS, [
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

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::WORKFLOW, [
            new LogItem("workflows", "workflowID",  $this->workflowID)
        ]);

        return true;
    }

    public function renameWorkflow(string $description): string
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required.';
        }

        // Don't allow changes to standardized components
        if ($this->workflowID < 0) {
            return 'Restricted command.';
        }

        $vars = array(':workflowID' => $this->workflowID,
                      ':description' => $description
                );
        $strSQL = "UPDATE workflows SET description = :description WHERE workflowID = :workflowID";

        $this->db->prepared_query($strSQL, $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::WORKFLOW_NAME, [
            new LogItem("workflow_name", "description",  $description),
            new LogItem("workflow_name", "workflowID",  $this->workflowID)
        ]);

        return $this->workflowID;
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

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::WORKFLOW, [
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

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "stepID",  $stepID),
            new LogItem("workflow_steps", "indicatorID_for_assigned_empUID",  $indicatorID),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]);

        $vars = array(':indicatorID' => $indicatorID);
        $this->db->prepared_query('UPDATE indicators
    										SET required=1
                                            WHERE indicatorID=:indicatorID', $vars);

       $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::INDICATOR, [
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

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::WORKFLOW_STEP, [
            new LogItem("workflow_steps", "indicatorID_for_assigned_groupID",  $indicatorID),
            new LogItem("workflow_steps", "stepID",  $stepID),
            new LogItem("workflow_steps", "workflowID", $this->getWorkflowIDFromStep($stepID))
        ]);

        $vars = array(':indicatorID' => $indicatorID);
        $this->db->prepared_query('UPDATE indicators
    										SET required=1
    										WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::INDICATOR, [
            new LogItem("indicators", "required",  1, "True"),
            new LogItem("indicators", "indicatorID",  $indicatorID)
        ]);

        return true;
    }

    /**
     * @param int $stepID
     *
     * @return array
     *
     * Created at: 7/25/2023, 3:01:12 PM (America/New_York)
     */
    public function getStepDependencies(int $stepID): array
    {
        $vars = array(':stepID' => $stepID);
        $sql = 'SELECT `stepID`, `dependencyID`
                FROM `step_dependencies`
                WHERE `stepID` = :stepID';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
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
            return [];
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
        $vars = array(
            ':systemAction' => implode(",", $this->systemAction)
        );
        $qSQL = "SELECT `actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`, `deleted`
            FROM actions WHERE NOT FIND_IN_SET(actionType, :systemAction) AND NOT (deleted = 1)";
        $res = $this->db->prepared_query($qSQL, $vars);

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

        if (in_array($actionType, $this->systemAction))
        {
            return 'System Actions cannot be edited.';
        }

        $alignment = 'right';
        if ($_POST['fillDependency'] < 1)
        {
            $alignment = 'left';
        }
        $sort = (int)strip_tags($_POST['sort'] ?? 0);
        if ($sort < -128) {
            $sort = -128;
        }
        if ($sort > 127) {
            $sort = 127;
        }

        $vars = array(
            ':actionType' => preg_replace('/[^a-zA-Z0-9_]/', '', strip_tags($actionType)),
            ':actionText' => strip_tags($_POST['actionText']),
            ':actionTextPasttense' => strip_tags($_POST['actionTextPasttense']),
            ':actionIcon' => $_POST['actionIcon'],
            ':actionAlignment' => $alignment,
            ':sort' => $sort,
            ':fillDependency' => $_POST['fillDependency'],
        );

        $this->db->prepared_query('UPDATE actions SET actionText=:actionText, actionTextPasttense=:actionTextPasttense, actionIcon=:actionIcon, actionAlignment=:actionAlignment, sort=:sort, fillDependency=:fillDependency WHERE actionType=:actionType AND NOT (deleted = 1)', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::ACTIONS, [
            new LogItem("actions", "actionText",  strip_tags($_POST['actionText'])),
            new LogItem("actions", "actionIcon",  $_POST['actionIcon']),
            new LogItem("actions", "actionAlignment",  $alignment),
            new LogItem("actions", "sort",  $sort),
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

        if (in_array($actionType, $this->systemAction))
        {
            return 'System Actions cannot be removed.';
        }

        $vars = array(':actionType' => strip_tags($actionType), ':deleted' => 1);

        $this->db->prepared_query('UPDATE actions SET deleted=:deleted WHERE actionType=:actionType', $vars);

        $this->dataActionLogger->logAction(DataActions::DELETE, LoggableTypes::ACTIONS, [
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

    public function getHistory(string $filterById): array
    {
        $stepVars = array(':workflowID' => $filterById);
        $strSQL = "SELECT workflow_steps.stepID, dependencyID FROM workflow_steps
            INNER JOIN step_dependencies USING (stepID)
            WHERE workflowID=:workflowID
            GROUP BY dependencyID";

        $depData = $this->db->prepared_query($strSQL, $stepVars);

        $log = $this->dataActionLogger->getHistory($filterById, "workflowID", LoggableTypes::WORKFLOW);
        if(count($depData) > 0) {
            foreach($depData as $entry) {
                $depHistory = $this->dataActionLogger->getHistory((string)$entry["dependencyID"], "dependencyID", LoggableTypes::DEPENDENCY_PRIVS);
                $log = array_merge($log, $depHistory);
            }
        }
        return $log;
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

    /**
     * @param int $stepID
     * @param int $dependencyID
     *
     * @return void
     *
     */
    private function cleanUpDbAfterDependencyDelete(int $stepID, int $dependencyID): void
    {
        $vars = array(':stepID' => $stepID,
            ':dependencyID' => $dependencyID,
        );
        $sql = 'DELETE `records_dependencies`
                FROM `records_dependencies`
                INNER JOIN `category_count` USING (`recordID`)
                INNER JOIN `categories` USING (`categoryID`)
                INNER JOIN `workflow_steps` USING (`workflowID`)
                WHERE `stepID` = :stepID
                AND `dependencyID` = :dependencyID
                AND `filled` = 0
                AND `records_dependencies`.`time` IS NULL';

        $this->db->prepared_query($sql, $vars);

        // if deleting person designated or group designated then the indicator
        // needs to be cleared in the workflow_steps table as well
        if ($dependencyID === -1) {
            unset($vars[':dependencyID']);
            $sql2 = 'UPDATE `workflow_steps`
                    SET `indicatorID_for_assigned_empUID` = NULL
                    WHERE `stepID` = :stepID';
        } else if ($dependencyID === -3) {
            unset($vars[':dependencyID']);
            $sql2 = 'UPDATE `workflow_steps`
                    SET `indicatorID_for_assigned_groupID` = NULL
                    WHERE `stepID` = :stepID';
        }
        if ($dependencyID === -1 || $dependencyID === -3) {
            $this->db->prepared_query($sql2, $vars);
        }
    }

    /**
     * @param int $stepID
     * @param int $dependencyID
     *
     * @return void
     *
     */
    private function deleteStepDependency(int $stepID, int $dependencyID): void
    {
        $vars = array(':stepID' => $stepID,
            ':dependencyID' => $dependencyID,
        );
        $sql = 'DELETE
                FROM `step_dependencies`
                WHERE `stepID` = :stepID
                AND `dependencyID` = :dependencyID';

        $this->db->prepared_query($sql, $vars);
    }
}
