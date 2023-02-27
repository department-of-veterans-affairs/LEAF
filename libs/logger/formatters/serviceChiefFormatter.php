<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';

class ServiceChiefFormatter {
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::SERVICE_CHIEF => [
            "message"=>"added <strong>new user:</strong> %s",
            "variables"=>"userID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::SERVICE_CHIEF=> [
            "message"=>"removed <strong>user:</strong> %s",
            "variables"=>"userID"
        ],
    ];
}