<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

use App\Leaf\Db;

class Site
{
    private $db;

    private $match;

    private $portal_path;

    private $site_paths;

    public $error = false;

    /**
     * @param Db $db
     *
     * Created at: 9/5/2023, 10:56:00 AM (America/New_York)
     */
    public function __construct(Db $db, string $path)
    {
        $this->db = $db;

        preg_match('(\/.+\/)', $path, $match);
        $this->match = rtrim(str_replace('/var/www/html', '', $match[0]), '/');
        // the only time that more than one folder gets removed is here so going to strip it here rather than wait.
        $this->match = str_replace('/sources/../mailer', '', $this->match);

        $portal_path = $this->checkPath();

        if ($portal_path['status']['code'] == 2 && !empty($portal_path['data'])) {
            $this->portal_path = $this->match;
            $this->site_paths = $portal_path['data'][0];
        } else {
            // the original url does not produce a site, need to extract the end of the url and try again.
            $this->stripLast();
            $portal_path = $this->checkPath();

            if ($portal_path['status']['code'] == 2 && !empty($portal_path['data'])) {
                $this->portal_path = $this->match;
                $this->site_paths = $portal_path['data'][0];
            } else {
                $this->error = true;
            }
        }
    }

    public function getPortalPath(): string
    {
        return $this->portal_path;
    }

    public function getSitePath(): array
    {
        return $this->site_paths;
    }

    private function stripLast(): void
    {
        $path_array = explode('/', $this->match);

        array_shift($path_array);
        array_pop($path_array);

        $path = '';

        for ($i = 0; $i < count($path_array); $i++) {
            $path .= '/' . $path_array[$i];
        }

        $this->match = $path;
    }

    private function checkPath(): array
    {
        $vars = array(':site_path' => $this->match);
        $sql = 'SELECT `site_path`, `site_uploads`, `portal_database`, `orgchart_path`,
                    `orgchart_database`
                FROM `sites`
                WHERE `site_path` = BINARY :site_path';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}