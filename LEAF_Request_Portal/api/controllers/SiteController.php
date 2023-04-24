<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class SiteController extends RESTfulResponse
{
	public $index = array();

	private $API_VERSION = 1;

	private $site;

	public function __construct($db, $login)
	{
		$this->site = new Site($db, $login);
	}

	public function get($act)
	{
		$site = $this->site;

		$this->index['GET'] = new ControllerMap();

		$this->index['GET']->register('site/version', function () {
			return $this->API_VERSION;
		});

		$this->index['GET']->register('site/paths', function($args) use ($site){
			return $site->getAllSitePaths();
		});

		return $this->index['GET']->runControl($act['key'], $act['args']);
	}

	public function post($act)
    {
		$site = $this->site;

		$this->index['POST'] = new ControllerMap();

		$this->index['POST']->register('site/settings/sitemap_json', function ($args) use ($site) {
			return $site->setSitemapJSON();
		});
		$this->index['POST']->register('site/settings/home_menu_json', function ($args) use ($site) {
            $list = $_POST['home_menu_list'] ?? [];
			return $site->setHomeMenuJSON($list);
		});
		$this->index['POST']->register('site/settings/enable_home', function ($args) use ($site) {
			return $site->enableNoCodeHome((int)$_POST['home_enabled']);
		});

		return $this->index['POST']->runControl($act['key'], $act['args']);
	}

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
