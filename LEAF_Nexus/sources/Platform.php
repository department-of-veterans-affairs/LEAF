<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date: September 17, 2015

*/

namespace Orgchart;

use \App\Leaf\Db;

class Platform
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $launchpad_db;

    public function __construct(Db $db, Login $login, Db $launchpad_db)
    {
        $this->db = $db;
        $this->login = $login;
        $this->launchpad_db = $launchpad_db;

        $protocol = 'https';
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    public function getLaunchpadSites(string $orgchart_path): array
    {
        $vars = array(':orgchart_path' => '/' . $orgchart_path);
        $sql = 'SELECT `launchpadID`, `site_path`, `portal_database`
                FROM `sites`
                WHERE `orgchart_path` = :orgchart_path
                AND `site_type` = "portal"';

        $sites = $this->launchpad_db->prepared_query($sql, $vars);

        return $sites;
    }

    public function getTags(Db $portal_db): array
    {
        $vars = array(':tag' => 'orgchartImportTags');
        $sql = 'SELECT `data`
                FROM `settings`
                WHERE `setting` = :tag';

        $tags = $portal_db->prepared_query($sql, $vars);

        return json_decode($tags[0]['data'], true);
    }
}
