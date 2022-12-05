<?php

namespace Leaf;

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class EmailTemplateFormatter{

    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE_TO => [
            "message" => "'Email To' field of <strong>%s</strong> was edited",
            "variables" => "emailTo"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE_CC => [
            "message" => "'Email CC' field of <strong>%s</strong> was edited",
            "variables" => "emailCc"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE_SUBJECT => [
            "message" => "Subject of <strong>%s</strong> was edited",
            "variables" => "subject"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::EMAIL_TEMPLATE_BODY => [
            "message" => "Body of <strong>%s</strong> was edited",
            "variables" => "body"
        ]
    ];

}