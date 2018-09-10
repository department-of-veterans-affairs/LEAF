<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

// Since Groups are primarily controlled via the Org. Chart, this provides read access to the local group database.

require '../admin/Group.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

class GroupController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $group;

    private $login;

    public function __construct($db, $login)
    {
        $this->group = new Group($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $group = $this->group;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('group/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('group/members', function ($args) use ($group) {
            return $group->getGroupsAndMembers();
        });

        $this->index['GET']->register('group/[digit]/members', function ($args) use ($group) {
            return $group->getMembers($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $this->verifyAdminReferrer();
        $group = $this->group;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('group', function ($args) use ($group) {
            return $group->addGroup(
                XSSHelpers::sanitizeHTML($_POST['groupName']),
                XSSHelpers::sanitizeHTML($_POST['groupDesc'])
            );
        });

        $this->index['POST']->register('group/[digit]/members', function ($args) use ($group) {
            return $group->addMember($_POST['userID'], $args[0]);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $this->verifyAdminReferrer();
        $group = $this->group;

        $this->index['DELETE'] = new ControllerMap();

        $this->index['DELETE']->register('group/[digit]', function ($args) use ($group) {
            return $group->removeGroup($args[0]);
        });

        $this->index['DELETE']->register('group/[digit]/members/[text]', function ($args) use ($group) {
            return $group->removeMember($args[1], $args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
