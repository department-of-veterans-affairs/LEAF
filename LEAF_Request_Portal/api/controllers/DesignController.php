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

        $this->index['POST']->register('design/new', function ($args) use ($design) {
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            return $design->newDesign($templateName);
        });
        
        $this->index['POST']->register('design/[digit]/content', function ($args) use ($design) {
            $input = $_POST['inputJSON'];
            $designID = \Leaf\XSSHelpers::xscrub($args[0]);
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            return $design->updateDesignContent($input, $designID, $templateName);
        });

        $this->index['POST']->register('design/[digit]/active', function ($args) use ($design) {
            $active = \Leaf\XSSHelpers::xscrub($_POST['active']);
            $designID = \Leaf\XSSHelpers::xscrub($args[0]);
            return $design->updateDesignActive($active, $designID);
        });

        $this->index['POST']->register('design/publish', function ($args) use ($design) {
            $designID = \Leaf\XSSHelpers::xscrub($_POST['designID']);
            $templateName = \Leaf\XSSHelpers::xscrub($_POST['templateName']);
            return $design->publishTemplate((int)$designID, $templateName);
        });

		return $this->index['POST']->runControl($act['key'], $act['args']);
	}


    public function delete($act)
    {
        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('design', function ($args) {
        });

        $this->index['DELETE']->register('design/delete/[digit]', function ($args) use ($design) {
            return $workflow->deleteDesign($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }

}
