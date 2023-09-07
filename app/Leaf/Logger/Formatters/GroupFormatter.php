<?php

namespace App\Leaf\Logger\Formatters;

class GroupFormatter
{
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::GROUP => [
            "message"=>"Group %s created",
            "variables"=>"groupTitle"
        ],
        DataActions::DELETE.'-'.LoggableTypes::GROUP=> [
            "message"=>"Group %s deleted",
            "variables"=>"groupID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::GROUP=> [
            "message"=>"Group name has changed to %s",
            "variables"=>"groupTitle"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::PRIVILEGES=> [
            "message"=>"User %s has the following permissions for group %s: Read: %s Write: %s Grant: %s",
            "variables"=>"UID,groupID,read,write,grant"
        ],
        DataActions::ADD.'-'.LoggableTypes::EMPLOYEE=> [
            "message"=>"User %s has been added to Group %s",
            "variables"=>"empUID,groupID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::EMPLOYEE=> [
            "message"=>"User %s has been removed from Group %s",
            "variables"=>"empUID,groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::POSITION=> [
            "message"=>"Position %s added to Group %s",
            "variables"=>"positionID,groupID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::POSITION=> [
            "message"=>"Position %s has been removed from Group %s",
            "variables"=>"positionID,groupID"
        ],
        DataActions::ADD.'-'.LoggableTypes::TAG=>[
            "message"=> "Tag '%s' added",
            "variables"=>"tag"
        ],
        DataActions::DELETE.'-'.LoggableTypes::TAG=>[
            "message"=> "Tag '%s' removed",
            "variables"=>"tag"
        ]
    ];

    const TABLE = "groups";
}
