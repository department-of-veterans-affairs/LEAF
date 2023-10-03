<?php

namespace App\Leaf\Logger\Formatters;

class EmailTemplateFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY . '-' . LoggableTypes::EMAIL_TEMPLATE_TO => [
            "message" => "edited 'Email To' field of <strong>%s</strong>",
            "variables" => "emailTo"
        ],
        DataActions::MODIFY . '-' . LoggableTypes::EMAIL_TEMPLATE_CC => [
            "message" => "edited 'Email CC' field of <strong>%s</strong>",
            "variables" => "emailCc"
        ],
        DataActions::MODIFY . '-' . LoggableTypes::EMAIL_TEMPLATE_SUBJECT => [
            "message" => " edited subject of <strong>%s</strong>",
            "variables" => "subject"
        ],
        DataActions::MODIFY . '-' . LoggableTypes::EMAIL_TEMPLATE_BODY => [
            "message" => "edited body of <strong>%s</strong>",
            "variables" => "body"
        ],
        DataActions::MERGE . '-' . LoggableTypes::EMAIL_TEMPLATE_BODY => [
            "message" => "merge changes to file <strong>%s</strong>",
            "variables" => "body"
        ],
        DataActions::RESTORE . '-' . LoggableTypes::EMAIL_TEMPLATE_BODY => [
            "message" => "restored file <strong>%s</strong>",
            "variables" => "body"
        ]
    ];

    const TABLE = "email_templates";
}
