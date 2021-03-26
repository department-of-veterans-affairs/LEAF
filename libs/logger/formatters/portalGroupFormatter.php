<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class PortalGroupFormatter{
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"Group <strong>%s</strong> created",
            "variables"=>"name"
        ],
        DataActions::DELETE.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"Group <strong>%s</strong> deleted",
            "variables"=>"groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "User <strong>%s</strong> has been added to group <strong>%s</strong>",
            "variables" => "userID,groupID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "User <strong>%s</strong> has been removed from group <strong>%s</strong>",
            "variables" => "userID,groupID"
        ]
    ];

}