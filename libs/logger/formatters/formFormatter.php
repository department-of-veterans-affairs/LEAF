<?php

require_once 'loggableTypes.php';
require_once 'dataActions.php';
require_once 'formatOptions.php';

class FormFormatter{

    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::FORM => [
            "message"=> "Form %s has been created",
            "variables" => "categoryName"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::FORM => [
            "message" => "Form %s",
            "variables" => "categoryID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns" => "categoryName,categoryDescription,workflowID,needToKnow,sort,visible,type"
        ],
        DataActions::ADD.'-'.LoggableTypes::INDICATOR => [
            "message" => "Indicator %s has been added to form %s",
            "variables"=> "name,categoryID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::INDICATOR => [
            "message" => "Indicator %s",
            "variables"=> "indicatorID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns"=>"name,format,description,default,parentID,required,is_sensitive,disabled,sort,html,htmlPrint"
        ]
    ];

}