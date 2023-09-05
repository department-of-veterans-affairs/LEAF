<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class FormController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $form;

    private $login;

    public function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('form/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('form', function ($args) use ($form) {
        });

        $this->index['GET']->register('form/categories', function ($args) use ($form) {
            $result = $form->getAllCategories();

            for ($i = 0; $i < count($result); $i++)
            {
                $result[$i]['categoryID'] = XSSHelpers::xscrub($result[$i]['categoryID']);
                $result[$i]['categoryName'] = XSSHelpers::xscrub($result[$i]['categoryName']);
                $result[$i]['categoryDescription'] = XSSHelpers::xscrub($result[$i]['categoryDescription']);
            }

            return $result;
        });

        $this->index['GET']->register('form/category', function ($args) use ($form) {
            return $form->getFormByCategory(XSSHelpers::xscrub($_GET['id']));
        });

        // form/customData/ recordID list (csv) / indicatorID list (csv)
        $this->index['GET']->register('form/customData/[text]/[text]', function ($args) use ($form) {
            $recordIDs = array();
            $args[0] = trim($args[0], ',');
            $tempRecordIDs = explode(',', $args[0]);
            foreach ($tempRecordIDs as $id)
            {
                if (!is_numeric($id))
                {
                    return false;
                }
                $recordIDs[$id]['recordID'] = $id;
            }

            return $form->getCustomData($recordIDs, $args[1]);
        });

        // takes json encoded pairs [{id, operator, match}]
        $this->index['GET']->register('form/query', function ($args) use ($form) {
            if (isset($_GET['debug']))
            {
                return $query = XSSHelpers::scrubObjectOrArray(json_decode(html_entity_decode(html_entity_decode($_GET['q'])), true));
            }

            return $form->query($_GET['q']);
        });

        $this->index['GET']->register('form/search/indicator/[digit]', function ($args) use ($form) {
            $query = '{"terms":[{"id":"data","indicatorID":"' . $args[0] . '","operator":"=","match":"' . $_GET['q'] . '"}]}';

            return $form->query($query);
        });

        $this->index['GET']->register('form/search/submitter/[text]', function ($args) use ($form) {
            $query = '{"terms":[{"id":"userID","operator":"=","match":"' . $args[0] . '"}]}';

            return $form->query($query);
        });

        $this->index['GET']->register('form/[digit]', function ($args) use ($form) {
            return $form->getForm($args[0]);
        });

        $this->index['GET']->register('form/[digit]/data', function ($args) use ($form) {
            return $form->getFullFormData($args[0]);
        });

        $this->index['GET']->register('form/[digit]/data/tree', function ($args) use ($form) {
            return $form->getFullForm((int)$args[0], null);
        });

        $this->index['GET']->register('form/[digit]/[text]', function ($args) use ($form) {
            return $form->getForm($args[0], $args[1]);
        });

        $this->index['GET']->register('form/[digit]/[text]/data', function ($args) use ($form) {
            return $form->getFullFormData($args[0], $args[1]);
        });

        $this->index['GET']->register('form/[digit]/[text]/data/tree', function ($args) use ($form) {
            return $form->getFullForm($args[0], $args[1]);
        });

        $this->index['GET']->register('form/[digit]/dataforsigning', function ($args) use ($form) {
            return $form->getFullFormDataForSigning($args[0]);
        });

        $this->index['GET']->register('form/[digit]/progress', function ($args) use ($form) {
            $return = $form->getProgress($args[0]);
            return $return;
        });

        $this->index['GET']->register('form/[digit]/tags', function ($args) use ($form) {
            return $form->getTags($args[0]);
        });

        $this->index['GET']->register('form/[digit]/rawIndicator/[digit]/[digit]', function ($args) use ($form) {
            return $form->getIndicator($args[1], $args[2], $args[0]);
        });

        $this->index['GET']->register('form/[digit]/[digit]/[digit]/history', function ($args) use ($form) {
            return $form->getIndicatorLog($args[1], $args[2], $args[0]);
        });

        $this->index['GET']->register('form/indicator/nameSearch', function ($args) use ($form) {
            $names = $_GET['names'];
            $categoryID = $_GET['categoryID'];
            for ($i = 0; $i < count($names); $i++)
            {
                $names[$i] = XSSHelpers::xscrub($names[$i]);
            }

            return $form->getIndicatorsByRecordAndName($categoryID, $names);
        });


        $this->index['GET']->register('form/[digit]/indicator/formatSearch', function ($args) use ($form) {
            $formats = $_GET['formats'];
            for ($i = 0; $i < count($formats); $i++)
            {
                $formats[$i] = XSSHelpers::xscrub($formats[$i]);
            }

            return $form->getIndicatorsByRecordAndFormat((int)$args[0], $formats);
        });

        $this->index['GET']->register('form/[digit]/workflow/indicator/assigned', function ($args) use ($form) {
            return $form->getIndicatorsAssociatedWithWorkflow((int)$args[0]);
        });

        $this->index['GET']->register('form/indicator/list', function ($args) use ($form) {
            return $form->getIndicatorList($_GET['sort'], $_GET['includeHeadings'], $_GET['forms']);
        });

        $this->index['GET']->register('form/indicator/list/unabridged', function ($args) use ($form) {
            return $form->getIndicatorList($_GET['sort'], $_GET['includeHeadings'], $_GET['forms'], true);
        });

        $this->index['GET']->register('form/indicator/list/disabled', function ($args) use ($form) {
            return $form->getDisabledIndicatorList(1);
        });

        $this->index['GET']->register('form/[text]', function ($args) use ($form) {
            return $form->getFormByCategory($args[0]);
        });

        $this->index['GET']->register('form/[text]/flat', function ($args) use ($form) {
            $out = array();
            $data = $form->getFormByCategory($args[0]);
            $form->flattenFullFormData($data, $out);
            ksort($out);

            return $out;
        });

        $this->index['GET']->register('form/[text]/export', function ($args) use ($form) {
            return $form->getFormByCategory($args[0], false);
        });

        $this->index['GET']->register('form/[text]/workflow', function ($args) use ($form) {
            return $form->getWorkflow(XSSHelpers::xscrub($args[0]));
        });

        $this->index['GET']->register('form/[digit]/recordinfo', function ($args) use ($form) {
            return $form->getRecordInfo($args[0]);
        });

        $this->index['GET']->register('form/[text]/records', function ($args) use ($form) {
            return $form->getRecordsByCategory($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $form = $this->form;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('form', function ($args) {
        });

        // Expects POST input: $_POST['service'], title, priority, num(categoryID), CSRFToken
        $this->index['POST']->register('form/new', function ($args) use ($form, $login) {
            return $form->newForm($login->getUserID());
        });

        $this->index['POST']->register('form/[digit]', function ($args) use ($form) {
            return $form->doModify($args[0]);
        });

        $this->index['POST']->register('form/[digit]/submit', function ($args) use ($form) {
            return $form->doSubmit($args[0]);
        });

        $this->index['POST']->register('form/[digit]/title', function ($args) use ($form) {
            return $form->setTitle($args[0], XSSHelpers::sanitizeHTML($_POST['title']));
        });

        $this->index['POST']->register('form/[digit]/service', function ($args) use ($form) {
            return $form->setService($args[0], $_POST['serviceID']);
        });

        $this->index['POST']->register('form/[digit]/initiator', function ($args) use ($form) {
            return $form->setInitiator($args[0], XSSHelpers::sanitizeHTML($_POST['initiator']));
        });

        $this->index['POST']->register('form/[digit]/types', function ($args) use ($form) {
            return $form->changeFormType($args[0], $_POST['categories']);
        });

        $this->index['POST']->register('form/[digit]/types/append', function ($args) use ($form) {
            return $form->addFormType($args[0], XSSHelpers::sanitizeHTML($_POST['category']));
        });

        $this->index['POST']->register('form/[digit]/cancel', function ($args) use ($form) {
            return $form->deleteRecord((int)$args[0], $_POST['comment']);
        });

        $this->index['POST']->register('form/[digit]/delete', function ($args) use ($form) {
            return $form->permanentlyDeleteRecord((int)$args[0]);
        });

        $this->index['POST']->register('form/[digit]/reminder/[digit]', function ($args) use ($form) {
            return $form->sendReminderEmail((int)$args[0], (int)$args[1]);
        });

        // form/customData/ recordID list (csv) / indicatorID list (csv)
        $this->index['POST']->register('form/customData', function ($args) use ($form) {
            $recordIDs = array();
            $_POST['recordList'] = trim($_POST['recordList'], ',');
            $tempRecordIDs = explode(',', $_POST['recordList']);
            foreach ($tempRecordIDs as $id)
            {
                if (!is_numeric($id))
                {
                    return false;
                }
                $recordIDs[$id]['recordID'] = $id;
            }

            return $form->getCustomData($recordIDs, $_POST['indicatorList']);
        });

        $this->index['POST']->register('form/files/copy', function ($args) use ($form) {
            return $form->copyAttachment($_POST['indicatorID'], $_POST['fileName'], $_POST['recordID'], $_POST['newRecordID'], $_POST['series']);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
