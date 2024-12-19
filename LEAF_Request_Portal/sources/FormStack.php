<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Stack
    Date Created: April 2, 2013

*/

namespace Portal;

class FormStack
{
    private $db;

    private $login;

    private $formEditor;

    public function __construct($db, $login)
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
        $res = $this->db->prepared_query('SELECT * FROM categories
    										   LEFT JOIN workflows USING (workflowID)
    	                                       WHERE disabled = 0
                                                AND workflowID >= 0
                                                ORDER BY sort, categoryName ASC', null);

        return $res;
    }

    public function getAllCategoriesWithStaples() {
        $strSQL = "SELECT categories.categoryID, parentID, categoryName, categoryDescription, categories.workflowID,
            sort, needToKnow, formLibraryID, visible, categories.disabled, categories.type, destructionAge,
            workflows.description AS workflowDescription FROM categories
            LEFT JOIN workflows ON categories.workflowID=workflows.workflowID
            WHERE categories.workflowID >= 0 AND categories.disabled = 0
            ORDER BY sort, categoryName ASC";

        $res = $this->db->prepared_query($strSQL, null);

        foreach($res as $ind => $val) {
            $res[$ind]['stapledFormIDs'] = [];
            //internal forms have a parentID.  They cannot have staples by normal means so don't query.
            if (empty($val['parendID'])) {
                $vars = array(':categoryID' => $val['categoryID']);
                $strStaples = "SELECT stapledCategoryID FROM category_staples
                    WHERE categoryID=:categoryID AND stapledCategoryID !=''";
                $resStaples = $this->db->prepared_query($strStaples, $vars) ?? [];

                $res[$ind]['stapledFormIDs'] = array_column($resStaples,'stapledCategoryID');
            }
        }
        return $res;
    }

    public function deleteForm($categoryID)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        // make sure the form isn't the target of the stapled form feature
        $vars = array(':categoryID' => $categoryID);
        $res = $this->db->prepared_query('SELECT * FROM category_staples
                                            LEFT JOIN categories USING (categoryID)
    										WHERE stapledCategoryID=:categoryID
                                                AND disabled=0', $vars);
        if (count($res) != 0)
        {
            return 'Cannot delete forms that have been stapled to another.';
        }

        $vars = array(':categoryID' => $categoryID);
        $this->db->prepared_query('UPDATE categories
		    							SET disabled=1, needToKnow=1
		    							WHERE categoryID=:categoryID', $vars);

        // "delete" internal use forms
        $res = $this->db->prepared_query('SELECT * FROM categories
		    								WHERE parentID=:categoryID', $vars);
        foreach ($res as $form)
        {
            $this->deleteForm($form['categoryID']);
        }

        return true;
    }

    public function initFormEditor()
    {
        if (!isset($this->formEditor))
        {
            $this->formEditor = new FormEditor($this->db, $this->login);
        }
    }

    /**
     * @param string $overwiteExisting - If specified, matching IDs will be overwritten.
     *                             This should only be used with centrally standardized forms
     * @return string/bool
     */
    public function importForm($overwiteExisting = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $this->initFormEditor();

        if (empty($_FILES)
            && !isset($_FILES['formPacket'])
            && !isset($_POST['formPacket']))
        {
            return 'No files selected';
        }
        if (isset($_POST['formPacket']))
        {
            $formPacket = json_decode($_POST['formPacket'], true);
        }
        else
        {
            $file = file_get_contents($_FILES['formPacket']['tmp_name']);
            $formPacket = json_decode($file, true);
        }

        $categoryID = null;
        if ($overwiteExisting)
        {
            if ($formPacket['packet']['categoryID'] == '')
            {
                return 'Missing form ID';
            }
            $categoryID = $formPacket['packet']['categoryID'];
            $workflowID = isset($formPacket['packet']['workflowID']) ? $formPacket['packet']['workflowID'] : 0;
        }

        // cursory format verification
        if ($formPacket['version'] != 1)
        {
            return 'File format or version not supported.';
        }

        $formName = mb_strimwidth($formPacket['name'], 0, 50, '...');
        $formCategoryID = $this->formEditor->createForm($formName, $formPacket['description'], '', (int)$_POST['formLibraryID'], $categoryID, $workflowID);

        $formIndicatorsAdded = array();
        foreach ($formPacket['packet']['form'] as $indicator)
        {
            $formIndicatorsAdded = $this->importIndicator($indicator, $formCategoryID, null, $overwiteExisting, $formIndicatorsAdded);
        }

        foreach ($formPacket['packet']['subforms'] as $key => $subform)
        {
            $subformCategoryID = null;
            if ($overwiteExisting)
            {
                $subformCategoryID = $key;
            }
            $subformCategoryID = $this->formEditor->createForm($subform['name'], $subform['description'], $formCategoryID, null, $subformCategoryID);

            foreach ($subform['packet'] as $indicator)
            {
                $formIndicatorsAdded = $this->importIndicator($indicator, $subformCategoryID, null, $overwiteExisting, $formIndicatorsAdded);
            }
        }

        $this->updateConditionRelations($formIndicatorsAdded);
        return $formCategoryID;
    }

    private function importIndicator($indicatorPackage, $categoryID, $parentID = null, $overwriteExisting = false, $formIndicatorsAdded = null)
    {
        $indicatorPackage['categoryID'] = $categoryID;
        $indicatorPackage['parentID'] = $parentID;

        if (is_array($indicatorPackage['options']))
        {
            foreach ($indicatorPackage['options'] as $option)
            {
                $indicatorPackage['format'] .= "\r\n" . $option;
            }
        }

        $indicatorID = $this->formEditor->addIndicator($indicatorPackage, $overwriteExisting);
        $formIndicatorsAdded[$indicatorPackage['indicatorID']] = $indicatorID;
        if (is_array($indicatorPackage['child']))
        {
            foreach ($indicatorPackage['child'] as $child)
            {
                $formIndicatorsAdded = $this->importIndicator($child, $categoryID, $indicatorID, $overwriteExisting, $formIndicatorsAdded);
            }
        }
        return $formIndicatorsAdded;
    }

    private function updateConditionRelations($formIndicatorsAdded)
    {
        $indicatorList = (implode(',', $formIndicatorsAdded));
        $strSQL = "SELECT indicatorID, conditions FROM indicators WHERE indicatorID IN ({$indicatorList})";
        $records = $this->db->query($strSQL);

        foreach($records as $rec) {
            if($rec['conditions'] !== '' && $rec['conditions'] !== null)
            {
                $conditions = json_decode($rec['conditions']);
                foreach($conditions as $c)
                {
                    $currParentID = $c->parentIndID;
                    $c->childIndID = $rec['indicatorID'];
                    $c->parentIndID = (int)$formIndicatorsAdded[$currParentID] ?? 0;
                    if(isset($c->level2IndID)) {
                        $currentLevel2 = $c->level2IndID;
                        $c->level2IndID = (int)$formIndicatorsAdded[$currentLevel2];
                    }
                }
                $updatedConditions = json_encode($conditions);

                $vars = array(
                    ':indicatorID' => $rec['indicatorID'],
                    ':updatedConditions'=> $updatedConditions
                );
                $strSQL = 'UPDATE indicators SET indicators.conditions = :updatedConditions WHERE indicatorID=:indicatorID';
                $this->db->prepared_query($strSQL, $vars);
            }
        }
    }
}
