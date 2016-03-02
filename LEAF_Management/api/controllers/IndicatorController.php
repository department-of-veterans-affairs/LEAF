<?php
/************************
    RESTful Controller
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: November 30, 2011

*/

require '../sources/Indicators.php';

class IndicatorController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $indicators;

    function __construct($db, $login)
    {
        $this->indicators = new OrgChart\Indicators($db, $login);

    }

    public function get($act)
    {
        $indicators = $this->indicators;

        $this->index['GET'] = new ControllerMap();
        $this->index['GET']->register('indicator/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('indicator/[digit]/permissions', function($args) use ($indicators) {
            return $indicators->getPrivileges($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $indicators = $this->indicators;

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('indicator/[digit]/permissions/addEmployee', function($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'employee', $_POST['empUID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permissions/addPosition', function($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'position', $_POST['positionID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permissions/addGroup', function($args) use ($indicators) {
            return $indicators->addPermission($args[0], 'group', $_POST['groupID'], 'read');
        });
        $this->index['POST']->register('indicator/[digit]/permission/[text]/[digit]/[text]/toggle', function($args) use ($indicators) {
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
