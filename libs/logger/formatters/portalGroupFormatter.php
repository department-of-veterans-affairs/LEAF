<?php

require_once __DIR__.'/loggableTypes.php';
require_once __DIR__.'/dataActions.php';

class PortalGroupFormatter{
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "User %s has been added to group %s",
            "variables" => "userID,groupID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "User %s has been removed from group %s",
            "variables" => "userID,groupID"
        ]
    ];

}