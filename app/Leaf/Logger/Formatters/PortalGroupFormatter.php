<?php

namespace App\Leaf\Logger\Formatters;

class PortalGroupFormatter{

    const TEMPLATES = [
        DataActions::IMPORT.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"imported <strong>group: </strong>%s",
            "variables"=>"groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"added <strong>new group:</strong> %s",
            "variables"=>"name"
        ],
        DataActions::DELETE.'-'.LoggableTypes::PORTAL_GROUP => [
            "message"=>"deleted <strong>group:</strong> %s",
            "variables"=>"groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "added <strong>new user:</strong> %s",
            "variables" => "userID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "removed <strong>user:</strong> %s",
            "variables" => "userID"
        ],
        DataActions::PRUNE.'-'.LoggableTypes::EMPLOYEE => [
            "message" => "pruned <strong>user:</strong> %s",
            "variables" => "userID"
        ]
    ];

    const TABLE = "groups";
}