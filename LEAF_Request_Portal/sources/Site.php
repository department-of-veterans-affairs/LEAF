<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';

class Site
{
	public $siteRoot = '';

	private $db;

	private $login;

	public function __construct($db, $login)
	{
		$this->db = $db;
		$this->login = $login;

		$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
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
}
