<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class EmailTemplateFormatter{
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message"=>"<strong>%s</strong> email template was created by <strong>%s</strong>",
            "variables"=>"name,userID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message"=>"<strong>%s</strong> email template was deleted by <strong>%s</strong>",
            "variables"=>"name,userID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message" => "<strong>%s</strong> was edited by <strong>%s</strong>",
            "variables" => "name,userID"
        ]
    ];

}