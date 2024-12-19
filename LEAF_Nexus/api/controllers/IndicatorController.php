<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class IndicatorController extends RESTfulResponse
{
    public $index = array();

    private $indicators;

    public function __construct($db, $login)
    {
        $this->indicators = new Indicators($db, $login);
    }

    public function get($act)
    {
        $indicators = $this->indicators;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('indicator/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('indicator/[digit]/permissions', function ($args) use ($indicators) {
            return $indicators->getPrivileges($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $indicators = $this->indicators;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('indicator/[digit]/permissions/addEmployee', function ($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'employee', $_POST['empUID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permissions/addPosition', function ($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'position', $_POST['positionID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permissions/addGroup', function ($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'group', $_POST['groupID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permission/[text]/[digit]/[text]/toggle', function ($args) use ($indicators) {
            //$indicatorID, $categoryID, $UID, $permissionType
            return $indicators->togglePermission($args[0], $args[1], $args[2], $args[3]);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $indicators = $this->indicators;

        $this->index['DELETE'] = new ControllerMap();

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
