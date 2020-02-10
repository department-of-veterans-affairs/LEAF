<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';
require_once 'formatOptions.php';

class WorkflowFormatter {
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::GROUP => [
            "message"=>"Group %s created",
            "variables"=>"groupTitle"
        ]
    ];

}