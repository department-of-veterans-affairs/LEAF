<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class PortalGroupFormatter{
    
    const TEMPLATES = [
        DataActions::IMPORT.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"<strong>%s</strong> group was imported",
            "variables"=>"groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"<strong>%s</strong> group was created",
            "variables"=>"name"
        ],
        DataActions::DELETE.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"<strong>%s</strong> group was deleted",
            "variables"=>"groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "<strong>%s</strong> was added to the group <strong>%s</strong>",
            "variables" => "userID,groupID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "<strong>%s</strong> was removed from the group <strong>%s</strong>",
            "variables" => "userID,groupID"
        ]
    ];

}