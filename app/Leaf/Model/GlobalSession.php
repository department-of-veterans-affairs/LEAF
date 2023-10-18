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
                FROM `sessions`
                WHERE `csrf` = :session';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }

    public function postSession(string $csrf, string $session): void
    {
        $vars = array(':session' => $csrf,
                    ':variables' => $session);
        $sql = 'INSERT INTO `sessions`
                (`csrf`, `session`)
                VALUES
                (:csrf, :variables)
                ON DUPLICATE KEY UPDATE `session` = :variables';

        $this->db->pdo_insert_query($sql, $vars);
    }
}