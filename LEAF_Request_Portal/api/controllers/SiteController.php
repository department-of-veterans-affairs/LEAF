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

		$this->index['GET']->register('site/settings/sitemap_json', function() use ($site){
			return LEAF_SETTINGS['sitemap_json'];
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
        $this->index['POST']->register('site/settings/homepage_design_json', function ($args) use ($site) {
            $list = $_POST['home_menu_list'] ?? [];
            $direction = $_POST['menu_direction'] ?? 'v';
            return $site->setHomeDesignJSON($list, $direction);
        });
        $this->index['POST']->register('site/settings/search_design_json', function ($args) use ($site) {
            $list = $_POST['chosen_headers'] ?? [];
			return $site->setSearchDesignJSON($list);
		});
		$this->index['POST']->register('site/settings/enable_homepage', function ($args) use ($site) {
			return $site->enableNoCodeHomepage((int)$_POST['enabled']);
		});

		return $this->index['POST']->runControl($act['key'], $act['args']);
	}

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
