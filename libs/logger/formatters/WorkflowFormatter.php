<?php

namespace Leaf;

class WorkflowFormatter
{
    /** Templates for determining what data to grab based on the workflow action.
     * Action data is retrieved from the data_log_items table.
     * Each action consists of three rows, each serving as an attribute of the action.
     * The attributes differ based on the type of action.
     * The attributes are described in the variables property of each template.
     */

    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"added <strong>new workflow step:</strong> %s",
            "variables"=>"stepTitle"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"removed <strong>workflow step:</strong> %s",
            "variables"=>"stepTitle"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::STEP_MODULE => [
            "message"=>"changed form field to %s in <strong>workflow step:</strong> %s",
            "variables"=>"moduleConfig,stepID",
            "loggableColumns"=>"moduleConfig"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"<strong>workflow step:</strong> %s",
            "variables"=>"stepID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns"=>"posX,posY,stepTitle,indicatorID_for_assigned_empUID,indicatorID_for_assigned_groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::EVENTS => [
            "message"=>"added <strong>new event:</strong> %s",
            "variables"=>"eventDescription"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EVENTS => [
            "message"=>"removed <strong>event</strong> %s",
            "variables"=>"eventID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EVENTS => [
            "message"=>"modified <strong>event:</strong> %s",
            "variables"=>"eventDescription"
        ],
        DataActions::ADD.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"added <strong>new action:</strong> <strong>workflow:</strong> %s <strong>step %s:</strong> %s",
            "variables"=>"workflowID,stepID,actionType"
        ],
        // This is labelled differently in the data_log_items table than the add route_events event. (action instead of actionType)
        DataActions::DELETE.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"removed <strong>action:</strong> <strong>workflow:</strong> %s <strong>step %s:</strong> %s",
            "variables"=>"workflowID,stepID,action"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_ROUTE => [
            "message"=>"added <strong>action: </strong>%s between <strong>steps:</strong> %s, %s",
            "variables"=>"actionType,stepID,nextStepID"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"added <strong>new workflow:</strong> %s",
            "variables"=>"workflowID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"removed <strong>workflow:</strong> %s",
            "variables"=>"workflowID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"set <strong>initial step:</strong> %s in <strong>workflow:</strong> %s",
            "variables"=>"initialStepID,workflowID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW_NAME => [
            "message"=>"set <strong>name:</strong> %s in <strong>workflow:</strong> %s",
            "variables"=>"description,workflowID"
        ],
    ];

    const TABLE = "workflows";

}
