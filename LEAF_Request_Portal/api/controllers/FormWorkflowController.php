<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

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

        $this->index['GET']->register('formWorkflow/getCSRFToken', function () {
            return $_SESSION['CSRFToken'];
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
            if(is_numeric($_POST['dependencyID'])) {
                return $formWorkflow->handleAction($_POST['dependencyID'], XSSHelpers::xscrub($_POST['actionType']), $_POST['comment'], $_POST['stepID']);
            } else {
                http_response_code(400);
                return 'The configuration for this workflow is incomplete. Please contact the administrator (missing requirement).';
            }
        });

        $this->index['POST']->register('formWorkflow/[digit]/step', function ($args) use ($formWorkflow) {
            $formWorkflow->initRecordID($args[0]);

            return $formWorkflow->setStep($_POST['stepID'], false, $_POST['comment']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
