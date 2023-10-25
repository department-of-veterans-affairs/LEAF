<?php

namespace App\Nexus\Model;

use App\Leaf\Db;

class Employee
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
     * @param string $user_name
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:54:34 PM (America/New_York)
     */
    public function getEmployeeByUserName(string $user_name): array
    {
        $vars = array(':user_name' => $user_name);
        $sql = "SELECT *
                FROM `employee`
                WHERE `userName` = :user_name
                AND `deleted` = 0";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param int $empUID
     *
     * @return array
     *
     * Created at: 10/12/2023, 1:54:24 PM (America/New_York)
     */
    public function getEmployeeByEmpUID(int $empUID): array
    {
        $vars = array(':empUID' => $empUID);
        $sql = "SELECT *
                FROM `employee`
                WHERE `empUID` = :empUID
                AND `deleted` = 0";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $disabled
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:07:19 AM (America/New_York)
     */
    public function getUsersByLastName(array $vars, string $domain, string $disabled, string $sort, string $direction, string $limit): array
    {
        $sql = "SELECT *
                FROM `employee`
                WHERE `lastName` LIKE :lastName {$domain}
                {$disabled}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $disabled
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:25:52 AM (America/New_York)
     */
    public function getUsersByPhoneticLastName(array $vars, string $domain, string $disabled, string $sort, string $direction, string $limit): array
    {
        $sql = "SELECT *
                FROM `employee`
                WHERE `lastName` LIKE :lastName {$domain}
                {$disabled}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $disabled
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:07:19 AM (America/New_York)
     */
    public function getUsersByFirstName(array $vars, string $domain, string $disabled, string $sort, string $direction, string $limit): array
    {
        $sql = "SELECT *
                FROM `employee`
                WHERE `firstName` LIKE :firstName {$domain}
                {$disabled}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $disabled
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:25:52 AM (America/New_York)
     */
    public function getUsersByPhoneticFirstName(array $vars, string $domain, string $disabled, string $sort, string $direction, string $limit): array
    {
        $sql = "SELECT *
                FROM `employee`
                WHERE `firstName` LIKE :firstName {$domain}
                {$disabled}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $disabled
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:52:38 AM (America/New_York)
     */
    public function getUsersByWholeName(array $vars, string $domain, string $disabled, string $sort, string $direction, string $limit): array
    {
        if (empty($vars[':middleName'])){
            unset($vars['middleName']);
            $middle_name = '';
        } else {
            $middle_name = 'AND middleName LIKE :middleName';
        }

        $sql = "SELECT *
                FROM `employee`
                WHERE `firstName` LIKE :firstName
                AND `lastName` LIKE :lastName
                {$middle_name}
                {$disabled}
                {$domain}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $vars
     * @param string $domain
     * @param string $sort
     * @param string $direction
     * @param string $limit
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:52:30 AM (America/New_York)
     */
    public function getUsersByPhoneticWholeName(array $vars, string $domain, string $sort, string $direction, string $limit): array
    {
        $sql = "SELECT *
                FROM `employee`
                WHERE phoneticFirstName LIKE :firstName
                AND phoneticLastName LIKE :lastName
                AND deleted = 0
                {$domain}
                ORDER BY {$sort} {$direction}
                {$limit}";

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}