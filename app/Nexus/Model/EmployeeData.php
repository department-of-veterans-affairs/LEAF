<?php

namespace App\Nexus\Model;

use App\Leaf\Db;

class EmployeeData
{
    /**
     * @var Db
     */
    protected $db;

    public function __construct(Db $db)
    {
        $this->db = $db;
    }

    /**
     * @param int $id
     * @param string $indicatorList
     * @param string $tableId
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:52:54 PM (America/New_York)
     */
    public function getData(int $id, string $indicatorList, string $tableId): array
    {
        $vars = array(':id' => $id);
        $sql = "SELECT `data`, `timestamp`, `indicatorID`, `author`
                FROM `employee_data`
                WHERE `indicatorID` IN ({$indicatorList})
                AND {$tableId} = :id";
        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $empUID
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:53:06 PM (America/New_York)
     */
    public function getEmail(int $empUID): array
    {
        $vars = array(':empUID' => $empUID);
        $sql = 'SELECT `data` AS `email`
                FROM `employee_data`
                WHERE `empUID` = :empUID
                AND `indicatorID` = 6';
        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param string $data
     * @param string $limit
     * @param int $indicator
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:53:46 PM (America/New_York)
     */
    public function getUsersByIndicator(string $data, string $limit, int $indicator): array
    {
        $vars = array(':data' => $data,
                    ':indicator' => $indicator);
        $sql = "SELECT *
                FROM `employee_data`
    			LEFT JOIN `employee` USING (`empUID`)
    			WHERE `indicatorID` = :indicator
    			AND `data` = :data
    			AND `deleted` = 0
    			{$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}