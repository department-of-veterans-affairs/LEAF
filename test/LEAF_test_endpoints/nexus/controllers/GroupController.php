<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once __DIR__ . '/../../../../LEAF_Nexus/sources/Group.php';

class GroupController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $group;

    public function __construct($db, $login)
    {
        $this->group = new OrgChart\Group($db, $login);
    }

    public function get($act)
    {
        $group = $this->group;

        $this->index['GET'] = new ControllerMap();

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $group = $this->group;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('group/editParentID', function ($args) use ($group) {
            return $group->editParentID($_POST['groupID'], $_POST['newParentID']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
