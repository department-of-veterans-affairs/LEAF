<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../FormWorkflow.php';

if (!class_exists('XSSHelpers'))
{
    require_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

class FormWorkflowController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $db;

    private $formWorkflow;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->formWorkflow = new FormWorkflow($db, $login, 0);
        $this->login = $login;
    }

    public function get($act)
    {
        $db = $this->db;
        $formWorkflow = $this->formWorkflow;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('formWorkflow/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('formWorkflow/[digit]/currentStep', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);

            return $formWorkflow->getCurrentSteps();
        });

        $this->index['GET']->register('formWorkflow/[digit]/lastAction', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);

            return $formWorkflow->getLastAction();
        });

        $this->index['GET']->register('formWorkflow/[digit]/lastActionSummary', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);
            
            return $formWorkflow->getLastActionSummary();
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formWorkflow = $this->formWorkflow;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('formWorkflow', function ($args) {
        });

        $this->index['POST']->register('formWorkflow/[digit]/apply', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);

            return $formWorkflow->handleAction($_POST['dependencyID'], XSSHelpers::xscrub($_POST['actionType']), $_POST['comment']);
        });

        $this->index['POST']->register('formWorkflow/[digit]/step', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);

            return $formWorkflow->setStep($_POST['stepID'], false, $_POST['comment']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
