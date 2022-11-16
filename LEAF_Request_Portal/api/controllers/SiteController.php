<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/Site.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

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

		return $this->index['POST']->runControl($act['key'], $act['args']);
	}
}
