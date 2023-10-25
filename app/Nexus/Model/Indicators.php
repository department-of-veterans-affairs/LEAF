<?php

namespace App\Nexus\Model;

use App\Leaf\Db;

class Indicators
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
     * @param int $indicator
     * @param int $category
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:52:17 PM (America/New_York)
     */
    public function getIndicatorsById(int $indicator, int $category): array
    {
        $vars = array(':indicatorID' => $indicator,
                      ':categoryID' => $category);
        $sql = 'SELECT `indicatorID`, `name`, `format`, `description`,
                    `default`, `html`, `required`, `encrypted`, `sort`
                FROM `indicators`
                WHERE `categoryID` = :categoryID
                AND `disabled` = 0
                AND `indicatorID` = :indicatorID
                ORDER BY `sort`';
        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $category
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:52:10 PM (America/New_York)
     */
    public function getAllIndicators(int $category): array
    {
         $category_id = array('1' => 'employee',
                            '2' => 'position',
                            '3' => 'group');

        $vars = array(':categoryID' => $category_id[$category]);
        $sql = 'SELECT `indicatorID`, `name`, `format`, `description`,
                    `default`, `html`, `required`, `encrypted`, `sort`
                FROM `indicators`
                WHERE `categoryID` = :categoryID
                AND `disabled` = 0
                ORDER BY `sort`';
        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}