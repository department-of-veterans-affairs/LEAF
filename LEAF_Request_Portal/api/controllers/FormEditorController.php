<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class FormEditorController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $form;

    private $formEditor;

    private $login;

    public function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->formEditor = new FormEditor($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $form = $this->form;
        $formEditor = $this->formEditor;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];

        $this->index['GET']->register('formEditor/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('formEditor', function ($args) use ($formEditor) {
        });

        $this->index['GET']->register('formEditor/indicator/[digit]', function ($args) use ($form, $formEditor) {
            $parseTemplate = isset($_GET['parseTemplate']);
            $recordID = isset($_GET['recordID']) ? XSSHelpers::xscrub($_GET['recordID']) : null;
            return $form->getIndicator($args[0], 1, $recordID, $parseTemplate);
        });

        $this->index['GET']->register('formEditor/indicator/[digit]/privileges', function ($args) use ($formEditor) {
            return $formEditor->getIndicatorPrivileges((int)$args[0]);
        });

        $this->index['GET']->register('formEditor/[text]/privileges', function ($args) use ($formEditor) {
            return $formEditor->getCategoryPrivileges($args[0]);
        });

        $this->index['GET']->register('formEditor/[text]/stapled', function ($args) use ($formEditor) {
            return $formEditor->getStapledCategories(XSSHelpers::xscrub($args[0]));
        });

        $this->index['GET']->register('formEditor/[text]/destructionAge', function ($args) use ($formEditor) {
            return $formEditor->getDestructionAge($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formEditor = $this->formEditor;

        //        $this->verifyAdminReferrer();
        // The above line was commented out when I
        // refactored RESTfulResponse so I'm leaving
        // it out here as well. But should it need to
        // be added back in remove the line above,
        // uncomment the line below and replace
        // false with '!$verified' in the if statement
        // and uncomment the echo in the true portion
        // of the if statement.
        // $verified = $this->verifyAdminReferrer();

        if (false) {
            // echo $verified;
        } else {
            $this->index['POST'] = new ControllerMap();
            $this->index['POST']->register('formEditor', function ($args) {
            });

            $this->index['POST']->register('formEditor/newIndicator', function ($args) use ($formEditor) {
                $package = array();
                $package['name'] = XSSHelpers::sanitizeHTML($_POST['name']);
                $package['format'] = strip_tags($_POST['format']);
                $package['description'] = XSSHelpers::sanitizeHTML($_POST['description']);
                $package['default'] = XSSHelpers::sanitizeHTML($_POST['default']);
                $package['parentID'] = $_POST['parentID'] ? (int)$_POST['parentID'] : null;
                $package['categoryID'] = XSSHelpers::xscrub($_POST['categoryID']);
                $package['html'] = $_POST['html'];
                $package['htmlPrint'] = $_POST['htmlPrint'];
                $package['conditions'] = $_POST['conditions'];
                $package['required'] = (int)$_POST['required'];
                $package['is_sensitive'] = $_POST['is_sensitive'];
                $package['sort'] = (int)$_POST['sort'];

                return $formEditor->addIndicator($package);
            });

            $this->index['POST']->register('formEditor/sort/batch', function ($args) use ($formEditor) {
                return $formEditor->setSortBatch(XSSHelpers::scrubObjectOrArray($_POST['sortData']));
            });

            $this->index['POST']->register('formEditor/[digit]/name', function ($args) use ($formEditor) {
                return $formEditor->setName((int)$args[0], $_POST['name']);
            });

            $this->index['POST']->register('formEditor/[digit]/format', function ($args) use ($formEditor) {
                return $formEditor->setFormat((int)$args[0], strip_tags($_POST['format']));
            });

            $this->index['POST']->register('formEditor/[digit]/description', function ($args) use ($formEditor) {
                return $formEditor->setDescription($args[0], XSSHelpers::sanitizeHTML($_POST['description']));
            });

            $this->index['POST']->register('formEditor/[digit]/default', function ($args) use ($formEditor) {
                return $formEditor->setDefault($args[0], XSSHelpers::sanitizeHTML($_POST['default']));
            });

            $this->index['POST']->register('formEditor/[digit]/parentID', function ($args) use ($formEditor) {
                return $formEditor->setParentID((int)$args[0], (int)$_POST['parentID']);
            });

            $this->index['POST']->register('formEditor/[digit]/categoryID', function ($args) use ($formEditor) {
                return $formEditor->setCategoryID((int)$args[0], XSSHelpers::xscrub($_POST['categoryID']));
            });

            $this->index['POST']->register('formEditor/[digit]/required', function ($args) use ($formEditor) {
                return $formEditor->setRequired((int)$args[0], (int)$_POST['required']);
            });

            $this->index['POST']->register('formEditor/[digit]/sensitive', function($args) use ($formEditor) {
                return $formEditor->setSensitive((int)$args[0], (int)$_POST['is_sensitive']);
            });

            $this->index['POST']->register('formEditor/[digit]/disabled', function ($args) use ($formEditor) {
                return $formEditor->setDisabled((int)$args[0], (int)$_POST['disabled']);
            });

            $this->index['POST']->register('formEditor/[digit]/deleted', function ($args) use ($formEditor) {
                return $formEditor->setDisabled((int)$args[0], (int)$_POST['deleted']);
            });

            $this->index['POST']->register('formEditor/formType', function ($args) use ($formEditor) {
                return $formEditor->setFormType(XSSHelpers::xscrub($_POST['categoryID']), XSSHelpers::xscrub($_POST['type']));
            });

            $this->index['POST']->register('formEditor/[digit]/sort', function ($args) use ($formEditor) {
                return $formEditor->setSort((int)$args[0], (int)$_POST['sort']);
            });

            // Advanced Option allows HTML/JS
            $this->index['POST']->register('formEditor/[digit]/html', function ($args) use ($formEditor) {
                return $formEditor->setHtml((int)$args[0], $_POST['html']);
            });

            // Advanced Option allows HTML/JS
            $this->index['POST']->register('formEditor/[digit]/htmlPrint', function ($args) use ($formEditor) {
                return $formEditor->setHtmlPrint((int)$args[0], $_POST['htmlPrint']);
            });

            // Set Conditional Formatting for Indicator
            $this->index['POST']->register('formEditor/[digit]/conditions', function ($args) use ($formEditor) {
                return $formEditor->setCondition((int)$args[0], $_POST['conditions']);
            });

            $this->index['POST']->register('formEditor/new', function ($args) use ($formEditor) {
                return $formEditor->createForm(
                    XSSHelpers::sanitizeHTML($_POST['name']),
                    XSSHelpers::sanitizeHTML($_POST['description']),
                    XSSHelpers::sanitizeHTML($_POST['parentID'] ?? "")
                );
            });

            $this->index['POST']->register('formEditor/formName', function ($args) use ($formEditor) {
                return $formEditor->setFormName(
                    strip_tags($_POST['categoryID']),
                    XSSHelpers::sanitizeHTML($_POST['name'])
                );
            });

            $this->index['POST']->register('formEditor/formDescription', function ($args) use ($formEditor) {
                return $formEditor->setFormDescription(
                    $_POST['categoryID'],
                    XSSHelpers::sanitizeHTML($_POST['description'])
                );
            });

            $this->index['POST']->register('formEditor/formWorkflow', function ($args) use ($formEditor) {
                return $formEditor->setFormWorkflow(XSSHelpers::xscrub($_POST['categoryID']), (int)$_POST['workflowID']);
            });

            $this->index['POST']->register('formEditor/formNeedToKnow', function ($args) use ($formEditor) {
                return $formEditor->setFormNeedToKnow(XSSHelpers::xscrub($_POST['categoryID']), (int)$_POST['needToKnow']);
            });

            $this->index['POST']->register('formEditor/formSort', function ($args) use ($formEditor) {
                return $formEditor->setFormSort(XSSHelpers::xscrub($_POST['categoryID']), (int)$_POST['sort']);
            });

            $this->index['POST']->register('formEditor/formVisible', function ($args) use ($formEditor) {
                return $formEditor->setFormVisible(XSSHelpers::xscrub($_POST['categoryID']), (int)$_POST['visible']);
            });

            $this->index['POST']->register('formEditor/destructionAge', function ($args) use ($formEditor) {
                return $formEditor->setFormDestructionAge(XSSHelpers::xscrub($_POST['categoryID']), (int)$_POST['destructionAge']);
            });

            $this->index['POST']->register('formEditor/[text]/privileges', function ($args) use ($formEditor) {
                return $formEditor->setCategoryPrivileges(XSSHelpers::xscrub($args[0]), (int)$_POST['groupID'], (int)$_POST['read'], (int)$_POST['write']);
            });

            $this->index['POST']->register('formEditor/[text]/stapled', function ($args) use ($formEditor) {
                return $formEditor->addStapledCategory(XSSHelpers::xscrub($args[0]), XSSHelpers::xscrub($_POST['stapledCategoryID']));
            });

            $this->index['POST']->register('formEditor/indicator/[digit]/privileges/remove', function ($args) use ($formEditor) {
                return $formEditor->removeIndicatorPrivilege((int)$args[0], (int)$_POST['groupID']);
            });

            $this->index['POST']->register('formEditor/indicator/[digit]/privileges', function ($args) use ($formEditor) {
                if (!is_array($_POST['groupIDs']))
                {
                    return false;
                }

                $groups = array();
                foreach ($_POST['groupIDs'] as $group)
                {
                    if (is_numeric($group))
                    {
                        $groups[] = (int)$group;
                    }
                }

                if (count($groups) < 1)
                {
                    return false;
                }

                return $formEditor->setIndicatorPrivileges((int)$args[0], $groups);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }


    }

    public function delete($act)
    {
        $formEditor = $this->formEditor;

        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $this->index['DELETE'] = new ControllerMap();
            $this->index['DELETE']->register('formEditor', function ($args) {
            });

            $this->index['DELETE']->register('formEditor/[text]/stapled/[text]', function ($args) use ($formEditor) {
                return $formEditor->removeStapledCategory(XSSHelpers::xscrub($args[0]), XSSHelpers::xscrub($args[1]));
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
