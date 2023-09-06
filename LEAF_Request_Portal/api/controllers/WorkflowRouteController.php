<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class WorkflowRouteController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $workflow_route;

    public function __construct($db, $login)
    {
        $this->workflow_route = new WorkflowRoute($db, $login);
    }

    public function get($act)
    {
        $workflow_route = $this->workflow_route;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('workflowRoute/action/[text]', function ($args) use ($workflow_route) {
            return $workflow_route->getUsedAction($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $workflow_route = $this->workflow_route;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('workflowRoute/require', function ($args) use ($workflow_route) {
            return $workflow_route->toggleRequired($_POST);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {

    }
}
