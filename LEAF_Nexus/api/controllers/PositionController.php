<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class PositionController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $position;

    public function __construct($db, $login)
    {
        $this->position = new Position($db, $login);
    }

    public function get($act)
    {
        $position = $this->position;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('position/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('position', function ($args) {
            return print_r($args, true) . print_r($_GET, true);
        });
        $this->index['GET']->register('position/[digit]', function ($args) use ($position) {
            $positionID = (int)$args[0];
            $ret = $position->getAllData($positionID);
            $ret['title'] = $position->getTitle($positionID);
            $ret['subordinates'] = $position->getSubordinates($positionID);
            $ret['tags'] = $position->getAllTags($positionID);

            return $ret;
        });
        $this->index['GET']->register('position/search', function ($args) use ($position) {
            if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1)
            {
                $position->setNoLimit();
            }

            return $position->search($_GET['q'], $position->sanitizeInput($_GET['tag']), $_GET['employeeSearch']);
        });
        $this->index['GET']->register('position/[digit]/employees', function ($args) use ($position) {
            return $position->getEmployees($args[0]);
        });
        $this->index['GET']->register('position/[digit]/subordinates', function ($args) use ($position) {
            return $position->getSubordinates($args[0]);
        });
        $this->index['GET']->register('position/[digit]/supervisor', function ($args) use ($position) {
            return $position->getSupervisor($args[0]);
        });
        $this->index['GET']->register('position/[digit]/service', function ($args) use ($position) {
            return $position->getService($args[0]);
        });
        $this->index['GET']->register('position/[digit]/quadrad', function ($args) use ($position) {
            return $position->getQuadrad($args[0]);
        });
        $this->index['GET']->register('position/[digit]/search/parentTag/[text]', function ($args) use ($position) {
            return $position->findRootPositionByGroupTag($args[0], $position->sanitizeInput($args[1]));
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $position = $this->position;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('position', function ($args) use ($position) {
            try
            {
                return $position->addNew($_POST['title'], $_POST['parentID'], $_POST['groupID']);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['POST']->register('position/[digit]', function ($args) use ($position) {
            try
            {
                $position->modify($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }

            return true;
        });
        $this->index['POST']->register('position/[digit]/title', function ($args) use ($position) {
            $position->editTitle($args[0], $_POST['title']);
        });
        $this->index['POST']->register('position/[digit]/employee', function ($args) use ($position) {
            return $position->addEmployee($args[0], $_POST['empUID'], $_POST['isActing']);
        });
        $this->index['POST']->register('position/[digit]/supervisor', function ($args) use ($position) {
            return $position->setSupervisor($args[0], $_POST['positionID']);
        });
        $this->index['POST']->register('position/[digit]/setLeader', function ($args) use ($position) {
            return $position->addTag((int)$args[0], 'group_leader');
        });
        $this->index['POST']->register('position/[digit]/permissions/addEmployee', function ($args) use ($position) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $position->addPermission($args[0], 'employee', $_POST['empUID'], $type);
        });
        $this->index['POST']->register('position/[digit]/permissions/addPosition', function ($args) use ($position) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $position->addPermission($args[0], 'position', $_POST['positionID'], $type);
        });
        $this->index['POST']->register('position/[digit]/permissions/addGroup', function ($args) use ($position) {
            $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

            return $position->addPermission($args[0], 'group', $_POST['groupID'], $type);
        });
        $this->index['POST']->register('position/[digit]/permission/[text]/[digit]/[text]/toggle', function ($args) use ($position) {
            //$positionID, $categoryID, $UID, $permissionType
            return $position->togglePermission($args[0], $position->sanitizeInput($args[1]), $args[2], $args[3]);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $position = $this->position;

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('position/[digit]', function ($args) use ($position) {
            try
            {
                return $position->deletePosition($args[0]);
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });
        $this->index['DELETE']->register('position/[digit]/employee/[digit]', function ($args) use ($position) {
            return $position->removeEmployee($args[0], $args[1]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
