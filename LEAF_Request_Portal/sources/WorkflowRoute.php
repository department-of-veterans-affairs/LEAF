<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Workflow
    Date Created: December 12, 2011

*/

namespace Portal;

class WorkflowRoute
{
    private $db;

    private $login;
    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function toggleRequired(array $post_data): array
    {
        $json = json_encode(array('required' => $post_data['required']));

        $return_value = $this->postRequired($json, $post_data);

        return $return_value;
    }

    /**
     * @param string $action
     *
     * @return array
     * this db method returns a properly formatted json response
     *
     * Created at: 7/31/2023, 8:20:21 AM (America/New_York)
     */
    public function getUsedAction(string $action): array
    {
        $vars = array(':actionType' => $action);
        $sql = 'SELECT `description`, `stepID`
                FROM `workflow_routes`
                LEFT JOIN `workflows` USING (`workflowID`)
                WHERE `actionType` = :actionType';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    private function postRequired(string $value, array $post_data): array
    {
        $vars = array(':displayConditional' => $value,
                    ':workflowID' => (int) $post_data['workflow_id'],
                    ':stepID' => (int) $post_data['step_id'],
                    ':actionType' => 'sendback'
                );
        $sql = 'UPDATE `workflow_routes`
                SET `displayConditional` = :displayConditional
                WHERE `workflowID` = :workflowID
                AND `stepID` = :stepID
                AND `actionType` = :actionType';

        $return_value = $this->db->pdo_update_query($sql, $vars);

        // apparently it's not possible to get the data affected in an update statement
        // but I want to return this data here so getting it myself to send back to the api
        $return_value = $this->getWorkflowRoute($post_data, 'sendback');

        return $return_value;
    }

    private function getWorkflowRoute(array $post_data, string $action_type): array
    {
        $vars = array(':workflowID' => (int) $post_data['workflow_id'],
                    ':stepID' => (int) $post_data['step_id'],
                    ':actionType' => $action_type
                );
        $sql = 'SELECT `workflowID`, `stepID`, `nextStepID`, `actionType`,
                    `displayConditional`
                FROM `workflow_routes`
                WHERE `workflowID` = :workflowID
                AND `stepID` = :stepID
                AND `actionType` = :actionType';

        // this query returns a properly formatted json response
        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

}
