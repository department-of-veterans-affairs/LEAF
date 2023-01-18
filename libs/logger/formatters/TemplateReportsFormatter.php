<?php

namespace Leaf;

class TemplateReportsFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_REPORTS_BODY => [
            "message" => "Body of <strong>%s</strong> was edited",
            "variables" => "body"
        ]
    ];

}
