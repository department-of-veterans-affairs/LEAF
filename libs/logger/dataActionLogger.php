<?php

if(!class_exists('LogFormatter'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/logFormatter.php';
}

if(!class_exists('LogItem'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/logItem.php';
}

class DataActionLogger{

    protected $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    public function logAction($action, $toLog){

        $vars = array(
            ':userID' => (int)$this->login->getEmpUID(),
            ':action' => $action
        );

        $sql = 
            "BEGIN;

            INSERT INTO data_action_log (`userID`, `timestamp`, `action`)
                    VALUES (:userID, NOW(), :action);

            SELECT LAST_INSERT_ID() INTO @log_id; 
            
            INSERT INTO data_log_items (`data_action_log_fk`, `tableName`, `column`, `value`, `displayValue`)
                VALUES";

        for($i = 0; $i < count($toLog); $i++){

            $nowAdding = $toLog[$i];

            $vars[":tableName$i"] = $nowAdding->tableName;
            $vars[":column$i"] = $nowAdding->column;
            $vars[":value$i"] = $nowAdding->value;
            $vars[":displayValue$i"] = $nowAdding->displayValue;

            $sql = $sql."(@log_id, :tableName$i, :column$i, :value$i, :displayValue$i)".(($i == count($toLog)-1? "; ":", "));
        }

        $sql = $sql.'COMMIT;';

        $this->db->prepared_query($sql, $vars);
    }

    public function getHistory($filterById, $tablePKName){
        
        $logResults = $this->fetchLogData($filterById, $tablePKName);

        for($i = 0; $i<count($logResults); $i++){
            $logResults[$i]["items"] = $this->fetchLogItems($logResults[$i]);
            $logResults[$i]["history"] = \LogFormatter::getFormattedString($logResults[$i], $this->dataTableUID);
        }
        
        return $logResults;
    }

    function fetchLogData($filterById, $tablePKName){

        $vars = array(
            ':filterBy' => $tablePKName,
            ':filterById' => $filterById
        );

        $sqlCreateTemp =
            "create temporary table group_logs
            select data_action_log_fk 
            from data_log_items 
            WHERE `column` = :filterBy
            AND `VALUE` = :filterById;";
        
        $this->db->prepared_query($sqlCreateTemp, $vars);

        $sqlFetchLogData= 
            " Select 
                    dal.ID,
                    concat(e.firstName,' ',e.lastName) as userName,
                    dal.action,
                    dal.timestamp
                from data_action_log dal
                        LEFT JOIN
                    employee e ON e.empUID = dal.userID
                Where id in (select * from group_logs)
                order by dal.ID desc;";
        
        $results = $this->db->query($sqlFetchLogData);

        $sqlCleanUp = "drop temporary table group_logs;";
        $this->db->query($sqlCleanUp);
        
        return $results;
    }

    function fetchLogItems($logResult){

        $vars = array(
            ':dalFK' => $logResult["ID"]);

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
}