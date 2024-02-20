<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Editor
    Date Created: February 12, 2015

*/

namespace Portal;

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\XSSHelpers;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;

class FormEditor
{
    private $db;

    private $login;

    private $cache = array();

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        if (!$login->checkGroup(1))
        {
            echo 'Admin access required';
            exit();
        }
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    /**
     * @param array $package - Array of input items
     * @param bool $overwriteExisting - If true, matching IDs will be overwritten
     * @return number
     */
    function addIndicator($package, $overwriteExisting = false) {
    	$package['parentID'] = $package['parentID'] == '' ? null : $package['parentID'];

        // update category to reflect modification
        $vars = array(':categoryID' => $package['categoryID'],
            ':time' => time());
        $this->db->prepared_query('UPDATE categories SET lastModified=:time WHERE categoryID=:categoryID', $vars);

        if(!$overwriteExisting)
        {
    	    $vars = array(':name' => $package['name'],
    	        ':format' => $package['format'],
    	        ':description' => $package['description'],
    	        ':default' => $package['default'],
    	        ':parentID' => $package['parentID'],
    	        ':categoryID' => $package['categoryID'],
    	        ':html' => $package['html'],
    	        ':htmlPrint' => $package['htmlPrint'],
                ':conditions' => $package['conditions'],
    	        ':required' => $package['required'],
                ':is_sensitive' => $package['is_sensitive'] ?? 0,
    	        ':sort' => isset($package['sort']) ? $package['sort'] : 1);

    	    $this->db->prepared_query('INSERT INTO indicators (indicatorID, name, format, description, `default`, parentID, categoryID, html, htmlPrint, conditions, required, is_sensitive, sort, timeAdded, disabled)
                                            VALUES (null, :name, :format, :description, :default, :parentID, :categoryID, :html, :htmlPrint, :conditions, :required, :is_sensitive, :sort, CURRENT_TIMESTAMP, 0)', $vars);
    	}
        else
        {
    	    $vars = array(':indicatorID' => $package['indicatorID'],
    	        ':name' => $package['name'],
    	        ':format' => $package['format'],
    	        ':description' => $package['description'],
    	        ':default' => $package['default'],
    	        ':parentID' => $package['parentID'],
    	        ':categoryID' => $package['categoryID'],
    	        ':html' => $package['html'],
    	        ':htmlPrint' => $package['htmlPrint'],
                ':conditions' => $package['conditions'],
    	        ':required' => $package['required'],
    	        ':is_sensitive' => $package['is_sensitive'] ?? 0,
    	        ':sort' => isset($package['sort']) ? $package['sort'] : 1);

    	    $this->db->prepared_query('INSERT INTO indicators (indicatorID, name, format, description, `default`, parentID, categoryID, html, htmlPrint, conditions, required, is_sensitive, sort, timeAdded, disabled)
            								VALUES (:indicatorID, :name, :format, :description, :default, :parentID, :categoryID, :html, :htmlPrint, :conditions, :required, :is_sensitive, :sort, CURRENT_TIMESTAMP, 0)
                                            ON DUPLICATE KEY UPDATE name=:name, format=:format, description=:description, `default`=:default, parentID=:parentID, categoryID=:categoryID, html=:html, htmlPrint=:htmlPrint, conditions=:conditions, required=:required, is_sensitive=:is_sensitive, sort=:sort', $vars);
        }

        $newIndicatorID = $this->db->getLastInsertID();

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::INDICATOR, [
            new LogItem("indicators", "indicatorID", $newIndicatorID),
            new LogItem("indicators", "categoryID", $package['categoryID']),
            new LogItem("indicators", "name", $package['name']),
            new LogItem("indicators", "is_sensitive", $package['is_sensitive'] ?? 0)
        ]);

        return $newIndicatorID;
    }

    public function setName($indicatorID, $name)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':name' => trim($name), );

        $result = $this->db->prepared_query('UPDATE indicators
                    SET name=:name
                    WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "name", $name)
        ]);

        return $result;


    }

    public function setFormat($indicatorID, $format)
    {
        if(strlen($format) > 65535) {
            $result = 'size limit exceeded';

        } else {
            $vars = array(
                ':indicatorID' => $indicatorID,
                ':format' => trim($format),
            );

            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
                new LogItem("indicators", "indicatorID", $indicatorID),
                new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
                new LogItem("indicators", "format", $format)
            ]);

            $result = $this->db->prepared_query('UPDATE indicators
                        SET format=:format
                        WHERE indicatorID=:indicatorID', $vars);
        }
        return $result;
    }

    public function setDescription($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => trim($input), );

        $result =  $this->db->prepared_query('UPDATE indicators
                    SET description=:input
                    WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "description", $input)
        ]);

        return $result;
    }

    public function setDefault($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => trim($input), );

        $result = $this->db->prepared_query('UPDATE indicators
    								SET `default`=:input
                                    WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "default", $input)
        ]);


        return $result;
    }

    public function setParentID($indicatorID, $input)
    {
        if ($input == 0 || $input == '')
        {
            $input = null;
        }

        if ($input == $indicatorID)
        {
            return 'Invalid parentID to be set';
        }

        if ($input != null
            && $this->hasParentIDLoop($input, array((int)$indicatorID => 1)))
        {
            return 'Cannot set parentID. You must first remove the parentID for the sub-question.';
        }

        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => $input, );
        $this->db->prepared_query('UPDATE indicators
    									SET parentID=:input
                                        WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "parentID", $input)
        ]);

    }

    public function setCategoryID($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => $input, );

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators", "categoryID", $input)
        ]);

        return $this->db->prepared_query('UPDATE indicators
    								SET categoryID=:input
                                    WHERE indicatorID=:indicatorID', $vars);
    }

    public function setRequired($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => $input, );

        $result = $this->db->prepared_query('UPDATE indicators
    								SET required=:input
                                    WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "required", $input)
        ]);


        return $result;
    }

    function setSensitive($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
			':input' => (int) $input);

        $result = $this->db->prepared_query('UPDATE indicators
                SET is_sensitive=:input
                WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "is_sensitive", $input)
        ]);

        return $result;
    }

    function setDisabled($indicatorID, $input)
    {

    	if($input == 1) {
            $this->setRequired($indicatorID, 0);
            $this->disableSubindicators($indicatorID);
    	    $disabledTime = 1;
    	}
    	elseif ($input == 2){
    		$this->setRequired($indicatorID, 0);
    		$this->disableSubindicators($indicatorID);
    		$disabledTime = time();
    	} else {
            $disabledTime = 0;
        }

    	$vars = array(':indicatorID' => $indicatorID,
                      ':input' => $disabledTime);

        $result = $this->db->prepared_query('UPDATE indicators
                        SET disabled=:input
                        WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "disabled", $input)
        ]);

    	return $result;
    }

    public function setSort($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':input' => $input, );

        $result = $this->db->prepared_query('UPDATE indicators
    								SET sort=:input
                                    WHERE indicatorID=:indicatorID', $vars);

        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators", "categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "sort", $input)
        ]);


        return $result;
    }

    public function setSortBatch(array $batch): array {
        $updates = array();
        foreach($batch as $item) {
            $this->setSort((int)$item['indicatorID'], (int)$item['sort']);
            $updates[] = array(
                'indicatorID' => (int)$item['indicatorID'],
                'sort' => (int)$item['sort']
            );
        }
        return $updates;
    }

    public function setHtml($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                ':input' => $input, );

        $result = $this->db->prepared_query('UPDATE indicators
    								SET html=:input
                                    WHERE indicatorID=:indicatorID', $vars);
        $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::INDICATOR,[
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators","categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "html", $input)
        ]);


        return $result;
    }

    public function setHtmlPrint($indicatorID, $input)
    {
        $vars = array(':indicatorID' => $indicatorID,
                ':input' => $input, );

        $result =  $this->db->prepared_query('UPDATE indicators
    								SET htmlPrint=:input
                                    WHERE indicatorID=:indicatorID', $vars);
        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::INDICATOR, [
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators", "categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "htmlPrint", $input)
        ]);


        return $result;
    }

    public function setCondition($indicatorID, $input)
    {
        $inputArr = json_decode($input);
        foreach($inputArr as $i=>$inp) {
            $inputArr[$i]->selectedParentValue =  XSSHelpers::sanitizeHTML($inputArr[$i]->selectedParentValue);
            $inputArr[$i]->selectedChildValue =  XSSHelpers::sanitizeHTML($inputArr[$i]->selectedChildValue);
        }
        if ($inputArr !== null) $inputArr = json_encode($inputArr);

        $vars = array(
            ':indicatorID' => $indicatorID,
            ':input' => $inputArr
        );

        $result =  $this->db->prepared_query('UPDATE indicators
    								SET conditions=:input
                                    WHERE indicatorID=:indicatorID', $vars);
        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::INDICATOR, [
            new LogItem("indicators", "indicatorID", $indicatorID),
            new LogItem("indicators", "categoryID", $this->getCategoryID($indicatorID)),
            new LogItem("indicators", "conditions", $input)
        ]);

        return $result;
    }

    /**
     * @param string $name
     * @param string $description
     * @param string $formLibraryID
     * @param string $categoryID - Optional. If specified, existing data matching the ID will be overwritten
     * @param string $workflowID
     * @return string
     */
    public function createForm($name, $description, $parentID = '', $formLibraryID = null, $categoryID = null, $workflowID = 0)
    {
        $name = trim($name);
        if ($categoryID == null)
        {
            $categoryID = 'form_' . substr(sha1($name . random_int(1, 9999999)), 0, 5);
        }
        if ($workflowID == null)
        {
            $workflowID = 0;
        }

        $vars = array(':name' => $name,
                      ':description' => $description,
                      ':parentID' => $parentID,
                      ':categoryID' => $categoryID,
                      ':workflowID' => $workflowID,
                      ':formLibraryID' => $formLibraryID,
                      ':lastModified' => time()
        );
        $this->db->prepared_query('INSERT INTO categories (categoryID, parentID, categoryName, categoryDescription, workflowID, formLibraryID, lastModified)
    									VALUES (:categoryID, :parentID, :name, :description, :workflowID, :formLibraryID, :lastModified)
                                        ON DUPLICATE KEY UPDATE categoryName=:name, categoryDescription=:description, workflowID=:workflowID, lastModified=:lastModified, disabled=0', $vars);

        $this->dataActionLogger->logAction(DataActions::ADD, LoggableTypes::FORM, [
            new LogItem("categories", "categoryID", $categoryID),
            new LogItem("categories", "parentID", $parentID),
            new LogItem("categories", "categoryName", $name),
            new LogItem("categories", "categoryDescription", $description),
            new LogItem("categories", "workflowID", $workflowID),
            new LogItem("categories", "formLibraryID", $formLibraryID)
        ]);

        // need to know enabled by default if leaf secure is active
        $res = $this->db->query('SELECT * FROM settings WHERE setting="leafSecure" AND data>=1');
        if(count($res) > 0) {
            $vars = array(':categoryID' => $categoryID);
            $this->db->prepared_query('UPDATE categories
                                        SET needToKnow=1
                                        WHERE categoryID=:categoryID', $vars);
        }

        return $categoryID;
    }

    public function setFormName($categoryID, $input)
    {
        $vars = array(':categoryID' => $categoryID,
                      ':input' => $input, );

        $result =  $this->db->prepared_query('UPDATE categories
    								SET categoryName=:input
                                    WHERE categoryID=:categoryID', $vars);

        if(isset($input)){
            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                new LogItem("categories", "categoryID", $categoryID),
                new LogItem("categories", "categoryName", $input)
            ]);
        }


        return $result;
    }

    public function setFormDescription($categoryID, $input)
    {
        $vars = array(':categoryID' => $categoryID,
                      ':input' => $input, );

        $result = $this->db->prepared_query('UPDATE categories
    								SET categoryDescription=:input
                                    WHERE categoryID=:categoryID', $vars);

        if(isset($input)){
            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                new LogItem("categories", "categoryID", $categoryID),
                new LogItem("categories", "categoryDescription", $input)
            ]);
        }


        return $result;
    }

    public function setFormWorkflow($categoryID, $input)
    {
        // don't allow standardized workflows to be set by the user
        if($input < 0) {
            return false;
        }

        // don't allow a workflow to be set if it's a stapled form
        $vars = array(':categoryID' => $categoryID);
        $res = $this->db->prepared_query('SELECT * FROM category_staples
    										WHERE stapledCategoryID=:categoryID', $vars);
        if (count($res) == 0)
        {
            $vars = array(':categoryID' => $categoryID,
                          ':input' => $input, );
            $this->db->prepared_query('UPDATE categories
		    								SET workflowID=:input
		    								WHERE categoryID=:categoryID', $vars);

            if(isset($input)){
                $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                    new LogItem("categories", "categoryID", $categoryID),
                    new LogItem("categories", "workflowID", $input)
                ]);
            }

            return 1;
        }

        return false;
    }

    public function setFormNeedToKnow($categoryID, $input)
    {
        $vars = array(':categoryID' => $categoryID,
                      ':input' => $input, );

        $response = $this->db->prepared_query('UPDATE categories
                        SET needToKnow=:input
                        WHERE categoryID=:categoryID', $vars);

        if(isset($input)){
            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                new LogItem("categories", "categoryID", $categoryID),
                new LogItem("categories", "needToKnow", $input)
            ]);
        }


        return $response;
    }

    public function setFormSort($categoryID, $input)
    {
        $vars = array(':categoryID' => $categoryID,
                      ':input' => $input, );

        $result =  $this->db->prepared_query('UPDATE categories
    								SET sort=:input
                                    WHERE categoryID=:categoryID', $vars);

        if(isset($input)){
            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                new LogItem("categories", "categoryID", $categoryID),
                new LogItem("categories", "sort", $input)
            ]);
        }


        return $result;
    }

    public function setFormVisible($categoryID, $input)
    {
        $vars = array(':categoryID' => $categoryID,
            ':input' => $input, );

        $result = $this->db->prepared_query('UPDATE categories
    								SET visible=:input
                                    WHERE categoryID=:categoryID', $vars);

        if(isset($input)){
            $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                new LogItem("categories", "categoryID", $categoryID),
                new LogItem("categories", "visible", $input)
            ]);
        }


        return $result;
    }

    public function setFormType($categoryID, $input){

        $vars = array(':categoryID' => $categoryID,
            ':input' => $input );

        $result = $this->db->prepared_query('UPDATE categories
                    SET type=:input
                    WHERE categoryID=:categoryID', $vars);

        $display = empty($input) ? "standard" : $input;

        $this->dataActionLogger->logAction(DataActions::MODIFY, LoggableTypes::FORM, [
            new LogItem("categories", "categoryID", $categoryID),
            new LogItem("categories", "type", $input, $display)
        ]);

        return $result;
    }

    /**
     * Create age (days) for destruction records
     *
     * @param string $categoryID - category having its destructionAge set
     * @param int|null $input - number of days to mark a record for destruction
     *
     * @return array
     */
    public function setFormDestructionAge(string $categoryID, int $input = null): array {
        if (!$this->login->checkGroup(1))
        {
            $return_value['status']['code'] = 4;
            $return_value['status']['message'] = "Admin access required";
        }

        if ($input === 0 || $input === null) {
            $input = null;
            $vars = array(':categoryID' => $categoryID, ':input' => $input);
            $strSQL = 'UPDATE categories SET destructionAge=:input WHERE categoryID=:categoryID';
            $return_value = $this->db->pdo_insert_query($strSQL, $vars);

            if($return_value['status']['code'] == 2){
                $return_value['data'] = $input;
                $this->dataActionLogger->logAction(\Leaf\DataActions::MODIFY,\Leaf\LoggableTypes::FORM,[
                    new \Leaf\LogItem("categories", "categoryID", $categoryID),
                    new \Leaf\LogItem("categories", "destructionAge", 'never')
                ]);
            }
        } else {
            $input = $input * 365;
            $vars = array(':categoryID' => $categoryID, ':input' => $input);
            $strSQL = 'UPDATE categories SET destructionAge=:input WHERE categoryID=:categoryID';
            $return_value = $this->db->pdo_insert_query($strSQL, $vars);

            if($return_value['status']['code'] == 2){
                $return_value['data'] = $input;
                if(!empty($input)) {
                    $this->dataActionLogger->logAction(DataActions::MODIFY,LoggableTypes::FORM,[
                        new LogItem("categories", "categoryID", $categoryID),
                        new LogItem("categories", "destructionAge", $input." days")
                    ]);
                }
            }
        }

        return $return_value;
    }

    /**
     * Get flag (days) for destruction records
     *
     * @param string $categoryID - category we are getting destructionAge for
     *
     * @return array
     */
    public function getDestructionAge(string $categoryID): array
    {
        $return_value['status']['code'] = 4;
        $return_value['status']['message'] = "Error";
        if ($categoryID) {
            $vars = array(':categoryID' => $categoryID);
            $strSQL = 'SELECT destructionAge FROM categories WHERE categoryID=:categoryID';
            $res = $this->db->prepared_query($strSQL, $vars);

            if (count($res) > 0) {
                $return_value['status']['code'] = 2;
                $return_value['status']['message'] = "Success";
                $return_value['data'] = $res[0]['destructionAge'];
            }
        }

        return $return_value;
    }

    public function getCategoryPrivileges($categoryID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin Only';
        }

        $vars = array(':categoryID' => $categoryID);

        return $this->db->prepared_query('SELECT * FROM category_privs
    										LEFT JOIN `groups` USING (groupID)
    										WHERE categoryID=:categoryID', $vars);
    }

    public function setCategoryPrivileges($categoryID, $groupID, $read, $write)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin Only';
        }

        if ($write == 0)
        {
            $vars = array(':categoryID' => $categoryID,
                    ':groupID' => $groupID,
            );
            $this->db->prepared_query('DELETE FROM category_privs WHERE categoryID=:categoryID AND groupID=:groupID', $vars);
        }
        else
        {
            $vars = array(':categoryID' => $categoryID,
                    ':groupID' => $groupID,
                    ':read' => $read,
                    ':write' => $write,
            );
            $this->db->prepared_query('INSERT INTO category_privs (categoryID, groupID, readable, writable)
    									VALUES (:categoryID, :groupID, :read, :write)', $vars);
        }
    }

    public function getStapledCategories($categoryID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin Only';
        }

        $vars = array(':categoryID' => $categoryID);

        return $this->db->prepared_query('SELECT * FROM category_staples
    										LEFT JOIN categories ON (category_staples.stapledCategoryID = categories.categoryID)
    										WHERE category_staples.categoryID=:categoryID
    											AND categories.disabled=0', $vars);
    }

    public function addStapledCategory($categoryID, $stapledCategoryID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin Only';
        }

        // don't allow the form to be merged if it's already the subject of another merge
        $vars = array(':categoryID' => $categoryID);
        $res = $this->db->prepared_query('SELECT * FROM category_staples
    										WHERE stapledCategoryID=:categoryID', $vars);
        if (count($res) == 0)
        {
            $vars = array(':categoryID' => $categoryID,
                    ':stapledCategoryID' => $stapledCategoryID,
            );
            $this->db->prepared_query('INSERT INTO category_staples (categoryID, stapledCategoryID)
    										VALUES (:categoryID, :stapledCategoryID)', $vars);

            return 1;
        }

        return 'Cannot merge forms when this form is the subject of another merged form.';
    }

    public function removeStapledCategory($categoryID, $stapledCategoryID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin Only';
        }

        $vars = array(':categoryID' => $categoryID,
                      ':stapledCategoryID' => $stapledCategoryID,
        );

        $this->db->prepared_query('DELETE FROM category_staples
    									WHERE categoryID=:categoryID
    										AND stapledCategoryID=:stapledCategoryID', $vars);

        return 1;
    }

    /**
     * Get the access privileges for a given indicator.
     *
     * @param int $indcatorID	the id of the indicator to retrieve privileges for
     *
     * @return array an array containing the ids of groups that have access to the indicator
     */
    public function getIndicatorPrivileges($indicatorID)
    {
        if (isset($this->cache["indicatorPrivileges_{$indicatorID}"]))
        {
            return $this->cache["indicatorPrivileges_{$indicatorID}"];
        }

        $res = $this->db->prepared_query(
            'SELECT indicator_mask.groupID, `groups`.name AS groupName
				FROM indicator_mask
				LEFT JOIN `groups` ON (`groups`.groupID = indicator_mask.groupID)
				WHERE indicator_mask.indicatorID = :indicatorID ORDER BY indicator_mask.groupID ASC',
            array(':indicatorID' => $indicatorID)
        );

        $groups = array();

        foreach ($res as $group)
        {
            array_push($groups, array(
                'id' => (int)$group['groupID'],
                'name' => $group['groupName'],
            ));
        }

        $this->cache["indicatorPrivileges_{$indicatorID}"] = $groups;

        return $groups;
    }

    /**
     * Set the access privileges for a given indicator
     *
     * @param int	$indicatorID	the id of the indicator to set privileges for
     * @param array	$groupIDs		an array of integer group ids to allow access
     *
     * @return bool if setting privileges was successful
     */
    public function setIndicatorPrivileges($indicatorID, $groupIDs)
    {
        if (!is_array($groupIDs))
        {
            return false;
        }

        $q = 'REPLACE INTO indicator_mask (indicatorID, groupID) VALUES ';
        $vars = array(':indicatorID' => (int)$indicatorID);
        foreach ($groupIDs as $key => $val)
        {
            if ($key !== 0)
            {
                $q = $q . ',';
            }

            $var = ':group' . $key;
            $vars[$var] = $val;
            $q = $q . '(:indicatorID, ' . $var . ')';
        }

        $q = $q . ';';

        $res = $this->db->prepared_query($q, $vars);

        unset($this->cache["indicatorPrivileges_{$indicatorID}"]);

        // return if any errors occurred
        return is_array($res) && count($res) == 0;
    }

    /**
     * Remove an access privilege for the given indicator and group ID
     *
     * @param int $indicatorID 	the id of the indicator to remove access for
     * @param int $groupID 		the id of the group to remove access for
     *
     * @return bool if removal was successful
     */
    public function removeIndicatorPrivilege($indicatorID, $groupID)
    {
        $q = 'DELETE FROM indicator_mask WHERE indicatorID = :indicatorID AND groupID = :groupID';
        $res = $this->db->prepared_query(
            $q,
            array(
                ':indicatorID' => (int)$indicatorID,
                ':groupID' => (int)$groupID,
            )
        );

        unset($this->cache["indicatorPrivileges_{$indicatorID}"]);

        // return if row was deleted
        return is_int($res) && (int)$res == 1;
    }

    private function hasParentIDLoop($indicatorID, $cache = array())
    {
        if (isset($cache[$indicatorID]))
        {
            return true;
        }

        $vars = array(':indicatorID' => $indicatorID);
        $res = $this->db->prepared_query('SELECT * FROM indicators
    										WHERE indicatorID=:indicatorID', $vars);
        if ($res[0]['parentID'] != null)
        {
            $cache[$indicatorID] = 1;

            return $this->hasParentIDLoop($res[0]['parentID'], $cache);
        }

        return false;
    }

    private function disableSubindicators($indicatorID)
    {
        $vars = array(':indicatorID' => $indicatorID);
        $res = $this->db->prepared_query('SELECT * FROM indicators
    										WHERE parentID=:indicatorID', $vars);

        foreach ($res as $item)
        {
            $this->setDisabled($item['indicatorID'], 1);
        }
    }

    /**
     * Gets category Id for given indicatorID.
     * @param int $indicatorID 	the id of the indicator to find categoryID of
     * @return string
     */
    private function getCategoryID($indicatorID)
    {
        $vars = array(':indicatorID' => $indicatorID);
        return $this->db->prepared_query('SELECT * FROM indicators
                                            WHERE indicatorID=:indicatorID', $vars)[0]['categoryID'];
    }

    public function getFormName($categoryID){
        $vars = array(':categoryID' => $categoryID);

        return $this->db->prepared_query('SELECT * FROM categories
    										WHERE categoryID=:categoryID', $vars)[0]['categoryName'];
    }

    /**
     *
     * @param string|null $filterById
     *
     * @return array
     *
     * Created at: 12/5/2022, 10:45:38 AM (America/New_York)
     */
    public function getHistory(?string $filterById): array
    {
        return $this->dataActionLogger->getHistory($filterById, "categoryID", LoggableTypes::FORM);
    }
}
