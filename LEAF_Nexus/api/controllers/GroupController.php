<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class GroupController extends RESTfulResponse
{
    public $index = array();

    private $group;

    public function __construct($db, $login)
    {
        $this->group = new Group($db, $login);
    }

    public function get($act)
    {
        $group = $this->group;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('group/version', function () {
            return self::API_VERSION;
        });

                $this->index['GET']->register('group', function ($args) {
            return print_r($args, true) . print_r($_GET, true);
        });
        $this->index['GET']->register('group/list', function ($args) use ($group) {
            return $group->listGroups(0, $_GET['offset'], $_GET['quantity']);
        });
        $this->index['GET']->register('group/[digit]', function ($args) use ($group) {
            $groupID = (int)$args[0];
            $ret = $group->getAllData($groupID);
            $ret['title'] = $group->getTitle($groupID);

            return $ret;
        });
        $this->index['GET']->register('group/[digit]/summary', function ($args) use ($group) {
            return $group->getSummary($args[0]);
        });
        $this->index['GET']->register('group/[digit]/list', function ($args) use ($group) {
            return $group->listGroups($args[0], $_GET['offset'], $_GET['quantity']);
        });
        $this->index['GET']->register('group/[digit]/positions', function ($args) use ($group) {
            return $group->listGroupPositions($args[0]);
        });
        $this->index['GET']->register('group/[digit]/leader', function ($args) use ($group) {
            return $group->getGroupLeader($args[0]);
        });
        $this->index['GET']->register('group/[digit]/employees', function ($args) use ($group) {
            return $group->listGroupEmployees($args[0]);
        });
        $this->index['GET']->register('group/[digit]/employees/all', function ($args) use ($group) {
            return $group->listGroupEmployeesAll($args[0]);
        });
        $this->index['GET']->register('group/[digit]/employees/detailed', function ($args) use ($group) {
            $limit = -1;
            if (isset($_GET['limit']))
            {
                $limit = (int)$_GET['limit'];
            }

            $offset = 0;
            if (isset($_GET['offset']))
            {
                $offset = (int)$_GET['offset'];
            }

            // this method only accepts 3 arguments and searchText is not one of them.
            // return $group->listGroupEmployeesDetailed($args[0], $searchText, $offset, $limit);
            // here is the definition of this method listGroupEmployeesDetailed($groupID, $offset = 0, $limit = -1)
            return $group->listGroupEmployeesDetailed($args[0], $offset, $limit);
        });
        $this->index['GET']->register('group/search', function ($args) use ($group) {
            if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1)
            {
                $group->setNoLimit();
            }

            return $group->search($_GET['q'], $group->sanitizeInput($_GET['tag']));
        });
        $this->index['GET']->register('group/tag', function ($args) use ($group) {
            return $group->listGroupsByTag($group->sanitizeInput($_GET['tag']));
        });
        $this->index['GET']->register('group/tag/[text]', function ($args) use ($group) {
            return $group->listGroupsByTag($group->sanitizeInput($args[0]));
        });
        $this->index['GET']->register('group/[digit]/data/[digit]', function ($args) use ($group) {
            return $group->getAllData((int)$args[0], (int)$args[1]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $group = $this->group;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('group', function ($args) use ($group) {
            $_POST['parentID'] = isset($_POST['parentID']) ? $_POST['parentID'] : 0;

            try
            {
                return $group->addNew($_POST['title'], $_POST['parentID']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('group/[digit]', function ($args) use ($group) {
            try
            {
                $group->modify($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }

            return true;
        });
        $this->index['POST']->register('group/[digit]/position', function ($args) use ($group) {
            return $group->addPosition($args[0], $_POST['positionID']);
        });
        $this->index['POST']->register('group/[digit]/employee', function ($args) use ($group) {
            return $group->addEmployee($args[0], $_POST['empUID']);
        });
        $this->index['POST']->register('group/[digit]/tag', function ($args) use ($group) {
            try
            {
                return $group->addTag((int)$args[0], $_POST['tag']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('group/[digit]/title', function ($args) use ($group) {
            $_POST['abbreviatedTitle'] = isset($_POST['abbreviatedTitle']) ? $_POST['abbreviatedTitle'] : '';

            try
            {
                $group->editTitle($args[0], $_POST['title'], $_POST['abbreviatedTitle']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }

            return true;
        });

        $this->index['POST']->register('group/[digit]/permissions/addEmployee', function ($args) use ($group) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $group->addPermission($args[0], 'employee', $_POST['empUID'], $type);
        });
        $this->index['POST']->register('group/[digit]/permissions/addPosition', function ($args) use ($group) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $group->addPermission($args[0], 'position', $_POST['positionID'], $type);
        });
        $this->index['POST']->register('group/[digit]/permissions/addGroup', function ($args) use ($group) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $group->addPermission($args[0], 'group', $_POST['groupID'], $type);
        });
        $this->index['POST']->register('group/[digit]/permission/[text]/[digit]/[text]/toggle', function ($args) use ($group) {
            //$groupID, $categoryID, $UID, $permissionType
            return $group->togglePermission($args[0], $group->sanitizeInput($args[1]), $args[2], $args[3]);
        });

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
                return $group->deleteTag((int)$args[0], $group->sanitizeInput($_GET['tag']));
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['DELETE']->register('group/[digit]/local/tag', function ($args) use ($group) {
            try
            {
                return $group->deleteLocalTag((int)$args[0], $group->sanitizeInput($_GET['tag']));
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
