<?php

require '../FormWorkflow.php';

require_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';

class FormWorkflowController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $db;
    private $formWorkflow;
    private $login;

    function __construct($db, $login)
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
        $this->index['GET']->register('formWorkflow/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('formWorkflow/[digit]/currentStep', function($args) use ($formWorkflow) {
        	$formWorkflow->initRecordID($args[0]);
			return $formWorkflow->getCurrentSteps();
        });

       	$this->index['GET']->register('formWorkflow/[digit]/lastAction', function($args) use ($formWorkflow) {
       		$formWorkflow->initRecordID($args[0]);
       		return $formWorkflow->getLastAction();
       	});

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formWorkflow = $this->formWorkflow;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('formWorkflow', function($args) {

        });

        $this->index['POST']->register('formWorkflow/[digit]/apply', function($args) use ($formWorkflow) {
        	$formWorkflow->initRecordID($args[0]);

        	return $formWorkflow->handleAction($_POST['dependencyID'], XSSHelpers::sanitizeHTML($_POST['actionType']), $_POST['comment']);
        });

       	$this->index['POST']->register('formWorkflow/[digit]/step', function($args) use ($formWorkflow) {
       		$formWorkflow->initRecordID($args[0]);

       		return $formWorkflow->setStep($_POST['stepID'], false, $_POST['comment']);
       	});

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}

