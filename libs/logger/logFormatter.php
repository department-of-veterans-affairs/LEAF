<?php

class LogFormatter{

    const formatters = array(
        "groupID"=> self::groupFormattedStrings
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
            "variables"=>"empuID,groupID"
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

    public static function getFormattedString($logData, $logType){

        $logDictionary = self::formatters[$logType];

        $dictionaryItem = $logDictionary[$logData["action"]];

        $columnNames = explode("," , $dictionaryItem["variables"]);

        $variableArray = [];

        foreach($columnNames as $columnName){
            array_push($variableArray,self::findValue($logData["items"], $columnName));
        }

        return vsprintf($dictionaryItem["message"],$variableArray);
    }

    private static function findValue($items, $columnName){

        $value = '';

        foreach($items as $key=> $item){
            if($item["column"] == $columnName){
                $value = isset($item["displayValue"]) ? $item["displayValue"] : $item["value"];
                break;
            }
        }
        
        return $value;
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
}
