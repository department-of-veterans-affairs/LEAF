<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

use App\Leaf\Db;

class Setting
{
    protected $db;

    protected $settings;

    /**
     * @param Db $db
     *
     * Created at: 9/5/2023, 10:56:00 AM (America/New_York)
     */
    public function __construct(Db $db)
    {
        $this->db = $db;

        $this->initilize();
    }

    public function initilize(): void
    {
        $vars = array();
        $sql = 'SELECT `setting`, `data`
                FROM `settings`';

        $this->parseSettings($this->db->prepared_query($sql, $vars));
    }

    /**
     * @return array
     *
     * Created at: 9/5/2023, 10:56:09 AM (America/New_York)
     */
    public function getSettings(): array
    {
        return $this->settings;
    }

    /**
     * @param array $settings
     *
     * @return void
     *
     * Created at: 9/5/2023, 10:56:19 AM (America/New_York)
     */
    private function parseSettings(array $settings): void
    {
        foreach ($settings as $key => $value) {
            $this->settings[$value['setting']] = self::parseJson($value['data']);
        }
    }

    /**
     * @param string $data
     *
     * @return string|array
     *
     * Created at: 9/5/2023, 10:56:46 AM (America/New_York)
     */
    public static function parseJson(string $data): string|array
    {
        $return_value = json_decode($data, true) ?? $data;

        return $return_value;
    }

    public static function checkUserExists(string $userName, Db $oc_db): bool
    {
        $return_value = false;

        $vars = array(':userName' => $userName);
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `userName` = :userName
                AND `deleted` = 0';

        $res = $oc_db->prepared_query($sql, $vars);

        if (count($res) > 0) {
            $return_value = true;
        }

        return $return_value;
    }
}