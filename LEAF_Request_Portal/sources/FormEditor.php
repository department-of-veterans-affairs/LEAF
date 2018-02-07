<?php
/************************
    Form Editor
    Date Created: February 12, 2015

*/

class FormEditor
{
    private $db;
    private $login;

    function __construct($db, $login)
    {
    	if(!$login->checkGroup(1)) {
    		echo 'Admin access required';
    		exit();
    	}
        $this->db = $db;
        $this->login = $login;
    }


    /**
     * @param array $package - Array of input items
     * @param bool $overwriteExisting - If true, matching IDs will be overwritten
     * @return number
     */
    function addIndicator($package, $overwriteExisting = false) {
    	$package['parentID'] = $package['parentID'] == '' ? null : $package['parentID'];

    	if(!$overwriteExisting) {
    	    $vars = array(':name' => $package['name'],
    	        ':format' => $package['format'],
    	        ':description' => $package['description'],
    	        ':default' => $package['default'],
    	        ':parentID' => $package['parentID'],
    	        ':categoryID' => $package['categoryID'],
    	        ':html' => $package['html'],
    	        ':htmlPrint' => $package['htmlPrint'],
    	        ':required' => $package['required'],
    	        ':sort' => isset($package['sort']) ? $package['sort'] : 1);

    	    $this->db->prepared_query('INSERT INTO indicators (indicatorID, name, format, description, `default`, parentID, categoryID, html, htmlPrint, required, sort, timeAdded, disabled)
            								VALUES (null, :name, :format, :description, :default, :parentID, :categoryID, :html, :htmlPrint, :required, :sort, CURRENT_TIMESTAMP, 0)', $vars);
    	}
    	else {
    	    $vars = array(':indicatorID' => $package['indicatorID'],
    	        ':name' => $package['name'],
    	        ':format' => $package['format'],
    	        ':description' => $package['description'],
    	        ':default' => $package['default'],
    	        ':parentID' => $package['parentID'],
    	        ':categoryID' => $package['categoryID'],
    	        ':html' => $package['html'],
    	        ':htmlPrint' => $package['htmlPrint'],
    	        ':required' => $package['required'],
    	        ':sort' => isset($package['sort']) ? $package['sort'] : 1);

    	    $this->db->prepared_query('INSERT INTO indicators (indicatorID, name, format, description, `default`, parentID, categoryID, html, htmlPrint, required, sort, timeAdded, disabled)
            								VALUES (:indicatorID, :name, :format, :description, :default, :parentID, :categoryID, :html, :htmlPrint, :required, :sort, CURRENT_TIMESTAMP, 0)
                                            ON DUPLICATE KEY UPDATE name=:name, format=:format, description=:description, `default`=:default, parentID=:parentID, categoryID=:categoryID, html=:html, htmlPrint=:htmlPrint, required=:required, sort=:sort', $vars);
    	}

    	return $this->db->getLastInsertID();
    }


    function setName($indicatorID, $name) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':name' => $name);
    	return $this->db->prepared_query('UPDATE indicators
    								SET name=:name
    								WHERE indicatorID=:indicatorID', $vars);
    }

    function setFormat($indicatorID, $format) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':format' => trim($format));
    	return $this->db->prepared_query('UPDATE indicators
    								SET format=:format
    								WHERE indicatorID=:indicatorID', $vars);
    }

    function setDescription($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET description=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }

    function setDefault($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => trim($input));
    	return $this->db->prepared_query('UPDATE indicators
    								SET `default`=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }

    private function hasParentIDLoop($indicatorID, $cache = []) {
    	if(isset($cache[$indicatorID])) {
    		return true;
    	}
    	
    	$vars = array(':indicatorID' => $indicatorID);
    	$res = $this->db->prepared_query('SELECT * FROM indicators
    										WHERE indicatorID=:indicatorID', $vars);
    	if($res[0]['parentID'] != null) {
    		$cache[$indicatorID] = 1;
    		return $this->hasParentIDLoop($res[0]['parentID'], $cache);
    	}

    	return false;
    }

    function setParentID($indicatorID, $input) {
        if($input == 0 || $input == '') {
            $input = null;
        }
        
        if($input == $indicatorID) {
        	return 'Invalid parentID to be set';
        }

		if($input != null
			&& $this->hasParentIDLoop($input, array((int)$indicatorID => 1))) {
			return 'Cannot set parentID. You must first remove the parentID for the sub-question.';
		}

    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $input);
    	$this->db->prepared_query('UPDATE indicators
    									SET parentID=:input
    									WHERE indicatorID=:indicatorID', $vars);
    	return null;
    }

    function setCategoryID($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET categoryID=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }

    function setRequired($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET required=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }
    
    private function disableSubindicators($indicatorID) {
    	$vars = array(':indicatorID' => $indicatorID);
    	$res = $this->db->prepared_query('SELECT * FROM indicators
    										WHERE parentID=:indicatorID', $vars);
    	
    	foreach($res as $item) {
    		$this->setDisabled($item['indicatorID'], 1);
    	}
    }
    
    function setDisabled($indicatorID, $input) {
    	$disabledTime = 0;
    	if($input >= 1) {
    		$this->setRequired($indicatorID, 0);
    		$this->disableSubindicators($indicatorID);
    		$disabledTime = time();
    	}
    	
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $disabledTime);
    	return $this->db->prepared_query('UPDATE indicators
    								SET disabled=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }
    
    function setSort($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET sort=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }
    
    function setHtml($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    			':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET html=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }
    
    function setHtmlPrint($indicatorID, $input) {
    	$vars = array(':indicatorID' => $indicatorID,
    			':input' => $input);
    	return $this->db->prepared_query('UPDATE indicators
    								SET htmlPrint=:input
    								WHERE indicatorID=:indicatorID', $vars);
    }

    /**
     * @param string $name
     * @param string $description
     * @param string $formLibraryID
     * @param string $categoryID - Optional. If specified, existing data matching the ID will be overwritten
     * @param string $workflowID
     * @return string
     */
    function createForm($name, $description, $parentID = '', $formLibraryID = null, $categoryID = null, $workflowID = 0) {
    	$name = trim($name);
    	if($categoryID == null) {
    	    $categoryID = 'form_' . substr(sha1($name . random_int(1, 9999999)), 0, 5);
    	}
    	if($workflowID == null) {
    	    $workflowID = 0;
    	}
    	
    	$vars = array(':name' => $name,
    				  ':description' => $description,
    			      ':parentID' => $parentID,
    			      ':categoryID' => $categoryID,
    			      ':workflowID' => $workflowID,
    				  ':formLibraryID' => $formLibraryID
    	);
    	$this->db->prepared_query('INSERT INTO categories (categoryID, parentID, categoryName, categoryDescription, workflowID, formLibraryID)
    									VALUES (:categoryID, :parentID, :name, :description, :workflowID, :formLibraryID)
                                        ON DUPLICATE KEY UPDATE categoryName=:name, categoryDescription=:description, workflowID=:workflowID, disabled=0', $vars);
    	return $categoryID;
    }

    function setFormName($categoryID, $input) {
    	$vars = array(':categoryID' => $categoryID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE categories
    								SET categoryName=:input
    								WHERE categoryID=:categoryID', $vars);
    }

    function setFormDescription($categoryID, $input) {
    	$vars = array(':categoryID' => $categoryID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE categories
    								SET categoryDescription=:input
    								WHERE categoryID=:categoryID', $vars);
    }

    function setFormWorkflow($categoryID, $input) {
    	
    	// don't allow a workflow to be set if it's a stapled form
    	$vars = array(':categoryID' => $categoryID);
    	$res = $this->db->prepared_query('SELECT * FROM category_staples
    										WHERE stapledCategoryID=:categoryID', $vars);
    	if(count($res) == 0) {
    		$vars = array(':categoryID' => $categoryID,
    					  ':input' => $input);
    		$this->db->prepared_query('UPDATE categories
		    								SET workflowID=:input
		    								WHERE categoryID=:categoryID', $vars);
    		return 1;
    	}
    	return false;
    }
    
    function setFormNeedToKnow($categoryID, $input) {
    	$vars = array(':categoryID' => $categoryID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE categories
    								SET needToKnow=:input
    								WHERE categoryID=:categoryID', $vars);
    }

    function setFormSort($categoryID, $input) {
    	$vars = array(':categoryID' => $categoryID,
    				  ':input' => $input);
    	return $this->db->prepared_query('UPDATE categories
    								SET sort=:input
    								WHERE categoryID=:categoryID', $vars);
    }

    function setFormVisible($categoryID, $input) {
        $vars = array(':categoryID' => $categoryID,
            ':input' => $input);
        return $this->db->prepared_query('UPDATE categories
    								SET visible=:input
    								WHERE categoryID=:categoryID', $vars);
    }

    function getCategoryPrivileges($categoryID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin Only';
    	}

    	$vars = array(':categoryID' => $categoryID);
    	return $this->db->prepared_query('SELECT * FROM category_privs
    										LEFT JOIN groups USING (groupID)
    										WHERE categoryID=:categoryID', $vars);
    }

    function setCategoryPrivileges($categoryID, $groupID, $read, $write) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin Only';
    	}
    
    	if($write == 0) {
    		$vars = array(':categoryID' => $categoryID,
    				':groupID' => $groupID
    		);
    		$this->db->prepared_query('DELETE FROM category_privs WHERE categoryID=:categoryID AND groupID=:groupID', $vars);
    	}
		else {
			$vars = array(':categoryID' => $categoryID,
					':groupID' => $groupID,
					':read' => $read,
					':write' => $write,
			);
			$this->db->prepared_query('INSERT INTO category_privs (categoryID, groupID, readable, writable)
    									VALUES (:categoryID, :groupID, :read, :write)', $vars);
		}
    }

    function getStapledCategories($categoryID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin Only';
    	}
    
    	$vars = array(':categoryID' => $categoryID);
    	return $this->db->prepared_query('SELECT * FROM category_staples
    										LEFT JOIN categories ON (category_staples.stapledCategoryID = categories.categoryID)
    										WHERE category_staples.categoryID=:categoryID
    											AND categories.disabled=0', $vars);
    }

    function addStapledCategory($categoryID, $stapledCategoryID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin Only';
    	}

    	// don't allow the form to be merged if it's already the subject of another merge
    	$vars = array(':categoryID' => $categoryID);
    	$res = $this->db->prepared_query('SELECT * FROM category_staples
    										WHERE stapledCategoryID=:categoryID', $vars);
    	if(count($res) == 0) {
    		$vars = array(':categoryID' => $categoryID,
    				':stapledCategoryID' => $stapledCategoryID
    		);
    		$this->db->prepared_query('INSERT INTO category_staples (categoryID, stapledCategoryID)
    										VALUES (:categoryID, :stapledCategoryID)', $vars);
    		return 1;
    	}

    	return 'Cannot merge forms when this form is the subject of another merged form.';
    }

    function removeStapledCategory($categoryID, $stapledCategoryID) {
    	if(!$this->login->checkGroup(1)) {
    		return 'Admin Only';
    	}
    
    	$vars = array(':categoryID' => $categoryID,
    				  ':stapledCategoryID' => $stapledCategoryID
    	);

    	$this->db->prepared_query('DELETE FROM category_staples
    									WHERE categoryID=:categoryID
    										AND stapledCategoryID=:stapledCategoryID', $vars);
    	return 1;
    }
}
