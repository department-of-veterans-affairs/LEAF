<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

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

    public function setHomeDesignJSON(string $inputJSON = '{}'): array {
        $status = array();
        if (!$this->login->checkGroup(1)) {
            $status['code'] = 0;
            $status['message'] = "Admin access required";
            return $status;
        }

        $inputData = json_decode($inputJSON, true);

        $menuItemsIn = $inputData['menuItems'] ?? [];
        $menuItems = array();
        foreach ($menuItemsIn as $i => $item) {
            $card = array();
            $card['id'] = \Leaf\XSSHelpers::xscrub($item['id']);
            $card['order'] = (int) \Leaf\XSSHelpers::xscrub($item['order']);
            $card['title'] = \Leaf\XSSHelpers::sanitizer($item['title'] ?? '');
            $card['subtitle'] = \Leaf\XSSHelpers::sanitizer($item['subtitle'] ?? '');
            $card['titleColor'] = preg_match('/^#[0-9a-f]{6}$/i', $item['titleColor'] ?? '') ? $item['titleColor'] : '#000000';
            $card['subtitleColor'] = preg_match('/^#[0-9a-f]{6}$/i', $item['subtitleColor'] ?? '') ? $item['subtitleColor'] : '#000000';
            $card['bgColor'] = preg_match('/^#[0-9a-f]{6}$/i', $item['bgColor'] ?? '') ? $item['bgColor'] : '#000000';
            $card['link'] = \Leaf\XSSHelpers::scrubNewLinesFromURL(\Leaf\XSSHelpers::xscrub($item['link'] ?? ''));
            $card['icon'] = \Leaf\XSSHelpers::scrubFilename($item['icon'] ?? '');
            $card['enabled'] = (int) $item['enabled'] === 1 ? 1 : 0;
            $menuItems[] = $card;
        }

        $headerIn = $inputData['header'] ?? array();
        $header = array();
        $header['title'] = \Leaf\XSSHelpers::sanitizeHTMLRich($headerIn['title'] ?? '');
        $header['titleColor'] = preg_match('/^#[0-9a-f]{6}$/i', $headerIn['titleColor'] ?? '') ? $headerIn['titleColor'] : '#000000';
        $header['headerType'] = (int) ($headerIn['headerType'] ?? 1);
        $header['imageFile'] = \Leaf\XSSHelpers::scrubFilename($headerIn['imageFile'] ?? '');
        $header['imageW'] = (int) ($headerIn['imageW'] ?? 0);
        $header['enabled'] = (int) ($headerIn['enabled'] ?? 0);

        $home_design_data = array();
        $home_design_data['menuCards'] = $menuItems;
        $home_design_data['direction'] = $inputData['direction'] === 'v' ? 'v' : 'h';
        $home_design_data['header'] = $header;
        $home_design_data['searchHeaders'] =  \Leaf\XSSHelpers::scrubObjectOrArray($inputData['searchHeaders']);
        $homepage_design_json = json_encode($home_design_data);

        $strSQL = 'INSERT INTO settings (setting, `data`)
            VALUES ("homepage_design_json", :homepage_design_json)
            ON DUPLICATE KEY UPDATE `data`=:homepage_design_json';
        $vars = array(':homepage_design_json' => $homepage_design_json);

        $this->db->prepared_query($strSQL, $vars);
        $status['code'] = 1;
        $status['message'] = "success";
        $status['data'] = $homepage_design_json;
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
