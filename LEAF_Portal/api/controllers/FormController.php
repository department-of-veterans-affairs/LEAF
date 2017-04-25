<?php

require '../form.php';

class FormController extends RESTfulResponse
{
    private $API_VERSION = 1;    // Integer
    public $index = array();

    private $form;
    private $login;

    function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('form/version', function() {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('form', function($args) use ($form) {

        });

        // form/customData/ recordID list (csv) / indicatorID list (csv)
        $this->index['GET']->register('form/customData/[text]/[text]', function($args) use ($form) {
        	$recordIDs = array();
        	$args[0] = trim($args[0], ',');
        	$tempRecordIDs = explode(',', $args[0]);
        	foreach($tempRecordIDs as $id) {
        		if(!is_numeric($id)) {
        			return false;
        		}
        		$recordIDs[$id]['recordID'] = $id;
        	}
       		return $form->getCustomData($recordIDs, $args[1]);
       	});

        // takes json encoded pairs [{id, operator, match}]
        $this->index['GET']->register('form/query', function($args) use ($form) {
        	if(isset($_GET['debug'])) {
        		return $query = json_decode(html_entity_decode(html_entity_decode($_GET['q'])), true);
        	}
        	return $form->query($_GET['q']);
        });

       	$this->index['GET']->register('form/search/indicator/[digit]', function($args) use ($form) {
            $query = '{"terms":[{"id":"data","indicatorID":"'. $args[0] .'","operator":"=","match":"'. $_GET['q'] .'"}]}';
        	return $form->query($query);
       	});

		$this->index['GET']->register('form/search/submitter/[text]', function($args) use ($form) {
            $query = '{"terms":[{"id":"userID","operator":"=","match":"'. $args[0] .'"}]}';
        	return $form->query($query);
		});

		$this->index['GET']->register('form/[digit]', function($args) use ($form) {
			return $form->getForm($args[0]);
		});

		$this->index['GET']->register('form/[digit]/data', function($args) use ($form) {
			return $form->getFullFormData($args[0]);
		});

		$this->index['GET']->register('form/[digit]/progress', function($args) use ($form) {
			return $form->getProgress($args[0]);
		});

		$this->index['GET']->register('form/[digit]/tags', function($args) use ($form) {
			return $form->getTags($args[0]);
		});

		$this->index['GET']->register('form/[digit]/rawIndicator/[digit]/[digit]', function($args) use ($form) {
			return $form->getIndicator($args[1], $args[2], $args[0]);
		});

		$this->index['GET']->register('form/[digit]/[digit]/[digit]/history', function($args) use ($form) {
			return $form->getIndicatorLog($args[1], $args[2], $args[0]);
		});

		$this->index['GET']->register('form/indicator/list', function($args) use ($form) {
			return $form->getIndicatorList();
		});
		
		$this->index['GET']->register('form/indicator/list/disabled', function($args) use ($form) {
			return $form->getDisabledIndicatorList(1);
		});

		$this->index['GET']->register('form/[text]', function($args) use ($form) {
			return $form->getFormByCategory($args[0]);
		});

		$this->index['GET']->register('form/[text]/flat', function($args) use ($form) {
			$out = [];
			$data = $form->getFormByCategory($args[0]);
			$form->flattenFullFormData($data, $out);
			ksort($out);
			return $out;
		});

		$this->index['GET']->register('form/[text]/export', function($args) use ($form) {
			return $form->getFormByCategory($args[0], false);
		});

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $form = $this->form;
        $login = $this->login;

        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('form', function($args) {
            
        });
        
        // Expects POST input: $_POST['service'], title, priority, num(categoryID), CSRFToken
        $this->index['POST']->register('form/new', function($args) use ($form, $login) {
            return $form->newForm($login->getUserID());
        });

        $this->index['POST']->register('form/[digit]', function($args) use ($form) {
            return $form->doModify($args[0]);
        });

        $this->index['POST']->register('form/[digit]/submit', function($args) use ($form) {
        	return $form->doSubmit($args[0]);
        });

       	$this->index['POST']->register('form/[digit]/title', function($args) use ($form) {
       		return $form->setTitle($args[0], $_POST['title']);
       	});

    	$this->index['POST']->register('form/[digit]/service', function($args) use ($form) {
       		return $form->setService($args[0], $_POST['serviceID']);
       	});

   		$this->index['POST']->register('form/[digit]/initiator', function($args) use ($form) {
   			return $form->setInitiator($args[0], $_POST['initiator']);
   		});

   		$this->index['POST']->register('form/[digit]/types', function($args) use ($form) {
   			return $form->changeFormType($args[0], $_POST['categories']);
   		});

     	// form/customData/ recordID list (csv) / indicatorID list (csv)
   		$this->index['POST']->register('form/customData', function($args) use ($form) {
 			$recordIDs = array();
       		$_POST['recordList'] = trim($_POST['recordList'], ',');
       		$tempRecordIDs = explode(',', $_POST['recordList']);
       		foreach($tempRecordIDs as $id) {
       			if(!is_numeric($id)) {
       				return false;
       			}
       			$recordIDs[$id]['recordID'] = $id;
       		}
       		return $form->getCustomData($recordIDs, $_POST['indicatorList']);
       	});

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}

