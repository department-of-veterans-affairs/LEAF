<?php

require_once 'formatters/loggableTypes.php';
require_once 'formatters/dataActions.php';
require_once 'formatters/formatOptions.php';

require_once 'formatters/groupFormatter.php';
require_once 'formatters/serviceChiefFormatter.php';
require_once 'formatters/formFormatter.php';
require_once 'formatters/portalGroupFormatter.php';
require_once 'formatters/workflowFormatter.php';
require_once 'formatters/primaryAdminFormatter.php';

class LogFormatter{

    const formatters = array(
        LoggableTypes::GROUP=> GroupFormatter::TEMPLATES,
        LoggableTypes::SERVICE_CHIEF=> ServiceChiefFormatter::TEMPLATES,
        LoggableTypes::FORM=> FormFormatter::TEMPLATES,
        LoggableTypes::PORTAL_GROUP=> PortalGroupFormatter::TEMPLATES,
        LoggableTypes::WORKFLOW=> WorkflowFormatter::TEMPLATES,
        LoggableTypes::PRIMARY_ADMIN=> PrimaryAdminFormatter::TEMPLATES
    );

    public static function getFormattedString($logData, $logType){

        $logDictionary = self::formatters[$logType];

        $dictionaryItem = $logDictionary[$logData["action"]];

        $formatVariables = explode("," , $dictionaryItem["variables"]);

        $message = $dictionaryItem["message"];

        $loggableColumns = array();

        if(array_key_exists("loggableColumns", $dictionaryItem) && $dictionaryItem["loggableColumns"] != null){
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
            if($columnName == FormatOptions::READ_COLUMN_NAMES){
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



