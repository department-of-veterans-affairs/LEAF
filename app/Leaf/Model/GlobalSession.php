<?php

namespace App\Leaf\Model;

use App\Leaf\Db;

class GlobalSession
{
    protected $db;

    public function __construct(Db $db)
    {
        $this->db = $db;
    }

    public function getSession(string $csrf): array
    {
        $vars = array(':session' => $csrf);
        $sql = 'SELECT `csrf`, `session`, `established`
                FROM `global_sessions`
                WHERE `csrf` = :session';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    public function postSession(string $csrf, string $session): void
    {
        $vars = array(':csrf' => $csrf,
                    ':variables' => $session);
        $sql = "INSERT INTO `global_sessions`
                (`csrf`, `session`)
                VALUES
                (:csrf, :variables)
                ON DUPLICATE KEY UPDATE `session` = :variables";

        $this->db->pdo_insert_query($sql, $vars);
    }
}