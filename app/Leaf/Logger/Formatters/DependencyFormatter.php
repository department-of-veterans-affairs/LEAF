<?php

namespace App\Leaf\Logger\Formatters;

class DependencyFormatter
{
    /** Templates for determining what data to grab based on action on dependency(aka workflow requirement).
     * Action data is retrieved from the data_log_items table.
     * Each action consists of three rows, each serving as an attribute of the action.
     * The attributes differ based on the type of action.
     * The attributes are described in the variables property of each template.
     */

    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::DEPENDENCY_PRIVS => [
            "message"=>"granted privileges to group <strong>%s </strong> on requirement <strong> %s</strong>",
            "variables"=>"groupID,dependencyID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::DEPENDENCY_PRIVS => [
            "message"=>"revoked privileges from group <strong>%s </strong> on requirement <strong> %s</strong>",
            "variables"=>"groupID,dependencyID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::DEPENDENCY => [
            "message"=>"changed requirement #<strong>%s </strong>description to<strong> %s</strong>",
            "variables"=>"dependencyID,description"
        ],
    ];

    const TABLE = "dependency_privs";
}