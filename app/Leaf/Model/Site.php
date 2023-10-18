<?php

namespace App\Leaf\Model;

use App\Leaf\Db;

class Site
{
    protected $db;

    /**
     * [Description for __construct]
     * The db needs to be national_leaf_launchpad
     *
     * @param Db $db
     *
     * Created at: 10/18/2023, 10:40:27 AM (America/New_York)
     */
    public function __construct(Db $db)
    {
        $this->db = $db;
    }

    public function getSiteData(string $path): array
    {
        $vars = array(':site_path' => $path);
        $sql = 'SELECT `site_path`, `site_uploads`, `portal_database`, `orgchart_path`,
                    `orgchart_database`
                FROM `sites`
                WHERE `site_path` = BINARY :site_path';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}