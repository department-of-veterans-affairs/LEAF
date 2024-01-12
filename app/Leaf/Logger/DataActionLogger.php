<?php

namespace App\Leaf\Logger;

use App\Leaf\Logger\Formatters\AppletFormatter;
use App\Leaf\Logger\Formatters\EmailTemplateFormatter;
use App\Leaf\Logger\Formatters\FormFormatter;
use App\Leaf\Logger\Formatters\GroupFormatter;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\Formatters\PortalGroupFormatter;
use App\Leaf\Logger\Formatters\PrimaryAdminFormatter;
use App\Leaf\Logger\Formatters\ServiceChiefFormatter;
use App\Leaf\Logger\Formatters\TemplateFormatter;
use App\Leaf\Logger\Formatters\WorkflowFormatter;

class DataActionLogger
{

    protected $db;
    protected $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function logAction($verb, $type, $toLog)
    {

        $action = $verb . '-' . $type;

        $vars = array(
            ':userID' => (int)$this->login->getEmpUID(),
            ':action' => $action,
            ':userDisplay' =>  $this->login->getName()
        );

        $sql =
            "INSERT INTO data_action_log (`userID`, `timestamp`, `action`, `userDisplay`)
                    VALUES (:userID, UTC_TIMESTAMP(), :action, :userDisplay);

            SELECT LAST_INSERT_ID() INTO @log_id;

            INSERT INTO data_log_items (`data_action_log_fk`, `tableName`, `column`, `value`, `displayValue`)
                VALUES";

        for ($i = 0; $i < count($toLog); $i++) {

            $nowAdding = $toLog[$i];

            $vars[":tableName$i"] = $nowAdding->tableName;
            $vars[":column$i"] = $nowAdding->column;
            $vars[":value$i"] = $nowAdding->value;
            $vars[":displayValue$i"] = $nowAdding->displayValue;

            $sql = $sql . "(@log_id, :tableName$i, :column$i, :value$i, :displayValue$i)" . (($i == count($toLog) - 1 ? "; " : ", "));
        }

        $sql = $sql;

        $this->db->beginTransaction();
        $this->db->prepared_query($sql, $vars);
        $this->db->commitTransaction();
    }


    public function getHistory($filterById, $filterByColumnName, $logType)
    {

        $logResults = $this->fetchLogData($filterById, $filterByColumnName, $logType);

        if ($logResults != null) {
            for ($i = 0; $i < count($logResults); $i++) {
                $logResults[$i]["items"] = $this->fetchLogItems($logResults[$i]);
                // $logResults[$i] = $this->findExternalValue($logResults[$i], $logType);
                $logHistory = LogFormatter::getFormattedString($logResults[$i], $logType);
                $logResults[$i]["history"] = $logHistory["message"];
                if (array_key_exists("targetUID", $logHistory)) {
                    $logResults[$i]["targetUID"] = $logHistory["targetUID"];
                    $logResults[$i]["displayName"] = $logHistory["displayName"];
                }
            }
        }
        return $logResults;
    }

    public function logTemplateFileHistory($fileName, $templateFileHistory, $filePath, $fileSize, $time)
    {
        $vars = array(
            ':file_parent_name' => $templateFileHistory,
            ':file_name' => $fileName,
            ':file_path' => $filePath,
            ':file_size' => $fileSize,
            ':file_modify_by' => $this->login->getName(),
            ':file_created' => $time
        );
        $sql = 'INSERT INTO `template_history_files` (`file_parent_name`,`file_name`, `file_path`, `file_size`, `file_modify_by`, `file_created`) VALUES (:file_parent_name, :file_name, :file_path, :file_size, :file_modify_by, :file_created)';
        $stmt = $this->db->prepared_query($sql, $vars);

        if (!$stmt) {
            return 'Error: could not execute SQL statement';
        }
    }

    public function getHistoryLogAction($filterById, $filterByColumnName, $logType)
    {
        $logResults = $this->fetchLogData($filterById, $filterByColumnName, $logType);
        if ($logResults != null) {
            for ($i = 0; $i < count($logResults); $i++) {
                $logResults[$i]["items"] = $this->fetchLogItems($logResults[$i]);
                $logResults[$i]["history"] = LogFormatter::getFormattedString($logResults[$i], $logType);
            }
        }
        return $logResults;
    }

    /**
     * Returns all history ids for all groups
     *
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs()
    {
        $sql = "SELECT `value`
                FROM `data_log_items`
                WHERE `column` = 'groupID'
                GROUP BY `value`;";
        return  $this->db->query_kv($sql, 'value', 'value', array());
    }

    public function fetchLogData($filterById, $filterByColumnName, $logType)
    {
        $filterResults = isset($filterById) && isset($filterByColumnName);

        $sqlCreateTemp =
            "
            CREATE TEMPORARY TABLE group_logs
            SELECT data_action_log_fk
            FROM data_log_items dli
            LEFT JOIN data_action_log dal ON dal.id = dli.data_action_log_fk
            WHERE ";

        $vars = [];

        if ($filterResults) {
            $sqlCreateTemp .= "dli.column = :filterBy
            AND
                dli.VALUE = :filterById
            AND";

            // need to add this to this check here since passing the vars when they were not needed caused errors.
            $vars[':filterBy'] = $filterByColumnName;
            $vars[':filterById'] = $filterById;
        }

        $sqlCreateTemp .= " dal.ACTION IN " . $this->buildInClause($logType) . ";";

        $this->db->prepared_query($sqlCreateTemp, $vars);

        $sqlFetchLogData =
            " SELECT
                    dal.ID,
                    dal.userDisplay as userName,
                    dal.userID,
                    dal.action,
                    dal.timestamp
                from data_action_log dal
                Where id in (select * from group_logs)
                order by dal.ID desc;";
        $results = $this->db->query($sqlFetchLogData);

        $sqlCleanUp = "drop temporary table group_logs;";
        $this->db->query($sqlCleanUp);
        return $results;
    }

    public function buildInClause($logType)
    {
        $actions = array_keys(LogFormatter::formatters[$logType]);

        $inClause = "(";

        for ($i = 0; $i < count($actions); $i++) {
            $inClause .= "'" . $actions[$i] . "'" . ($i == count($actions) - 1 ? "" : ",");
        }

        $inClause .= ")";

        return $inClause;
    }

    public function fetchLogItems($logResult)
    {

        $vars = array(
            ':dalFK' => $logResult["ID"]
        );

        $sqlFetchLogItems =
            " Select
            `column`,
            `value`,
            `displayValue`
            from data_log_items
            WHERE data_action_log_fk = :dalFK
        ";

        return $this->db->prepared_query($sqlFetchLogItems, $vars);
    }

    private function findExternalValue(array $logData, string $logType): array
    {
        $tables = array(
            LoggableTypes::GROUP => GroupFormatter::TABLE,
            LoggableTypes::SERVICE_CHIEF => ServiceChiefFormatter::TABLE,
            LoggableTypes::FORM => FormFormatter::TABLE,
            LoggableTypes::PORTAL_GROUP => PortalGroupFormatter::TABLE,
            LoggableTypes::WORKFLOW => WorkflowFormatter::TABLE,
            LoggableTypes::PRIMARY_ADMIN => PrimaryAdminFormatter::TABLE,
            LoggableTypes::EMAIL_TEMPLATE_TO => EmailTemplateFormatter::TABLE,
            LoggableTypes::EMAIL_TEMPLATE_CC => EmailTemplateFormatter::TABLE,
            LoggableTypes::EMAIL_TEMPLATE_SUBJECT => EmailTemplateFormatter::TABLE,
            LoggableTypes::EMAIL_TEMPLATE_BODY => EmailTemplateFormatter::TABLE,
            LoggableTypes::TEMPLATE_BODY => TemplateFormatter::TABLE,
            LoggableTypes::TEMPLATE_REPORTS_BODY => AppletFormatter::TABLE,
        );

        $formatters = array(
            LoggableTypes::GROUP => GroupFormatter::TEMPLATES,
            LoggableTypes::SERVICE_CHIEF => ServiceChiefFormatter::TEMPLATES,
            LoggableTypes::FORM => FormFormatter::TEMPLATES,
            LoggableTypes::PORTAL_GROUP => PortalGroupFormatter::TEMPLATES,
            LoggableTypes::WORKFLOW => WorkflowFormatter::TEMPLATES,
            LoggableTypes::PRIMARY_ADMIN => PrimaryAdminFormatter::TEMPLATES,
            LoggableTypes::EMAIL_TEMPLATE_TO => EmailTemplateFormatter::TEMPLATES,
            LoggableTypes::EMAIL_TEMPLATE_CC => EmailTemplateFormatter::TEMPLATES,
            LoggableTypes::EMAIL_TEMPLATE_SUBJECT => EmailTemplateFormatter::TEMPLATES,
            LoggableTypes::EMAIL_TEMPLATE_BODY => EmailTemplateFormatter::TEMPLATES,
            LoggableTypes::TEMPLATE_BODY => TemplateFormatter::TEMPLATES,
            LoggableTypes::TEMPLATE_REPORTS_BODY => AppletFormatter::TEMPLATES,
        );

        $targetTable = $tables[$logType];

        $logDictionary = $formatters[$logType];
        $dictionaryItem = $logDictionary[$logData["action"]];
        $primaryKey = $dictionaryItem["key"];

        $displayVariables = array();
        $formatVariables = array();

        if (array_key_exists("displayColumns", $dictionaryItem) && $dictionaryItem["displayColumns"] != null) {
            $displayVariables = explode(",", $dictionaryItem["displayColumns"]);
        } else {
            return $logData;
        }

        if (array_key_exists("loggableColumns", $dictionaryItem) && $dictionaryItem["loggableColumns"] != null) {
            $loggableColumns = explode(",", $dictionaryItem["loggableColumns"]);
        }

        foreach ($logData["items"] as $detail) {
            if ($detail["column"] != $primaryKey) {
                continue;
            }

            $vars = array(
                ":table" => $targetTable,
                ":columns" => implode("`,`", $displayVariables),
                ":pk" => $primaryKey,
                ":id" => $detail["value"]
            );

            $strSQL = "SELECT :columns FROM :table WHERE :pk = :id";

            $potentialValues = $this->db->prepared_query($strSQL, $vars);
        }

        return $logData;
    }
}
