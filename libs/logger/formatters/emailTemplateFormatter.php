<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class EmailTemplateFormatter{
    
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message"=>"<strong>%s</strong> email template was created",
            "variables"=>"body"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message"=>"<strong>%s</strong> email template was deleted",
            "variables"=>"body"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE => [
            "message" => "<strong>%s</strong> email template was edited",
            "variables" => "body"
        ]
    ];

}