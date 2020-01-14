<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Stack
    Date Created: April 2, 2013

*/

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
            require_once 'FormEditor.php';
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

        foreach ($formPacket['packet']['form'] as $indicator)
        {
            $this->importIndicator($indicator, $formCategoryID, null, $overwiteExisting);
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
                $this->importIndicator($indicator, $subformCategoryID, null, $overwiteExisting);
            }
        }

        return true;
    }

    private function importIndicator($indicatorPackage, $categoryID, $parentID = null, $overwriteExisting = false)
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
        if (is_array($indicatorPackage['child']))
        {
            foreach ($indicatorPackage['child'] as $child)
            {
                $this->importIndicator($child, $categoryID, $indicatorID, $overwriteExisting);
            }
        }
    }
}
