<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class DesignController extends RESTfulResponse
{
	public $index = array();

	private $API_VERSION = 1;

    private $design;

	public function __construct($design)
	{
        $this->design = $design;
	}

	public function get($act)
	{
        $design = $this->design;

		$this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('design/version', function () {
            return $this->API_VERSION;
        });

		$this->index['GET']->register('design/designList', function() use ($design){
			return $design->getAllDesigns();
		});

		return $this->index['GET']->runControl($act['key'], $act['args']);
	}

	public function post($act)
    {
		$design = $this->design;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('design/new', function () use ($design) {
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            $designName = \Leaf\XSSHelpers::xscrub($_POST['designName']);
            return $design->newDesign($templateName, $designName);
        });

        $this->index['POST']->register('design/publish', function () use ($design) {
            $designID = \Leaf\XSSHelpers::xscrub($_POST['designID']);
            $currentID = \Leaf\XSSHelpers::xscrub($_POST['currentEnabledID']);
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            return $design->publishTemplate((int)$designID, (int)$currentID, $templateName);
        });

        $this->index['POST']->register('design/[digit]/content', function ($args) use ($design) {
            $input = $_POST['inputJSON'];
            $designID = \Leaf\XSSHelpers::xscrub($args[0]);
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            return $design->updateDesignContent($input, (int)$designID, $templateName);
        });

		return $this->index['POST']->runControl($act['key'], $act['args']);
	}


    public function delete($act)
    {
        $design = $this->design;

        $this->index['DELETE'] = new ControllerMap();

        $this->index['DELETE']->register('design/delete/[digit]/[text]', function ($args) use ($design) {
            $designID = \Leaf\XSSHelpers::xscrub($args[0]);
            $templateName = \Leaf\XSSHelpers::xscrub($args[1]);
            return $design->deleteDesign((int)$designID, $templateName);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }

}
