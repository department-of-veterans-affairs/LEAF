<?php

namespace App\Leaf\Logger\Formatters;

class AppletFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "edited body of <strong>%s</strong>",
            "variables" => "body"
        ],

        DataActions::DELETE.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "deleted file <strong>%s</strong>",
            "variables" => "body"
        ],

        DataActions::RESTORE.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "restored file <strong>%s</strong>",
            "variables" => "body"
        ],

        DataActions::CREATE.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "created file <strong>%s</strong>",
            "variables" => "body"
        ],

        DataActions::MERGE.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "merge changes to file <strong>%s</strong>",
            "variables" => "body"
        ]

    ];

    const TABLE = "";
}
