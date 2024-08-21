<?php

namespace App\Leaf\Logger\Formatters;

class FormFormatter{

    const TEMPLATES = [
        DataActions::ADD.'-'.LoggableTypes::FORM => [
            "message"=> "added <strong>new form:</strong> %s",
            "variables" => "categoryName"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::FORM => [
            "message" => "<strong>modified form:</strong> %s",
            "variables" => "categoryID,".FormatOptions::READ_COLUMN_NAMES,
            "loggableColumns" => "categoryName,categoryDescription,workflowID,needToKnow,sort,visible,type,destructionAge"
        ],
        DataActions::ADD.'-'.LoggableTypes::INDICATOR => [
            "message" => "added <strong>new question:</strong> %s",
            "variables"=> "name"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::INDICATOR => [
            "message" => "<strong>question</strong>: %s",
            "variables"=> "indicatorID,".FormatOptions::READ_COLUMN_NAMES.",".FormatOptions::DISPLAY,
            "key"=>"indicatorID",
            "displayColumns"=>"description,name",
            "loggableColumns"=>"name,format,description,default,parentID,required,is_sensitive,disabled,sort,html,htmlPrint,conditions"
        ]
    ];

    const TABLE = 'categories';
}