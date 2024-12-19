<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class WorkflowController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $workflow;

    public function __construct($db, $login)
    {
        $this->workflow = new Workflow($db, $login);
    }

    public function get($act)
    {
        $workflow = $this->workflow;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('workflow/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('workflow', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getAllUniqueWorkflows();
        });

        $this->index['GET']->register('workflow/[digit]', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getSteps();
        });

        $this->index['GET']->register('workflow/[digit]/categories', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getCategories();
        });

        $this->index['GET']->register('workflow/[digit]/route', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getRoutes();
        });

        $this->index['GET']->register('workflow/[digit]/map/summary', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getSummaryMap();
        });

        $this->index['GET']->register('workflow/[digit]/step/[digit]/[text]/events', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getEvents($args[1], $args[2]);
        });

        $this->index['GET']->register('workflow/categories', function ($args) use ($workflow) {
            return $workflow->getAllCategories();
        });

        $this->index['GET']->register('workflow/categoriesUnabridged', function ($args) use ($workflow) {
            return $workflow->getAllCategoriesUnabridged();
        });

        $this->index['GET']->register('workflow/dependencies', function ($args) use ($workflow) {
            return $workflow->getAllDependencies();
        });

        $this->index['GET']->register('workflow/dependencies/groups', function ($args) use ($workflow) {
            return $workflow->getCustomDependenciesAndGroups();
        });

        $this->index['GET']->register('workflow/step/[digit]/dependencies', function ($args) use ($workflow) {
            return $workflow->getDependencies($args[0]);
        });

        $this->index['GET']->register('workflow/actions', function ($args) use ($workflow) {
            return $workflow->getActions();
        });

        $this->index['GET']->register('workflow/userActions', function ($args) use ($workflow) {
            return $workflow->getUserActions();
        });

        $this->index['GET']->register('workflow/events', function ($args) use ($workflow) {
            return $workflow->getAllEvents();
        });

        $this->index['GET']->register('workflow/customEvents', function ($args) use ($workflow) {
            return $workflow->getCustomEvents();
        });

        $this->index['GET']->register('workflow/event/[text]', function ($args) use ( $workflow) {
            return $workflow->getEvent($args[0]);
        });

        $this->index['GET']->register('workflow/step/[digit]', function ($args) use ($workflow) {
            return $workflow->getStep((int)$args[0]);
        });

        $this->index['GET']->register('workflow/steps', function ($args) use ($workflow) {
            return $workflow->getAllSteps();
        });
        $this->index['GET']->register('workflow/workflowSteps', function ($args) use ($workflow) {
            return $workflow->getAllWorkflowSteps();
        });

        $this->index['GET']->register('workflow/action/[text]', function ($args) use ( $workflow) {
            return $workflow->getAction($args[0]);
        });

        $this->index['GET']->register('workflow/[digit]/step/[digit]/[text]/events/emailReminder', function ($args) use ( $workflow) {
            $workflow->setWorkflowID($args[0]);
            return $workflow->getEmailReminderData((int)$args[1], XSSHelpers::xscrub($args[2]));
        });

        $this->index['GET']->register('workflow/[digit]/step/routeEvents', function ($args) use ( $workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->getWorkflowEvents((int) $args[0]);
        });

        $this->index['GET']->register('workflow/[digit]/stepDependencies', function ($args) use ( $workflow) {
            return $workflow->getStepDependencies((int) $args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $workflow = $this->workflow;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('workflow', function ($args) {
        });

        $this->index['POST']->register('workflow/[digit]', function ($args) use ($workflow) {
            try
            {
                $workflow->setWorkflowID((int)$args[0]);
                return $workflow->renameWorkflow(XSSHelpers::xscrub($_POST['description']));
            }
            catch (Exception $e)
            {
                return $e->getMessage();
            }
        });

        $this->index['POST']->register('workflow/new', function ($args) use ($workflow) {
            return $workflow->newWorkflow(XSSHelpers::xscrub($_POST['description']));
        });

        $this->index['POST']->register('workflow/events', function ($args) use ($workflow) {
            return $workflow->createEvent(XSSHelpers::xscrub($_POST['name']),
                                          XSSHelpers::xscrub($_POST['description']),
                                          XSSHelpers::xscrub($_POST['type']),
                                          $_POST['data']);
        });

        $this->index['POST']->register('workflow/[digit]/editorPosition', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);

            return $workflow->setEditorPosition((int)$_POST['stepID'], (int)$_POST['x'], (int)$_POST['y']);
        });

        $this->index['POST']->register('workflow/[digit]/action', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);

            return $workflow->createAction((int)$_POST['stepID'], (int)$_POST['nextStepID'], XSSHelpers::xscrub($_POST['action']));
        });

        $this->index['POST']->register('workflow/[digit]/step', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);

            return $workflow->createStep(XSSHelpers::xscrub($_POST['stepTitle']), XSSHelpers::xscrub($_POST['stepBgColor']), XSSHelpers::xscrub($_POST['stepFontColor']));
        });

        $this->index['POST']->register('workflow/[digit]/initialStep', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);

            return $workflow->setInitialStep((int)$_POST['stepID']);
        });

        $this->index['POST']->register('workflow/step/[digit]', function ($args) use ($workflow) {
            return $workflow->updateStep((int)$args[0], XSSHelpers::xscrub($_POST['title']));
        });

        $this->index['POST']->register('workflow/stepdata/[digit]', function ($args) use ($workflow) {
            return $workflow->saveStepData((int)$args[0], $_POST['seriesData']);
        });

        $this->index['POST']->register('workflow/step/[digit]/dependencies', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$_POST['workflowID']);
            return $workflow->linkDependency((int)$args[0], (int)$_POST['dependencyID']);
        });

        $this->index['POST']->register('workflow/step/[digit]/indicatorID_for_assigned_empUID', function ($args) use ($workflow) {
            return $workflow->setDynamicApprover($args[0], $_POST['indicatorID']);
        });

        $this->index['POST']->register('workflow/step/[digit]/indicatorID_for_assigned_groupID', function ($args) use ($workflow) {
            return $workflow->setDynamicGroupApprover((int)$args[0], (int)$_POST['indicatorID']);
        });

        $this->index['POST']->register('workflow/step/[digit]/inlineIndicator', function($args) use ($workflow) {
            return $workflow->setStepInlineIndicator($args[0], (int)$_POST['indicatorID']);
        });

        $this->index['POST']->register('workflow/step/[digit]/requiresig', function($args) use ($workflow) {
            return $workflow->requireDigitalSignature($args[0], (int)$_POST['requiresSig']);
        });

        $this->index['POST']->register('workflow/dependencies', function ($args) use ($workflow) {
            return $workflow->addDependency(XSSHelpers::xscrub($_POST['description']));
        });

        $this->index['POST']->register('workflow/dependency/[digit]', function ($args) use ($workflow) {
            return $workflow->updateDependency((int)$args[0], XSSHelpers::xscrub($_POST['description']));
        });

        $this->index['POST']->register('workflow/dependency/[digit]/privileges', function ($args) use ($workflow) {
            return $workflow->grantDependencyPrivs((int)$args[0], (int)$_POST['groupID']);
        });

        $this->index['POST']->register('workflow/[digit]/step/[digit]/[text]/events', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);
            if($_POST['eventID'] == 'automated_email_reminder')
            {
                $workflow->setEmailReminderData((int)$args[1], XSSHelpers::xscrub($args[2]), XSSHelpers::xscrub($_POST['frequency']), XSSHelpers::xscrub($_POST['recipientGroupID']), XSSHelpers::xscrub($_POST['emailTemplate']), XSSHelpers::xscrub($_POST['startDateIndicatorID']));
            }
            return $workflow->linkEvent((int)$args[1], XSSHelpers::xscrub($args[2]), XSSHelpers::xscrub($_POST['eventID']));
        });

        $this->index['POST']->register('workflow/editAction/[text]', function ($args) use ($workflow) {
            return $workflow->editAction($args[0]);
        });

        $this->index['POST']->register('workflow/editEvent/[text]', function ($args) use ($workflow) {
            return $workflow->editEvent($args[0],
                                        XSSHelpers::xscrub($_POST['newName']),
                                        XSSHelpers::xscrub($_POST['description']),
                                        XSSHelpers::xscrub($_POST['type']),
                                        $_POST['data']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        $workflow = $this->workflow;

        $this->verifyAdminReferrer();

        $this->index['DELETE'] = new ControllerMap();
        $this->index['DELETE']->register('workflow', function ($args) {
        });

        $this->index['DELETE']->register('workflow/[digit]', function ($args) use ($workflow) {
            return $workflow->deleteWorkflow($args[0]);
        });

        $this->index['DELETE']->register('workflow/[digit]/step/[digit]/[text]/[digit]', function ($args) use ($workflow) {
            $workflow->setWorkflowID($args[0]);

            return $workflow->deleteAction($args[1], $args[3], $args[2]);
        });

        $this->index['DELETE']->register('workflow/step/[digit]/dependencies', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$_GET['workflowID']);
            return $workflow->unlinkDependency((int)$args[0], (int)$_GET['dependencyID']);
        });

        $this->index['DELETE']->register('workflow/dependency/[digit]/privileges', function ($args) use ($workflow) {
            return $workflow->revokeDependencyPrivs($args[0], $_GET['groupID']);
        });

        $this->index['DELETE']->register('workflow/[digit]/step/[digit]/[text]/events', function ($args) use ($workflow) {
            $workflow->setWorkflowID((int)$args[0]);

            if($_GET['eventID'] == 'automated_email_reminder')
            {
                $workflow->deleteEmailReminderData((int)$args[1], XSSHelpers::xscrub($args[2]));
            }
            return $workflow->unlinkEvent((int)$args[1], XSSHelpers::xscrub($args[2]), XSSHelpers::xscrub($_GET['eventID']));
        });

        $this->index['DELETE']->register('workflow/step/[digit]', function ($args) use ($workflow) {
            return $workflow->deleteStep($args[0]);
        });

        $this->index['DELETE']->register('workflow/action/[text]', function ($args) use ($workflow) {
            return $workflow->removeAction($args[0]);
        });

        $this->index['DELETE']->register('workflow/event/[text]', function ($args) use ($workflow) {
            return $workflow->removeEvent($args[0]);
        });

        return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}
