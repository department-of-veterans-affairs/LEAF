<?php

namespace Leaf;

class DesignFormatter
{
    const TEMPLATES = [
        DataActions::CREATE.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "created design <strong>%s</strong>",
            "variables" => "designID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "edited content of design <strong>%s</strong>",
            "variables" => "designID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "deleted design <strong>%s</strong>",
            "variables" => "designID"
        ]
    ];

    const TABLE = 'template_designs';
}