<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class Site
{
	public $siteRoot = '';

	private $db;

	private $login;

	public function __construct($db, $login)
	{
		$this->db = $db;
		$this->login = $login;

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//		$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
		$this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['REQUEST_URI']) . '/';
	}

	public function getAllSitePaths()
	{
		$res = $this->db->prepared_query("SELECT site_type, site_path FROM sites ORDER BY site_path ASC", null);
		return $res;
	}

	public function setSitemapJSON()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $vars = array(':input' => $_POST['sitemap_json']);
        $this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="sitemap_json"', $vars);

        return 1;
    }

    public function setHomeDesignJSON(array $menuItems = [], string $direction = 'v'): array {
        $status = array();
        if (!$this->login->checkGroup(1)) {
            $status['code'] = 0;
            $status['message'] = "Admin access required";
            return $status;
        }
        foreach ($menuItems as $i => $item) {
            $menuItems[$i]['title'] = XSSHelpers::sanitizer($item['title']);
            $menuItems[$i]['subtitle'] = XSSHelpers::sanitizer($item['subtitle']);
            $menuItems[$i]['link'] = XSSHelpers::scrubNewLinesFromURL(XSSHelpers::xscrub($item['link']));
            $menuItems[$i]['icon'] = XSSHelpers::scrubFilename($item['icon']);
        }
        $home_design_data = array();
        $home_design_data['menuCards'] = $menuItems;
        $home_design_data['direction'] = $direction === 'v' ? 'v' : 'h';
        $homepage_design_json = json_encode($home_design_data);

        $strSQL = 'INSERT INTO settings (setting, `data`)
            VALUES ("homepage_design_json", :homepage_design_json)
            ON DUPLICATE KEY UPDATE `data`=:homepage_design_json';
        $vars = array(':homepage_design_json' => $homepage_design_json);

        $this->db->prepared_query($strSQL, $vars);
        $status['code'] = 1;
        $status['message'] = "success";
        return $status;
    }
    public function setSearchDesignJSON(array $chosenHeaders = []): array {
        $status = array();
        if (!$this->login->checkGroup(1)) {
            $status['code'] = 0;
            $status['message'] = "Admin access required";
            return $status;
        }
        $search_design_data = array();
        $search_design_data['chosenHeaders'] = XSSHelpers::scrubObjectOrArray($chosenHeaders);
        $search_design_json = json_encode($search_design_data);

        $strSQL = 'INSERT INTO settings (setting, `data`)
            VALUES ("search_design_json", :search_design_json)
            ON DUPLICATE KEY UPDATE `data`=:search_design_json';
        $vars = array(':search_design_json' => $search_design_json);

        $this->db->prepared_query($strSQL, $vars);

        $status['code'] = 1;
        $status['message'] = "";
        return $status;
    }
    public function enableNoCodeHomepage(int $isEnabled = 0): array {
        $status = array();
        if (!$this->login->checkGroup(1)) {
            $status['code'] = 0;
            $status['message'] = "Admin access required";
            return $status;
        }
        $homepage_enabled = $isEnabled === 1 ? '1' : '0';
        $strSQL = 'INSERT INTO settings (setting, `data`)
            VALUES ("homepage_enabled", :homepage_enabled)
            ON DUPLICATE KEY UPDATE `data`=:homepage_enabled';
        $vars = array(':homepage_enabled' => $homepage_enabled);

        $this->db->prepared_query($strSQL, $vars);

        $status['code'] = 1;
        $status['message'] = "success";
        return $status;
    }
	public function getSitemapJSON()
	{
        $settings = $this->db->prepared_query('SELECT data from settings WHERE setting="sitemap_json"', null);

		return $settings;
	}
}
