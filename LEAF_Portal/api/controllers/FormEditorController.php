<?php

require '../form.php';
require '../sources/FormEditor.php';

class FormEditorController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $form;
    private $formEditor;
    private $login;

    function __construct($db, $login)
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
        $this->index['GET']->register('formEditor/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('formEditor', function($args) use ($formEditor) {

        });

        $this->index['GET']->register('formEditor/indicator/[digit]', function($args) use ($form, $formEditor) {
			return $form->getIndicator($args[0], 1, null, false);
        });

        $this->index['GET']->register('formEditor/[text]/privileges', function($args) use ($formEditor) {
        	return $formEditor->getCategoryPrivileges($args[0]);
        });

        $this->index['GET']->register('formEditor/[text]/stapled', function($args) use ($formEditor) {
        	return $formEditor->getStapledCategories($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $formEditor = $this->formEditor;
        $login = $this->login;

        $this->verifyAdminReferrer();

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('formEditor', function($args) {

        });

        $this->index['POST']->register('formEditor/newIndicator', function($args) use ($formEditor) {
        	$package = array();
        	$package['name'] = $_POST['name'];
        	$package['format'] = $_POST['format'];
        	$package['description'] = $_POST['description'];
        	$package['default'] = $_POST['default'];
        	$package['parentID'] = $_POST['parentID'];
        	$package['categoryID'] = $_POST['categoryID'];
        	$package['html'] = $_POST['html'];
        	$package['htmlPrint'] = $_POST['htmlPrint'];
        	$package['required'] = $_POST['required'];
        	$package['sort'] = $_POST['sort'];
        	return $formEditor->addIndicator($package);
        });

        $this->index['POST']->register('formEditor/[digit]/name', function($args) use ($formEditor) {
	        return $formEditor->setName($args[0], $_POST['name']);
        });

        $this->index['POST']->register('formEditor/[digit]/format', function($args) use ($formEditor) {
        	return $formEditor->setFormat($args[0], $_POST['format']);
        });

        $this->index['POST']->register('formEditor/[digit]/description', function($args) use ($formEditor) {
        	return $formEditor->setDescription($args[0], $_POST['description']);
        });

        $this->index['POST']->register('formEditor/[digit]/default', function($args) use ($formEditor) {
        	return $formEditor->setDefault($args[0], $_POST['default']);
        });

        $this->index['POST']->register('formEditor/[digit]/parentID', function($args) use ($formEditor) {
        	return $formEditor->setParentID($args[0], $_POST['parentID']);
        });
        
        $this->index['POST']->register('formEditor/[digit]/categoryID', function($args) use ($formEditor) {
        	return $formEditor->setCategoryID($args[0], $_POST['categoryID']);
        });

        $this->index['POST']->register('formEditor/[digit]/required', function($args) use ($formEditor) {
        	return $formEditor->setRequired($args[0], $_POST['required']);
        });
        
       	$this->index['POST']->register('formEditor/[digit]/disabled', function($args) use ($formEditor) {
       		return $formEditor->setDisabled($args[0], $_POST['disabled']);
       	});

       	$this->index['POST']->register('formEditor/[digit]/sort', function($args) use ($formEditor) {
       		return $formEditor->setSort($args[0], $_POST['sort']);
       	});

   		$this->index['POST']->register('formEditor/[digit]/html', function($args) use ($formEditor) {
   			return $formEditor->setHtml($args[0], $_POST['html']);
   		});
       	
       	$this->index['POST']->register('formEditor/[digit]/htmlPrint', function($args) use ($formEditor) {
       		return $formEditor->setHtmlPrint($args[0], $_POST['htmlPrint']);
       	});
       			
   		$this->index['POST']->register('formEditor/new', function($args) use ($formEditor) {
   			return $formEditor->createForm($_POST['name'], $_POST['description'], $_POST['parentID']);
   		});

   		$this->index['POST']->register('formEditor/formName', function($args) use ($formEditor) {
   			return $formEditor->setFormName($_POST['categoryID'], $_POST['name']);
   		});

   		$this->index['POST']->register('formEditor/formDescription', function($args) use ($formEditor) {
   			return $formEditor->setFormDescription($_POST['categoryID'], $_POST['description']);
   		});

   		$this->index['POST']->register('formEditor/formWorkflow', function($args) use ($formEditor) {
   			return $formEditor->setFormWorkflow($_POST['categoryID'], $_POST['workflowID']);
   		});
   		
   		$this->index['POST']->register('formEditor/formNeedToKnow', function($args) use ($formEditor) {
   			return $formEditor->setFormNeedToKnow($_POST['categoryID'], $_POST['needToKnow']);
   		});

		$this->index['POST']->register('formEditor/formSort', function($args) use ($formEditor) {
			return $formEditor->setFormSort($_POST['categoryID'], $_POST['sort']);
		});
   		
   		$this->index['POST']->register('formEditor/[text]/privileges', function($args) use ($formEditor) {
   			return $formEditor->setCategoryPrivileges($args[0], $_POST['groupID'], $_POST['read'], $_POST['write']);
   		});

   		$this->index['POST']->register('formEditor/[text]/stapled', function($args) use ($formEditor) {
   			return $formEditor->addStapledCategory($args[0], $_POST['stapledCategoryID']);
   		});

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
    	$formEditor = $this->formEditor;
    	$login = $this->login;

    	$this->verifyAdminReferrer();

    	$this->index['DELETE'] = new ControllerMap();
    	$this->index['DELETE']->register('formEditor', function($args) {
    
    	});

    	$this->index['DELETE']->register('formEditor/[text]/stapled/[text]', function($args) use ($formEditor) {
    		return $formEditor->removeStapledCategory($args[0], $args[1]);
    	});
    	
    	return $this->index['DELETE']->runControl($act['key'], $act['args']);
    }
}

