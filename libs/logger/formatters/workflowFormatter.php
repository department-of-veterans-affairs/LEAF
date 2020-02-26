<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';
require_once 'formatOptions.php';

class WorkflowFormatter {
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step %s - %s has been added",
            "variables"=>"stepID,stepTitle"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step %s deleted",
            "variables"=>"stepID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW_STEP => [
            "message"=>"Workflow Step %s",
            "variables"=>"stepID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns"=>"posX,posY,stepTitle,indicatorID_for_assigned_empUID,indicatorID_for_assigned_groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"Workflow %s Step %s %s action has been added",
            "variables"=>"workflowID,stepID,actionType"
        ],
        DataActions::DELETE.'-'.LoggableTypes::ROUTE_EVENTS => [
            "message"=>"Workflow Step %s %s action has been deleted",
            "variables"=>"stepID,actionType"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW_ROUTE => [
            "message"=>"Added %s action between steps %s and %s",
            "variables"=>"actionType,stepID,nextStepID"
        ],
        DataActions::ADD.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow %s created",
            "variables"=>"workflowID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow %s deleted",
            "variables"=>"workflowID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::WORKFLOW => [
            "message"=>"Workflow %s initial step set to %s",
            "variables"=>"workflowID,initialStepID"
        ]
        
    ];

}