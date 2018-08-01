<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/Group.php';

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
        $this->index['GET']->register('group/version', function () {
            return $this->API_VERSION;
        });

        include 'Group/GET.php';

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $group = $this->group;

        $this->index['POST'] = new ControllerMap();

        include 'Group/POST.php';

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $group = $this->group;

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('group/[digit]', function ($args) use ($group) {
            try
            {
                return $group->deleteGroup($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['DELETE']->register('group/[digit]/position/[digit]', function ($args) use ($group) {
            return $group->removePosition($args[0], $args[1]);
        });
        $this->index['DELETE']->register('group/[digit]/employee/[digit]', function ($args) use ($group) {
            return $group->removeEmployee($args[0], $args[1]);
        });
        $this->index['DELETE']->register('group/[digit]/tag', function ($args) use ($group) {
            try
            {
                $group->deleteTag((int)$args[0], $group->sanitizeInput($_GET['tag']));
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
