<?php

namespace App\Leaf\Logger\Formatters;

class TemplateFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY . '-' . LoggableTypes::TEMPLATE_BODY => [
            "message" => "edited body of <strong>%s</strong>",
            "variables" => "body"
        ],

        DataActions::MERGE . '-' . LoggableTypes::TEMPLATE_BODY => [
            "message" => "merge changes to file <strong>%s</strong>",
            "variables" => "body"
        ],
        DataActions::RESTORE . '-' . LoggableTypes::TEMPLATE_BODY => [
            "message" => "restored file <strong>%s</strong>",
            "variables" => "body"
        ]

    ];

    const TABLE = "";
}
