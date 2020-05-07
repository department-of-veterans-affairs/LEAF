<?php

require_once __DIR__.'/loggableTypes.php';
require_once __DIR__.'/dataActions.php';

class ServiceChiefFormatter {
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::SERVICE_CHIEF => [
            "message"=>"User %s has been added to %s",
            "variables"=>"userID,serviceID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::SERVICE_CHIEF=> [
            "message"=>"User %s has been removed from %s",
            "variables"=>"userID,serviceID"
        ],
    ];
}