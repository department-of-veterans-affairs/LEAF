<?php

namespace Leaf;

class TemplateReportsFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "edited body of <strong>%s</strong>",
            "variables" => "body"
        ]
    ];
    
    const TABLE = "";
}
