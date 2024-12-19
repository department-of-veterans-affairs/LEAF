<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

use App\Leaf\XSSHelpers;

class TagController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $tag;

    public function __construct($db, $login)
    {
        $this->tag = new Tag($db, $login);
    }

    public function get($act)
    {
        $tag = $this->tag;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('tag/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('tag/[text]/parent', function ($args) use ($tag) {
            return $tag->getParent(XSSHelpers::sanitizeHTML($args[0]));
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $tag = $this->tag;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('tag/[text]/parent', function ($args) use ($tag) {
            return $tag->setParent($args[0], XSSHelpers::sanitizeHTML($_POST['parentTag']));
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
