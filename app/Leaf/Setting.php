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

    /**
     * Safely decode data that may be JSON or legacy serialized PHP
     * Tries JSON first (preferred), falls back to unserialize for backward compatibility
     *
     * @param string|null $data The data to decode
     * @return mixed The decoded data or false on failure
     *
     * Created at: 11/21/2024
     */
    public static function safeDecodeData($data)
    {
        $return_value = false;

        if (!empty($data)) {
            // Try JSON first (modern format)
            $decoded = json_decode($data, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $return_value = $decoded;
            } else {
                // Fall back to unserialize for legacy data
                // Use allowed_classes => false to prevent object injection vulnerabilities
                $return_value = @unserialize($data, ['allowed_classes' => false]);
            }
        }

        return $return_value;
    }
}