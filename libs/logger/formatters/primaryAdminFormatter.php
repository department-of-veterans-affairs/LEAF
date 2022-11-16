<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class PrimaryAdminFormatter{
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::PRIMARY_ADMIN => [
            "message" => "User %s has been set as primary admin",
            "variables" => "userID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::PRIMARY_ADMIN => [
            "message" => "User %s has been unset as primary admin",
            "variables" => "userID"
        ]
    ];

}