<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Leaf;

class setting
{
    protected $settings;

    public function __construct(Db $db)
    {
        $vars = array();
        $sql = 'SELECT `setting`, `data`
                FROM `settings`';

        $this->parseSettings($db->prepared_query($sql, $vars));
    }

    public function getSettings(): array
    {
        return $this->settings;
    }

    private function parseSettings(array $settings): void
    {
        foreach ($settings as $key => $value) {
            //error_log(print_r($value, true));
            $this->settings[$value['setting']] = $this->parseJson($value['data']);
        }

        //error_log(print_r($this->settings, true));
    }

    private function parseJson($data): string|array
    {
        $return_value = json_decode($data, true) ?? $data;
        //error_log(print_r($return_value, true));
        return $return_value;
    }
}