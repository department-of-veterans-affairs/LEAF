<?php

class LogFormatter{

    const READ_COLUMN_NAMES = "READCOLUMNNAME";

    const formatters = array(
        LoggableTypes::GROUP=> self::groupFormattedStrings,
        LoggableTypes::SERVICE_CHIEF=> self::serviceChiefFormattedStrings,
        LoggableTypes::FORM=> self::formFormattedStrings
    );

    const groupFormattedStrings = [
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
        ]
    ];

    const serviceChiefFormattedStrings = [
        DataActions::ADD.'-'.LoggableTypes::SERVICE_CHIEF => [
            "message"=>"User %s has been added to %s",
            "variables"=>"userID,serviceID"
        ],
        DataActions::DELETE.'-'.LoggableTypes::SERVICE_CHIEF=> [
            "message"=>"User %s has been removed from %s",
            "variables"=>"userID,serviceID"
        ],
    ];

    const formFormattedStrings = [
        DataActions::ADD.'-'.LoggableTypes::FORM => [
            "message"=> "Form %s has been created",
            "variables" => "categoryName"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::FORM => [
            "message" => "Form %s",
            "variables" => "categoryID,".self::READ_COLUMN_NAMES,
            "loggableColumns" => "categoryName,categoryDescription,workflowID,needToKnow,sort,visible,type"
        ],
        DataActions::ADD.'-'.LoggableTypes::INDICATOR => [
            "message" => "Indicator %s has been added to form %s",
            "variables"=> "name,categoryID"
        ],
        DataActions::MODIFY.'-'.LoggableTypes::INDICATOR => [
            "message" => "Indicator %s",
            "variables"=> "name,".self::READ_COLUMN_NAMES,
            "loggableColumns"=>"name,format,description,default,parentID,required,is_sensitive,disabled,sort,html,htmlPrint"
        ]
    ];

    public static function getFormattedString($logData, $logType){

        $logDictionary = self::formatters[$logType];

        $dictionaryItem = $logDictionary[$logData["action"]];

        $formatVariables = explode("," , $dictionaryItem["variables"]);

        $message = $dictionaryItem["message"];

        if($dictionaryItem["loggableColumns"] != null){
            $loggableColumns = explode(",", $dictionaryItem["loggableColumns"]);
        }

        $variableArray = [];

        foreach($formatVariables as $formatVariable){
            $result = self::findValue($logData["items"], $formatVariable, $loggableColumns, $message);
            $message = $result["message"];
            foreach($result["values"] as $value){
                array_push($variableArray, $value);
            }
        }

        return vsprintf($message,$variableArray);
    }

    private static function findValue($changeDetails, $columnName, $loggableColumns, $message){

        $result = ["message"=> $message, "values"=> array()];

        foreach($changeDetails as $key=> $detail){
            if($columnName == self::READ_COLUMN_NAMES){
                if(in_array($detail["column"], $loggableColumns)){
                    $result["message"].=" %s changed to %s ";
                    array_push($result["values"], $detail["column"]);
                    $value = isset($detail["displayValue"]) ? $detail["displayValue"] : $detail["value"];
                    array_push($result["values"], $value);
                }
            }
            if($detail["column"] == $columnName){
                $value = isset($detail["displayValue"]) ? $detail["displayValue"] : $detail["value"];
                array_push($result["values"], $value);
            }
        }
        
        return $result;
    }
}

class DataActions {
    const MODIFY = 'modify';
    const DELETE = 'delete';
    const ADD = 'add';
}

class LoggableTypes {
    const GROUP = 'group';
    const PRIVILEGES = 'privileges';
    const POSITION = 'position';
    const EMPLOYEE = 'employee';
    const SERVICE_CHIEF = "service_chief";
    const FORM = "form";
    const INDICATOR = "indicator";
}
