<?php

namespace App\Leaf\Logger\Formatters;

class PrimaryAdminFormatter
{
    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::PRIMARY_ADMIN => [
            "message" => "set <strong>user</strong> %s as primary admin",
            "variables" => "userID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::PRIMARY_ADMIN => [
            "message" => "unset <strong>user</strong> %s as primary admin",
            "variables" => "userID"
        ]
    ];

    const TABLE = "users";
}
