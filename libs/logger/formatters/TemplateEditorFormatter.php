<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class TemplateEditorFormatter{

    const TEMPLATES = [
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_BODY => [
            "message" => "Body of <strong>%s</strong> was edited",
            "variables" => "body"
        ]
    ];

    const TABLE = "";
}