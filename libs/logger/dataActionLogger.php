<?php

require_once 'logFormatter.php';
require_once 'logItem.php';

class DataActionLogger{

    protected $db;
    protected $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function logAction($verb, $type, $toLog){

        $action = $verb.'-'.$type;

        $vars = array(
            ':userID' => (int)$this->login->getEmpUID(),
            ':action' => $action,
            ':userDisplay' =>  $this->login->getName()
        );

        $sql =
            "BEGIN;

            INSERT INTO data_action_log (`userID`, `timestamp`, `action`, `userDisplay`)
                    VALUES (:userID, UTC_TIMESTAMP(), :action, :userDisplay);

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


    public function getHistory($filterById, $filterByColumnName, $logType){

        $logResults = $this->fetchLogData($filterById, $filterByColumnName, $logType);

        if($logResults != null){
            for($i = 0; $i<count($logResults); $i++){
                $logResults[$i]["items"] = $this->fetchLogItems($logResults[$i]);
                $logResults[$i]["history"] = \LogFormatter::getFormattedString($logResults[$i], $logType);
            }
        }
        return $logResults;

    }

    /**
     * Returns all history ids for all groups
     *
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs(){
        $sql = "SELECT `value`
                FROM `data_log_items`
                WHERE `column` = 'groupID'
                GROUP BY `value`;";
        return  $this->db->query_kv($sql, 'value', 'value', array());
    }

    function fetchLogData($filterById, $filterByColumnName, $logType){

        $filterResults = isset($filterById) && isset($filterByColumnName);

        $vars = array(
            ':filterBy' => $filterByColumnName,
            ':filterById' => $filterById
        );

        $sqlCreateTemp =
            "
            CREATE TEMPORARY TABLE group_logs
            SELECT data_action_log_fk
            FROM data_log_items dli
            LEFT JOIN data_action_log dal ON dal.id = dli.data_action_log_fk
            WHERE ";

        if($filterResults){
            $sqlCreateTemp.="dli.column = :filterBy
            AND
                dli.VALUE = :filterById
            AND";
        }

        $sqlCreateTemp.=" dal.ACTION IN ".$this->buildInClause($logType).";";

        $this->db->prepared_query($sqlCreateTemp, $vars);

        $sqlFetchLogData=
            " SELECT
                    dal.ID,
                    dal.userDisplay as userName,
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

    function buildInClause($logType){
        $actions = array_keys(\LogFormatter::formatters[$logType]);

        $inClause = "(";

        for($i=0; $i<count($actions); $i++){
            $inClause.="'".$actions[$i]."'".($i == count($actions)-1 ? "": ",");
        }

        $inClause.=")";

        return $inClause;
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
