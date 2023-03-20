<?php

namespace Leaf;

class TemplateEditorFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_BODY => [
            "message" => "edited body of <strong>%s</strong>",
            "variables" => "body"
        ]
    ];

    const TABLE = "";
}
