<?php
// Since Groups are primarily controlled via the Org. Chart, this provides read access to the local group database.


require '../admin/Group.php';

class GroupController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $group;
    private $login;

    function __construct($db, $login)
    {
        $this->group = new Group($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $group = $this->group;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('group/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('group/members', function($args) use ($group) {
			return $group->getGroupsAndMembers();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
