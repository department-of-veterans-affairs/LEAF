<?php

namespace Leaf;

class ServiceChiefFormatter {
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::SERVICE_CHIEF => [
            "message"=>"<strong>%s</strong> has been added to <strong>%s</strong>",
            "variables"=>"userID,serviceID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::SERVICE_CHIEF=> [
            "message"=>"<strong>%s</strong> has been removed from <strong>%s</strong>",
            "variables"=>"userID,serviceID"
        ],
    ];
}