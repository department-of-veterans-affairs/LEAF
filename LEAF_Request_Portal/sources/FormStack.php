<?php
/************************
    Form Stack
    Date Created: April 2, 2013

*/

class FormStack
{
    private $db;
    private $login;
    private $formEditor;

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function getCategories()
    {
        $res = $this->db->prepared_query("SELECT * FROM categories
                                                WHERE workflowID > 0
                                                    AND parentID = ''
                                                    AND disabled = 0
                                                    AND visible = 1
                                                ORDER BY sort, categoryName ASC", null);
        return $res;
    }

    public function getAllCategories()
    {
    	$res = $this->db->prepared_query("SELECT * FROM categories
    										   LEFT JOIN workflows USING (workflowID)
    	                                       WHERE disabled = 0
                                                ORDER BY sort, categoryName ASC", null);
    	return $res;
    }

    public function deleteForm($categoryID) {
        // make sure the form isn't the target of the stapled form feature
        $vars = array(':categoryID' => $categoryID);
        $res = $this->db->prepared_query('SELECT * FROM category_staples
    										WHERE stapledCategoryID=:categoryID', $vars);
        if(count($res) != 0) {
            return 'Cannot delete forms that have been stapled to another.';
        }

    	$vars = array(':categoryID' => $categoryID);
    	$this->db->prepared_query('UPDATE categories
		    							SET disabled=1
		    							WHERE categoryID=:categoryID', $vars);

    	// "delete" internal use forms
    	$res = $this->db->prepared_query('SELECT * FROM categories
		    								WHERE parentID=:categoryID', $vars);
    	foreach($res as $form) {
    		$this->deleteForm($form['categoryID']);
    	}

    	return true;
    }
    
    private function importIndicator($indicatorPackage, $categoryID, $parentID = null) {
    	$indicatorPackage['categoryID'] = $categoryID;
    	$indicatorPackage['parentID'] = $parentID;

    	if(is_array($indicatorPackage['options'])) {
    		foreach($indicatorPackage['options'] as $option) {
    			$indicatorPackage['format'] .= "\r\n" . $option;
    		}
    	}
    	
    	$indicatorID = $this->formEditor->addIndicator($indicatorPackage);
    	if(is_array($indicatorPackage['child'])) {
    		foreach($indicatorPackage['child'] as $child) {
    			$this->importIndicator($child, $categoryID, $indicatorID);
    		}
    	}
    }
    
    public function initFormEditor() {
    	if(!isset($this->formEditor)) {
    		require_once 'FormEditor.php';
    		$this->formEditor = new FormEditor($this->db, $this->login);
    	}
    }

    public function importForm() {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin access required';
    	}

    	$this->initFormEditor();

    	if(empty($_FILES)
    	 	&& !isset($_FILES['formPacket'])
    		&& !isset($_POST['formPacket'])) {
    	     return 'No files selected';
    	}
    	if(isset($_POST['formPacket'])) {
    		$formPacket = $_POST['formPacket'];
    	}
    	else {
    		$file = file_get_contents($_FILES['formPacket']['tmp_name']);
    		$formPacket = json_decode($file, true);
    	}

    	// cursory format verification
    	if($formPacket['version'] != 1) {
    		return 'File format or version not supported.';
    	}
    	
    	$formName = mb_strimwidth($formPacket['name'], 0, 50, '...');
    	$formCategoryID = $this->formEditor->createForm($formName, $formPacket['description'], '', $_POST['formLibraryID']);

    	foreach($formPacket['packet']['form'] as $indicator) {
    		$this->importIndicator($indicator, $formCategoryID);
    	}

    	foreach($formPacket['packet']['subforms'] as $subform) {
    		$subformCategoryID = $this->formEditor->createForm($subform['name'], $subform['description'], $formCategoryID);
    		
    		foreach($subform['packet'] as $indicator) {
    			$this->importIndicator($indicator, $subformCategoryID);
    		}
    	}
    	
    	return true;
    }
}
