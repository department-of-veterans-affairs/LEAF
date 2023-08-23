<?php

namespace Leaf;

class DesignFormatter
{
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "added design <strong>%s</strong>",
            "variables" => "designID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "edited content of design <strong>%s</strong>",
            "variables" => "designID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::TEMPLATE_DESIGN => [
            "message" => "deleted design <strong>%s</strong>",
            "variables" => "designID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::PUBLISH => [
            "message" => "published design <strong>%s</strong>",
            "variables" => "designID,templateName"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::UNPUBLISH => [
            "message" => "changed design <strong>%s</strong> to draft",
            "variables" => "designID,templateName"
        ],
    ];

    const TABLE = 'template_designs';
}