<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Generator
    Date Created: September 11, 2007

*/

namespace Portal;

use App\Leaf\XSSHelpers;
use App\Leaf\CommonConfig;
use App\Leaf\Db;

define('UPLOAD_DIR', './UPLOADS/'); // with trailing slash

class Form
{
    public $employee;    // Org Chart

    public $position;    // Org Chart

    public $group;       // Org Chart

    public $oc_dbName;   // Org Chart

    public $log = array(
        "write" => array(),
        "read" => array()
    );  // used by checkReadAccess() and hasWriteAccess() to log activity

    private $db;

    private $login;

    private $cache = array();

    private $formWorkflow;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $oc_db = OC_DB;
        $oc_login = new \Orgchart\Login($oc_db, $oc_db);
        $oc_login->loginUser();
        $this->oc_dbName = \ORGCHART_DB;

        $this->employee = new \Orgchart\Employee($oc_db, $oc_login);
        $this->position = new \Orgchart\Position($oc_db, $oc_login);
        $this->group = new \Orgchart\Group($oc_db, $oc_login);
    }

    /**
     * getFormWorkflow initializes and returns a generic instance of FormWorkflow
     * @return object
     */
    private function getFormWorkflow(): object
    {
        if (!isset($this->formWorkflow))
        {
            $this->formWorkflow = new FormWorkflow($this->db, $this->login, 0);
        }

        return $this->formWorkflow;
    }

    /**
     * Get all category (Form) IDs, names, and descriptions.
     *
     * @return array of all category IDs, names and descriptions
     */
    public function getAllCategories(): array
    {
        $res = $this->db->prepared_query(
            'SELECT categoryID, categoryName, categoryDescription FROM categories WHERE disabled = 0 ORDER BY categoryName',
            array()
        );

        return $res;
    }

    /**
     * New version of getServices
     * @return array
     */
    public function getServices2()
    {
        $res = $this->db->prepared_query('SELECT serviceID, service FROM services ORDER BY service ASC', array());
        $services = array();

        foreach ($res as $field)
        {
            $temp['serviceID'] = (int)$field['serviceID'];
            $temp['service'] = $field['service'];
            $services[] = $temp;
        }

        return $services;
    }

    /**
     * Retrieves a form and includes any associated data, while retaining the form tree
     * @param int $recordID
     * @param string $limitCategory
     * @return array
     */
    public function getFullForm($recordID, $limitCategory = null)
    {
        $fullForm = array();

        // build the whole form structure
        $form = $this->getForm($recordID, $limitCategory);

        if (isset($form['items']))
        {
            foreach ($form['items'] as $section)
            {
                foreach ($section['children'] as $subsection)
                {
                    try {
                        $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
                    } catch (\TypeError $te) {
                        error_log($te);
                    }
                }
            }
        }

        return $fullForm;
    }

    public function flattenFullFormData($data, &$output, $parentID = null)
    {
        foreach ($data as $key => $item)
        {
            if ($item['child'] == null)
            {
                unset($item['child']);
                $item['parentID'] = $parentID;
                $output[$item['indicatorID']][$item['series']] = $item;
            }
            else
            {
                $this->flattenFullFormData($item['child'], $output, $item['indicatorID']);
                unset($item['child']);
                $item['parentID'] = $parentID;
                $output[$item['indicatorID']][$item['series']] = $item;
            }
        }
    }

    /**
     * Retrieves a form and includes any associated data, in a flat data array
     * @param int $recordID
     * @param string $limitCategory
     * @return array
     */
    public function getFullFormData($recordID, $limitCategory = null)
    {
        $fullForm = $this->getFullForm($recordID, $limitCategory);
        $output = array();

        $this->flattenFullFormData($fullForm, $output);

        return $output;
    }

    /**
     * Retrieves a form in JSON format and includes any associated data,
     * in a flat data array, with additional fields that are required
     * when preparing a form to be digitally signed.
     *
     * @param int       $recordID       The record id to retrieve for signing
     * @param string    $limitCategory  The internal use form (optional)
     *
     * @return array    An array that represents the form ready for signing
     */
    public function getFullFormDataForSigning($recordID, $limitCategory = null)
    {
        // This function cannot use getFullFormData() above since that
        // function does not allow access to the $form object.
        // It uses the contents of getFullForm().

        // contents of getFullForm()
        // build the whole form structure
        $form = $this->getForm($recordID, $limitCategory);
        $fullForm = array();
        if (isset($form['items']))
        {
            foreach ($form['items'] as $section)
            {
                foreach ($section['children'] as $subsection)
                {
                    try {
                        $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
                    } catch (\TypeError $te) {
                        error_log($te);
                    }
                }
            }
        }

        $indicators = array();
        $this->flattenFullFormData($fullForm, $indicators);

        $output = array(
            'userName' => $this->login->getUserID(),
            'timestamp' => time(),
            'formId' => $form['items'][0]['children'][0]['type'],
            'recordId' => $recordID,
            'limitCategory' => $limitCategory != null ? $limitCategory : '',
            'indicators' => $indicators,
        );

        return $output;
    }

    /**
     * Retrieves a form based on categoryID
     * @param string $categoryID
     * @param bool $parseTemplate - see getIndicator()
     * @return array
     */
    public function getFormByCategory($categoryID, $parseTemplate = true)
    {
        $fullForm = array();

        // build the form structure
        $form = $this->buildFormJSONStructure($categoryID);

        foreach ($form as $item)
        {
            try {
                $fullForm = array_merge($fullForm, $this->getIndicator($item['indicatorID'], 1, null, $parseTemplate));
            } catch (\TypeError $te) {
                error_log($te);
            }
        }

        return $fullForm;
    }

    /**
     * Retrieves a list of form pages based on provided categoryIDs
     * @param string $categoryIDs of the forms to retrieve
     * @param bool $parseTemplate - see getIndicator()
     * @return array
     */
    public function getSpecifiedForms($categoryIDs = '', $parseTemplate = true): array
    {
        $categories = explode(',', $categoryIDs);
        $fullFormPages = array();
        foreach($categories as $catID) {
            $form = $this->getFormByCategory($catID, $parseTemplate);
            if(is_array($form) && count($form) > 0) {
                $fullFormPages = array_merge($fullFormPages, $form);
            }
        }

        return $fullFormPages;
    }

    /**
     * Retrieves a form's workflow based on categoryID
     * @param int $recordID
     * @return array
     */
    public function getWorkflow($categoryID)
    {
        $vars = array(':categoryID' => $categoryID);

        return $this->db->prepared_query('SELECT * FROM categories
    										LEFT JOIN workflows USING (workflowID)
    										WHERE categoryID=:categoryID', $vars);
    }

    public function getForm($recordID, $limitCategory = null)
    {
        if ($this->isNeedToKnow($recordID))
        {
            $query[$recordID]['recordID'] = $recordID;
            $resRead = $this->checkReadAccess($query);
            if (!isset($resRead[$recordID]))
            {
                return '';
            }
        }

        $jsonRootIdx = -1;

        $json['label'] = 'name';
        $json['identifier'] = 'jsonIdx';

        if ($limitCategory == null)
        {
            // pull category counts
            $vars = array(':recordID' => $recordID);
            $res2 = $this->db->prepared_query('SELECT * FROM category_count
                                                    LEFT JOIN categories USING (categoryID)
                                                    WHERE recordID = :recordID
                                                        AND count > 0
                                                    ORDER BY sort', $vars);
        }
        else
        {
            $vars = array(':categoryID' => XSSHelpers::xscrub($limitCategory));
            $res2 = $this->db->prepared_query('SELECT * FROM categories
                                                    WHERE categoryID = :categoryID', $vars);
            $res2[0]['count'] = 1;
        }

        foreach ($res2 as $catType)
        {
            for ($i = 1; $i <= $catType['count']; $i++)
            {
                $tmp['name'] = $catType['count'] > 1
                                    ? $catType['categoryName'] . ' #' . $i
                                    : $catType['categoryName'];
                $tmp['type'] = 'form';
                $tmp['jsonIdx'] = --$jsonRootIdx;
                $tmp['series'] = $i;
                $tmp['children'] = $this->buildFormJSONStructure($catType['categoryID'], $i);
                $json['items'][] = $tmp;
            }
        }

        return $json;
    }

    // Expects POST input: $_POST['service'], title, priority, num(categoryID)
    public function newForm($userID)
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 'Error: Invalid token.';
        }
        $title = XSSHelpers::sanitizeHTML($_POST['title']);
        $_POST['title'] = $title == '' ? '[blank]' : $title;
        $_POST['service'] = !isset($_POST['service']) || $_POST['service'] == '' ? 0 : (int)$_POST['service'];
        $_POST['priority'] = !isset($_POST['priority']) || $_POST['priority'] == '' ? 0 : (int)$_POST['priority'];

        if ($_POST['title'] == ''
            || !is_numeric($_POST['service'])
            || !is_numeric($_POST['priority']))
        {
            return 'Error: Please check the data you\'ve entered, and try again.';
        }

        $keys = array_keys($_POST);

        $categoryIDsArr = array();
        if (isset($_POST['title']))
        {
            foreach ($keys as $key)
            {
                if (strpos($key, 'num') === 0)
                {
                    $categoryIDsArr[] = XSSHelpers::xscrub(strtolower(substr($key, 3)));
                }
            }
        }
        if (count($categoryIDsArr) === 0)
        {
            return 'Error: No forms selected. Please Select a form and try again.';
        }

        //check category visible status.  unpublished forms (visibility -1) should not be created.
        $pubVars = array(
            ":categoryIDs" => implode(',', $categoryIDsArr)
        );
        $pubSQL = "SELECT * FROM categories WHERE FIND_IN_SET(categoryID, :categoryIDs) AND `visible` = -1";
        $unpublishedForms = $this->db->prepared_query($pubSQL, $pubVars);

        if (count($unpublishedForms) > 0) {
            return 'Forms associated with this request are unpublished.  Please check the New Request page or contact an administrator about possible form updates.';
        }

        $var = array(':service' => $_POST['service']);
        $res = null;
        if (is_numeric($_POST['service']))
        {
            $res = $this->db->prepared_query('SELECT serviceID FROM services WHERE serviceID=:service', $var);
        }
        else
        {
            $res = $this->db->prepared_query('SELECT serviceID FROM services WHERE service=:service', $var);
        }

        $serviceID = $res[0]['serviceID'];
        if (!is_numeric($serviceID))
        {
            if ($_POST['service'] == 0)
            {
                $serviceID = 0;
            }
            else
            {
                return 'Error: Service ID is not synchronized to Org. Chart.';
            }
        }

        $userMetadata  = $this->employee->getInfoForUserMetadata($userID, false);
        $vars = array(
            ':date' => time(),
            ':serviceID' => $serviceID,
            ':userID' => $userID,
            ':title' => XSSHelpers::sanitizer($_POST['title']),
            ':priority' => $_POST['priority'],
            ':userMetadata' => $userMetadata,
        );

        $this->db->prepared_query('INSERT INTO records (date, serviceID, userID, title, priority, userMetadata)
                                    VALUES (:date, :serviceID, :userID, :title, :priority, :userMetadata)', $vars);

        $recordID = $this->db->getLastInsertID(); // note this doesn't work with all DBs (eg. with transactions, MySQL should be ok)

        $keys = array_keys($_POST);

        $containsFieldData = false;
        if (isset($_POST['title']))
        {
            foreach ($keys as $key)
            {
                if (strpos($key, 'num') === 0)
                {
                    $tCount = is_numeric($_POST[$key]) ? $_POST[$key] : 1; // check how many copies of the form we need

                    if ($tCount >= 1)
                    {
                        $categoryID = XSSHelpers::xscrub(strtolower(substr($key, 3)));
                        $vars = array(':recordID' => $recordID,
                                ':categoryID' => $categoryID,
                                ':count' => $tCount, );

                        if ($this->isCategory($categoryID))
                        {
                            $res = $this->db->prepared_query('INSERT INTO category_count (recordID, categoryID, count)
                                                            VALUES (:recordID, :categoryID, :count)
                                                            ON DUPLICATE KEY UPDATE count=:count', $vars);

                            // handle stapled (merged) forms
                            $vars = array(':categoryID' => $categoryID);
                            $res2 = $this->db->prepared_query('SELECT * FROM category_staples
                												WHERE categoryID=:categoryID', $vars);
                            foreach ($res2 as $merged)
                            {
                                $vars = array(':recordID' => $recordID,
                                              ':categoryID' => $merged['stapledCategoryID'],
                                              ':count' => $tCount, );
                                $res = $this->db->prepared_query('INSERT INTO category_count (recordID, categoryID, count)
                                                            		VALUES (:recordID, :categoryID, :count)
                                                            		ON DUPLICATE KEY UPDATE count=:count', $vars);
                            }
                        }
                    }
                }

                if(is_numeric($key) && !$containsFieldData) {
                    $containsFieldData = true;
                }
            }
        }

        if($containsFieldData) {
            $this->doModify($recordID);
        }
        return (int)$recordID;
    }

    /**
     * Get a form's indicator and all children, including data if available
     *
     * Flags:
     *  $_GET['context'] If the context is set to "formEditor", an additional "isMaskable" property indicates
     *                   whether the field has Special Access Restrictions assigned. Used in the Form Editor
     *                   to provide a visual indicator.
     *
     * @param int $indicatorID
     * @param int $series
     * @param int $recordID
     * @param bool $parseTemplate - parses html/htmlPrint template variables
     * @param bool $forceReadOnly ***Only use in safe contexts*** Force allow read only access and
     *                            bypasses normal access checks. Does not load child indicators.
     * @return array
     */
    public function getIndicator($indicatorID, $series, $recordID = null, $parseTemplate = true, $forceReadOnly = false)
    {
        if(isset($this->cache["getIndicator_{$indicatorID}_{$series}_{$recordID}_{$parseTemplate}"])) {
            return $this->cache["getIndicator_{$indicatorID}_{$series}_{$recordID}_{$parseTemplate}"];
        }
        $form = array();
        if (!is_numeric($indicatorID) || !is_numeric($series))
        {
            return array();
        }

        // check needToKnow mode
        if(!$forceReadOnly) {
            if ($recordID != null && $this->isNeedToKnow($recordID) && !$this->hasReadAccess($recordID))
            {
                return array();
            }
        }

        $vars = array(':indicatorID' => $indicatorID,
                      ':series' => $series,
                      ':recordID' => $recordID, );
        $data = $this->db->prepared_query('SELECT * FROM data
                                            LEFT JOIN indicators USING (indicatorID)
                                            LEFT JOIN indicator_mask USING (indicatorID)
                                            WHERE indicatorID=:indicatorID AND series=:series AND recordID=:recordID AND disabled=0', $vars);
        if (!isset($data[0]))
        {
            if(isset($this->cache['getIndicator_'.$indicatorID])) {
                $data = $this->cache['getIndicator_'.$indicatorID];
            }
            else {
                $vars = array(':indicatorID' => $indicatorID);
                $data = $this->db->prepared_query('SELECT * FROM indicators
                                                    LEFT JOIN indicator_mask USING (indicatorID)
                                                    WHERE indicatorID=:indicatorID AND disabled = 0', $vars);
                $this->cache['getIndicator_'.$indicatorID] = $data;
            }
        }

        if (!empty($data)) {
            $idx = $data[0]['indicatorID'];
            $form[$idx]['indicatorID'] = $data[0]['indicatorID'];
            $form[$idx]['categoryID'] = $data[0]['categoryID'];
            $form[$idx]['series'] = $series;
            $form[$idx]['name'] = $data[0]['name'];
            $form[$idx]['description'] = $data[0]['description'];
            $form[$idx]['default'] = $data[0]['default'];
            $form[$idx]['parentID'] = $data[0]['parentID'];
            $form[$idx]['html'] = $data[0]['html'];
            $form[$idx]['htmlPrint'] = $data[0]['htmlPrint'];
            $form[$idx]['conditions'] = $data[0]['conditions'];
            $form[$idx]['required'] = $data[0]['required'];
            $form[$idx]['is_sensitive'] = $data[0]['is_sensitive'];
            $form[$idx]['isEmpty'] = (isset($data[0]['data']) && !is_array($data[0]['data']) && strip_tags($data[0]['data']) != '') ? false : true;
            $form[$idx]['value'] = (isset($data[0]['data']) && $data[0]['data'] != '') ? $data[0]['data'] : $form[$idx]['default'];
            $form[$idx]['displayedValue'] = ''; // used for Org Charts
            $form[$idx]['timestamp'] = isset($data[0]['timestamp']) ? $data[0]['timestamp'] : 0;
            $form[$idx]['userID'] = $data[0]['userID'];
            if(!$forceReadOnly) {
                $form[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $data[0]['categoryID']);
                $form[$idx]['isMasked'] = isset($data[0]['groupID']) ? $this->isMasked($data[0]['indicatorID'], $recordID) : 0;

                if(isset($_GET['context']) && $_GET['context'] == 'formEditor') {
                    $form[$idx]['isMaskable'] = isset($data[0]['groupID']) ? 1 : 0;
                }
            }
            $form[$idx]['sort'] = $data[0]['sort'];

            if (!empty($data[0]['html'])) {
                $form[$idx]['has_code'] = trim($data[0]['html']);
            } elseif (!empty($data[0]['htmlPrint'])) {
                $form[$idx]['has_code'] = trim($data[0]['htmlPrint']);
            } else {
                $form[$idx]['has_code'] = '';
            }

            // handle file upload
            if (isset($data[0]['data'])
                && ($data[0]['format'] == 'fileupload'
                    || $data[0]['format'] == 'image'))
            {
                $form[$idx]['value'] = $this->fileToArray($data[0]['data']);
                $form[$idx]['raw'] = $data[0]['data'];
            }
            // special handling for org chart data types (request header questions, edited report builder cells)
            else if ($data[0]['format'] == 'orgchart_employee'
                && !empty($data[0]['data']))
            {
                $form[$idx]['displayedValue'] = '';
                if (isset($data[0]['metadata'])) {
                    $orgchartInfo = json_decode($data[0]['metadata'], true);
                    if(!empty(trim($orgchartInfo['lastName']))) {
                        $form[$idx]['displayedValue'] = "{$orgchartInfo['firstName']} {$orgchartInfo['lastName']}";
                    }
                }
            }
            else if ($data[0]['format'] == 'orgchart_position'
                && isset($data[0]['data']))
            {
                $positionTitle = $this->position->getTitle($data[0]['data']);
                $form[$idx]['displayedValue'] = $positionTitle;
            }
            else if ($data[0]['format'] == 'orgchart_group'
                && isset($data[0]['data']))
            {
                $groupTitle = $this->group->getGroup($data[0]['data']);
                $form[$idx]['displayedValue'] = $groupTitle[0]['groupTitle'];
            }
            else if (substr($data[0]['format'], 0, 4) == 'grid'
                && isset($data[0]['data']))
            {
                $values = @unserialize($data[0]['data']);
                $format = json_decode(substr($data[0]['format'], 5, -1) . ']');
                $form[$idx]['value'] = @unserialize($form[$idx]['value']) === false ? $form[$idx]['value'] : unserialize($form[$idx]['value']);
                try {
                    if(!is_array($values)) {
                        $values = [];
                    }
                    $form[$idx]['displayedValue'] = array_merge($values, array("format" => $format));
                } catch (\TypeError $te) {
                    error_log($te);
                }
            }
            // handle multiselect and checkboxes format
            // includes backwards compatibility for data stored as CSV
            else if (isset($data[0]['data']) && $data[0]['data'] != ''
                && (substr($data[0]['format'], 0, 11) == 'multiselect'
                    || substr($data[0]['format'], 0, 10) == 'checkboxes'))
            {
                $form[$idx]['value'] = @unserialize($data[0]['data']) !== false ? @unserialize($data[0]['data']) : preg_split('/,(?!\s)/', $data[0]['data']);
            }

            // prevent masked data from being output
            if ($form[$idx]['isMasked'])
            {
                if (isset($data[0]['data'])
                    && ($data[0]['format'] == 'fileupload'
                        || $data[0]['format'] == 'image')) {
                    $form[$idx]['value'] = $this->fileToArray('[protected data]');
                    $form[$idx]['displayedValue'] = $this->fileToArray('[protected data]');
                } else {
                    $form[$idx]['value'] = '[protected data]';
                    $form[$idx]['displayedValue'] = '[protected data]';
                }
            }

            // handle radio/checkbox options
            $inputType = explode("\n", $data[0]['format']);
            $numOptions = count($inputType) > 1 ? count($inputType) : 0;
            for ($i = 1; $i < $numOptions; $i++)
            {
                $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                if (strpos($inputType[$i], 'default:') !== false)
                {
                    $form[$idx]['options'][] = array(substr($inputType[$i], 8), 'default');
                }
                else
                {
                    $form[$idx]['options'][] = $inputType[$i];
                }
            }

            if($parseTemplate) {
                if($data[0]['html'] != null) {
                    $form[$idx]['html'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                            [$idx, $recordID, $form[$idx]['value']],
                                            $data[0]['html']);
                }
                if($data[0]['htmlPrint'] != null) {
                    $form[$idx]['htmlPrint'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                                [$idx, $recordID, $form[$idx]['value']],
                                                $data[0]['htmlPrint']);
                }
            }

            $form[$idx]['format'] = trim($inputType[0]);

            if(!$forceReadOnly) {
                $form[$idx]['child'] = $this->buildFormTree($data[0]['indicatorID'], $series, $recordID, $parseTemplate);
            }
        }

        $this->cache["getIndicator_{$indicatorID}_{$series}_{$recordID}_{$parseTemplate}"] = $form;
        return $form;
    }

    public function getIndicatorLog($indicatorID, $series, $recordID)
    {
        // check needToKnow mode
        if (!$this->hasReadAccess($recordID))
        {
            return array();
        }

        // get request initiator
        $vars = array(':recordID' => (int)$recordID);
        $resInitiator = $this->db->prepared_query(
            'SELECT userID FROM records
                WHERE recordID=:recordID',
            $vars
        );

        $vars = array(':recordID' => (int)$recordID,
                      ':indicatorID' => (int)$indicatorID,
                      ':series' => (int)$series, );


        $res = $this->db->prepared_query(
            'SELECT h.recordID, h.indicatorID, h.series, h.data, h.timestamp, h.userID, i.is_sensitive, groupID
                FROM data_history h
                    LEFT JOIN indicator_mask USING (indicatorID)
                    LEFT JOIN indicators i USING (indicatorID)
                    WHERE h.recordID=:recordID
                    AND h.indicatorID=:indicatorID
                    AND h.series=:series
                    ORDER BY timestamp DESC',
            $vars
        );

        $dir = new VAMC_Directory;

        $res2 = array();
        foreach ($res as $line)
        {
            $user = $dir->lookupLogin($line['userID']);

            // if 'groupID' is set, this means there is an entry for it in the `indicator_mask`
            // database table and the access permissions for that indicator needs to be checked
            if (isset($line['groupID']))
            {
                $groups = $this->login->getMembership();

                // check if logged in user is request initiator
                if ($this->login->getUserID() != $resInitiator[0]['userID'])
                {
                    // the user does not need permission to view the indicator data, so the data
                    // must be masked
                    if (!isset($groups['groupID'][$line['groupID']]))
                    {
                        $line['data'] = '[protected data]';
                    }
                }
            }
            $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $line['userID'];
            $line['name'] = $name;
            $res2[] = $line;
        }

        return $res2;
    }

    public function buildFormJSONStructure($categoryID, $series = 1)
    {
        $categoryID = ($categoryID == null) ? 'general' : XSSHelpers::xscrub($categoryID);

        if (!isset($this->cache["categoryID{$categoryID}_indicators"]))
        {
            $vars = array(':categoryID' => $categoryID);
            $res = $this->db->prepared_query('SELECT * FROM indicators
                                                WHERE categoryID=:categoryID
                                                    AND parentID IS NULL
                                                    AND disabled = 0
                                                ORDER BY sort', $vars);
            $this->cache["categoryID{$categoryID}_indicators"] = $res;
        }
        else
        {
            $res = $this->cache["categoryID{$categoryID}_indicators"];
        }

        $indicators = array();
        $counter = 1;
        foreach ($res as $ind)
        {
            $desc = $ind['description'] != '' ? $ind['description'] : $ind['name'];
            $indicator['name'] = "$series.$counter: " . strip_tags($desc);
            $indicator['desc'] = strip_tags($desc);
            $indicator['type'] = $categoryID;
            $indicator['jsonIdx'] = $ind['indicatorID'] . '.' . $series;
            $indicator['series'] = $series;
            $indicator['format'] = $ind['format'];
            $indicator['indicatorID'] = $ind['indicatorID'];
            $indicators[] = $indicator;
            $counter++;
        }

        return $indicators;
    }

    public function getFormJSON($recordID)
    {
        $json = $this->getForm($recordID);

        return json_encode($json);
    }

    /**
     * cancelRecord marks a record as cancelled.
     *
     * Only admins should be able to cancel submitted records.
     *
     * @param int $recordID
     * @param string $comment
     *
     * @return int|string Return 1 on success, error string on failure
     */
    public function cancelRecord(int $recordID, ?string $comment = '', bool $suppressNotification = false): int|string
    {
        $return_value = 'Please contact your administrator';

        $vars = array(':recordID' => $recordID);
        $sql = 'SELECT `submitted`
                    FROM `records`
                    WHERE `recordID` = :recordID';
        $resIsSubmitted = $this->db->prepared_query($sql, $vars);

        if ($resIsSubmitted[0]['submitted'] != 0 && !$this->login->checkGroup(1)) {
            $return_value = 'To help avoid confusion in the process, Please contact your administrator to cancel this request.';
        } else if ($this->hasWriteAccess($recordID)) {
            $actionUserID = $this->login->getUserID();
            $userMetadata  = $this->employee->getInfoForUserMetadata($actionUserID, false);

            $this->db->beginTransaction();
            $vars = array(':recordID' => $recordID,
                        ':time' => time());
            $sql = 'UPDATE `records`
                    SET `deleted` = :time
                    WHERE `recordID` = :recordID';

            $this->db->prepared_query($sql, $vars);

            // actionID 4 = delete
            $vars = array(':recordID' => $recordID,
                ':userID' => $actionUserID ,
                ':dependencyID' => 0,
                ':actionType' => 'deleted',
                ':actionTypeID' => 4,
                ':time' => time(),
                ':comment' => XSSHelpers::xscrub($comment),
                ':userMetadata' => $userMetadata,
            );
            $sql = 'INSERT INTO `action_history`
                        (`recordID`, `userID`, `dependencyID`, `actionType`, `actionTypeID`, `time`, `comment`, `userMetadata`)
                    VALUES
                        (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment, :userMetadata)';

            $this->db->prepared_query($sql, $vars);

            // delete state
            $vars = array(':recordID' => $recordID);
            $sql = 'DELETE
                    FROM `records_workflow_state`
                    WHERE `recordID` = :recordID';

            $this->db->prepared_query($sql, $vars);

            // delete tags
            $vars = array(':recordID' => $recordID);
            $sql = 'DELETE
                    FROM `tags`
                    WHERE `recordID` = :recordID';

            $this->db->prepared_query($sql, $vars);

            if($this->db->commitTransaction())
            {
                // need to send emails to everyone upstream from the currect step.
                if(!$suppressNotification) {
                    $this->notifyPriorSteps($recordID);
                }

                $return_value = 1;
            }
        }

        return $return_value;
    }

    private function notifyPriorSteps(int $recordID): void
    {
        $email = new Email();
        $email->setSender('leaf.noreply@va.gov');

        $email->attachApproversAndEmail($recordID, Email::CANCEL_REQUEST, $this->login);
    }

    public function restoreRecord($recordID)
    {
        // only allow admins to un-delete records
        if (!$this->login->checkGroup(1))
        {
            return 0;
        }

        $vars = array(':recordID' => (int)$recordID,
                ':time' => 0, );
        $res = $this->db->prepared_query('UPDATE records SET
                                            deleted=:time
                                            WHERE recordID=:recordID', $vars);

        return true;
    }

    // TODO: cleanup this and doModify to not use $_POST

    /**
     * Delete file/image attachment
     *
     * @param int $recordID
     * @param int $indicatorID
     * @param int $series
     * @param string $fileName
     *
     * @return bool
     *
     * Created at: 10/31/2022, 8:32:58 AM (America/New_York)
     */
    public function deleteAttachment(int $recordID, int $indicatorID, int $series, string $fileName): bool
    {
        if (!is_numeric($recordID) || !is_numeric($indicatorID) || !is_numeric($series)) {
            $return_value = false;
        } else if ($_POST['CSRFToken'] != $_SESSION['CSRFToken']) {
            $return_value = false;
        } else if (!$this->hasWriteAccess($recordID, 0, $indicatorID)) {
            $return_value = false;
        } else {
            $data = $this->getIndicator($indicatorID, $series, $recordID);
            $value = $data[$indicatorID]['value'];
            $index = $this->getIndex($recordID, $indicatorID, $series, $fileName);

            $file = $this->getFileHash($recordID, $indicatorID, $series, $data[$indicatorID]['value'][$index]);

            $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;

            if (is_array($value) && isset($value[$index])) {
                $_POST['overwrite'] = true;
                $_POST['series'] = 1;
                $_POST[$indicatorID] = '';

                for ($i = 0; $i < count($value); $i++) {
                    if ($i != $index) {
                        $_POST[$indicatorID] .= $value[$i] . "\n";
                    }
                }

                $this->doModify($recordID);

                if (file_exists($uploadDir . $file)) {
                    unlink($uploadDir . $file);
                }

                $return_value = true;
            }

            $return_value = false;
        }

        return $return_value;
    }

    public function getRecordInfo($recordID)
    {
        $vars = array(':recordID' => (int)$recordID,
                      ':bookmarkID' => 'bookmark_' . $this->login->getUserID(), );

        $res = $this->db->prepared_query('SELECT * FROM records
                                            LEFT JOIN services USING (serviceID)
                                            LEFT JOIN (SELECT recordID, tag FROM tags
                                            			WHERE tag=:bookmarkID) lj1 USING (recordID)
                                            LEFT JOIN records_workflow_state USING (recordID)
                                            WHERE recordID=:recordID', $vars);

        $vars = array(':recordID' => (int)$recordID);

        $resCategory = $this->db->prepared_query('SELECT * FROM category_count
        									LEFT JOIN categories USING (categoryID)
                                            WHERE recordID=:recordID AND count > 0', $vars);
        $categoryData = array();
        $categoryNames = array();
        foreach ($resCategory as $cat)
        {
            $categoryData[$cat['categoryID']] = $cat['categoryID'];
            $categoryNames[$cat['categoryID']] = $cat['categoryName'];
        }
        $parentIDs = implode(',', array_values($categoryData));

        //Check for forms with these parentIDs (Internal Forms)
        $vars = array(':parentIDs' => $parentIDs);
        $resInternal = $this->db->prepared_query('SELECT * FROM categories
                                            WHERE FIND_IN_SET(parentID, :parentIDs) AND `disabled`=0', $vars);
        $count = count($resInternal);
        $internalIDs = array();
        for ($i = 0; $i < $count;$i++) {
            $internalIDs[$i] = $resInternal[$i]['categoryID'];
        }

        if (count($res) == 0)
        {
            return array('name' => 'None',
                      'service' => 'None',
                      'serviceID' => 0,
                      'date' => 0,
                      'title' => 'Does not exist',
                      'priority' => 0,
                      'submitted' => 0,
                      'stepID' => null,
                      'deleted' => 1,
                      'bookmarked' => '',
            );
        }

        if (!$this->hasReadAccess($recordID))
        {
            return array('name' => 'Protected Data',
                    'service' => 'Protected Data',
                    'serviceID' => 0,
                    'date' => 0,
                    'title' => 'Protected Data',
                    'priority' => 0,
                    'submitted' => 1,
                    'stepID' => null,
                    'deleted' => 0,
                    'bookmarked' => '',
            );
        }

        $userMetadata = json_decode($res[0]['userMetadata'], true);
        $name = isset($userMetadata) && !empty(trim($userMetadata['lastName'])) ?
            "{$userMetadata['firstName']} {$userMetadata['lastName']}" : $res[0]['userID'];

        $data = array('name' => $name,
                      'service' => $res[0]['service'],
                      'serviceID' => $res[0]['serviceID'],
                      'date' => $res[0]['date'],
                      'title' => $res[0]['title'],
                      'priority' => $res[0]['priority'],
                      'submitted' => $res[0]['submitted'],
                      'stepID' => $res[0]['stepID'],
                      'deleted' => $res[0]['deleted'],
                      'bookmarked' => $res[0]['tag'],
                      'internalForms' => $internalIDs,
                      'categories' => $categoryData,
                      'categoryNames' => $categoryNames, );

        return $data;
    }

    public function isSubmitted($recordID)
    {
        $vars = array(':recordID' => (int)$recordID);
        $res = $this->db->prepared_query('SELECT submitted FROM records WHERE recordID=:recordID', $vars);

        return $res[0]['submitted'] >= 1 ? true : false;
    }

    public function getOwnerID($recordID)
    {
        if (isset($this->cache['owner_' . $recordID]))
        {
            return $this->cache['owner_' . $recordID];
        }
        $vars = array(':recordID' => (int)$recordID);
        $res = $this->db->prepared_query('SELECT userID FROM records WHERE recordID=:recordID', $vars);
        $this->cache['owner_' . $recordID] = $res[0]['userID'];

        return $res[0]['userID'];
    }

    // return last status from cached value
    public function getLastStatus($recordID)
    {
        $vars = array(':recordID' => (int)$recordID);
        $res = $this->db->prepared_query('SELECT lastStatus FROM records
                                            WHERE recordID=:recordID', $vars);

        return $res[0]['lastStatus'];
    }

    public static function getFileHash($recordID, $indicatorID, $series, $fileName)
    {
        $fileName = strip_tags($fileName);

        return "{$recordID}_{$indicatorID}_{$series}_{$fileName}";
    }

    public function isCategory($categoryID)
    {
        if (isset($this->cache['isCategory_' . $categoryID]))
        {
            return $this->cache['isCategory_' . $categoryID];
        }
        $vars = array(':categoryID' => XSSHelpers::xscrub($categoryID));
        $res = $this->db->prepared_query('SELECT COUNT(*) FROM categories WHERE categoryID=:categoryID', $vars);
        if ($res[0]['COUNT(*)'] != 0)
        {
            $this->cache['isCategory_' . $categoryID] = 1;

            return 1;
        }
        $this->cache['isCategory_' . $categoryID] = 0;

        return 0;
    }

    /**
     * Write data from input fields if the current user has access, used with doModify()
     * @param int $recordID
     * @param int $key
     * @param int $series
     * @return int 1 for success, 0 for error
     */
    private function writeDataField($recordID, $key, $series)
    {
        
        if (is_array($_POST[$key])) //multiselect, checkbox, grid items
        {
            $_POST[$key] = XSSHelpers::scrubObjectOrArray($_POST[$key]);
            $_POST[$key] = serialize($_POST[$key]);
        }
        else
        {
            $_POST[$key] = XSSHelpers::sanitizeHTML($_POST[$key]);
        }

        $vars = array(':recordID' => $recordID,
                      ':indicatorID' => $key,
                      ':series' => $series, );

        $sql = "SELECT `format`, `data` FROM `data`
            LEFT JOIN `indicators` USING (`indicatorID`)
            WHERE `recordID`=:recordID AND `indicators`.`indicatorID`=:indicatorID AND `series`=:series";

        $res = $this->db->prepared_query($sql, $vars);

        if(empty($res)) {
            $vf = array(":indicatorID" => $key);
            $sqlf = "SELECT `format` FROM `indicators` WHERE `indicatorID`=:indicatorID";
            $res =  $this->db->prepared_query($sqlf, $vf);
        }

        // handle fileupload indicator type
        if (isset($res[0]['format'])
                && ($res[0]['format'] == 'fileupload'
                        || $res[0]['format'] == 'image'))
        {
            if (!isset($_POST['overwrite'])
                && strpos($res[0]['data'], $_POST[$key]) === false)
            {
                $_POST[$key] = trim($res[0]['data'] . "\n" . $_POST[$key]);
            }
            else
            {
                if (!isset($_POST['overwrite'])
                && strpos($res[0]['data'], $_POST[$key]) !== false)
                {
                    $_POST[$key] = trim($res[0]['data']);
                }
            }
        }

        $duplicate = false;
        if (isset($res[0]['data']) && $res[0]['data'] == trim($_POST[$key]))
        {
            $duplicate = true;
        }

        // check write access
        if (!$this->hasWriteAccess($recordID, 0, $key)) {
            return 0;
        }
        $orgchartEmpMetadata = null;
        if($res[0]['format'] === 'orgchart_employee' && is_numeric($_POST[$key])) {
            $orgchartEmpMetadata = $this->employee->getInfoForUserMetadata($_POST[$key], true);
        }
        $vars = array(
            ':recordID' => $recordID,
            ':indicatorID' => $key,
            ':series' => $series,
            ':data' => trim($_POST[$key]),
            ':metadata' => $orgchartEmpMetadata,
            ':timestamp' => time(),
            ':userID' => $this->login->getUserID(),
        );

        $this->db->prepared_query('INSERT INTO data (recordID, indicatorID, series, data, metadata, timestamp, userID)
                                            VALUES (:recordID, :indicatorID, :series, :data, :metadata, :timestamp, :userID)
                                            ON DUPLICATE KEY UPDATE data=:data, metadata=:metadata, timestamp=:timestamp, userID=:userID', $vars);

        if (!$duplicate) {
            $vars[':userDisplay'] = $this->login->getName();
            $this->db->prepared_query('INSERT INTO data_history (recordID, indicatorID, series, data, metadata, timestamp, userID, userDisplay)
                                                   VALUES (:recordID, :indicatorID, :series, :data, :metadata, :timestamp, :userID, :userDisplay)', $vars);
        }
        /*  signatures (not yet implemented)
        $vars = array(':recordID' => $recordID,
                      ':indicatorID' => $key,
                      ':series' => $series, );

        $res = $this->db->prepared_query('SELECT data, format FROM data
                                            LEFT JOIN indicators USING (indicatorID)
                                            WHERE recordID=:recordID AND indicatorID=:indicatorID AND series=:series', $vars);

        if (strpos($res[0]['format'], 'signature') == 0) {
            // $this->writeSignature($recordID);
        }*/
        return 1;
    }

    private function writeSignature(int $recordID): void
    {
        $form = json_encode($this->getFullFormDataForSigning($recordID));
        $workflow = new FormWorkflow($this->db, $this->login, $recordID);
        $current_step = $workflow->getCurrentSteps();

        if ($current_step === null) {
            $step_id = -1;
            $dependency_id = 0;
        } else {
            foreach ($current_step as $key => $value) {
                $step_id = $value['stepID'];
                $dependency_id = $value['dependencyID'];
            }
        }

        $signature = new Signature($this->db, $this->login);
        $signature->create('place holder, coming from piv card?', $recordID, $step_id, $dependency_id, $form, 'another place holder for signerPublicKey');
    }

    /**
     * Write data from input fields if the current user has access - HTTP POST
     * @param int $recordID
     * @return int|string 1 for success, error string for error
     */
    public function doModify($recordID)
    {
        if (!is_numeric($recordID))
        {
            http_response_code(400);
            return 'Invalid recordID';
        }
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            http_response_code(401);
            return 'CSRF Token mismatch';
        }

        $series = isset($_POST['series']) && is_numeric($_POST['series']) ? $_POST['series'] : 1;

        // Check for file uploads
        if (is_array($_FILES))
        {
            $commonConfig = new CommonConfig();
            $fileExtensionWhitelist = $commonConfig->requestWhitelist;
            $fileIndicators = array_keys($_FILES);
            foreach ($fileIndicators as $indicator)
            {
                if (is_int($indicator))
                {
                    // check write access
                    if (!$this->hasWriteAccess($recordID, 0, $indicator))
                    {
                        http_response_code(401);
                        return 'No write access';
                    }
                    $_FILES[$indicator]['name'] = XSSHelpers::scrubFilename($_FILES[$indicator]['name']);
                    $_POST[$indicator] = XSSHelpers::scrubFilename($_FILES[$indicator]['name']);

                    $filenameParts = explode('.', $_FILES[$indicator]['name']);
                    $fileExtension = array_pop($filenameParts);
                    $fileExtension = strtolower($fileExtension);
                    if (in_array($fileExtension, $fileExtensionWhitelist) && $_FILES[$indicator]['error'] === UPLOAD_ERR_OK)
                    {
                        $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
                        if (!is_dir($uploadDir))
                        {
                            mkdir($uploadDir, 0755, true);
                        }

                        $sanitizedFileName = $this->getFileHash($recordID, $indicator, $series, XSSHelpers::sanitizeHTML($_FILES[$indicator]['name']));
                        move_uploaded_file($_FILES[$indicator]['tmp_name'], $uploadDir . $sanitizedFileName);
                    }
                    else
                    {
                        http_response_code(500);
                        error_log('PHP _FILES error code: ' . $_FILES[$indicator]['error']);
                        return 'File upload error code: ' . $_FILES[$indicator]['error'];
                    }
                }
            }
        }

        $keys = array_keys($_POST);

        if (isset($_POST['title']))
        {
            foreach ($keys as $key)
            {
                if (strpos($key, 'num') === 0)
                {
                    $categoryID = strtolower(substr($key, 3));

                    // check write access
                    if (!$this->hasWriteAccess($recordID, $categoryID))
                    {
                        http_response_code(401);
                        return 'No write access (title)';
                    }
                    $vars = array(':recordID' => (int)$recordID,
                                  ':categoryID' => XSSHelpers::xscrub($categoryID),
                                  ':count' => $_POST[$key], );

                    if ($this->isCategory($categoryID))
                    {
                        $res = $this->db->prepared_query('INSERT INTO category_count (recordID, categoryID, count)
                                                            VALUES (:recordID, :categoryID, :count)
                                                            ON DUPLICATE KEY UPDATE count=:count', $vars);
                    }
                }
            }

            $_POST['title'] = ($_POST['title'] != '') ? $_POST['title'] : '- blank -';

            $priority = isset($_POST['priority']) ? $_POST['priority'] : 0;
            $vars = array(':recordID' => (int)$recordID,
                          ':title' => XSSHelpers::sanitizeHTML($_POST['title']),
                          ':priority' => (int)$priority, );

            $res = $this->db->prepared_query('UPDATE records SET
                                                title=:title,
                                                priority=:priority
                                                WHERE recordID=:recordID', $vars);
        }

        foreach ($keys as $key)
        {
            if (is_numeric($key))
            {
                if (!$this->writeDataField($recordID, $key, $series)) {
                    http_response_code(401);
                    return 'No write access (data field)';
                }
            }
            else // Check for keys
            {
                list($tRecordID, $tIndicatorID) = explode('_', $key);
                if ($tRecordID == $recordID
                    && is_numeric($tIndicatorID)) {
                    if (!$this->writeDataField($recordID, $tIndicatorID, $series)) {
                        http_response_code(401);
                        return 'No write access (data field, list)';
                    }
                }

            }
        }

        return 1;
    }

    /**
     * Submit a request and start the workflow if it has not already been submitted
     *
     * @param int $recordID
     *
     * @return int|array
     *
     * Created at: 10/3/2022, 7:40:04 AM (America/New_York)
     */
    public function doSubmit(int $recordID): array
    {
        $recordID = (int)$recordID;

        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT submitted FROM records
                                        WHERE recordID=:recordID', $vars);

        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken']) {
            $return_value = array('status' => 0, 'errors' => array('Invalid Token'));
        } else if (!is_numeric($recordID)) {
            $return_value = array('status' => 0, 'errors' => array('Invalid Record'));
        } else if (!$this->hasWriteAccess($recordID)) {
            $return_value = array('status' => 0, 'errors' => array('No Write Access'));
        } else if ($res[0]['submitted'] > 0) {
            // make sure request isn't already submitted
            $return_value = array('status' => 0, 'errors' => array('Already Submitted'));
        } else {
            $this->db->beginTransaction();

            // write new workflow states
            $vars = array(':recordID' => $recordID);
            $sql = 'SELECT initialStepID, workflowID
                    FROM category_count
                    LEFT JOIN categories USING (categoryID)
                    LEFT JOIN workflows USING (workflowID)
                    WHERE recordID=:recordID
                    AND count > 0';

            $res = $this->db->prepared_query($sql, $vars);

            $workflowIDs = array();
            $hasInitialStep = false;

            foreach ($res as $workflow) {
                if ($workflow['initialStepID'] != 0) {
                    // make sure the initial step is valid
                    $vars = array(':stepID' => $workflow['initialStepID']);
                    $sql = 'SELECT workflowID
                            FROM workflow_steps
                            WHERE stepID=:stepID';

                    $res = $this->db->prepared_query($sql, $vars);

                    if ($res[0]['workflowID'] == $workflow['workflowID']) {
                        $vars = array(':recordID' => $recordID,
                                    ':stepID' => $workflow['initialStepID'], );
                        $this->db->prepared_query('INSERT INTO records_workflow_state (recordID, stepID)
                                                VALUES (:recordID, :stepID)', $vars);
                        $hasInitialStep = true;
                    }
                }

                // check if the request only needs to be marked as submitted (e.g.:for surveys)
                if ($workflow['initialStepID'] == 0) {
                    $vars = array(':workflowID' => $workflow['workflowID']);
                    $sql = 'SELECT workflowID
                            FROM workflow_routes
                            WHERE workflowID=:workflowID
                            AND stepID=-1
                            AND actionType="submit"';

                    $res = $this->db->prepared_query($sql, $vars);

                    if (count($res) > 0) {
                        $hasInitialStep = true;
                    }
                }

                if ($workflow['workflowID'] != 0) {
                    $workflowIDs[] = $workflow['workflowID'];
                }
            }

            if (!$hasInitialStep) {
                $return_value = array('status' => 1, 'errors' => array('Workflow is configured incorrectly'));
            } else {
                $vars = array(':recordID' => $recordID,
                            ':time' => time(), );
                $sql = 'UPDATE records
                        SET submitted=:time, isWritableUser=0, lastStatus = "Submitted"
                        WHERE recordID=:recordID';

                $res = $this->db->prepared_query($sql, $vars);

                $actionUserID = $this->login->getUserID();
                $userMetadata  = $this->employee->getInfoForUserMetadata($actionUserID, false);

                // write history data, actionID 6 = filled dependency
                $vars = array(':recordID' => $recordID,
                            ':userID' => $actionUserID,
                            ':dependencyID' => 5,
                            ':actionType' => 'submit',
                            ':actionTypeID' => 6,
                            ':time' => time(),
                            ':comment' => '',
                            ':userMetadata' => $userMetadata,
                        );
                $sql = 'INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time, comment, userMetadata)
                        VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment, :userMetadata)';

                $res = $this->db->prepared_query($sql, $vars);

                // populate dependency data using new workflow system
                $vars = array(':recordID' => $recordID);
                $sql = 'SELECT dependencyID
                        FROM category_count
                        LEFT JOIN categories USING (categoryID)
                        LEFT JOIN workflows USING (workflowID)
                        LEFT JOIN workflow_steps USING (workflowID)
                        LEFT JOIN step_dependencies USING (stepID)
                        WHERE recordID=:recordID
                            AND count > 0
                            AND workflowID != 0
                        GROUP BY dependencyID';

                $res = $this->db->prepared_query($sql, $vars);

                foreach ($res as $dep) {
                    $vars = array(':recordID' => $recordID,
                                ':dependencyID' => $dep['dependencyID'],
                                ':filled' => 0,
                                ':time' => time(), );
                    $sql = 'INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                            VALUES (:recordID, :dependencyID, :filled, :time)
                            ON DUPLICATE KEY UPDATE filled=:filled, time=:time';

                    $res = $this->db->prepared_query($sql, $vars);
                }

                // mark form as submitted, dependencyID 5 = submitted form
                $vars = array(':recordID' => $recordID,
                            ':dependencyID' => 5,
                            ':filled' => 1,
                            ':time' => time(), );
                $sql = 'INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                        VALUES (:recordID, :dependencyID, :filled, :time)
                        ON DUPLICATE KEY UPDATE filled=:filled, time=:time';

                $res = $this->db->prepared_query($sql, $vars);

                $this->db->commitTransaction();

                $errors = array();
                // trigger initial submit event
                $FormWorkflow = new FormWorkflow($this->db, $this->login, $recordID);
                $FormWorkflow->setEventFolder('../scripts/events/');

                foreach ($workflowIDs as $id) {
                    // The initial step for Requestor is special step id -1
                    $status = $FormWorkflow->handleEvents($id, -1, 'submit', '');

                    if (count($status['errors']) > 0) {
                        try {
                            $errors = array_merge($errors, $status['errors']);
                        } catch (\TypeError $te) {
                            error_log($te);
                        }
                    }
                }

                $return_value = array('status' => 1, 'errors' => $errors);
            }
        }

        return $return_value;
    }

    /**
     * Keep track of number of required questions, number visible, and form branch visibility state
     *
     * @param array dataTable (ref) lookup table of form data.  Used to check if question is answered and for conditional logic assessment
     * @param array formNode form question with potential substructure
     * @param bool parentOrSelfHidden is question and children in hidden state
     * @param int required_visible (ref) number of required questions that are visible
     * @param int required_answered (ref) number of required questions that are answered
     * @param int required_total (ref) total number of required questions found during checking
     * @param int res_max_required total number of required questions on the form
     */
    private function count_required(
        array &$dataTable,
        array $formNode,
        bool $parentOrSelfHidden = false,
        int &$required_visible,
        int &$required_answered,
        int &$required_total,
        int $res_max_required): void
    {
        if((int)$formNode['required'] === 1) {
            $required_total += 1; //keep track to skip calls once all required questions are found.
        }
        //don't care about any of this if the question is in a hidden state
        if($parentOrSelfHidden === false) {
            //Check for conditions and if the state is hidden.
            $format = trim(strtolower($formNode['format']));
            if(!empty($formNode['conditions']) && $formNode['conditions'] !== 'null') {
                $conditions = json_decode(strip_tags($formNode['conditions']));
                $multiChoiceParentFormats = array('multiselect', 'checkboxes');
                $singleChoiceParentFormats = array('radio', 'dropdown', 'number', 'currency');
                $conditionMet = false;
                foreach ($conditions as $c) {
                    if ($c->childFormat === $format &&
                        (strtolower($c->selectedOutcome) === 'hide' || strtolower($c->selectedOutcome) === 'show')) {

                        $parentFormat = $c->parentFormat;
                        $conditionParentValue = preg_split('/\R/', $c->selectedParentValue) ?? [];
                        $currentParentDataValue = preg_replace('/&apos;/', '&#039;', $dataTable[$c->parentIndID] ?? '');
                        /* if ($parentFormat === 'checkbox') { //single checkbox ifthen is either checked or not checked (pending parent checkbox)
                            $currentParentDataValue = !empty($currentParentDataValue) && $currentParentDataValue !== 'no' ? '1' : '0';
                        } */
                        if (in_array($parentFormat, $multiChoiceParentFormats)) {
                            $currentParentDataValue = @unserialize($currentParentDataValue) === false ?
                                array($currentParentDataValue) : unserialize($currentParentDataValue);
                        } else {
                            $currentParentDataValue = array($currentParentDataValue);
                        }

                        $operator = $c->selectedOp;
                        switch ($operator) {
                            case '==':
                            case '!=':
                                if (in_array($parentFormat, $multiChoiceParentFormats)) {
                                    //true if the current data value includes any of the condition values
                                    foreach ($currentParentDataValue as $v) {
                                        if (in_array($v, $conditionParentValue)) {
                                            $conditionMet = true;
                                            break;
                                        }
                                    }
                                } else if (in_array($parentFormat, $singleChoiceParentFormats) && $currentParentDataValue[0] === $conditionParentValue[0]) {
                                    $conditionMet = true;
                                }
                                if($operator === "!=") {
                                    $conditionMet = !$conditionMet;
                                }
                                break;
                            case 'gt':
                            case 'gte':
                            case 'lt':
                            case 'lte':
                                $arrNumVals = array();
                                $arrNumComp = array();
                                foreach($currentParentDataValue as $v) {
                                    if(is_numeric($v)) {
                                        $arrNumVals[] = (float) $v;
                                    }
                                }
                                foreach($conditionParentValue as $cval) {
                                    if(is_numeric($cval)) {
                                        $arrNumComp[] = (float) $cval;
                                    }
                                }
                                $useOrEqual = str_contains($operator, 'e');
                                $useGreaterThan = str_contains($operator, 'g');
                                $lenValues = count(array_values($arrNumVals));
                                $lenCompare = count(array_values($arrNumComp));
                                if($lenCompare > 0) {
                                    for ($i = 0; $i < $lenValues; $i++) {
                                        $currVal = $arrNumVals[$i];
                                        if($useGreaterThan === true) {
                                            $conditionMet = $useOrEqual === true ? $currVal >= max($arrNumComp) : $currVal > max($arrNumComp);
                                        } else {
                                            $conditionMet = $useOrEqual === true ? $currVal <= min($arrNumComp) : $currVal < min($arrNumComp);
                                        }
                                        if($conditionMet === true) {
                                            break;
                                        }
                                    }
                                }
                                break;
                            default:
                            break;
                        }
                    }
                    //if in hidden state, set parenthidden to true and break out of condition checking.
                    if (($conditionMet === false && strtolower($c->selectedOutcome) === 'show') ||
                        ($conditionMet === true && strtolower($c->selectedOutcome) === 'hide')) {
                        $parentOrSelfHidden = true;
                        break;
                    }
                }
                unset($conditions);
            }

            //if not in hidden state and required: increment required total.  Check for answer and increment answered total if answered.
            if(!$parentOrSelfHidden && (int)$formNode['required'] === 1) {
                $required_visible += 1;
                $answered = false;
                $val = $formNode['value'];
                if(isset($val) && $val !== '') {
                    /*value property is already processed based on format and could be string or array.
                    Convert to array for more consistent comparison and to simplify checkbox(es) and grid formats.*/
                    $valType = gettype($val);

                    $arrVal = array();
                    if($valType === 'array') {
                        $arrVal = $val;
                    } elseif ($valType === 'string') {
                        $val = trim($val);
                        $arrVal =  @unserialize($val) === false ? array($val) : unserialize($val);
                    }
                    //these formats can have values despite being unanswered ('no', or serialized data about the entry)
                    $specialFormat = $format === 'checkbox' || $format === 'checkboxes' || $format === 'grid';
                    if ($specialFormat === true) {
                        if($format === 'grid') {
                            $hasInput = isset($arrVal['cells']);
                            $gridContainsEmptyValue = !$hasInput;
                            if($hasInput) {
                                $arrRowEntries = $arrVal['cells'];
                                foreach ($arrRowEntries as $row) {
                                    if (in_array("", $row)) {
                                        $gridContainsEmptyValue = true;
                                        break;
                                    }
                                }
                            }
                            $answered = !$gridContainsEmptyValue;

                        } else {
                            //checkbox(es) - only one needed
                            foreach($arrVal as $ele) {
                                if ($ele !== '' && $ele !== 'no') {
                                    $answered = true;
                                    break;
                                }
                            }
                        }

                    //any other format, confirm the element is not an empty string
                    } else {
                        $answered = $arrVal[0] !== '';
                    }
                }

                if($answered === true) {
                    $required_answered += 1;
                }
            }
        }
        //progress tree depth if required total is not at max.
        if(isset($formNode['child'])) {
            foreach($formNode['child'] as $child) {
                if($required_total < $res_max_required) {
                    $this->count_required(
                        $dataTable,
                        $child,
                        $parentOrSelfHidden,
                        $required_visible,
                        $required_answered,
                        $required_total,
                        $res_max_required
                    );
                }
            }
        }
    }

    /**
     * Get the progress percentage (as integer), accounting for conditinally hidden questions
     * @param int $recordID
     * @return int Percent completed
     */
    public function getProgress(int $recordID): int
    {
        $subSQL = 'SELECT submitted, categoryID FROM records
            LEFT JOIN category_count USING (recordID)
            WHERE recordID=:recordID';
        $subVars = array(':recordID' => (int)$recordID);

        $resRecordInfoEachForm = $this->db->prepared_query($subSQL, $subVars);

        //Check if submitted, return 100 if it is.  Get catIDs for otherwise.
        $categoryIDs = array();
        foreach ($resRecordInfoEachForm as $request) {
            $categoryIDs[] = $request['categoryID'];
            if ($request['submitted'] > 0) {
                return 100;
            }
        }

        $maxRequiredSQL = "SELECT `indicatorID` FROM `indicators`
            WHERE `required`=1 AND `disabled`=0 AND FIND_IN_SET(categoryID, :categoryIDs)";
        $maxRequiredVars = array(
            ":categoryIDs" => implode(",", $categoryIDs)
        );
        $resMaxRequired =  count($this->db->prepared_query($maxRequiredSQL, $maxRequiredVars));

        //Check max count.  Return 100 if there are none.  Otherwise use this count for total checking.
        if ($resMaxRequired === 0) {
            return 100;
        }

        $dataSQL = "SELECT `indicatorID`, `format`, TRIM(`data`) as `data` FROM `data`
            LEFT JOIN indicators USING (indicatorID)
            WHERE recordID=:recordID
            AND indicators.disabled = 0
            AND TRIM(`data`) != ''";
        $dataVars = array(':recordID' => (int)$recordID);
        $resData = $this->db->prepared_query($dataSQL, $dataVars);

        $dataTable = array();
        foreach($resData as $d) {
            $dataTable[$d['indicatorID']] = $d['data'];
        }

        $requiredVisible = 0;
        $requiredAnswered = 0;
        $requiredTotal = 0;

        $fullForm = $this->getFullForm($recordID);
        foreach($fullForm as $page) {
            if($requiredTotal < $resMaxRequired) {
                $this->count_required($dataTable, $page, false, $requiredVisible, $requiredAnswered, $requiredTotal, $resMaxRequired);
            }
        }

        $returnValue = 0;
        if ($requiredVisible === 0) {
            $returnValue = 100;
        } else {
            $returnValue = round(100 * ($requiredAnswered / $requiredVisible));
        }
        return $returnValue;
    }

    /**
     * Checks if the current user has write access
     * Users should have write access if they are in "posession" of a request (they are currently reviewing it)
     * @param int $recordID
     * @param int $categoryID
     * @param int $indicatorID
     * @return int 1 = has access, 0 = no access
     */
    public function hasWriteAccess($recordID, $categoryID = 0, $indicatorID = 0)
    {
        // if an indicatorID is specified, find out what the indicator's categoryID is
        if (isset($this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"]))
        {
            $categoryID = $this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"];
        }
        else
        {
            if ($indicatorID != 0)
            {
                $vars = array(':indicatorID' => (int)$indicatorID);
                $res = $this->db->prepared_query('SELECT * FROM indicators WHERE indicatorID=:indicatorID', $vars);
                if (isset($res[0]['categoryID']))
                {
                    $categoryID = $res[0]['categoryID'];
                    $this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"] = $categoryID;
                    $this->log["write"]["{$recordID}_{$categoryID}_{$indicatorID}"] = "Indicator {$indicatorID} is associated with {$categoryID}.";
                }
                else
                {
                    $this->log["write"]["{$recordID}_{$categoryID}_{$indicatorID}"] = "Indicator {$indicatorID} on record {$recordID} is not associated with any form.";
                }
            }
        }

        $multipleCategories = array();
        if ($categoryID === 0
            && $indicatorID == 0)
        {
            $categoryID = '';
            $vars = array(':recordID' => (int)$recordID);
            $res = $this->db->prepared_query('SELECT * FROM category_count
        										WHERE recordID=:recordID
        										GROUP BY categoryID', $vars);
            foreach ($res as $type)
            {
                $categoryID .= $type['categoryID'];
                $multipleCategories[] = $type['categoryID'];
            }
        }

        // check cached result
        if (isset($this->cache["hasWriteAccess_{$recordID}_{$categoryID}"]))
        {
            return $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"];
        }

        $resRecords = null;
        if (isset($this->cache["resRecords_{$recordID}"]))
        {
            $resRecords = $this->cache["resRecords_{$recordID}"];
        }
        else
        {
            $vars = array(':recordID' => (int)$recordID);
            $resRecords = $this->db->prepared_query('SELECT userID, isWritableUser, isWritableGroup FROM records
                                                WHERE recordID=:recordID', $vars);
            $this->cache["resRecords_{$recordID}"] = $resRecords;
        }

        // give the requestor access if the record explictly gives them write access
        if ($resRecords[0]['isWritableUser'] == 1 &&
            (strtolower($this->login->getUserID()) == strtolower($resRecords[0]['userID']) || $this->checkIfBackupUserName($resRecords[0]['userID']))
        )
        {
            $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;
            $this->log["write"]["{$recordID}_{$categoryID}_writable"] = "You are a writable user or initiator of record {$recordID}, {$categoryID}.";

            return 1;
        }
        $this->log["write"]["{$recordID}_{$categoryID}_writable"] = "You are not a writable user or initiator of record {$recordID}, {$categoryID}.";

        // give admins access
        if ($this->login->checkGroup(1))
        {
            $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;
            $this->log["write"]["{$recordID}_{$categoryID}_admin"] = 'You are an admin.';

            return 1;
        }
        $this->log["write"]["{$recordID}_{$categoryID}_admin"] = 'You are not an admin.';

        // find out if explicit permissions have been granted to any groups
        if (count($multipleCategories) <= 1)
        {
            $resCategoryPrivs = null;
            $cacheHash = 'hasWriteAccess_catPrivs_'.$categoryID.$this->login->getUserID();
            if(isset($this->cache[$cacheHash])) {
                $resCategoryPrivs = $this->cache[$cacheHash];
            }
            else {
                $vars = array(':categoryID' => $categoryID,
                              ':userID' => $this->login->getUserID());
                $resCategoryPrivs = $this->db->prepared_query('SELECT COUNT(*) FROM category_privs
                                                            LEFT JOIN users USING (groupID)
                                                            WHERE categoryID=:categoryID
                                                                AND userID=:userID
                                                                AND writable=1
                                                                AND active=1', $vars);
                $this->cache[$cacheHash] = $resCategoryPrivs;
            }

            if ($resCategoryPrivs[0]['COUNT(*)'] > 0)
            {
                $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;
                $this->log["write"]["{$recordID}_{$categoryID}_group"] = 'You are in group with appropriate write permissions.';

                return 1;
            }
            $this->log["write"]["{$recordID}_{$categoryID}_group"] = 'You are not in group with appropriate write permissions.';
        }
        else
        {
            foreach ($multipleCategories as $category)
            {
                $vars = array(':categoryID' => $category,
                              ':userID' => $this->login->getUserID(), );
                $resCategoryPrivs = $this->db->prepared_query('SELECT COUNT(*) FROM category_privs
                                                        LEFT JOIN users USING (groupID)
                                                        WHERE categoryID=:categoryID
                                                            AND userID=:userID
            												AND writable=1
                                                            AND active=1', $vars);

                if ($resCategoryPrivs[0]['COUNT(*)'] > 0)
                {
                    $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;
                    $this->log["write"]["{$recordID}_{$categoryID}_group"] = 'You are in group with appropriate write permissions.';

                    return 1;
                }
                $this->log["write"]["{$recordID}_{$categoryID}_group"] = 'You are not in group with appropriate write permissions.';
            }
        }

        // grant permissions to whoever currently "has" the form (whoever is the current approver)
        $vars = array(':recordID' => (int)$recordID);
        $resRecordPrivs = $this->db->prepared_query('SELECT recordID, groupID, dependencyID, records.userID, serviceID, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID FROM records_workflow_state
        												LEFT JOIN step_dependencies USING (stepID)
        												LEFT JOIN workflow_steps USING (stepID)
        												LEFT JOIN dependency_privs USING (dependencyID)
                                                        LEFT JOIN users USING (groupID)
        												LEFT JOIN records USING (recordID)
                                                        WHERE recordID=:recordID', $vars);
        foreach ($resRecordPrivs as $priv)
        {
            if ($this->hasDependencyAccess($priv['dependencyID'], $priv))
            {
                $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;
                $this->log["write"]["{$recordID}_{$categoryID}_dependency"] = 'You are a dependency.';

                return 1;
            }
            $this->log["write"]["{$recordID}_{$categoryID}_dependency"] = 'You are not a dependency.';
        }

        // default no access
        $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 0;

        return 0;
    }

    /**
     * Checks if the current user has read access to a form
     * @param int $recordID
     * @param int $categoryID
     * @param int $indicatorID
     * @return int 1 = has access, 0 = no access
     */
    public function hasReadAccess($recordID)
    {
        if (isset($this->cache["hasReadAccess_{$recordID}"]))
        {
            return $this->cache["hasReadAccess_{$recordID}"];
        }

        if ($this->isNeedToKnow($recordID))
        {
            $query[$recordID]['recordID'] = $recordID;
            $resRead = $this->checkReadAccess($query);
            if (!isset($resRead[$recordID]))
            {
                $this->cache["hasReadAccess_{$recordID}"] = 0;
                $this->log["read"]["{$recordID}"] = "Record {$recordID} is need to know and you do not have read access.";

                return 0;
            }
            $this->log["read"]["{$recordID}"] = "Record {$recordID} is need to know but you have read access.";
        }
        else
        {
            $this->log["read"]["{$recordID}"] = "Record {$recordID} is not need to know.";
        }
        $this->cache["hasReadAccess_{$recordID}"] = 1;

        return 1;
    }

    /**
     * Checks if the current user has access to a particular dependency
     * @param int $dependencyID
     * @param array $details - Associative Array containing dependency-specific details, eg: $details['groupID']
     *                         Must contain DB reference to records.userID
     * @return boolean
     */
    public function hasDependencyAccess($dependencyID, $details)
    {
        switch ($dependencyID) {
            case 1:
                if ($this->login->checkService($details['serviceID']))
                {
                    return true;
                }

                break;
            case 8:
                $quadGroupIDs = $this->login->getQuadradGroupID();
                $res3 = array();
                if ($quadGroupIDs != 0)
                {
                    if (isset($this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']]))
                    {
                        $res3 = $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']];
                    }
                    else
                    {
                        $vars3 = array(':serviceID' => (int)$details['serviceID']);
                        $res3 = $this->db->prepared_query("SELECT * FROM services
    							WHERE groupID IN ($quadGroupIDs)
    							AND serviceID=:serviceID", $vars3);
                        $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']] = $res3;
                    }
                }

                if (isset($res3[0]))
                {
                    return true;
                }

                break;
            case -1: // dependencyID -1 : person designated by the requestor
                $empUID = 0;
                if (isset($this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']]))
                {
                    $empUID = $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']];
                }
                else
                {
                    $vars = array(':indicatorID' => (int)$details['indicatorID_for_assigned_empUID'],
                            ':recordID' => (int)$details['recordID'], );
                    $resEmpUID = $this->db->prepared_query('SELECT * FROM data
                                                                        WHERE recordID=:recordID
                                                                            AND indicatorID=:indicatorID
                                                                            AND series=1', $vars);
                    if (isset($resEmpUID[0]))
                    {
                        $empUID = $resEmpUID[0]['data'];
                        $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']] = $empUID;
                    }
                }

                if ($empUID == $this->login->getEmpUID())
                {
                    return true;
                }

                if($this->checkIfBackup($empUID)) {
                    return true;
                }

                break;
            case -2: // dependencyID -2 : requestor followup
                 if (strtolower($details['userID']) == strtolower($this->login->getUserID()))
                 {
                     return true;
                 }
                 else
                 {
                    return $this->checkIfBackupUserName($details['userID']);
                 }
                 // unreachable code so no break
            case -3: // dependencyID -3 : group designated by the requestor
                $groupID = 0;
                if (isset($this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']]))
                {
                    $groupID = $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']];
                }
                else
                {
                    $vars = array(':indicatorID' => (int)$details['indicatorID_for_assigned_groupID'],
                                  ':recordID' => (int)$details['recordID'], );
                    $resGroupID = $this->db->prepared_query('SELECT * FROM data
                                                                       WHERE recordID=:recordID
                                                                           AND indicatorID=:indicatorID
                                                                           AND series=1', $vars);
                    if (isset($resGroupID[0]))
                    {
                        $groupID = $resGroupID[0]['data'];
                        $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']] = $groupID;
                    }
                }

                if ($this->login->checkGroup($groupID))
                {
                    return true;
                }

                break;
            default:
                if ($this->login->checkGroup($details['groupID']))
                {
                    return true;
                }

                break;
        }

        return false;
    }

    /**
     * batchUpdateDependencyAccess amends $accessList for specific dependencyIDs to optimize
     * performance related to dynamic assignments, such as "person/group designated by requestor"
     *
     * @param array $accessList Map of recordID->int of the current user's access. 1 = has access
     * @param array $records List of records to process
     * @return array Amended $accessList
     */
    private function batchUpdateDependencyAccess(array $accessList, array $records): array
    {
        // get sanitized lists for DB query
        $indicatorIDs_pd = [];
        $recordIDs_pd = [];
        $indicatorIDs_gd = [];
        $recordIDs_gd = [];
        foreach($records as $dep) {
            if($accessList[$dep['recordID']] == 0 && $dep['dependencyID'] == -1) {
                $indicatorIDs_pd[] = (int)$dep['indicatorID_for_assigned_empUID'];
                $recordIDs_pd[] = (int)$dep['recordID'];
            }

            if($accessList[$dep['recordID']] == 0 && $dep['dependencyID'] == -3) {
                $indicatorIDs_gd[] = (int)$dep['indicatorID_for_assigned_groupID'];
                $recordIDs_gd[] = (int)$dep['recordID'];
            }
        }

        // get the list of records related to dependencyID -1 (person designated by requestor)
        if(count($recordIDs_pd) > 0) {
            $indicators = implode(',', array_unique($indicatorIDs_pd));
            $records = implode(',', $recordIDs_pd);
            $query = "SELECT recordID, `data` FROM `data`
                        WHERE indicatorID IN ({$indicators})
                            AND recordID IN ({$records})
                            AND series=1";
            $res = $this->db->prepared_query($query, []);

            foreach($res as $record) {
                // check if the current user is the designated person
                if($record['data'] == $this->login->getEmpUID()) {
                    $accessList[$record['recordID']] = 1;
                }
                // check if the current user is a backup of the designated person
                else if($this->checkIfBackup($record['data'])) {
                    $accessList[$record['recordID']] = 1;
                }
            }
        }

        // get the list of records related to dependencyID -3 (group designated by requestor)
        if(count($recordIDs_gd) > 0) {
            $indicators = implode(',', array_unique($indicatorIDs_gd));
            $records = implode(',', $recordIDs_gd);
            $query = "SELECT recordID, `data` FROM `data`
                        WHERE indicatorID IN ({$indicators})
                            AND recordID IN ({$records})
                            AND series=1";
            $res = $this->db->prepared_query($query, []);

            foreach($res as $record) {
                // check if the current users is a member of the designated group
                if($this->login->checkGroup($record['data'])) {
                    $accessList[$record['recordID']] = 1;
                }
            }
        }

        return $accessList;
    }

    /**
     * getEmpUID translates a userName to empUID
     *
     * @param string $userName
     * @return int
     */
    public function getEmpUID($userName): int
    {
        if(isset($this->cache['getEmpUID_'. $userName])) {
            return $this->cache['getEmpUID_'. $userName];
        }
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        $response = $nexusDB->prepared_query('SELECT empUID FROM employee WHERE userName =:userName', $vars);
        $this->cache['getEmpUID_'. $userName] = (int)$response[0]["empUID"];

        return $this->cache['getEmpUID_'. $userName];
    }

    /**
     * checkIfBackup determines if the current user is a backup of the provided $empUID
     *
     * @param string $empUID empUID to check
     * @return boolean
     */
    public function checkIfBackup(string|int $empUID): bool
    {
        $empUID = (int)$empUID;

        if(isset($this->cache['checkIfBackup'])) {
            return isset($this->cache['checkIfBackup'][$empUID]);
        }

        $nexusDB = $this->login->getNexusDB();

        $vars = array(':currEmpUID' => $this->login->getEmpUID());
        $strSQL = 'SELECT empUID FROM relation_employee_backup
                    WHERE backupEmpUID =:currEmpUID
                        AND approved=1';
        $backupIds = $nexusDB->prepared_query($strSQL, $vars);

        $this->cache['checkIfBackup'] = [];
        foreach ($backupIds as $row)
        {
            $this->cache['checkIfBackup'][$row['empUID']] = true;
        }

        return isset($this->cache['checkIfBackup'][$empUID]);
    }

    /**
     * checkIfBackupUserName determines if the current user is a backup of the provided $userName
     *
     * @param string $empUID empUID to check
     * @return boolean
     */
    public function checkIfBackupUserName(string $userName): bool
    {
        $userName = strtolower($userName);
        if(isset($this->cache['checkIfBackupUserName'])) {
            return isset($this->cache['checkIfBackupUserName'][$userName]);
        }

        $nexusDB = $this->login->getNexusDB();

        $vars = array(':currEmpUID' => $this->login->getEmpUID());
        $strSQL = 'SELECT userName FROM relation_employee_backup
                    INNER JOIN employee USING (empUID)
                    WHERE backupEmpUID =:currEmpUID
                        AND approved=1';
        $backupIds = $nexusDB->prepared_query($strSQL, $vars);

        $this->cache['checkIfBackupUserName'] = [];
        foreach ($backupIds as $row)
        {
            $this->cache['checkIfBackupUserName'][strtolower($row['userName'])] = true;
        }

        return isset($this->cache['checkIfBackupUserName'][$userName]);
    }

    /**
     * Scrubs a list of records to remove records that the current user doesn't have access to
     * Defaults to enable read access, unless needToKnow mode is set for any form
     * @param array
     * @return array Returns the input array, scrubbing records that the current user doesn't have access to
     */
    public function checkReadAccess($records)
    {
        if (count($records) > 0) {

            $recordIDs = '';

            foreach ($records as $item) {
                if (is_numeric($item['recordID'])) {
                    $recordIDs .= $item['recordID'] . ',';
                }
            }

            $recordIDs = trim($recordIDs, ',');
            $recordIDsHash = sha1($recordIDs);

            $res = array();
            $hasCategoryAccess = array(); // the keys will be categoryIDs that the current user has access to
            if (isset($this->cache["checkReadAccess_{$recordIDsHash}"])) {
                $res = $this->cache["checkReadAccess_{$recordIDsHash}"];
            } else {
                // get a list of records which have categories marked as need-to-know
                $vars = array();
                $query =
                    "SELECT recordID, categoryID, dependencyID, groupID, serviceID, userID,
                            indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID
                    FROM records
                    LEFT JOIN category_count USING (recordID)
                    LEFT JOIN categories USING (categoryID)
                    LEFT JOIN workflows USING (workflowID)
                    LEFT JOIN workflow_steps USING (workflowID)
                    LEFT JOIN step_dependencies USING (stepID)
                    LEFT JOIN dependency_privs USING (dependencyID)
                    WHERE recordID IN ({$recordIDs})
                    AND needToKnow = 1
                    AND count > 0";

                $res = $this->db->prepared_query($query, $vars);

                // if a needToKnow form doesn't have a workflow (eg: general info), pull in approval chain for associated forms
                $t_needToKnowRecords = '';
                $t_uniqueCategories = array();

                foreach ($res as $dep) {
                    if (is_null($dep['dependencyID']) && is_numeric($dep['recordID'])) {
                        $t_needToKnowRecords .= $dep['recordID'] . ',';
                    }

                    // keep track of unique categories
                    if (isset($dep['categoryID']) && !isset($t_uniqueCategories[$dep['categoryID']])) {
                        $t_uniqueCategories[$dep['categoryID']] = 1;
                    }
                }

                $t_needToKnowRecords = trim($t_needToKnowRecords, ',');

                if ($t_needToKnowRecords != '') {
                    $vars = array();
                    $sql = "SELECT recordID, dependencyID, groupID, serviceID, userID,
                                indicatorID_for_assigned_empUID,
                                indicatorID_for_assigned_groupID
                            FROM records
                            LEFT JOIN category_count USING (recordID)
                            LEFT JOIN categories USING (categoryID)
                            LEFT JOIN workflows USING (workflowID)
                            LEFT JOIN workflow_steps USING (workflowID)
                            LEFT JOIN step_dependencies USING (stepID)
                            LEFT JOIN dependency_privs USING (dependencyID)
                            WHERE recordID IN ({$t_needToKnowRecords})
                            AND needToKnow = 0
                            AND count > 0";

                    $res2 = $this->db->prepared_query($sql, $vars);

                    try {
                        $res = array_merge($res, $res2);
                    } catch (\TypeError $te) {
                        error_log($te);
                    }
                }

                // find out if "collaborator access" is being used for any categoryID in the set
                // and whether the current user has access
                $uniqueCategoryIDs = '';

                foreach ($t_uniqueCategories as $key => $value)
                {
                    $uniqueCategoryIDs .= "'{$key}',";
                }

                $uniqueCategoryIDs = trim($uniqueCategoryIDs, ',');
                $uniqueCategoryIDs = $uniqueCategoryIDs ? : 0;

                if (!empty($uniqueCategoryIDs)) {
                    $sql = "SELECT groupID, categoryID
                            FROM category_privs
                            WHERE categoryID IN ({$uniqueCategoryIDs})
                            AND readable = 1";

                    $catsInGroups = $this->db->prepared_query($sql, array());

                    if (count($catsInGroups) > 0) {
                        $groups = $this->login->getMembership();
                        foreach ($catsInGroups as $cat) {
                            if (isset($groups['groupID'][$cat['groupID']]) && $groups['groupID'][$cat['groupID']] == 1) {
                                $hasCategoryAccess[$cat['categoryID']] = 1;
                            }
                        }
                    }
                }

                $this->cache["checkReadAccess_{$recordIDsHash}"] = $res;
            }

            // don't scrub anything if no limits are in place or admin group
            if (count($res) == 0 || $this->login->checkGroup(1)) {
                $return_value = $records;
            } else {
                // initialize empty array to map recordID->hasAccess as int. 1 = has access
                $temp = isset($this->cache['checkReadAccess_tempArray']) ? $this->cache['checkReadAccess_tempArray'] : array();

                // grant access
                foreach ($res as $dep) {
                    if (!isset($temp[$dep['recordID']]) || $temp[$dep['recordID']] == 0) {
                        $temp[$dep['recordID']] = 0;

                        // Use optimized path for certain dependencyIDs. See batchUpdateDependencyAccess.
                        if($dep['dependencyID'] != -1 // person designated by requestor
                            && $dep['dependencyID'] != -3) // group designated by requestor
                        {
                            $temp[$dep['recordID']] = $this->hasDependencyAccess($dep['dependencyID'], $dep) ? 1 : 0;
                        }

                        // request initiator
                        if (strtolower($dep['userID']) == strtolower($this->login->getUserID())) {
                            $temp[$dep['recordID']] = 1;
                        }

                        // backup of the request initiator
                        if($temp[$dep['recordID']] == 0 && $this->checkIfBackupUserName($dep['userID'])) {
                            $temp[$dep['recordID']] = 1;
                        }

                        // collaborator access
                        if (isset($dep['categoryID']) && isset($hasCategoryAccess[$dep['categoryID']])) {
                            $temp[$dep['recordID']] = 1;
                        }
                    }
                }

                $temp = $this->batchUpdateDependencyAccess($temp, $res);

                $this->cache['checkReadAccess_tempArray'] = $temp;

                $countPurged = 0;
                foreach ($records as $record) {
                    if (isset($temp[$record['recordID']]) && $temp[$record['recordID']] == 0) {
                        unset($records[$record['recordID']]);
                        $countPurged++;
                    }
                }

                if($countPurged > 0 && !headers_sent()) {
                    header('LEAF-Query: continue');
                }

                $return_value = $records;
            }
        } else {
            $return_value = $records;
        }

        return $return_value;
    }

    /**
     * Check if field is masked/protected
     * @param int $indicatorID
     * @param int $recordID
     * @return int (0 = not masked, 1 = masked)
     */
    public function isMasked($indicatorID, $recordID = null)
    {
        $vars = array(':indicatorID' => (int)$indicatorID);
        $res = $this->db->prepared_query('SELECT * FROM indicator_mask WHERE indicatorID = :indicatorID', $vars);
        if (count($res) == 0)
        {
            return 0;
        }

        if (is_numeric($recordID) && ($this->getOwnerID($recordID) == $this->login->getUserID()))
        {
            return 0;
        }
        foreach ($res as $indicator)
        {
            if ($this->login->checkGroup($indicator['groupID']))
            {
                return 0;
            }
        }

        return 1;
    }

    /**
     * Check if need to know mode is enabled for any form, or a specific form
     * @param int $recordID
     * @return boolean
     */
    public function isNeedToKnow($recordID = null)
    {
        if (isset($this->cache['isNeedToKnow_' . $recordID]))
        {
            return $this->cache['isNeedToKnow_' . $recordID];
        }

        if ($recordID == null)
        {
            $vars = array();
            $res = $this->db->prepared_query('SELECT * FROM categories WHERE needToKnow = 1', $vars);
            if (count($res) == 0)
            {
                $this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }
        else
        {
            $vars = array(':recordID' => (int)$recordID);
            $res = $this->db->prepared_query('SELECT * FROM category_count
    											LEFT JOIN categories USING (categoryID)
    											WHERE recordID=:recordID
    												AND needToKnow = 1
    												AND count > 0', $vars);
            if (count($res) == 0)
            {
                $this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }

        $this->cache['isNeedToKnow_' . $recordID] = true;

        return true;
    }

    public function getDependencyStatus($recordID)
    {
        // check privileges
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }

        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM records_dependencies
                                            LEFT JOIN dependencies USING (dependencyID)
                                            RIGHT JOIN category_count USING (recordID)
                                            WHERE recordID=:recordID
                                            GROUP BY dependencyID', $vars);

        return $res;
    }

    public function openForEditing($recordID)
    {
        $vars = array(':recordID' => (int)$recordID);
        $res = $this->db->prepared_query('UPDATE records SET
                                            submitted=0, isWritableUser=1, lastStatus="Re-opened for editing"
                                            WHERE recordID=:recordID', $vars);
        $res = $this->db->prepared_query('UPDATE records_dependencies SET
                                            filled=0
                                            WHERE recordID=:recordID', $vars);
        // delete state
        $this->db->prepared_query('DELETE FROM records_workflow_state
                                        WHERE recordID=:recordID', $vars);
    }

    public function getChildForms($recordID)
    {
        $vars = array(':recordID' => (int)$recordID);
        $res = $this->db->prepared_query('SELECT * FROM category_count
                                            RIGHT JOIN (
                                                SELECT categoryID as childCategoryID,
                                                       categoryName as childCategoryName,
                                                       categoryDescription as childCategoryDescription,
                                                       parentID
                                                       FROM categories
                                                       WHERE disabled = 0
                                                ) j1
                                                ON category_count.categoryID = j1.parentID
                                            WHERE recordID = :recordID
                                                AND count > 0
        									ORDER BY childCategoryName ASC', $vars);

        return $res;
    }

    /* getCustomData iterates through an array of $recordID_list and incorporates any associated data
     * specified by $indicatorID_list (string of ID#'s delimited by ',')
     *
     * WARNING: $alreadyCheckedReadAccess can only be set to true if $recordID_list has been
     *          processed by checkReadAccess().
     *
     * @param array $recordID_list
     * @param array $indicatorID_list
     * @param bool (optional) $alreadyCheckedReadAccess
     * @return array on success | boolean false on malformed input
     */
    public function getCustomData(array $recordID_list, string|null $indicatorID_list, bool $alreadyCheckedReadAccess = false): array|bool
    {
        if (count($recordID_list) == 0) {
            return $recordID_list;
        }

        $indicatorID_list = trim($indicatorID_list, ',');
        $tempIndicatorIDs = explode(',', $indicatorID_list);
        $indicatorIdStructure = array();
        foreach ($tempIndicatorIDs as $id)
        {
            if (!is_numeric($id) && $id != '')
            {
                return false; // abort if indicatorID_list is malformed
            }
            $indicatorIdStructure['id' . $id] = null;
        }

        $indicators = array();
        $indicatorDefaults = array();
        if ($indicatorID_list != '')
        {
            $res = $this->db->prepared_query("SELECT * FROM indicators
                                                WHERE indicatorID IN ({$indicatorID_list})", array());
            if (count($res) > 0)
            {
                foreach ($res as $item)
                {
                    $indicators[$item['indicatorID']] = $item;
                    if ($item['default'] != '')
                    {
                        $indicatorDefaults['id' . $item['indicatorID']] = '( ' . $item['default'] . ' )';
                    }
                    if ($item['htmlPrint'] != '')
                    {
                        $indicatorIdStructure['id' . $item['indicatorID'] . '_htmlPrint'] = $item['htmlPrint'];
                    }
                }
            }
        }

        $recordIDs = '';
        $recordData = array();
        $out = array();
        foreach ($recordID_list as $id)
        {
            if (!is_numeric($id['recordID']) && $id['recordID'] != '')
            {
                return false;
            }

            $recordIDs .= $id['recordID'] . ',';
            $recordData[$id['recordID']] = $id;

            if (!isset($out[$id['recordID']]['title']))
            {
                $imported = array_keys($id);
                foreach ($imported as $importedKey)
                {
                    $out[$id['recordID']][$importedKey] = $id[$importedKey];
                }
            }

            if ($indicatorID_list != '')
            {
                $out[$id['recordID']]['s1'] = $indicatorIdStructure; // initialize structure
            }
        }
        $recordIDs = trim($recordIDs, ',');

        if ($indicatorID_list == '')
        {
            return $out;
        }

        // already made sure that $indicatorID_list and $recordIDs are comma delimited lists of numbers
        $res = $this->db->prepared_query("SELECT * FROM indicator_mask
                                    WHERE indicatorID IN ({$indicatorID_list})", array());
        $indicatorMasks = array();
        if (count($res) > 0)
        {
            // if indicator_masks exist, see if the user has access
            foreach ($res as $item)
            {
                if (!$this->login->checkGroup($item['groupID']))
                {
                    if (!isset($indicatorMasks[$item['indicatorID']]))
                    {
                        $indicatorMasks[$item['indicatorID']] = 1;
                    }
                }
                else
                {
                    $indicatorMasks[$item['indicatorID']] = 0;
                }
            }
        }

        // if we do not have record IDs then lets not run go any further with this logic
        if (!empty($recordIDs))
        {
            // updated this from "Select * from to this
	    $strSQL = "SELECT * FROM data
                    WHERE indicatorID IN ({$indicatorID_list})
                    AND recordID IN ({$recordIDs})";
            $res = $this->db->query($strSQL);

            if (is_array($res) && count($res) > 0)
            {
                foreach ($res as $item)
                {

                    // handle special data types
                    switch(strtolower($indicators[$item['indicatorID']]['format'])) {
                        case 'date':
                            if ($item['data'] != '' && !is_numeric($item['data']))
                            {
                                $parsedDate = strtotime($item['data']);
                                if ($parsedDate !== false)
                                {
                                    $item['data'] = date('m/d/Y', $parsedDate);
                                }
                            }
                            break;
                        case 'orgchart_employee': //report builder cells, form/query
                            $dataDisplay = "";
                            if(!empty($item['data'])) {
                                $orgchartInfo = array('empUID' => (int)$item['data']);
                                if (isset($item['metadata'])) {
                                    $orgchartInfo = array_merge($orgchartInfo, json_decode($item['metadata'], true));
                                    if(!empty(trim($orgchartInfo['lastName']))) {
                                        $dataDisplay = "{$orgchartInfo['firstName']} {$orgchartInfo['lastName']}";
                                    } else {
                                        $dataDisplay = "Employee #" . $item['data'] ." no longer available";
                                    }
                                }
                                $item['dataOrgchart'] = $orgchartInfo;
                            }
                            $item['data'] = $dataDisplay;
                            break;
                        case 'orgchart_position':
                            $dataDisplay = "";
                            if(!empty(trim($item['data']))) {
                                $positionTitle = $this->position->getTitle($item['data']);
                                if ($positionTitle !== false) {
                                    $positionData = $this->position->getAllData($item['data']);
                                    $dataDisplay = "{$positionTitle} ({$positionData[2]['data']}-{$positionData[13]['data']}-{$positionData[14]['data']})";
                                    $item['dataOrgchart'] = $positionData;
                                    $item['dataOrgchart']['positionID'] = $item['data'];
                                } else {
                                    $dataDisplay = "Position #" . $item['data'] ." no longer available";
                                }
                            }
                            $item['data'] = $dataDisplay;
                            break;
                        case 'orgchart_group':
                            $dataDisplay = "";
                            if(!empty(trim($item['data']))) {
                                $groupTitle = $this->group->getTitle($item['data']);
                                $dataDisplay = $groupTitle !== false ? $groupTitle : "Group #" . $item['data'] ." no longer available";
                            }
                            $item['data'] = $dataDisplay;
                            break;
                        case 'raw_data':
                            if($indicators[$item['indicatorID']]['htmlPrint'] != '') {
                                $item['dataHtmlPrint'] = $indicators[$item['indicatorID']]['htmlPrint'];
                                $pData = isset($indicatorMasks[$item['indicatorID']]) && $indicatorMasks[$item['indicatorID']] == 1 ? '[protected data]' : $item['data'];
                                $item['dataHtmlPrint'] = str_replace('{{ data }}',
                                                            $pData,
                                                            $item['dataHtmlPrint']);
                            }
                            break;
                        default:
                            if (substr($indicators[$item['indicatorID']]['format'], 0, 10) == 'checkboxes' ||
			        substr($indicators[$item['indicatorID']]['format'], 0, 11) == 'multiselect')
			    {
			        $tData = @unserialize($item['data']) !== false ? @unserialize($item['data']) : preg_split('/,(?!\s)/', $item['data']);
			    	$item['data'] = '';
			    	if (is_array($tData))
			    	{
				    foreach ($tData as $tItem)
				    {
				    	if ($tItem != 'no')
				    	{
					    $item['data'] .= "{$tItem}, ";
					    $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID'] . '_array'][] = $tItem;
				       	}
				    }
			    	}
			    	$item['data'] = trim($item['data'], ', ');
			    }
			    if (substr($indicators[$item['indicatorID']]['format'], 0, 4) == 'grid')
			    {
			    	$values = @unserialize($item['data']);
			    	$format = json_decode(substr($indicators[$item['indicatorID']]['format'], 5, -1) . ']', true);
                    try {
                        $item['gridInput'] = array_merge($values, array("format" => $format));
                    } catch (\TypeError $te) {
                        error_log($te);
                    }
			    	$item['data'] = 'id' . $item['indicatorID'] . '_gridInput';
			    }
			    break;
                    }

                    $isProtected = isset($indicatorMasks[$item['indicatorID']]) && $indicatorMasks[$item['indicatorID']] == 1;
                    $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID']] = $isProtected ? '[protected data]' : $item['data'];
                    if (isset($item['dataOrgchart']) && !$isProtected)
                    {
                        $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID'] . '_orgchart'] = $item['dataOrgchart'];
                    }


                    if (isset($item['dataHtmlPrint']))
                    {
                        $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID'] . '_htmlPrint'] = $item['dataHtmlPrint'];
                    }
                    if (isset($item['gridInput']))
                    {
                        $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID'] . '_gridInput'] = $item['gridInput'];
                    }

                    $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID'] . '_timestamp'] = $item['timestamp'];
                }
            }
        }

        // fill out default data
        $outKeys = array_keys($out);
        $indicatorDefaultKeys = array_keys($indicatorDefaults);
        foreach ($outKeys as $tID)
        {
            foreach ($indicatorDefaultKeys as $key)
            {
                if (!isset($out[$tID]['s1'][$key]))
                {
                    $out[$tID]['s1'][$key] = $indicatorDefaults[$key];
                }
            }
        }

        if (!$alreadyCheckedReadAccess && $this->isNeedToKnow())
        {
            $out = $this->checkReadAccess($out);
        }

        return $out;
    }

    /**
     * Retrieve workflow comments and record notes to display
     *
     * @param int $recordID
     *
     * @return array
     *
     * Created at: 10/7/2022, 7:56:06 AM (America/New_York)
     */
    public function getActionComments(int $recordID): array
    {
        if (!$this->hasReadAccess($recordID)) {
            $return_value = array();
        } else {
            $vars = array(':recordID' => $recordID);

            $sql = 'SELECT actionTextPasttense, comment, time, userID, userMetadata
                    FROM action_history
                    LEFT JOIN dependencies USING (dependencyID)
                    LEFT JOIN actions USING (actionType)
                    WHERE recordID = :recordID
                    AND comment != ""
                    UNION
                    SELECT "Note Added", note, timestamp, userID, userMetadata
                    FROM notes
                    WHERE recordID = :recordID
                    AND deleted IS NULL
                    ORDER BY time DESC';

            $res = $this->db->prepared_query($sql, $vars);

            $total = count($res);
            for ($i = 0; $i < $total; $i++) {
                $userMetadata = json_decode($res[$i]['userMetadata'], true);
                $name = isset($userMetadata) && !empty(trim($userMetadata['lastName'])) ?
                    "{$userMetadata['firstName']} {$userMetadata['lastName']}" : $res[$i]['userID'];

                $res[$i]['name'] = $name;
            }

            $return_value = $res;
        }

        return (array) $return_value;
    }

    public function getTags($recordID)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return array();
        }

        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM tags
                                            WHERE recordID=:recordID', $vars);

        return $res;
    }

    public function addTag($recordID, $tag)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }
        $vars = array(':recordID' => (int)$recordID,
                      ':tag' => XSSHelpers::xscrub($tag),
                      ':timestamp' => time(),
                      ':userID' => $this->login->getUserID(), );

        $res = $this->db->prepared_query('INSERT INTO tags (recordID, tag, timestamp, userID)
                                            VALUES (:recordID, :tag, :timestamp, :userID)
                                            ON DUPLICATE KEY UPDATE timestamp=:timestamp', $vars);
    }

    public function deleteTag($recordID, $tag)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }
        $vars = array(':recordID' => (int)$recordID,
                      ':tag' => XSSHelpers::xscrub($tag),
                      ':userID' => $this->login->getUserID(), );

        $res = $this->db->prepared_query('DELETE FROM tags WHERE recordID=:recordID AND userID=:userID AND tag=:tag', $vars);
    }

    // deletes old tags, inserts new ones
    public function parseTags($recordID, $input)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }
        $vars = array(':recordID' => (int)$recordID,
                      ':userID' => $this->login->getUserID(), );
        $res = $this->db->prepared_query('DELETE FROM tags WHERE recordID=:recordID AND userID=:userID', $vars);

        $tags = explode(' ', trim($input));
        foreach ($tags as $tag)
        {
            if (trim($tag) != '')
            {
                $this->addTag((int)$recordID, XSSHelpers::xscrub(trim($tag)));
            }
        }
    }

    public function getTagMembers($tag)
    {
        $vars = array(':tag' => $tag);
        $res = $this->db->prepared_query('SELECT * FROM tags
                                            LEFT JOIN records USING (recordID)
                                            WHERE tag=:tag
                                                AND deleted=0', $vars);

        return $this->checkReadAccess($res);
    }

    public function getUniqueTags()
    {
        $res = $this->db->prepared_query('SELECT tag, COUNT(tag) FROM tags
                                    GROUP BY tag', array());

        return $res;
    }

    public function setTitle($recordID, $title)
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return;
        }
        $title = XSSHelpers::sanitizeHTML($title);

        if ($this->hasWriteAccess($recordID))
        {
            $vars = array(':recordID' => $recordID,
                    ':title' => $title, );
            $res = $this->db->prepared_query('UPDATE records SET
                                            title=:title
                                            WHERE recordID=:recordID', $vars);

            return $title;
        }
    }

    public function setService($recordID, $serviceID)
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken']
            || !is_numeric($serviceID))
        {
            return;
        }

        if ($this->hasWriteAccess($recordID))
        {
            $vars = array(':recordID' => $recordID,
                          ':serviceID' => $serviceID, );
            $res = $this->db->prepared_query('UPDATE records SET
                                            	serviceID=:serviceID
                                            	WHERE recordID=:recordID', $vars);

            return $serviceID;
        }
    }

    public function setInitiator($recordID, $userID)
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return;
        }

        if ($this->login->checkGroup(1))
        {
            $newInitiatorMetadata = $this->employee->getInfoForUserMetadata($userID, false);
            $vars = array(
                ':recordID' => (int)$recordID,
                ':userID' => $userID,
                ':userMetadata' => $newInitiatorMetadata,
            );
            $res = $this->db->prepared_query('UPDATE records SET
                                            	userID=:userID, userMetadata=:userMetadata
                                            	WHERE recordID=:recordID', $vars);


            $newInitiatorInfo = json_decode($newInitiatorMetadata, true);
            $name = "{$newInitiatorInfo['firstName']} {$newInitiatorInfo['lastName']}";

            $actionUserID = $this->login->getUserID();
            $actionUserMetadata  = $this->employee->getInfoForUserMetadata($actionUserID, false);

            $comment = "Initiator changed to {$name}";
            $vars2 = array(
                ':recordID' => (int)$recordID,
                ':userID' => $actionUserID,
                ':dependencyID' => 0,
                ':actionType' => 'changeInitiator',
                ':actionTypeID' => 8,
                ':time' => time(),
                ':comment' => $comment,
                ':userMetadata' => $actionUserMetadata,
            );
            $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time, comment, userMetadata)
                                            VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment, :userMetadata)', $vars2);

            return $userID;
        }
    }

    public function addFormType($recordID, $category)
    {
        // only allow admins
        if (!$this->login->checkGroup(1))
        {
            return 0;
        }

        if ($this->isCategory($category))
        {
            $vars = array(':recordID' => $recordID,
                          ':categoryID' => $category,
                          ':count' => 1, );

            $res = $this->db->prepared_query('INSERT INTO category_count (recordID, categoryID, count)
                                                    VALUES (:recordID, :categoryID, :count)
                                                    ON DUPLICATE KEY UPDATE count=:count', $vars);
        }
        else
        {
            return 0;
        }
    }

    public function changeFormType($recordID, $categories)
    {
        // only allow admins
        if (!$this->login->checkGroup(1))
        {
            return 0;
        }

        $vars = array(':recordID' => $recordID);
        $this->db->prepared_query('UPDATE category_count SET count = 0
    								WHERE recordID=:recordID', $vars);

        foreach ($categories as $category)
        {
            $this->addFormType($recordID, $category);
        }

        return 1;
    }

    /**
     * parseBooleanQuery transforms a user's query to add implied "+" prefixes when
     * a "MATCH ALL" condition is selected.
     *
     * @param $query
     * @return string Transformed query
     */
    private function parseBooleanQuery(string $query): string
    {
        $fulltext_stopwords = array(
            'a' => 1,
            'about' => 1,
            'an' => 1,
            'are' => 1,
            'as' => 1,
            'at' => 1,
            'be' => 1,
            'by' => 1,
            'com' => 1,
            'de' => 1,
            'en' => 1,
            'for' => 1,
            'from' => 1,
            'how' => 1,
            'i' => 1,
            'in' => 1,
            'is' => 1,
            'it' => 1,
            'la' => 1,
            'of' => 1,
            'on' => 1,
            'or' => 1,
            'that'=> 1,
            'the'=> 1,
            'this'=> 1,
            'to' => 1,
            'was' => 1,
            'what' => 1,
            'when' => 1,
            'where' => 1,
            'who' => 1,
            'will' => 1,
            'with' => 1,
            'und' => 1,
            'www' => 1,
        );
        $words = explode(' ', trim($query));

        //Prevent stopwords and words less than 3 characters from being required,
        //since that could cause no results even if the data entry contained them.
        foreach($words as $k => $word) {
            $searchWord = trim($word);
            $firstChar = substr($searchWord, 0, 1);
            if(strlen($searchWord) > 2 && $fulltext_stopwords[strtolower($searchWord)] !== 1 && $firstChar !== '+' && $firstChar !== '-') {
                $words[$k] = '+' . $searchWord;
            } else {
                $words[$k] = $searchWord;
            }
        }
        return implode(' ', $words);
    }

    /**
     * query parses a JSON formatted user query defined in formQuery.js.
     *
     * Returns an array on success, and string/int for malformed queries
     *
     * @param string JSON formatted string of the query
     * @return mixed
     */
    public function query(string $inQuery): mixed
    {
        $query = json_decode(html_entity_decode(html_entity_decode($inQuery)), true);
        if ($query == null)
        {
            return 'Invalid query';
        }

        $joinSearchAllData = false;
        $joinSearchOrgchartEmployeeData = false;
        $filterActionable = false;
        $usingFulltextIndex = false;
        $vars = array();
        $conditions = '';
        $joins = '';
        $count = 0;
        foreach ($query['terms'] as $q)
        {
            // Logic for AND/OR Gate
            if ($count === 0) {
                $gate = '';
                $conditions = '(';
            } else {
                switch ($q['gate']) {
                    case 'OR':
                        $gate = ' OR ';

                        break;
                    default:
                        $gate = ') AND (';

                        break;
                }
            }

            $operator = '';
            switch ($q['operator']) {
                case '>':
                case '>=':
                case '=':
                case '<=':
                case '<':
                case '!=':
                    $operator = $q['operator'];
                    $q['match'] = str_replace('*', '%', $q['match']);

                    break;
                case 'LIKE':
                case 'NOT LIKE':
                    $operator = $q['operator'];
                    if (strpos($q['match'], '*') !== false)
                    {
                        $q['match'] = str_replace('*', '%', $q['match']);
                    }
                    else
                    {
                        $q['match'] = '%' . $q['match'] . '%';
                    }

                    break;
                case 'MATCH ALL': // Only usable when a fulltext index exists AND logic has been implemented
                    $operator = 'MATCH ALL';
                    $usingFulltextIndex = true;
                    break;
                case 'NOT MATCH': // Only usable when a fulltext index exists AND logic has been implemented
                    $operator = 'NOT MATCH';
                    $usingFulltextIndex = true;
                    break;
                case 'MATCH': // Only usable when a fulltext index exists AND logic has been implemented
                    $operator = 'MATCH';
                    $usingFulltextIndex = true;
                    break;
                case 'RIGHT JOIN':
                    break;
                default:
                    return 0;
            }

            if ($q['id'] === 'userID') {
                $q['match'] = htmlspecialchars_decode($q['match'], ENT_QUOTES);
            }
            $vars[':' . $q['id'] . $count] = $q['match'];
            switch ($q['id']) {
                case 'recordID':
                    $conditions .= "{$gate}records.recordID {$operator} :recordID{$count}";

                    break;
                case 'recordIDs':
                    $tempRecordIDs = explode(',', $vars[":recordIDs{$count}"]);
                    $validRecordIDs = '';
                    foreach ($tempRecordIDs as $id)
                    {
                        if (!is_numeric($id) && $id != '')
                        {
                            return false;
                        }
                        $validRecordIDs .= $id . ',';
                    }
                    $validRecordIDs = trim($validRecordIDs, ',');

                    $conditions .= "{$gate}records.recordID IN ({$validRecordIDs})";

                    unset($vars[":recordIDs{$count}"]);

                    break;
                case 'serviceID':
                    $conditions .= "{$gate}serviceID {$operator} :serviceID{$count}";

                    break;
                case 'submitted':
                    $conditions .= "{$gate}submitted {$operator} :submitted{$count}";

                    break;
                case 'deleted':
                    $conditions .= "{$gate}deleted {$operator} :deleted{$count}";

                    break;
                case 'title':
                    $conditions .= "{$gate}title {$operator} :title{$count}";
                    $scrubSpace = array('/^(%\s)+/', '/(\s+%)$/');
                    $vars[':title' . $count] = preg_replace($scrubSpace, '%', $vars[':title' . $count]);

                    break;
                case 'userID':
                    $conditions .= "{$gate}userID {$operator} :userID{$count}";

                    break;
                case 'date': // backwards compatibility
                    $vars[':date' . $count] = strtotime($vars[':date' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':date' . $count . 'b'] = $vars[':date' . $count] + 86400;
                            $conditions .= "{$gate}(date >= :date{$count} AND date <= :date{$count}b)";

                            break;
                        case '<=':
                            $vars[':date' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "{$gate}date {$operator} :date{$count}";

                            break;
                    }

                    break;
                case 'dateInitiated':
                    $vars[':dateInitiated' . $count] = strtotime($vars[':dateInitiated' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':dateInitiated' . $count . 'b'] = $vars[':dateInitiated' . $count] + 86400;
                            $conditions .= "{$gate}(date >= :dateInitiated{$count} AND date <= :dateInitiated{$count}b)";

                            break;
                        case '<=':
                            $vars[':dateInitiated' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "{$gate}date {$operator} :dateInitiated{$count}";

                            break;
                    }

                    break;
                case 'dateSubmitted':
                    $vars[':dateSubmitted' . $count] = strtotime($vars[':dateSubmitted' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':dateSubmitted' . $count . 'b'] = $vars[':dateSubmitted' . $count] + 86400;
                            $conditions .= "{$gate}(submitted >= :dateSubmitted{$count} AND submitted <= :dateSubmitted{$count}b)";

                            break;
                        case '<=':
                            $vars[':dateSubmitted' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "{$gate}submitted {$operator} :dateSubmitted{$count}";

                            break;
                    }

                    break;
                case 'categoryID':
                    if (!str_contains($joins,'lj_category_count')) {
                        $joins .= "LEFT JOIN (SELECT * FROM category_count WHERE count > 0) lj_category_count USING (recordID) ";
                    }
                    if ($q['operator'] != '!=')
                    {
                        // Backwards Compatibility
                        $conditions .= "{$gate}lj_category_count.categoryID = :categoryID{$count}";
                    }
                    else
                    {
                        // Backwards Compatibility
                        $conditions .= "{$gate}lj_category_count.categoryID != :categoryID{$count}";
                    }

                    break;
                case 'stepID':
                    if ($q['operator'] == '=')
                    {
                        switch ($vars[':stepID' . $count]) {
                            case 'submitted':
                                $conditions .= "{$gate}submitted > 0";

                                break;
                            case 'notSubmitted': // backwards compat
                                $conditions .= "{$gate}submitted = 0";

                                break;
                            case 'deleted':
                                $conditions .= "{$gate}deleted > 0";

                                break;
                            case 'notDeleted': // backwards compat
                                $conditions .= "{$gate}deleted = 0";

                                break;
                            case 'resolved':
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'notResolved': // backwards compat
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NOT NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'actionable':
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NOT NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';
                                $filterActionable = true;

                                break;
                            /*case 'destruction':
                                $conditions .= "{$gate}(categories.destructionAge IS NOT NULL AND ".
                                    "records_workflow_state.stepID IS NULL AND submitted != 0)";
                                if (!str_contains($joins,'lj_category_count')) {
                                    $joins .= "LEFT JOIN (SELECT * FROM category_count WHERE count > 0) lj_category_count USING (recordID) ";
                                }
                                $joins .= "LEFT JOIN categories USING (categoryID) ";
                                $joins .= "LEFT JOIN records_workflow_state USING (recordID) ";
                                break;*/
                            default:
                                if (is_numeric($vars[':stepID' . $count]))
                                {
                                    if (!str_contains($joins,'lj_records_workflow_state')) {
                                        $joins .= "LEFT JOIN records_workflow_state lj_records_workflow_state USING (recordID) ";
                                    }

                                    $conditions .= "{$gate}lj_records_workflow_state.stepID = :stepID{$count}";
                                }
                                else
                                {
                                    return 'Unsupported match in stepID';
                                }

                                break;
                        }
                    }
                    else
                    {
                        if ($q['operator'] == '!=')
                        {
                            switch ($vars[':stepID' . $count]) {
                            case 'submitted':
                                $conditions .= "{$gate}submitted = 0";

                                break;
                            case 'notSubmitted': // backwards compat
                                $conditions .= "{$gate}submitted > 0";

                                break;
                            case 'deleted':
                                $conditions .= "{$gate}deleted = 0";

                                break;
                            case 'notDeleted': // backwards compat
                                $conditions .= "{$gate}deleted > 0";

                                break;
                            case 'resolved':
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NOT NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'notResolved': // backwards compat
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'actionable':
                                $conditions .= "{$gate}(records_workflow_state.stepID IS NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            /*case 'destruction':
                                $conditions .= "{$gate}(categories.destructionAge IS NULL OR ".
                                    "(records_workflow_state.stepID IS NOT NULL OR submitted = 0)".
                                ")";
                                if (!str_contains($joins,'lj_category_count')) {
                                    $joins .= "LEFT JOIN (SELECT * FROM category_count WHERE count > 0) lj_category_count USING (recordID) ";
                                }
                                $joins .= "LEFT JOIN categories USING (categoryID) ";
                                $joins .= "LEFT JOIN records_workflow_state USING (recordID) ";
                                break;*/
                            default:
                                if (is_numeric($vars[':stepID' . $count]))
                                {
                                    if (!str_contains($joins,'lj_records_workflow_state')) {
                                        $joins .= "LEFT JOIN records_workflow_state lj_records_workflow_state USING (recordID) ";
                                    }

                                    $conditions .= "{$gate}lj_records_workflow_state.stepID != :stepID{$count}";
                                }
                                else
                                {
                                    return 'Unsupported match in stepID';
                                }

                                break;
                        }
                        }
                        else
                        {
                            return 'Invalid operator for stepID';
                        }
                    }

                    if (!is_numeric($vars[':stepID' . $count]))
                    {
                        unset($vars[':stepID' . $count]);
                    }

                    break;
                case 'data':
                    if (!isset($q['indicatorID']) || !is_numeric($q['indicatorID']))
                    {
                        return 0;
                    }

                    $tResTypeHint = array();
                    if ($q['indicatorID'] > 0)
                    {
                        // check protected field mask, ignore query if masked
                        if($this->isMasked($q['indicatorID'])) {
                            continue 2;
                        }

                        // need data type hint and default data
                        $tVarTypeHint = array(':indicatorID' => $q['indicatorID']);
                        $tResTypeHint = $this->db->prepared_query('SELECT format, `default` FROM indicators
                                                                    WHERE indicatorID=:indicatorID', $tVarTypeHint);

                        $vars[':indicatorID' . $count] = $q['indicatorID'];
                        $joins .= "LEFT JOIN (SELECT recordID, indicatorID, series, data FROM data
										WHERE indicatorID=:indicatorID{$count}) lj_data{$count}
										USING (recordID) ";
                    }
                    else
                    {
                        if ($q['indicatorID'] === '0')
                        {
                            $joinSearchAllData = true;
                        }
                        else
                        {
                            if ($q['indicatorID'] == '0.0')
                            { // to search all fields matching the orgchart_employee input format
                                $joinSearchOrgchartEmployeeData = true;
                            }
                        }
                    }

                    // fix to select null data
                    if ($operator == '=' && $vars[':data' . $count] == '')
                    {
                        $conditions .= "{$gate}(lj_data{$count}.data {$operator} :data{$count} OR lj_data{$count}.data IS NULL)";
                    }
                    else
                    {
                        if ($operator == '!=' && $vars[':data' . $count] == '')
                        {
                            $conditions .= "{$gate}(lj_data{$count}.data {$operator} :data{$count})";
                        }
                        else
                        {
                            $dataTerm = "lj_data{$count}.data";
                            if ($joinSearchAllData
                            || $joinSearchOrgchartEmployeeData)
                            {
                                $dataTerm = 'lj_data.data';
                            }
                            $dataTermSql = '';

                            $dataMatch = ":data{$count}";
                            switch ($tResTypeHint[0]['format']) {
                                case 'number':
                                case 'currency':
                                    $dataTermSql = "CAST({$dataTerm} as DECIMAL(21,5))";

                                    break;
                                case 'date':
                                    $dataTermSql = "STR_TO_DATE({$dataTerm}, '%m/%d/%Y')";
                                    $dataMatch = "STR_TO_DATE(:data{$count}, '%m/%d/%Y')";

                                    break;
                                default:
                                    if($operator == 'MATCH ALL') {
                                        $vars[":data{$count}"] = $this->parseBooleanQuery($vars[":data{$count}"]);
                                    }

                                    if(strpos($operator, 'MATCH') !== false) {
                                        if($operator == 'NOT MATCH') {
                                            $dataTermSql = "NOT MATCH ({$dataTerm})";
                                        }
                                        else {
                                            $dataTermSql = "MATCH ({$dataTerm})";
                                        }

                                        $operator = 'AGAINST';
                                        $dataMatch = "({$dataMatch} IN BOOLEAN MODE)";
                                    } else {
                                        //Temporary means to handle quotes for non BOOLEAN MODE text searches.
                                        //TODO: remove this on move to markdown
                                        $vars[":data{$count}"] = htmlentities(trim($vars[":data{$count}"]), ENT_QUOTES);
                                    }
                                    break;
                            }

                            if($dataTermSql == '') {
                                $dataTermSql = $dataTerm;
                            }
                            // catch default data
                            if (isset($tResTypeHint[0]['default'])
                                    && $tResTypeHint[0]['default'] == $vars[':data' . $count])
                            {
                                $conditions .= "{$gate}({$dataTermSql} {$operator} $dataMatch OR {$dataTerm} IS NULL)";
                            }
                            else
                            {
                                $conditions .= "{$gate}{$dataTermSql} {$operator} $dataMatch";
                            }
                        }
                    }

                    break;
                case 'dependencyID':	//search records_dependencies
                    if (!isset($q['indicatorID']) || !is_numeric($q['indicatorID']))
                    {
                        return 0;
                    }
                    // Backwards Compatibility
                    $vars[':indicatorID' . $count] = $q['indicatorID'];
                    $joins .= "LEFT JOIN (SELECT *, time as `depTime_{$q['indicatorID']}` FROM records_dependencies
								WHERE dependencyID=:indicatorID{$count}
                                    AND filled{$operator}:dependencyID{$count}) lj_dependency{$count}
								USING (recordID) ";
                    $conditions .= "{$gate}lj_dependency{$count}.dependencyID = :indicatorID{$count}";

                    break;
                case 'stepAction':
                    if (!isset($q['indicatorID']) || !is_numeric($q['indicatorID']))
                    {
                        return 0;
                    }

                    switch($operator) {
                        case "=":
                            $vars[':indicatorID' . $count] = $q['indicatorID']; // this is the stepID
                            // This checks if someone has taken a specific action for a stepID
                            // OUTER JOIN gets the most recent action for a specific stepID, since there can be
                            // loops within a workflow, and people can take different actions later
                            $joins .= "LEFT JOIN (SELECT ah.recordID, ah.stepID, ah.actionType FROM action_history ah
                                                    LEFT OUTER JOIN action_history sFA_ah{$count}
                                                        ON (ah.recordID = sFA_ah{$count}.recordID 
                                                            AND ah.stepID = sFA_ah{$count}.stepID 
                                                            AND ah.time < sFA_ah{$count}.time)
                                            WHERE ah.stepID=:indicatorID{$count} AND sFA_ah{$count}.recordID IS NULL) lj_action_history{$count}
                                            USING (recordID) ";
                            // Check if the step was fulfilled. This reduces confusion for multi-requirement steps (which would have multiple actions)
                            $joins .= "LEFT JOIN (SELECT recordID, stepID, fulfillmentTime FROM records_step_fulfillment
                                            WHERE stepID=:indicatorID{$count}) lj_action_history_fulfillment{$count}
                                            USING (recordID) ";
                            $conditions .= "{$gate}(lj_action_history{$count}.stepID=:indicatorID{$count}
                                                    AND lj_action_history_fulfillment{$count}.fulfillmentTime IS NOT NULL
                                                    AND lj_action_history{$count}.actionType=:stepAction{$count}
                                                )";
                            break;
                        case "!=":
                            // This checks if someone has taken a specific action for a stepID
                            // OUTER JOIN gets the most recent action for a specific stepID, since there can be
                            // loops within a workflow, and people can take different actions later
                            $vars[':indicatorID' . $count] = $q['indicatorID']; // this is the stepID
                            $joins .= "LEFT JOIN (SELECT ah.recordID, ah.stepID, ah.actionType FROM action_history ah
                                                    LEFT OUTER JOIN action_history sFA_ah{$count}
                                                        ON (ah.recordID = sFA_ah{$count}.recordID
                                                            AND ah.stepID = sFA_ah{$count}.stepID 
                                                            AND ah.time < sFA_ah{$count}.time)
                                            WHERE ah.stepID=:indicatorID{$count} AND sFA_ah{$count}.recordID IS NULL AND ah.actionType=:stepAction{$count}) lj_action_history{$count}
                                            USING (recordID) ";
                            $conditions .= "{$gate}lj_action_history{$count}.stepID IS NULL";
                            break;
                        case "not implemented": // disabled
                            // This checks if a specific action has never been taken for a stepID
                            $vars[':indicatorID' . $count] = $q['indicatorID'];
                            $joins .= "LEFT JOIN (SELECT recordID, stepID FROM action_history
                                        WHERE stepID=:indicatorID{$count}
                                            AND actionType=:stepAction{$count}) lj_action_history{$count}
                                        USING (recordID) ";
                            $conditions .= "{$gate}lj_action_history{$count}.stepID IS NULL";
                            break;
                    }
                    break;
                default:
                    return 0;
            }
            $count++;
        }

        // End Check for Conditions Query
        if ($count) {
            $conditions .= ') ';
        } else {
            $conditions = '';
        }

        $joinCategoryID = false;
        $joinAllCategoryID = false;
        $joinRecordsDependencies = false;
        $joinRecords_Step_Fulfillment = false;
        $addJoinRecords_Step_Fulfillment_Only = false;
        $joinActionHistory = false;
        $joinRecordResolutionData = false;
        $joinRecordResolutionBy = false;
        $joinInitiatorNames = false;
        $joinUnfilledDependencies = false;
        if (isset($query['joins']))
        {
            foreach ($query['joins'] as $table)
            {
                switch ($table) {
                    case 'service':
                        $joins .= 'LEFT JOIN services USING (serviceID) ';

                        break;
                    case 'status':
                        $joins .= 'LEFT JOIN (SELECT * FROM records_workflow_state) lj_status USING (recordID)
							   LEFT JOIN (SELECT stepID, stepTitle FROM workflow_steps) lj_steps ON (lj_status.stepID = lj_steps.stepID) ';

                        break;
                    case 'categoryName':
                        $joinCategoryID = true;
                        // see below
                        break;
                    case 'categoryNameUnabridged': // include categories marked as disabled
                        $joinAllCategoryID = true;
                        // see below
                        break;
                    case 'recordsDependencies':
                        $joinRecordsDependencies = true;

                        break;
                    case 'action_history':
                        $joinActionHistory = true;

                        break;
                    case 'stepFulfillment':
                        $joinRecords_Step_Fulfillment = true;
                        break;

                    case 'stepFulfillmentOnly':
                        $addJoinRecords_Step_Fulfillment_Only = true;
                        break;

                    case 'recordResolutionData':
                        $joinRecordResolutionData = true;

                        break;
                    case 'recordResolutionBy':
                        $joinRecordResolutionBy = true;

                        break;
                    case 'initiatorName':
                        $joinInitiatorNames = true;

                        break;
                    case 'destructionDate':
                        $joinRecordResolutionData = true;
                        $joinAllCategoryID = true;
                        break;
                    case 'unfilledDependencies':
                        $joinUnfilledDependencies = true;
                    default:
                        break;
                }
            }
        }

        $conditions = $conditions == '' ? '1=1' : $conditions;
        $limit = '';
        if (isset($query['limit']) && is_numeric($query['limit']))
        {
            $offset = '';
            if (isset($query['limitOffset']) && is_numeric($query['limitOffset']))
            {
                $offset = "{$query['limitOffset']},";
            }
            $limit = ' LIMIT ' . $offset . $query['limit'];
        }
        $sort = '';
        if (isset($query['sort']['column']) && isset($query['sort']['direction']))
        {
            switch ($query['sort']['column']) {
                case 'date':
                    $sort = 'ORDER BY date ';

                    break;
                case 'recordID':
                    $sort = 'ORDER BY recordID ';

                    break;
                case 'title':
                    $sort = 'ORDER BY title ';

                    break;
                default:
                    break;
            }
            switch ($query['sort']['direction']) {
                case 'ASC':
                    $sort .= 'ASC ';

                    break;
                case 'DESC':
                    $sort .= 'DESC ';

                    break;
                default:
                    break;
            }
        }

        // avoid extra sort when using fulltext index
        if($usingFulltextIndex) {
            $sort = '';
        }

        // join tables for queries on data fields without filtering by indicatorID
        if ($joinSearchAllData
            || $joinSearchOrgchartEmployeeData)
        {
            $joins .= 'LEFT JOIN (SELECT recordID, indicatorID, series, data FROM data) lj_data ON (lj_data.recordID = records.recordID) ';
        }
        if ($joinSearchAllData)
        {
            $joins .= "INNER JOIN (SELECT indicatorID, format FROM indicators
									WHERE format != 'orgchart_employee'
										AND format != 'orgchart_position'
										AND format != 'orgchart_group') rj_AllData ON (lj_data.indicatorID = rj_AllData.indicatorID) ";
        }
        if ($joinSearchOrgchartEmployeeData)
        {
            $joins .= "INNER JOIN (SELECT indicatorID, format FROM indicators
									WHERE format = 'orgchart_employee') rj_OCEmployeeData ON (lj_data.indicatorID = rj_OCEmployeeData.indicatorID) ";
        }


        //joinInitiatorNames backwards compat - additional SQL for records.userMetadata replaces the previous join with orgchart.employee.
        //userMetadata properties are empty for accounts that were inactive when prior metadata values were updated.  Use lastName to check if empty
        //because userName might be removed in the future.  Display 'userID (inactive user)' instead of 'null, null' if metadata is empty.
        $initiatorNamesSQL = '';
        if ($joinInitiatorNames) {
            $initiatorNamesSQL = ',
                IF(
                    TRIM(JSON_VALUE(`userMetadata`, "$.lastName")) != "",
                    JSON_VALUE(`userMetadata`, "$.firstName"), "(inactive user)"
                ) AS `firstName`,
                IF(
                    TRIM(JSON_VALUE(`userMetadata`, "$.lastName")) != "",
                    JSON_VALUE(`userMetadata`, "$.lastName"), `userID`
                ) AS `lastName`';
        }
        $resSQL = 'SELECT * ' . $initiatorNamesSQL . ', userId as userName FROM `records` ' . $joins . ' WHERE ' . $conditions . $sort . $limit;

        if(isset($_GET['debugQuery'])) {
            if($this->login->checkGroup(1)) {
                $debugQuery = str_replace(["\r", "\n","\t", "%0d","%0a","%09","%20", ";"], ' ', $resSQL);
                $debugVars = [];
                foreach($vars as $key => $value) {
                    if(strpos($key, ':data') !== false
                        || !is_numeric($value)) {
                        $debugVars[$key] = '"'.$value.'"';
                    }
                    else {
                        $debugVars[$key] = $value;
                    }
                }

                header('X-LEAF-Query: '. str_replace(array_keys($debugVars), $debugVars, $debugQuery));

                return $res = $this->db->prepared_query('EXPLAIN ' . $resSQL, $vars);
            }
            else {
                return XSSHelpers::scrubObjectOrArray(json_decode(html_entity_decode(html_entity_decode($_GET['q'])), true));
            }
        }

        $res = $this->db->prepared_query($resSQL, $vars);

        $data = array();
        $recordIDs = '';
        foreach ($res as $item)
        {
            $item['userMetadata'] = json_decode($item['userMetadata'], true);
            if(!isset($data[$item['recordID']])) {
                $recordIDs .= $item['recordID'] . ',';
            }
            $data[$item['recordID']] = $item;
        }
        $recordIDs = trim($recordIDs, ',');
        $recordIDs = $recordIDs ?: 0;

        if(count($res) > count(array_keys($data))) {
            header('LEAF-Query: continue'); // signal frontend there might be more data
        }

        // These all require the recordIDs to be set
        if (!empty($recordIDs))
        {

            if ($joinCategoryID)
            {
                $categorySQL = 'SELECT recordID,categoryName,categoryID,destructionAge
                FROM category_count
                LEFT JOIN categories USING (categoryID)
                WHERE recordID IN (' . $recordIDs . ')
                AND disabled = 0
                AND count > 0';

                $res2 = $this->db->prepared_query($categorySQL, array());
                foreach ($res2 as $item)
                {
                    $data[$item['recordID']]['categoryNames'][] = $item['categoryName'];
                    $data[$item['recordID']]['categoryIDs'][] = $item['categoryID'];
                    $data[$item['recordID']]['destructionAge'] = $item['destructionAge'];
                }
            }

            if ($joinAllCategoryID)
            {

                $allCategorySQL = 'SELECT recordID,categoryName,categoryID,destructionAge
                FROM category_count
                LEFT JOIN categories USING (categoryID)
                WHERE recordID IN (' . $recordIDs . ')
                AND count > 0';

                $res2 = $this->db->prepared_query($allCategorySQL, array());
                foreach ($res2 as $item)
                {
                    $data[$item['recordID']]['categoryNamesUnabridged'][] = $item['categoryName'];
                    $data[$item['recordID']]['categoryIDsUnabridged'][] = $item['categoryID'];
                    $data[$item['recordID']]['destructionAge'] = $item['destructionAge'];
                }
            }

            if ($joinRecordsDependencies)
            {
                $recordDependenciesSQL = 'SELECT recordID,dependencyID,time,description
                FROM records_dependencies
                LEFT JOIN dependencies USING (dependencyID)
                WHERE recordID IN (' . $recordIDs . ')
                AND filled != 0';

                $res2 = $this->db->prepared_query($recordDependenciesSQL, array());
                foreach ($res2 as $item)
                {
                    $data[$item['recordID']]['recordsDependencies'][$item['dependencyID']]['time'] = $item['time'];
                    $data[$item['recordID']]['recordsDependencies'][$item['dependencyID']]['description'] = $item['description'];
                }
            }

            if ($joinActionHistory)
            {
                $actionHistorySQL =
                       'SELECT recordID, stepID, userID, userMetadata, time, description,
                            actionTextPasttense, actionType, comment
                        FROM action_history
                        LEFT JOIN dependencies USING (dependencyID)
                        LEFT JOIN actions USING (actionType)
                        WHERE recordID IN (' . $recordIDs . ')
                        UNION
                        SELECT recordID, "-5", userID, userMetadata, timestamp, "Note Added",
                             "Note Added", "LEAF_note", note
                        FROM notes
                        WHERE recordID IN (' . $recordIDs . ')
                        AND deleted IS NULL
                        ORDER BY time';

                $res2 = $this->db->prepared_query($actionHistorySQL, array());
                foreach ($res2 as $item)
                {
                    $item['userMetadata'] = json_decode($item['userMetadata'], true);
                    $userMetadata = $item['userMetadata'];
                    $name = isset($userMetadata) && trim("{$userMetadata['firstName']} {$userMetadata['lastName']}") !== "" ?
                        "{$userMetadata['firstName']} {$userMetadata['lastName']}" : $item['userID'];

                    $item['approverName'] = $name;

                    $data[$item['recordID']]['action_history'][] = $item;
                }
            }

            if($joinRecordResolutionData)
            {

                $recordResolutionSQL = 'SELECT recordID, lastStatus, records_step_fulfillment.stepID, fulfillmentTime
                FROM records
                LEFT JOIN records_step_fulfillment USING (recordID)
                LEFT JOIN records_workflow_state USING (recordID)
                WHERE recordID IN (' . $recordIDs . ')
                AND records_workflow_state.stepID IS NULL
                AND submitted > 0
                AND deleted = 0';

                $res2 = $this->db->prepared_query($recordResolutionSQL, array());
                foreach ($res2 as $item)
                {
                    // resolution data to be checked and updated.
                    $recordResolutionData = $data[$item['recordID']]['recordResolutionData'];
                    if(
                        $recordResolutionData['fulfillmentTime'] == null ||
                        $recordResolutionData['fulfillmentTime'] < $item['fulfillmentTime']
                    ) {
                        $recordResolutionData['lastStatus'] = $item['lastStatus'];
                        $recordResolutionData['fulfillmentTime'] = $item['fulfillmentTime'];

                        // set our resolution data back to the main array since we have changes.
                        $data[$item['recordID']]['recordResolutionData'] = $recordResolutionData;
                    }
                }
            }

            if ($joinRecordResolutionBy === true) {
                $recordResolutionBySQL = "SELECT recordID, action_history.userID as resolvedBy, action_history.userMetadata, action_history.stepID, action_history.actionType
                FROM action_history
                LEFT JOIN records USING (recordID)
                INNER JOIN workflow_routes USING (stepID)
                LEFT JOIN records_workflow_state USING (recordID)
                WHERE recordID IN ($recordIDs)
                AND action_history.actionType = workflow_routes.actionType
                AND records_workflow_state.stepID IS NULL
                AND nextStepID = 0
                AND submitted > 0
                AND deleted = 0";

                $res2 = $this->db->prepared_query($recordResolutionBySQL, array());

                foreach ($res2 as $item) {
                    $userMetadata = json_decode($item['userMetadata'], true);
                    $nameResolved =  isset($userMetadata) && trim("{$userMetadata['firstName']} {$userMetadata['lastName']}") !== "" ?
                        "{$userMetadata['firstName']} {$userMetadata['lastName']} " : $item['resolvedBy'];
                    $data[$item['recordID']]['recordResolutionBy']['resolvedBy'] = $nameResolved;
                }
            }

            if ($joinRecords_Step_Fulfillment)
            {
                $strSQL = 'SELECT * FROM records_step_fulfillment LEFT JOIN workflow_steps USING (stepID) '.
                    'WHERE recordID IN (' . $recordIDs . ')';
                $res2 = $this->db->prepared_query($strSQL, array());
                foreach ($res2 as $item)
                {
                    $data[$item['recordID']]['stepFulfillment'][$item['stepID']]['time'] = $item['fulfillmentTime'];
                    $data[$item['recordID']]['stepFulfillment'][$item['stepID']]['step'] = $item['stepTitle'];
                }
            }

            if ($addJoinRecords_Step_Fulfillment_Only) {
                $strSQL = 'SELECT recordID, stepID, fulfillmentTime FROM records_step_fulfillment WHERE recordID IN (' . $recordIDs . ') '.
                    'ORDER BY recordID, fulfillmentTime DESC';
                $res2 = $this->db->prepared_query($strSQL, array());
                foreach ($res2 as $item)
                {
                    // Need all bits to add to stepFullfillmentOnly otherwise skip
                    if (!empty($item['recordID']) && !empty($item['fulfillmentTime']) && !empty($item['stepID']))
                    {
                        $stepFulfill = [];
                        $stepFulfill['stepID'] = $item['stepID'];
                        $stepFulfill['time'] = $item['fulfillmentTime'];
                        $data[$item['recordID']]['stepFulfillmentOnly'][] = $stepFulfill;
                    }
                }
            }

            if ($joinUnfilledDependencies) {
                $formWorkflow = $this->getFormWorkflow();
                $unfilledDependencies = $formWorkflow->getRecordsDependencyData($this, $data, true);
                foreach ($unfilledDependencies as $ud) {
                    $temp = [];
                    $temp['description'] = $ud['description'];
                    if(isset($ud['approverName'])) {
                        $temp['approverName'] = $ud['approverName'];
                    }
                    if(isset($ud['approverUID'])) {
                        $temp['approverUID'] = $ud['approverUID']; // uniquely identify approvers
                    }
                    $data[$ud['recordID']]['unfilledDependencyData'][$ud['dependencyID']] = $temp;
                }
            }
        }

        // check needToKnow mode
        $alreadyCheckedReadAccess = false;
        if ($this->isNeedToKnow())
        {
            $data = $this->checkReadAccess($data);
            $alreadyCheckedReadAccess = true;
        }

        // check actionable
        if ($filterActionable)
        {
            $formWorkflow = $this->getFormWorkflow();

            $actionable = $formWorkflow->getActionable($this, $data);

            $actionLookup = [];
            foreach($actionable as $t) {
                if(!isset($actionLookup[$t['recordID']])) {
                    $actionLookup[$t['recordID']] = $t['isActionable'];
                }
            }
            $countPurged = 0;
            foreach($data as $i => $v) {
                if($actionLookup[$v['recordID']] != true) {
                    unset($data[$i]);
                    $countPurged++;
                }
            }
            if($countPurged > 0) {
                header('LEAF-Query: continue'); // signal frontend there might be more data
            }
        }

        // check if data is being requested as part of the query
        if (isset($query['getData']))
        {
            $indicatorIDs = '';
            foreach ($query['getData'] as $indicatorID)
            {
                $indicatorIDs .= $indicatorID . ',';
            }

            $data = $this->getCustomData($data, $indicatorIDs, $alreadyCheckedReadAccess);
        }

        return $data;
    }

    public function getDisabledIndicatorList(int $disabled)
    {
        $vars = array(':disabled' => (int)$disabled);
        $strSQL = "SELECT indicatorID, name, format, description, categories.categoryName, ".
                    "indicators.parentID AS parentIndicatorID, indicators.disabled FROM indicators ".
                    "LEFT JOIN categories USING (categoryID) ".
                    "WHERE indicators.disabled >= :disabled ".
                    "AND categories.disabled = 0 ".
                    "ORDER BY name";

        $res = $this->db->prepared_query($strSQL, $vars);

        $disabledIndicatorList = array();
        foreach ($res as $item)
        {
            $temp = array();
            $delDate = $item['disabled'] + 30*24*60*60; //30 days from timestamp
            $delDateFormat = date("m/d/Y",$delDate);
            $temp['indicatorID'] = $item['indicatorID'];
            $temp['parentIndicatorID'] = $item['parentIndicatorID'];
            $temp['name'] = $item['name'];
            $temp['format'] = $item['format'];
            $temp['description'] = $item['description'];
            $temp['categoryName'] = $item['categoryName'];
            // TODO: change the below name. New output should use new property names instead of recycling existing ones.
            $temp['disabled'] = ($item['disabled'] == 1) ? 'Archived' : 'Scheduled Deletion Date: '. $delDateFormat;
            $disabledIndicatorList[] = $temp;
        }

        return $disabledIndicatorList;
    }

    /**
     * List of all available active indicators
     * @param string $sort
     * @param boolean $includeHeadings
     * @param string $formsFilter - csv list of forms to search for
     * @param boolean $unabridged
     * @return array list of indicators
     */
    public function getIndicatorList($sort = 'name', $includeHeadings = false, $formsFilter = '', $unabridged = false)
    {
        $forms = [];
        if($formsFilter != '') {
            $forms = explode(',', trim($formsFilter, ','));
        }
        $orderBy = '';
        switch ($sort) {
            case 'indicatorID':
                $orderBy = ' ORDER BY indicatorID';

                break;
            case 'name':
            default:
                $orderBy = ' ORDER BY name';

                break;
        }
        $vars = array();
        $strSQL = "SELECT *, COALESCE(NULLIF(description, ''), name) as name, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive, indicators.disabled as isDisabled FROM indicators ".
                    "LEFT JOIN categories USING (categoryID) ".
                    "WHERE indicators.disabled <= 1 ".
                        "AND format != '' ".
                        "AND name != '' ".
                        "AND categories.disabled = 0" . $orderBy;
        if($includeHeadings) {
            $strSQL = "SELECT *, COALESCE(NULLIF(description, ''), name) as name, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive, indicators.disabled as isDisabled FROM indicators ".
                        "LEFT JOIN categories USING (categoryID) ".
                        "WHERE indicators.disabled <= 1 ".
                            "AND name != '' ".
                            "AND categories.disabled = 0" . $orderBy;
        }
        if($unabridged) {
            $strSQL = "SELECT *, COALESCE(NULLIF(description, ''), name) as name, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive, indicators.disabled as isDisabled FROM indicators ".
                "LEFT JOIN categories USING (categoryID) ".
                "WHERE indicators.disabled <= 1 ".
                "AND categories.disabled = 0" . $orderBy;
        }
        $res = $this->db->prepared_query($strSQL, $vars);

        $strSQL = "SELECT *, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive, indicators.disabled as isDisabled FROM indicators ".
                    "LEFT JOIN categories USING (categoryID) ".
					"WHERE indicators.disabled <= 1 ".
					    "AND categories.disabled = 0" . $orderBy;

        $resAll = $this->db->prepared_query($strSQL, $vars);

        $dataStaples = array();
        $resStaples = $this->db->prepared_query('SELECT stapledCategoryID, category_staples.categoryID as categoryID, categories.categoryID as stapledSubCategoryID, categories.parentID FROM category_staples LEFT JOIN categories ON (stapledCategoryID = categories.parentID)', $vars);
        foreach ($resStaples as $stapled)
        {
            $dataStaples[$stapled['stapledCategoryID']][] = $stapled['categoryID'];
            $dataStaples[$stapled['stapledSubCategoryID']][] = $stapled['categoryID'];
        }

        $data = array();
        $isActiveIndicator = array();
        $isActiveCategory = array();
        foreach ($resAll as $item)
        {
            // TODO: instead of checking for orphaned indicators, make sure the indicator list never contains orphans
            $temp = array();
            $temp['parentIndicatorID'] = $item['parentIndicatorID'];
            $temp['parentCategoryID'] = $item['parentCategoryID'];
            $temp['indicatorID'] = $item['indicatorID'];
            $temp['name'] = $item['name'];
            $temp['format'] = $item['format'];
            $temp['conditions'] = $item['conditions'];
            $temp['description'] = $item['description'];
            $temp['isDisabled'] = (int)$item['isDisabled'];
            $temp['categoryName'] = $item['categoryName'];
            $temp['categoryID'] = $item['categoryID'];
            $temp['is_sensitive'] = $item['is_sensitive'];
            $temp['timeAdded'] = $item['timeAdded'] . ' GMT';
            $isActiveIndicator[$item['indicatorID']] = $temp;
            $isActiveCategory[$item['categoryID']] = 1;
        }

        // check for orphaned indicators
        foreach ($res as $item)
        {
            // Skip built-in forms unless requested to avoid clutter
            if(substr($item['categoryID'], 0, 5) == 'leaf_' && !isset($_GET['dev'])) {
                continue;
            }

            if (!$this->isIndicatorOrphan($item, $isActiveIndicator))
            {
                // make sure the field's category isn't a member of a deleted category
                if ($item['parentCategoryID'] == ''
                    || $isActiveCategory[$item['parentCategoryID']] == 1)
                {
                    $temp = array();
                    $temp['parentIndicatorID'] = $item['parentIndicatorID'];
                    $temp['indicatorID'] = $item['indicatorID'];
                    $temp['name'] = $item['name'];
                    $temp['format'] = $item['format'];
                    $temp['conditions'] = $item['conditions'];
                    $temp['description'] = $item['description'];
                    $temp['isDisabled'] = (int)$item['isDisabled'];
                    $temp['categoryName'] = $item['categoryName'];
                    $temp['categoryID'] = $item['categoryID'];
                    $temp['is_sensitive'] = $item['is_sensitive'];
                    $temp['timeAdded'] = $item['timeAdded'] . ' GMT';
                    $temp['parentCategoryID'] = $item['parentCategoryID'];
                    $temp['parentStaples'] = $dataStaples[$item['categoryID']];
                    if(count($forms) > 0) {
                        foreach($forms as $form) {
                            if($form == $temp['categoryID']
                                || $form == $temp['parentCategoryID']
                                || (is_array($temp['parentStaples'])
                                    && array_search($form, $temp['parentStaples']) !== false)) {
                                $data[] = $temp;
                            }
                        }
                    }
                    else {
                        $data[] = $temp;
                    }
                }
            }
        }

        return $data;
    }

    /**
     * Retrieves all indicators associated with categoryID in a given array of names
     * returns array of indicators.indicatorID, indicators.name, indicators.format
     * @param int $categoryID
     * @param array $formats
     * @return array
     */
    public function getIndicatorsByRecordAndName($categoryID, $names)
    {
        $vars = array(
            ':categoryID' => $categoryID,
        );

        $res = $this->db->prepared_query(
            'SELECT indicatorID, name, format, parentID
                FROM indicators
                WHERE categoryID=:categoryID
                AND name IN ("' . implode('","', $names) . '")
                ORDER BY parentID',
            $vars
            );

        return $res;
    }

    /**
     * Retrieves all indicators associated with recordID in a given array of format
     * returns array of indicators.indicatorID, indicators.name, indicators.format
     * @param int $recordID
     * @param array $formats
     * @return array
     */
    public function getIndicatorsByRecordAndFormat($recordID, $formats)
    {
        $vars = array(
            ':recordID' => $recordID,
        );

        $res = $this->db->prepared_query(
            'SELECT indicatorID, name, format
                FROM category_count
                LEFT JOIN indicators USING (categoryID)
                WHERE recordID=:recordID
                AND format IN ("' . implode('","', $formats) . '")',
            $vars
            );

        return $res;
    }

    /**
     * Retrieves all indicators associated with a record and its workflow
     * returns array of indicators.indicatorID, indicators.name, indicators.format
     * @param int $recordID
     * @return array
     */
    public function getIndicatorsAssociatedWithWorkflow($recordID)
    {
        $vars = array(
            ':recordID' => $recordID,
        );

        $res = $this->db->prepared_query(
            'SELECT recordID, categoryID, workflowID, stepID, dependencyID, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID
                FROM category_count
                LEFT JOIN categories USING (categoryID)
                LEFT JOIN workflows USING (workflowID)
                LEFT JOIN workflow_steps USING (workflowID)
                LEFT JOIN step_dependencies USING (stepID)
                WHERE recordID=:recordID
                    AND count > 0
                    AND dependencyID < 0
                    AND (indicatorID_for_assigned_empUID != 0
    		            OR indicatorID_for_assigned_groupID != 0)',
            $vars
            );

        $indicatorList = '';
        foreach($res as $item) {
            if($item['indicatorID_for_assigned_empUID'] != ''
                && $item['dependencyID'] == -1) {
                $indicatorList .= (int)$item['indicatorID_for_assigned_empUID'] . ',';
            }
            if($item['indicatorID_for_assigned_groupID'] != ''
                && $item['dependencyID'] == -3) {
                $indicatorList .= (int)$item['indicatorID_for_assigned_groupID'] . ',';
            }
        }
        $indicatorList = trim($indicatorList, ',');

        $return = [];
        if($indicatorList != '') {
            $return = $this->db->query(
                'SELECT indicatorID, name, format
                    FROM indicators
                    WHERE indicatorID IN ('. $indicatorList .')'
                );
        }
        return $return;
    }

    /**
     * @deprecated use XSSHelpers::sanitizeHTML() from XSSHelpers.php instead.
     *
     * Clean up html input, allow some tags
     * @param string $in
     * @return string
     */
    public function sanitizeInput($in)
    {
        return XSSHelpers::sanitizeHTML($in);
    }

    /**
     * Companion function to getIndicator()
     * @param int $id
     * @param int $series
     * @param int $recordID
     * @param bool $parseTemplate - see getIndicator()
     * @return array
     */
    private function buildFormTree($id, $series = null, $recordID = null, $parseTemplate = true)
    {
        if (!isset($this->cache["indicator_parentID{$id}"]))
        {
            $var = array(':parentID' => (int)$id);
            $res = $this->db->prepared_query('SELECT * FROM indicators WHERE parentID=:parentID AND disabled = 0 ORDER BY sort', $var);
            $this->cache["indicator_parentID{$id}"] = $res;
        }
        else
        {
            $res = $this->cache["indicator_parentID{$id}"];
        }

        $data = array();

        $child = null;
        if (count($res) > 0)
        {
            $indicatorList = '';
            foreach ($res as $field)
            {
                if (is_numeric($field['indicatorID']))
                {
                    $indicatorList .= "{$field['indicatorID']},";
                }
            }
            $indicatorList = trim($indicatorList, ',');

            if ($series != null && $recordID != null)
            {
                $var = array(':series' => (int)$series,
                             ':recordID' => (int)$recordID, );
                $res2 = $this->db->prepared_query('SELECT data, metadata, timestamp, indicatorID, groupID, userID FROM data
                									LEFT JOIN indicator_mask USING (indicatorID)
                									WHERE indicatorID IN (' . $indicatorList . ') AND series=:series AND recordID=:recordID', $var);

                foreach ($res2 as $resIn)
                {
                    $idx = $resIn['indicatorID'];
                    $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                    $data[$idx]['metadata'] = isset($resIn['metadata']) ? $resIn['metadata'] : null;
                    $data[$idx]['timestamp'] = isset($resIn['timestamp']) ? $resIn['timestamp'] : 0;
                    $data[$idx]['groupID'] = isset($resIn['groupID']) ? $resIn['groupID'] : null;
                    $data[$idx]['userID'] = isset($resIn['userID']) ? $resIn['userID'] : '';
                }
            }
            else if(isset($_GET['context']) && $_GET['context'] == 'formEditor') {
                $res2 = $this->db->prepared_query('SELECT indicatorID, groupID FROM indicators
                									LEFT JOIN indicator_mask USING (indicatorID)
                									WHERE indicatorID IN (' . $indicatorList . ')', []);

                foreach ($res2 as $resIn)
                {
                    $idx = $resIn['indicatorID'];
                    $data[$idx]['groupID'] = isset($resIn['groupID']) ? $resIn['groupID'] : null;
                }
            }

            foreach ($res as $field)
            {
                $idx = $field['indicatorID'];

                $child[$idx]['indicatorID'] = $field['indicatorID'];
                $child[$idx]['series'] = $series;
                $child[$idx]['name'] = $field['name'];
                $child[$idx]['default'] = $field['default'];
                $child[$idx]['description'] = $field['description'];
                $child[$idx]['html'] = $field['html'];
                $child[$idx]['htmlPrint'] = $field['htmlPrint'];
                $child[$idx]['conditions'] = $field['conditions'];
                $child[$idx]['required'] = $field['required'];
                $child[$idx]['is_sensitive'] = $field['is_sensitive'];
                $child[$idx]['isEmpty'] = (isset($data[$idx]['data']) && !is_array($data[$idx]['data']) && strip_tags($data[$idx]['data']) != '') ? false : true;
                $child[$idx]['value'] = (isset($data[$idx]['data']) && $data[$idx]['data'] != '') ? $data[$idx]['data'] : $child[$idx]['default'];
                $child[$idx]['timestamp'] = isset($data[$idx]['timestamp']) ? $data[$idx]['timestamp'] : 0;
                $child[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $field['categoryID']);
                $child[$idx]['isMasked'] = isset($data[$idx]['groupID']) ? $this->isMasked($field['indicatorID'], $recordID) : 0;
                $child[$idx]['sort'] = $field['sort'];
                $child[$idx]['has_code'] = trim($field['html']) != '' || trim($field['htmlPrint']) != '';
                $child[$idx]['userID'] = isset($data[$idx]['userID']) ? $data[$idx]['userID'] : '';
                if(isset($_GET['context']) && $_GET['context'] == 'formEditor') {
                    $child[$idx]['isMaskable'] = isset($data[$idx]['groupID']) ? 1 : 0;
                }

                $inputType = explode("\n", $field['format']);
                $numOptions = count($inputType) > 1 ? count($inputType) : 0;
                for ($i = 1; $i < $numOptions; $i++)
                {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    if (strpos($inputType[$i], 'default:') !== false)
                    {
                        $child[$idx]['options'][] = substr($inputType[$i], 8); // legacy support
                    }
                    else
                    {
                        $child[$idx]['options'][] = $inputType[$i];
                    }
                }

                // handle file upload
                if (($field['format'] == 'fileupload'
                        || $field['format'] == 'image')
                    && isset($data[$idx]['data']))
                {
                    $child[$idx]['value'] = $this->fileToArray($data[$idx]['data']);
                }

                // special handling for org chart data types (request subquestions / child)
                if ($field['format'] == 'orgchart_employee')
                {
                    $child[$idx]['displayedValue'] = '';
                    if (isset($data[$idx]['metadata'])) {
                        $orgchartInfo = json_decode($data[$idx]['metadata'], true);
                        if(!empty(trim($orgchartInfo['lastName']))) {
                            $child[$idx]['displayedValue'] = "{$orgchartInfo['firstName']} {$orgchartInfo['lastName']}";
                        }
                    }
                }
                if ($field['format'] == 'orgchart_position')
                {
                    $positionTitle = $this->position->getTitle($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = $positionTitle;
                }
                if ($field['format'] == 'orgchart_group')
                {
                    $groupTitle = $this->group->getGroup($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = $groupTitle[0]['groupTitle'];
                }
                if (substr($field['format'], 0, 4) == 'grid'
                    && isset($data[$idx]['data']))
                {
                    $values = @unserialize($data[$idx]['data']);
                    $format = json_decode(substr($field['format'], 5, -1) . ']');
                    $child[$idx]['value'] = @unserialize($child[$idx]['value']) === false ? $child[$idx]['value'] : unserialize($child[$idx]['value']);
                    try {
                        if(!is_array($values)) {
                            $values = [];
                        }
                        $child[$idx]['displayedValue'] = array_merge($values, array("format" => $format));
                    } catch (\TypeError $te) {
                        error_log($te);
                    }
                }

                // handle multiselect and checkboxes formats
                // includes backwards compatibility for data stored as CSV
                if (isset($data[$idx]['data']) && $data[$idx]['data'] != ''
                    && (substr($field['format'], 0, 11) == 'multiselect'
                        || substr($field['format'], 0, 10) == 'checkboxes'))
                {
                    $child[$idx]['value'] = @unserialize($data[$idx]['data']) !== false ? @unserialize($data[$idx]['data']) : preg_split('/,(?!\s)/', $data[$idx]['data']);
                }

                if($parseTemplate) {
                     /* putting this here to see what this value is
                        the error is Array to string conversion and it gives the
                        location, so I checked the database that it is pulling this
                        from and I don't see any arrays in their data
                    */
                    if (is_array($field['html'])) {
                        error_log(print_r($field['html'], true));
                    }
                    $child[$idx]['html'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                                      [$idx, $recordID, $child[$idx]['value']],
                                                      $field['html']);
                    $child[$idx]['htmlPrint'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                                      [$idx, $recordID, $child[$idx]['value']],
                                                      $field['htmlPrint']);
                }

                if ($child[$idx]['isMasked'])
                {
                    $child[$idx]['value'] = (isset($data[$idx]['data']) && $data[$idx]['data'] != '')
                                                ? '[protected data]' : '';
                    if ($field['format'] == 'fileupload'
                        || $field['format'] == 'image') {
                        $child[$idx]['displayedValue'] = $this->fileToArray('[protected data]');
                    }
                    if(isset($child[$idx]['displayedValue']) && $child[$idx]['displayedValue'] != '') {
                        $child[$idx]['displayedValue'] = '[protected data]';
                    }
                }

                $child[$idx]['format'] = trim($inputType[0]);

                $child[$idx]['child'] = $this->buildFormTree($field['indicatorID'], $series, $recordID);
            }
        }

        return $child;
    }

    /**
     * Convert fileupload data into array
     * @param string $data
     * @return array
     */
    private function fileToArray($data)
    {
        $data = XSSHelpers::sanitizeHTML($data);
        $data = str_replace('<br />', "\n", $data);
        $data = str_replace('<br>', "\n", $data);
        $tmpFileNames = explode("\n", $data);
        $out = array();
        foreach ($tmpFileNames as $tmpFileName)
        {
            if (trim($tmpFileName) != '')
            {
                $out[] = $tmpFileName;
            }
        }

        return $out;
    }

    private function isIndicatorOrphan($indicator, &$indicatorList)
    {
        if (!isset($indicatorList[$indicator['indicatorID']]))
        {
            return 1;
        }

        if ($indicator['parentIndicatorID'] != '')
        {
            return $this->isIndicatorOrphan($indicatorList[$indicator['parentIndicatorID']], $indicatorList);
        }

        return 0;
    }
    /**
     * Copies file attachment from record to new record
     * @param int $indicatorID
     * @param string $fileName
     * @param int $recordID
     * @param int $newRecordID
     * @param int $series
     * @return array|int 1 for success, errors for failure
     */
    public function copyAttachment($indicatorID, $fileName, $recordID, $newRecordID, $series): array|int
    {
        if (!is_numeric($recordID) || !is_numeric($indicatorID) || !is_numeric($series))
        {
            $errors = array('type' => 2);
            return $errors;
        }

        if (!$this->hasReadAccess($recordID))
        {
            $errors = array('type' => 3);
            return $errors;
        }

        // prepends $uploadDir with '../' if $uploadDir ends up being relative './UPLOADS/'
        $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
        $uploadDir = $uploadDir === UPLOAD_DIR ? '../' . UPLOAD_DIR : $uploadDir;

        $cleanedFile = XSSHelpers::scrubFilename($fileName);

        $sourceFile = $uploadDir . $recordID . '_' . $indicatorID . '_' . $series . '_' . $cleanedFile;
        $destFile = $uploadDir . $newRecordID . '_' . $indicatorID . '_' . $series . '_' . $cleanedFile;

        if (!copy($sourceFile, $destFile)) {
            $errors = error_get_last();
            return $errors;
        }
        return 1;
    }

    public function getRecordsByCategory($categoryID)
    {
        $vars = array(':categoryID' => XSSHelpers::xscrub($categoryID));
        $data = $this->db->prepared_query('SELECT recordID, title, userID, categoryID, submitted
                                            FROM records
                                            JOIN category_count USING (recordID)
                                            WHERE categoryID=:categoryID', $vars);

        return $data;
    }

    public function permanentlyDeleteRecord($recordID) {
        if(!$this->login->checkGroup(1)) {
            return 0;
        }
        /*if ($_POST['CSRFToken'] != $_SESSION['CSRFToken']) {
            return 0;
        }*/

        $vars = array(
            ':time' => time(),
            ':date' => '0',
            ':serviceID' => '0',
            ':userID' => '',
            ':title' => 'record has been deleted',
            ':priority' => '0',
            ':lastStatus' => '',
            ':submitted' => '0',
            ':isWritableUser' => '0',
            ':isWritableGroup' => '0',
            ':recordID' => $recordID);

        $res = $this->db->prepared_query('UPDATE records SET
        deleted=:time,
        date=:date,
        serviceID=:serviceID,
        userID=:userID,
        title=:title,
        priority=:priority,
        lastStatus=:lastStatus,
        submitted=:submitted,
        isWritableUser=:isWritableUser,
        isWritableGroup=:isWritableGroup
        WHERE recordID=:recordID', $vars);

        $vars = array(':recordID' => $recordID);

        $res = $this->db->prepared_query('DELETE FROM action_history WHERE recordID=:recordID', $vars);

        $vars = array(':recordID' => $recordID,
            ':userID' => '',
            ':dependencyID' => 0,
            ':actionType' => 'deleted',
            ':actionTypeID' => 4,
            ':time' => time() );

        $res = $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time)
        VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time)', $vars);


        $vars = array(':recordID' => $recordID);

        $this->db->prepared_query('DELETE FROM records_workflow_state WHERE recordID=:recordID', $vars);


        $vars = array(':recordID' => $recordID);

        $res = $this->db->prepared_query('DELETE FROM tags WHERE recordID=:recordID', $vars);


        $vars = array(':recordID' => $recordID);

        $this->db->prepared_query('DELETE FROM records_dependencies WHERE recordID=:recordID', $vars);

        return 1;
    }

    /**
     * Purpose: Send reminder emails to users depending on current step of record
     * @param $recordID
     * @param $days
     * @throws \SmartyException
     */
    function sendReminderEmail(int $recordID, $days): void
    {
        $email_tracker = new EmailTracker($this->db);
        $last_email = $email_tracker->getEmailsSentByRecordId($recordID);

        $day_last_sent = date('j', $last_email['timestamp']);
        $current_day = date('j', time());

        if (time() - $last_email[0]['timestamp'] > 86400
            || $day_last_sent !== $current_day
        ) {
            $email = new Email();
            $email->setSender('leaf.noreply@va.gov');
            $email->addSmartyVariables(array(
                "daysSince" => $days
            ));

            $email->attachApproversAndEmail($recordID, Email::EMAIL_REMINDER, $this->login);
        }

    }

    /**
     *
     * @param int $recordID
     * @param int $indicatorID
     * @param int $series
     * @param string $fileName
     *
     * @return int
     *
     * Created at: 10/31/2022, 8:30:57 AM (America/New_York)
     */
    private function getIndex (int $recordID, int $indicatorID, int $series, string $fileName): int
    {
        $return_value = -1;

        $vars = array(':indicatorID' => $indicatorID,
                      ':series' => $series,
                      ':recordID' => $recordID);
        $sql = 'SELECT data
                FROM data
                LEFT JOIN indicators USING (indicatorID)
                WHERE indicatorID = :indicatorID
                AND series = :series
                AND recordID = :recordID
                AND disabled = 0';

        $data = $this->db->prepared_query($sql, $vars);

        // values in this array would be decoded values so &amp;'s will be &
        $values = $this->fileToArray($data[0]['data']);

        // right now we will have special chars encoded in the filename. We need this decoded.
        $fileName = XSSHelpers::sanitizeHTML($fileName);

        for ($i = 0; $i < count($values); $i++) {
            if ($values[$i] == $fileName) {
                $return_value = $i;
                break;
            }
        }

        return $return_value;
    }
}
