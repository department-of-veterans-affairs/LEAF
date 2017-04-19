<?php

require '../sources/Tag.php';

class TagController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $tag;

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->tag = new OrgChart\Tag($db, $login);

    }

    public function get($act)
    {
        $tag = $this->tag;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('tag/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('tag/[text]/parent', function($args) use ($tag) {
            return $tag->getParent($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
    	$tag = $this->tag;
    
    	$this->index['POST'] = new ControllerMap();
    
    	$this->index['POST']->register('tag/[text]/parent', function($args) use ($tag) {
    		return $tag->setParent($args[0], $_POST['parentTag']);
    	});

    	return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
