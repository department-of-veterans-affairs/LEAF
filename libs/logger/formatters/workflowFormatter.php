<?php

namespace Leaf;

require_once 'loggableTypes.php';
require_once 'dataActions.php';
require_once 'formatOptions.php';

class WorkflowFormatter {
    /** Templates for determining what data to grab based on the workflow action.
     * Action data is retrieved from the data_log_items table.
     * Each action consists of three rows, each serving as an attribute of the action.
     * The attributes differ based on the type of action.
     * The attributes are described in the variables property of each template.
     */


    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step <strong>%s</strong> - <strong>%s</strong> has been added",
            "variables"=>"stepID,stepTitle"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step <strong>%s</strong> deleted",
            "variables"=>"stepID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step <strong>%s</strong>",
            "variables"=>"stepID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns"=>"posX,posY,stepTitle,indicatorID_for_assigned_empUID,indicatorID_for_assigned_groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::EVENTS => [
            "message"=>"Event <strong>%s</strong> has been added",
            "variables"=>"eventDescription"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EVENTS => [
            "message"=>"Event <strong>%s</strong> has been deleted",
            "variables"=>"eventID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EVENTS => [
            "message"=>"Event <strong>%s</strong> has been modified",
            "variables"=>"eventDescription"
        ],
        DataActions::ADD.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"Workflow <strong>%s</strong> Step <strong>%s</strong> <strong>%s</strong> action has been added",
            "variables"=>"workflowID,stepID,actionType"
        ],
        // This is labelled differently in the data_log_items table than the add route_events event. (action instead of actionType)
        DataActions::DELETE.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"Workflow <strong>%s</strong> Step <strong>%s</strong> <strong>%s</strong> action has been deleted",
            "variables"=>"workflowID,stepID,action"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_ROUTE => [
            "message"=>"Added <strong>%s</strong> action between steps <strong>%s</strong> and <strong>%s</strong>",
            "variables"=>"actionType,stepID,nextStepID"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow <strong>%s</strong> created",
            "variables"=>"workflowID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow <strong>%s</strong> deleted",
            "variables"=>"workflowID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow <strong>%s</strong> initial step set to <strong>%s</strong>",
            "variables"=>"workflowID,initialStepID"
        ]

    ];

}