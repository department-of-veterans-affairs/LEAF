<?php

namespace Leaf;

class TemplateEditorFormatter
{
    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_BODY => [
            "message" => "Body of <strong>%s</strong> was edited",
            "variables" => "body"
        ]
    ];
}
