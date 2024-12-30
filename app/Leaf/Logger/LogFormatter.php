<?php

namespace App\Leaf\Logger;

use App\Leaf\Logger\Formatters\AppletFormatter;
use App\Leaf\Logger\Formatters\EmailTemplateFormatter;
use App\Leaf\Logger\Formatters\FormatOptions;
use App\Leaf\Logger\Formatters\FormFormatter;
use App\Leaf\Logger\Formatters\GroupFormatter;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\Formatters\PortalGroupFormatter;
use App\Leaf\Logger\Formatters\PrimaryAdminFormatter;
use App\Leaf\Logger\Formatters\ServiceChiefFormatter;
use App\Leaf\Logger\Formatters\TemplateFormatter;
use App\Leaf\Logger\Formatters\WorkflowFormatter;
use App\Leaf\Logger\Formatters\DependencyFormatter;

class LogFormatter
{
    const formatters = array(
        LoggableTypes::GROUP => GroupFormatter::TEMPLATES,
        LoggableTypes::SERVICE_CHIEF => ServiceChiefFormatter::TEMPLATES,
        LoggableTypes::FORM => FormFormatter::TEMPLATES,
        LoggableTypes::PORTAL_GROUP => PortalGroupFormatter::TEMPLATES,
        LoggableTypes::WORKFLOW => WorkflowFormatter::TEMPLATES,
        LoggableTypes::DEPENDENCY_PRIVS => DependencyFormatter::TEMPLATES,
        LoggableTypes::PRIMARY_ADMIN => PrimaryAdminFormatter::TEMPLATES,
        LoggableTypes::EMAIL_TEMPLATE_TO => EmailTemplateFormatter::TEMPLATES,
        LoggableTypes::EMAIL_TEMPLATE_CC => EmailTemplateFormatter::TEMPLATES,
        LoggableTypes::EMAIL_TEMPLATE_SUBJECT => EmailTemplateFormatter::TEMPLATES,
        LoggableTypes::EMAIL_TEMPLATE_BODY => EmailTemplateFormatter::TEMPLATES,
        LoggableTypes::TEMPLATE_BODY => TemplateFormatter::TEMPLATES,
        LoggableTypes::TEMPLATE_REPORTS_BODY => AppletFormatter::TEMPLATES,
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

        foreach($formatVariables as $formatVariable) {
            $result = self::findValue($logData["items"], $formatVariable, $loggableColumns, $message);
            $message = $result["message"];
            foreach($result["values"] as $value) {
                if($formatVariable == FormatOptions::READ_COLUMN_NAMES) {
                    array_unshift($variableArray, $value);
                } else {
                    array_push($variableArray, $value);
                }
            }
        }

        // try our sprintf.
        try{
            $output_message = vsprintf($message,$variableArray);
        }
        // if we have an error need to say something, maybe this?
        catch(\ValueError $e){
            //$output_message = 'Format error: ' . $e->getMessage() . ' Message:' . $message . ' Values: ' . implode(', ', $variableArray);
            $output_message = FALSE;
        }

        $output = array(
            "message" => $output_message
        );

        if (array_key_exists("targetUID", $result)) {
            $output["targetUID"] = $result["targetUID"];
            $output["displayName"] = $result["displayName"];
        }

        return $output;
    }

    private static function findValue($changeDetails, $columnName, $loggableColumns, $message){
        $result = ["message"=> $message, "values"=> array()];

        foreach($changeDetails as $key=> $detail){
            if($columnName == FormatOptions::READ_COLUMN_NAMES){
                if(in_array($detail["column"], $loggableColumns)){
                    $result["message"] = "<strong>changed</strong> %s to %s in ".$result["message"];
                    $value = isset($detail["displayValue"]) ? $detail["displayValue"] : $detail["value"];
                    array_push($result["values"], $value);
                    array_push($result["values"], $detail["column"]);
                }
            }
            if($detail["column"] == $columnName) {
                $value = isset($detail["displayValue"]) ? $detail["displayValue"] : $detail["value"];
                array_push($result["values"], $value);

                if ($columnName == "userID") {
                    $result["targetUID"] = $detail["value"];
                    $result["displayName"] = $detail["displayValue"];
                }
            }
        }
        return $result;
    }
}
