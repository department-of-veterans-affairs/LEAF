<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Form Generator
    Date Created: September 11, 2007

*/

define('UPLOAD_DIR', './UPLOADS/'); // with trailing slash

if (!class_exists('XSSHelpers'))
{
    require_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}
if (!class_exists('CommonConfig'))
{
    require_once dirname(__FILE__) . '/../libs/php-commons/CommonConfig.php';
}

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

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        // set up org chart assets
        if (!class_exists('Orgchart\Config'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/config.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
        }
        if (!class_exists('Orgchart\Login'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Login.php';
        }
        if (!class_exists('Orgchart\Employee'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Employee.php';
        }
        if (!class_exists('Orgchart\Position'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Position.php';
        }
        if (!class_exists('Orgchart\Group'))
        {
            include __DIR__ . '/' . Config::$orgchartPath . '/sources/Group.php';
        }
        $config = new Orgchart\Config;
        $oc_db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
        $oc_login = new OrgChart\Login($oc_db, $oc_db);
        $oc_login->loginUser();
        $this->oc_dbName = $config->dbName;
        $this->employee = new OrgChart\Employee($oc_db, $oc_login);
        $this->position = new OrgChart\Position($oc_db, $oc_login);
        $this->group = new OrgChart\Group($oc_db, $oc_login);
    }

    /**
     * Get all category (Form) IDs, names, and descriptions.
     *
     * @return an array of all category IDs, names and descriptions
     */
    public function getAllCategories()
    {
        $res = $this->db->prepared_query(
            'SELECT categoryID, categoryName, categoryDescription FROM categories WHERE disabled = 0',
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
                    $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
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
                    $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
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
     * @param int $recordID
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
            $fullForm = array_merge($fullForm, $this->getIndicator($item['indicatorID'], 1, null, $parseTemplate));
        }

        return $fullForm;
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
        $title = $this->sanitizeInput($_POST['title']);
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

        $countCategories = 0;
        if (isset($_POST['title']))
        {
            foreach ($keys as $key)
            {
                if (strpos($key, 'num') === 0)
                {
                    $countCategories++;
                }
            }
        }
        if ($countCategories == 0)
        {
            return 'Error: No forms selected. Please Select a form and try again.';
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

        $vars = array(':date' => time(),
                      ':serviceID' => $serviceID,
                      ':userID' => $userID,
                      ':title' => XSSHelpers::sanitizer($_POST['title']),
                      ':priority' => $_POST['priority'], );

        $this->db->prepared_query('INSERT INTO records (date, serviceID, userID, title, priority)
                                    VALUES (:date, :serviceID, :userID, :title, :priority)', $vars);

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
     * @param int $indicatorID
     * @param int $series
     * @param int $recordID
     * @param bool $parseTemplate - parses html/htmlPrint template variables
     * @return array
     */
    public function getIndicator($indicatorID, $series, $recordID = null, $parseTemplate = true)
    {
        $form = array();
        if (!is_numeric($indicatorID) || !is_numeric($series))
        {
            return array();
        }

        // check needToKnow mode
        if ($recordID != null && $this->isNeedToKnow($recordID))
        {
            if (!$this->hasReadAccess($recordID))
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
            $vars = array(':indicatorID' => $indicatorID);
            $data = $this->db->prepared_query('SELECT * FROM indicators WHERE indicatorID=:indicatorID AND disabled = 0', $vars);
        }

        $required = isset($data[0]['required']) && $data[0]['required'] == 1 ? ' required="true" ' : '';


        $idx = $data[0]['indicatorID'];
        $form[$idx]['indicatorID'] = $data[0]['indicatorID'];
        $form[$idx]['series'] = $series;
        $form[$idx]['name'] = $data[0]['name'];
        $form[$idx]['description'] = $data[0]['description'];
        $form[$idx]['default'] = $data[0]['default'];
        $form[$idx]['parentID'] = $data[0]['parentID'];
        $form[$idx]['html'] = $data[0]['html'];
        $form[$idx]['htmlPrint'] = $data[0]['htmlPrint'];
        $form[$idx]['required'] = $data[0]['required'];
        $form[$idx]['is_sensitive'] = $data[0]['is_sensitive'];
        $form[$idx]['isEmpty'] = (isset($data[0]['data']) && !is_array($data[0]['data']) && strip_tags($data[0]['data']) != '') ? false : true;
        $form[$idx]['value'] = (isset($data[0]['data']) && $data[0]['data'] != '') ? $data[0]['data'] : $form[$idx]['default'];
        $form[$idx]['value'] = @unserialize($form[$idx]['value']) === false ? $form[$idx]['value'] : unserialize($form[$idx]['value']);
        $form[$idx]['displayedValue'] = ''; // used for Org Charts
        $form[$idx]['timestamp'] = isset($data[0]['timestamp']) ? $data[0]['timestamp'] : 0;
        $form[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $data[0]['categoryID']);
        $form[$idx]['isMasked'] = isset($data[0]['groupID']) ? $this->isMasked($data[0]['indicatorID'], $recordID) : 0;
        $form[$idx]['sort'] = $data[0]['sort'];

        // handle file upload
        if (isset($data[0]['data'])
            && ($data[0]['format'] == 'fileupload'
                || $data[0]['format'] == 'image'))
        {
            $form[$idx]['value'] = $this->fileToArray($data[0]['data']);
            $form[$idx]['raw'] = $data[0]['data'];
        }

        // special handling for org chart data types
        if ($data[0]['format'] == 'orgchart_employee'
            && isset($data[0]['data']))
        {
            $empRes = $this->employee->lookupEmpUID($data[0]['data']);
            $form[$idx]['displayedValue'] = "{$empRes[0]['firstName']} {$empRes[0]['lastName']}";
        }
        if ($data[0]['format'] == 'orgchart_position'
            && isset($data[0]['data']))
        {
            $positionTitle = $this->position->getTitle($data[0]['data']);
            $form[$idx]['displayedValue'] = $positionTitle;
        }
        if ($data[0]['format'] == 'orgchart_group'
            && isset($data[0]['data']))
        {
            $groupTitle = $this->group->getGroup($data[0]['data']);
            $form[$idx]['displayedValue'] = $groupTitle[0]['groupTitle'];
        }
        if (substr($data[0]['format'], 0, 4) == 'grid'
            && isset($data[0]['data']))
        {
            $values = @unserialize($data[0]['data']);
            $format = json_decode(substr($data[0]['format'], 5, -1) . ']');
            $form[$idx]['displayedValue'] = array_merge($values, array("format" => $format));
        }

        // prevent masked data from being output
        if ($form[$idx]['isMasked'])
        {
            $form[$idx]['value'] = '[protected data]';
            $form[$idx]['displayedValue'] = '[protected data]';
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
            $form[$idx]['html'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                              [$idx, $recordID, $form[$idx]['value']],
                                              $data[0]['html']);
            $form[$idx]['htmlPrint'] = str_replace(['{{ iID }}', '{{ recordID }}', '{{ data }}'],
                                              [$idx, $recordID, $form[$idx]['value']],
                                              $data[0]['htmlPrint']);
        }

        $form[$idx]['format'] = trim($inputType[0]);

        $form[$idx]['child'] = $this->buildFormTree($data[0]['indicatorID'], $series, $recordID, $parseTemplate);

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
            'SELECT h.recordID, h.indicatorID, h.series, h.data, h.timestamp, h.userID, i.is_sensitive
                FROM data_history h
                    LEFT JOIN indicator_mask USING (indicatorID)
                    LEFT JOIN indicators i USING (indicatorID)
                    WHERE h.recordID=:recordID
                    AND h.indicatorID=:indicatorID
                    AND h.series=:series
                    ORDER BY timestamp DESC',
            $vars
        );

        require_once 'VAMC_Directory.php';
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
            $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $field['userID'];
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

    public function deleteRecord($recordID)
    {
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 0;
        }
        if (!$this->hasWriteAccess($recordID))
        {
            return 'Please contact your administrator to cancel this request to help avoid confusion in the process.';
        }

        // only allow admins to delete resolved requests
        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT recordID, submitted, stepID FROM records
        									LEFT JOIN records_workflow_state USING (recordID)
                                            WHERE recordID=:recordID
        										AND submitted > 0', $vars);
        if (isset($res[0])
            && $res[0]['stepID'] == null
            && !$this->login->checkGroup(1))
        {
            return 'Cannot cancel resolved request.';
        }

        $vars = array(':recordID' => $recordID,
                      ':time' => time(), );
        $res = $this->db->prepared_query('UPDATE records SET
                                            deleted=:time
                                            WHERE recordID=:recordID', $vars);

        // actionID 4 = delete
        $vars = array(':recordID' => $recordID,
                      ':userID' => $this->login->getUserID(),
                      ':dependencyID' => 0,
                      ':actionType' => 'deleted',
                      ':actionTypeID' => 4,
                      ':time' => time(), );
        $res = $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time)
                                            VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time)', $vars);

        // delete state
        $vars = array(':recordID' => $recordID);
        $this->db->prepared_query('DELETE FROM records_workflow_state
                                        WHERE recordID=:recordID', $vars);

        // delete tags
        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('DELETE FROM tags WHERE recordID=:recordID', $vars);

        return 1;
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
     * @param int $recordID
     * @param int $indicatorID
     * @param int $series
     * @return int 1 for success, 0 for fail
     */
    public function deleteAttachment($recordID, $indicatorID, $series, $fileIdx)
    {
        if (!is_numeric($recordID) || !is_numeric($indicatorID) || !is_numeric($series) || !is_numeric($fileIdx))
        {
            return 0;
        }
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 0;
        }

        if (!$this->hasWriteAccess($recordID, 0, $indicatorID))
        {
            return 0;
        }

        $data = $this->getIndicator($indicatorID, $series, $recordID);
        $value = $data[$indicatorID]['value'];
        $file = $this->getFileHash($recordID, $indicatorID, $series, $data[$indicatorID]['value'][$fileIdx]);

        $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;

        if (isset($value[$fileIdx]))
        {
            $_POST['overwrite'] = true;
            $_POST['series'] = 1;
            $_POST[$indicatorID] = '';
            for ($i = 0; $i < count($value); $i++)
            {
                if ($i != $fileIdx)
                {
                    $_POST[$indicatorID] .= $value[$i] . "\n";
                }
            }

            $this->doModify($recordID);
            if (file_exists($uploadDir . $file))
            {
                unlink($uploadDir . $file);
            }

            return 1;
        }

        return 0;
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

        //Check for Internal Forms of Main categoryID
        $vars = array(':parentID' => $resCategory[0]['categoryID']);

        $resInternal = $this->db->prepared_query('SELECT * FROM categories
                                            WHERE parentID=:parentID', $vars);

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

        require_once 'VAMC_Directory.php';
        $dir = new VAMC_Directory;
        $user = $dir->lookupLogin($res[0]['userID']);
        $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $res[0]['userID'];

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
        if (is_array($_POST[$key]))
        {
            $_POST[$key] = serialize($_POST[$key]); // special case for radio/checkbox items
        }
        else
        {
            $_POST[$key] = XSSHelpers::sanitizeHTML($_POST[$key]);
        }

        $vars = array(':recordID' => $recordID,
                      ':indicatorID' => $key,
                      ':series' => $series, );
        $res = $this->db->prepared_query('SELECT data, format FROM data
                                            LEFT JOIN indicators USING (indicatorID)
                                            WHERE recordID=:recordID AND indicatorID=:indicatorID AND series=:series', $vars);

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
        if (!$this->hasWriteAccess($recordID, 0, $key))
        {
            return 0;
        }
        $vars = array(':recordID' => $recordID,
                      ':indicatorID' => $key,
                      ':series' => $series,
                      ':data' => trim($_POST[$key]),
                      ':timestamp' => time(),
                      ':userID' => $this->login->getUserID(), );
        $res = $this->db->prepared_query('INSERT INTO data (recordID, indicatorID, series, data, timestamp, userID)
                                            VALUES (:recordID, :indicatorID, :series, :data, :timestamp, :userID)
                                            ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, userID=:userID', $vars);

        if (!$duplicate)
        {
            $res2 = $this->db->prepared_query('INSERT INTO data_history (recordID, indicatorID, series, data, timestamp, userID)
                                                   VALUES (:recordID, :indicatorID, :series, :data, :timestamp, :userID)', $vars);
        }
        return 1;
    }

    /**
     * Write data from input fields if the current user has access - HTTP POST
     * @param int $recordID
     * @return int 1 for success, 0 for error
     */
    public function doModify($recordID)
    {
        if (!is_numeric($recordID))
        {
            return 0;
        }
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 0;
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
                        return 0;
                    }
                    $_FILES[$indicator]['name'] = XSSHelpers::scrubFilename($_FILES[$indicator]['name']);
                    $_POST[$indicator] = XSSHelpers::scrubFilename($_FILES[$indicator]['name']);

                    $filenameParts = explode('.', $_FILES[$indicator]['name']);
                    $fileExtension = array_pop($filenameParts);
                    $fileExtension = strtolower($fileExtension);
                    if (in_array($fileExtension, $fileExtensionWhitelist))
                    {
                        $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
                        if (!is_dir($uploadDir))
                        {
                            mkdir($uploadDir, 755, true);
                        }

                        $sanitizedFileName = $this->getFileHash($recordID, $indicator, $series, $this->sanitizeInput($_FILES[$indicator]['name']));
                        move_uploaded_file($_FILES[$indicator]['tmp_name'], $uploadDir . $sanitizedFileName);
                    }
                    else
                    {
                        return 0;
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
                        return 0;
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
                          ':title' => $this->sanitizeInput($_POST['title']),
                          ':priority' => (int)$priority, );

            $res = $this->db->prepared_query('UPDATE records SET
                                                title=:title,
                                                priority=:priority
                                                WHERE recordID=:recordID', $vars);
        }

        foreach ($keys as $key)
        {
            // If form has _selected key use over initial key (Multi-Select Dropdown)
            if (is_numeric($key) && $_POST[$key . '_selected']) {
                $_POST[$key] = $_POST[$key . '_selected'];
                if (!$this->writeDataField($recordID, $key, $series)) {
                    return 0;
                }
            }
            elseif (is_numeric($key))
            {
                if (!$this->writeDataField($recordID, $key, $series)) {
                    return 0;
                }
            }
            elseif (!strpos($key, '_selected')) // Check for keys that don't include _selected
            {
                list($tRecordID, $tIndicatorID) = explode('_', $key);
                if ($tRecordID == $recordID
                    && is_numeric($tIndicatorID)) {
                    if (!$this->writeDataField($recordID, $tIndicatorID, $series)) {
                        return 0;
                    }
                }

            }
        }

        return 1;
    }

    /**
     * Submit a request and start the workflow if it has not already been submitted
     * @param int $recordID
     * @return array {status(int), errors[string]}
     */
    public function doSubmit($recordID)
    {
        $recordID = (int)$recordID;
        if ($_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 0;
        }
        if (!is_numeric($recordID))
        {
            return 0;
        }

        if (!$this->hasWriteAccess($recordID))
        {
            return 0;
        }

        // make sure request isn't already submitted
        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM records
                                                     WHERE recordID=:recordID', $vars);
        if ($res[0]['submitted'] > 0)
        {
            return $recordID;
        }

        $this->db->beginTransaction();

        // write new workflow states
        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM category_count
                                             LEFT JOIN categories USING (categoryID)
                                             LEFT JOIN workflows USING (workflowID)
                                             WHERE recordID=:recordID
                                               AND count > 0', $vars);
        $workflowIDs = array();
        $hasInitialStep = false;
        foreach ($res as $workflow)
        {
            if ($workflow['initialStepID'] != 0)
            {
                // make sure the initial step is valid
                $vars = array(':stepID' => $workflow['initialStepID']);
                $res = $this->db->prepared_query('SELECT * FROM workflow_steps
                                                     WHERE stepID=:stepID', $vars);
                if ($res[0]['workflowID'] == $workflow['workflowID'])
                {
                    $vars = array(':recordID' => $recordID,
                                  ':stepID' => $workflow['initialStepID'], );
                    $this->db->prepared_query('INSERT INTO records_workflow_state (recordID, stepID)
                                             VALUES (:recordID, :stepID)', $vars);
                    $hasInitialStep = true;
                }
            }
            // check if the request only needs to be marked as submitted (e.g.:for surveys)
            if ($workflow['initialStepID'] == 0)
            {
                $vars = array(':workflowID' => $workflow['workflowID']);
                $res = $this->db->prepared_query('SELECT * FROM workflow_routes
            										WHERE workflowID=:workflowID
            											AND stepID=-1
            											AND actionType="submit"', $vars);
                if (count($res) > 0)
                {
                    $hasInitialStep = true;
                }
            }

            if ($workflow['workflowID'] != 0)
            {
                $workflowIDs[] = $workflow['workflowID'];
            }
        }

        if (!$hasInitialStep)
        {
            return array('status' => 1, 'errors' => array('Workflow is configured incorrectly'));
        }

        $vars = array(':recordID' => $recordID,
                      ':time' => time(), );
        $res = $this->db->prepared_query('UPDATE records SET
                                            submitted=:time,
                                            isWritableUser=0,
                                            lastStatus = "Submitted"
                                            WHERE recordID=:recordID', $vars);

        // write history data, actionID 6 = filled dependency
        $vars = array(':recordID' => $recordID,
                      ':userID' => $this->login->getUserID(),
                      ':dependencyID' => 5,
                      ':actionType' => 'submit',
                      ':actionTypeID' => 6,
                      ':time' => time(),
                      ':comment' => '', );
        $res = $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time, comment)
                                            VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment)', $vars);

        // populate dependency data using new workflow system
        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM category_count
                                             LEFT JOIN categories USING (categoryID)
                                             LEFT JOIN workflows USING (workflowID)
                                             LEFT JOIN workflow_steps USING (workflowID)
                                             LEFT JOIN step_dependencies USING (stepID)
                                             WHERE recordID=:recordID
                                               AND count > 0
                                               AND workflowID > 0', $vars);
        foreach ($res as $dep)
        {
            $vars = array(':recordID' => $recordID,
                          ':dependencyID' => $dep['dependencyID'],
                          ':filled' => 0,
                          ':time' => time(), );
            $res = $this->db->prepared_query('INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                                                VALUES (:recordID, :dependencyID, :filled, :time)
                                                ON DUPLICATE KEY UPDATE filled=:filled, time=:time', $vars);
        }

        // mark form as submitted, dependencyID 5 = submitted form
        $vars = array(':recordID' => $recordID,
                      ':dependencyID' => 5,
                      ':filled' => 1,
                      ':time' => time(), );
        $res = $this->db->prepared_query('INSERT INTO records_dependencies (recordID, dependencyID, filled, time)
                                            VALUES (:recordID, :dependencyID, :filled, :time)
                                            ON DUPLICATE KEY UPDATE filled=:filled, time=:time', $vars);

        $this->db->commitTransaction();

        $errors = array();
        // trigger initial submit event
        include_once 'FormWorkflow.php';
        $FormWorkflow = new FormWorkflow($this->db, $this->login, $recordID);
        $FormWorkflow->setEventFolder('../scripts/events/');
        foreach ($workflowIDs as $id)
        {
            // The initial step for Requestor is special step id -1
            $status = $FormWorkflow->handleEvents($id, -1, 'submit', '');
            if (count($status['errors']) > 0)
            {
                $errors = array_merge($errors, $status['errors']);
            }
        }

        return array('status' => 1, 'errors' => $errors);
    }

    /**
     * Get the progress percentage (as integer)
     * @param int $recordID
     * @return int Percent completed
     */
    public function getProgress($recordID)
    {
        $vars = array(':recordID' => (int)$recordID);
        $tresRecord = $this->db->prepared_query('SELECT recordID, categoryID, count, submitted FROM records
                                                    LEFT JOIN category_count USING (recordID)
                                                    WHERE recordID=:recordID', $vars);
        $resRecord = array();
        foreach ($tresRecord as $record)
        {
            if ($record['submitted'] > 0)
            {
                return 100;
            }
            $resRecord[strtolower($record['categoryID'])] = $record['count'];
        }

        $vars = array(':recordID' => (int)$recordID);
        $resCompletedCount = $this->db->prepared_query('SELECT COUNT(*) FROM data LEFT JOIN indicators
                                                            USING (indicatorID)
                                                            WHERE recordID=:recordID
                                                                AND indicators.required = 1
        														AND indicators.disabled = 0
                                                                AND data != ""', $vars);

        $resCount = $this->db->prepared_query('SELECT categoryID, COUNT(*) FROM indicators WHERE required=1 AND disabled = 0 GROUP BY categoryID', array());
        $countData = array();
        $sum = 0;
        foreach ($resCount as $cat)
        {
            $sum += $cat['COUNT(*)'] * (isset($resRecord[strtolower($cat['categoryID'])]) ? $resRecord[strtolower($cat['categoryID'])] : 0);
        }
        if ($sum == 0)
        {
            return 100;
        }

        return round(($resCompletedCount[0]['COUNT(*)'] / $sum) * 100);
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
        if ($resRecords[0]['isWritableUser'] == 1
            && $this->login->getUserID() == $resRecords[0]['userID'])
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
            $vars = array(':categoryID' => XSSHelpers::xscrub($categoryID),
                          ':userID' => $this->login->getUserID(), );
            $resCategoryPrivs = $this->db->prepared_query('SELECT * FROM category_privs
                                                        LEFT JOIN users USING (groupID)
                                                        WHERE categoryID=:categoryID
                                                            AND userID=:userID
            												AND writable=1', $vars);

            if (count($resCategoryPrivs) > 0)
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
                $resCategoryPrivs = $this->db->prepared_query('SELECT * FROM category_privs
                                                        LEFT JOIN users USING (groupID)
                                                        WHERE categoryID=:categoryID
                                                            AND userID=:userID
            												AND writable=1', $vars);

                if (count($resCategoryPrivs) > 0)
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
     * @param dependencyID
     * @param details - Associative Array containing dependency-specific details, eg: $details['groupID']
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

                //check if the requester has any backups
                $nexusDB = $this->login->getNexusDB();
                $vars4 = array(':empId' => $empUID);
                $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);

                if ($empUID == $this->login->getEmpUID())
                {
                    return true;
                }
                    //check and provide access to backups
                    foreach ($backupIds as $row)
                    {
                        if ($row['backupEmpUID'] == $this->login->getEmpUID())
                        {
                            return true;
                        }
                    }

                break;
            case -2: // dependencyID -2 : requestor followup
                $varsPerson = array(':recordID' => (int)$details['recordID']);
                $resPerson = $this->db->prepared_query('SELECT userID FROM records
                                                               WHERE recordID=:recordID', $varsPerson);
                 if ($resPerson[0]['userID'] == $this->login->getUserID())
                 {
                     return true;
                 }
                 else{
                    $empUID = $this->getEmpUID($resPerson[0]['userID']);
                                                                
                    return $this->checkIfBackup($empUID);
                 }
               

                break;
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

    public function getEmpUID($userName){
        $nexusDB = $this->login->getNexusDB();
        $vars = array(':userName' => $userName);
        $response = $nexusDB->prepared_query('SELECT * FROM employee WHERE userName =:userName', $vars);
        return $response[0]["empUID"];
    }

    public function checkIfBackup($empUID){

        $nexusDB = $this->login->getNexusDB();
        $vars = array(':empId' => $empUID);
        $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars);

        if ($empUID != $this->login->getEmpUID())
        {
            foreach ($backupIds as $row)
            {
                if ($row['backupEmpUID'] == $this->login->getEmpUID())
                {
                    return true;
                }
            }

            return false;
        }

        return true;
    }

    /**
     * Scrubs a list of records to remove records that the current user doesn't have access to
     * Defaults to enable read access, unless needToKnow mode is set for any form
     * @param array
     * @return array Returns the input array, scrubbing records that the current user doesn't have access to
     */
    public function checkReadAccess($records)
    {
        if (count($records) == 0)
        {
            return $records;
        }

        $recordIDs = '';
        foreach ($records as $item)
        {
            if (is_numeric($item['recordID']))
            {
                $recordIDs .= $item['recordID'] . ',';
            }
        }
        $recordIDs = trim($recordIDs, ',');
        $recordIDsHash = sha1($recordIDs);

        $res = array();
        $hasCategoryAccess = array(); // the keys will be categoryIDs that the current user has access to
        if (isset($this->cache["checkReadAccess_{$recordIDsHash}"]))
        {
            $res = $this->cache["checkReadAccess_{$recordIDsHash}"];
        }
        else
        {
            // get a list of records which have categories marked as need-to-know
            $vars = array();
            $query = "
                SELECT recordID, categoryID, dependencyID, groupID, serviceID, userID,
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
            foreach ($res as $dep)
            {
                if ($dep['dependencyID'] == null)
                {
                    if (is_numeric($dep['recordID']))
                    {
                        $t_needToKnowRecords .= $dep['recordID'] . ',';
                    }
                }

                // keep track of unique categories
                if (isset($dep['categoryID']) && !isset($t_uniqueCategories[$dep['categoryID']]))
                {
                    $t_uniqueCategories[$dep['categoryID']] = 1;
                }
            }

            $t_needToKnowRecords = trim($t_needToKnowRecords, ',');
            if ($t_needToKnowRecords != '')
            {
                $vars = array();
                $res2 = $this->db->prepared_query("SELECT recordID, dependencyID, groupID, serviceID, userID, indicatorID_for_assigned_empUID, indicatorID_for_assigned_groupID FROM records
													LEFT JOIN category_count USING (recordID)
													LEFT JOIN categories USING (categoryID)
													LEFT JOIN workflows USING (workflowID)
													LEFT JOIN workflow_steps USING (workflowID)
													LEFT JOIN step_dependencies USING (stepID)
													LEFT JOIN dependency_privs USING (dependencyID)
													WHERE recordID IN ({$t_needToKnowRecords})
														AND needToKnow = 0
														AND count > 0", $vars);

                $res = array_merge($res, $res2);
            }

            // find out if "collaborator access" is being used for any categoryID in the set
            // and whether the current user has access
            $uniqueCategoryIDs = '';
            foreach ($t_uniqueCategories as $key => $value)
            {
                $uniqueCategoryIDs .= "'{$key}',";
            }
            $uniqueCategoryIDs = trim($uniqueCategoryIDs, ',');

            $catsInGroups = $this->db->prepared_query(
                "SELECT * FROM category_privs WHERE categoryID IN ({$uniqueCategoryIDs}) AND readable = 1",
                array()
            );
            if (count($catsInGroups) > 0)
            {
                $groups = $this->login->getMembership();
                foreach ($catsInGroups as $cat)
                {
                    if (isset($groups['groupID'][$cat['groupID']])
                        && $groups['groupID'][$cat['groupID']] == 1)
                    {
                        $hasCategoryAccess[$cat['categoryID']] = 1;
                    }
                }
            }

            $this->cache["checkReadAccess_{$recordIDsHash}"] = $res;
        }

        // don't scrub anything if no limits are in place
        if (count($res) == 0)
        {
            return $records;
        }

        // admin group
        if ($this->login->checkGroup(1))
        {
            return $records;
        }

        $temp = isset($this->cache['checkReadAccess_tempArray']) ? $this->cache['checkReadAccess_tempArray'] : array();

        // grant access
        foreach ($res as $dep)
        {
            if (!isset($temp[$dep['recordID']]) || $temp[$dep['recordID']] == 0)
            {
                $temp[$dep['recordID']] = 0;

                $temp[$dep['recordID']] = $this->hasDependencyAccess($dep['dependencyID'], $dep) ? 1 : 0;

                // request initiator
                if ($dep['userID'] == $this->login->getUserID())
                {
                    $temp[$dep['recordID']] = 1;
                }

                // grants backups the ability to access records of their backupFor
                if($temp[$dep['recordID']] == 0) {
                    foreach ($this->employee->getBackupsFor($this->login->getEmpUID()) as $emp)
                    {
                        if ($dep['userID'] == $emp["userName"])
                        {
                            $temp[$dep['recordID']] = 1;
                        }
                    }
                }

                // collaborator access
                if (isset($hasCategoryAccess[$dep['categoryID']]))
                {
                    $temp[$dep['recordID']] = 1;
                }
            }
        }
        $this->cache['checkReadAccess_tempArray'] = $temp;

        foreach ($records as $record)
        {
            if (isset($temp[$record['recordID']]) && $temp[$record['recordID']] == 0)
            {
                unset($records[$record['recordID']]);
            }
        }

        return $records;
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

    // recordID_list: array from view.php
    // indicatorID_list: ID#'s delimited by ','
    public function getCustomData($recordID_list, $indicatorID_list)
    {
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

        $vars2 = array('recordIDs' => $recordIDs);
        $res = $this->db->prepared_query("SELECT * FROM data
                                    WHERE indicatorID IN ({$indicatorID_list})
                                        AND recordID IN ({$recordIDs})", $vars2);

        if (is_array($res) && count($res) > 0)
        {
            foreach ($res as $item)
            {
                // handle special data types
                switch($indicators[$item['indicatorID']]['format']) {
                    case 'date':
                        if ($item['data'] != '' && !is_numeric($item['data']))
                        {
                            $parsedDate = strtotime($item['data']);
                            if ($parsedDate !== false)
                            {
                                $item['data'] = date('n/j/Y', $parsedDate);
                            }
                        }
                        break;
                    case 'orgchart_employee':
                        $empRes = $this->employee->lookupEmpUID($item['data']);
                        if (isset($empRes[0]))
                        {
                            $item['data'] = "{$empRes[0]['firstName']} {$empRes[0]['lastName']}";
                            $item['dataOrgchart'] = $empRes[0];
                        }
                        else
                        {
                            $item['data'] = '';
                        }
                        break;
                    case 'orgchart_position':
                        $positionTitle = $this->position->getTitle($item['data']);
                        $positionData = $this->position->getAllData($item['data']);

                        $item['dataOrgchart'] = $positionData;
                        $item['dataOrgchart']['positionID'] = $item['data'];
                        $item['data'] = "{$positionTitle} ({$positionData[2]['data']}-{$positionData[13]['data']}-{$positionData[14]['data']})";
                        break;
                    case 'orgchart_group':
                        $groupTitle = $this->group->getTitle($item['data']);

                        $item['data'] = $groupTitle;
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
                        if (substr($indicators[$item['indicatorID']]['format'], 0, 10) == 'checkboxes')
                        {
                            $tData = @unserialize($item['data']);
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
                            $item['gridInput'] = array_merge($values, array("format" => $format));
                            $item['data'] = 'id' . $item['indicatorID'] . '_gridInput';
                        }
                        break;
                }

                $out[$item['recordID']]['s' . $item['series']]['id' . $item['indicatorID']] = isset($indicatorMasks[$item['indicatorID']]) && $indicatorMasks[$item['indicatorID']] == 1 ? '[protected data]' : $item['data'];
                if (isset($item['dataOrgchart']))
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

        if ($this->isNeedToKnow())
        {
            $out = $this->checkReadAccess($out);
        }

        return $out;
    }

    public function getActionComments($recordID)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return array();
        }

        $vars = array(':recordID' => $recordID);
        $res = $this->db->prepared_query('SELECT * FROM action_history
                                            LEFT JOIN dependencies USING (dependencyID)
                                            LEFT JOIN actions USING (actionType)
                                            WHERE recordID=:recordID
                                                AND comment != ""
                                            ORDER BY time ASC', $vars);

        require_once 'VAMC_Directory.php';
        $dir = new VAMC_Directory;

        $total = count($res);
        for ($i = 0; $i < $total; $i++)
        {
            $user = $dir->lookupLogin($res[$i]['userID']);
            $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $field['userID'];
            $res[$i]['name'] = $name;
        }

        return $res;
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
        $title = $this->sanitizeInput($title);

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
            $vars = array(':recordID' => (int)$recordID,
                          ':userID' => $userID, );
            $res = $this->db->prepared_query('UPDATE records SET
                                            	userID=:userID
                                            	WHERE recordID=:recordID', $vars);

            // write log entry
            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

            $user = $dir->lookupLogin($userID);
            $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $userID;

            $comment = "Initiator changed to {$name}";
            $vars2 = array(':recordID' => (int)$recordID,
                ':userID' => $this->login->getUserID(),
                ':dependencyID' => 0,
                ':actionType' => 'changeInitiator',
                ':actionTypeID' => 8,
                ':time' => time(),
                ':comment' => $comment, );
            $this->db->prepared_query('INSERT INTO action_history (recordID, userID, dependencyID, actionType, actionTypeID, time, comment)
                                            VALUES (:recordID, :userID, :dependencyID, :actionType, :actionTypeID, :time, :comment)', $vars2);

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

    public function query($inQuery)
    {
        $query = json_decode(html_entity_decode(html_entity_decode($inQuery)), true);

        if ($query == null)
        {
            return 'Invalid query';
        }

        $joinSearchAllData = false;
        $joinSearchOrgchartEmployeeData = false;
        $vars = array();
        $conditions = '';
        $joins = '';
        $count = 0;
        foreach ($query['terms'] as $q)
        {
            // Logic for AND/OR Operator's
            $op = 'AND';
            if ($q['op']) {
                $op = $q['op'];
            }
            if ($count === 0) {
                $op = '';
                $conditions = '(';
            } else {
                if ($op == 'AND') {
                    $conditions = $conditions . ') AND (';
                } elseif ($op == 'OR') {
                    $conditions = $conditions . ' OR ';
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
                case 'RIGHT JOIN':
                    break;
                default:
                    return 0;

                    break;
            }

            $vars[':' . $q['id'] . $count] = $q['match'];
            switch ($q['id']) {
                case 'recordID':
                    $conditions .= "recordID {$operator} :recordID{$count}";

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

                    $conditions .= "recordID IN ({$validRecordIDs})";

                    unset($vars[":recordIDs{$count}"]);

                    break;
                case 'serviceID':
                    $conditions .= "serviceID {$operator} :serviceID{$count}";

                    break;
                case 'submitted':
                    $conditions .= "submitted {$operator} :submitted{$count}";

                    break;
                case 'deleted':
                    $conditions .= "deleted {$operator} :deleted{$count}";

                    break;
                case 'title':
                    $conditions .= "title {$operator} :title{$count}";
                    $scrubSpace = array('/^(%\s)+/', '/(\s+%)$/');
                    $vars[':title' . $count] = preg_replace($scrubSpace, '%', $vars[':title' . $count]);

                    break;
                case 'userID':
                    $conditions .= "userID {$operator} :userID{$count}";

                    break;
                case 'date': // backwards compatibility
                    $vars[':date' . $count] = strtotime($vars[':date' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':date' . $count . 'b'] = $vars[':date' . $count] + 86400;
                            $conditions .= "(date >= :date{$count} AND date <= :date{$count}b)";

                            break;
                        case '<=':
                            $vars[':date' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "date {$operator} :date{$count}";

                            break;
                    }

                    break;
                case 'dateInitiated':
                    $vars[':dateInitiated' . $count] = strtotime($vars[':dateInitiated' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':dateInitiated' . $count . 'b'] = $vars[':dateInitiated' . $count] + 86400;
                            $conditions .= "(date >= :dateInitiated{$count} AND date <= :dateInitiated{$count}b)";

                            break;
                        case '<=':
                            $vars[':dateInitiated' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "date {$operator} :dateInitiated{$count}";

                            break;
                    }

                    break;
                case 'dateSubmitted':
                    $vars[':dateSubmitted' . $count] = strtotime($vars[':dateSubmitted' . $count]);
                    switch ($operator) {
                        case '=':
                            $vars[':dateSubmitted' . $count . 'b'] = $vars[':dateSubmitted' . $count] + 86400;
                            $conditions .= "(submitted >= :dateSubmitted{$count} AND submitted <= :dateSubmitted{$count}b)";

                            break;
                        case '<=':
                            $vars[':dateSubmitted' . $count] += 86400; // set to end of day
                            // no break
                        default:
                            $conditions .= "submitted {$operator} :dateSubmitted{$count}";

                            break;
                    }

                    break;
                case 'categoryID':
                    if ($q['operator'] != '!=')
                    {
                        $joins .= "INNER JOIN (SELECT * FROM category_count
    								WHERE categoryID = :categoryID{$count}
    									  AND count > 0) rj_categoryID{$count}
    								USING (recordID) ";
                    }
                    else
                    {
                        $joins .= "INNER JOIN (SELECT * FROM category_count
    								WHERE categoryID != :categoryID{$count}
    									  AND count > 0) rj_categoryID{$count}
    								USING (recordID) ";
                    }

                    break;
                case 'stepID':
                    if ($q['operator'] == '=')
                    {
                        switch ($vars[':stepID' . $count]) {
                            case 'submitted':
                                $conditions .= "submitted > 0";

                                break;
                            case 'notSubmitted': // backwards compat
                                $conditions .= "submitted = 0";

                                break;
                            case 'deleted':
                                $conditions .= "deleted > 0";

                                break;
                            case 'notDeleted': // backwards compat
                                $conditions .= "deleted = 0";

                                break;
                            case 'resolved':
                                $conditions .= "(records_workflow_state.stepID IS NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'notResolved': // backwards compat
                                $conditions .= "(records_workflow_state.stepID IS NOT NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            default:
                                if (is_numeric($vars[':stepID' . $count]))
                                {
                                    $joins .= "INNER JOIN (SELECT * FROM records_workflow_state
                									WHERE stepID=:stepID{$count}) rj_stepID{$count}
                									USING (recordID) ";
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
                                $conditions .= "submitted = 0";

                                break;
                            case 'notSubmitted': // backwards compat
                                $conditions .= "submitted > 0";

                                break;
                            case 'deleted':
                                $conditions .= "deleted = 0";

                                break;
                            case 'notDeleted': // backwards compat
                                $conditions .= "deleted > 0";

                                break;
                            case 'resolved':
                                $conditions .= "(records_workflow_state.stepID IS NOT NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            case 'notResolved': // backwards compat
                                $conditions .= "(records_workflow_state.stepID IS NULL AND submitted > 0 AND deleted = 0)";
                                $joins .= 'LEFT JOIN records_workflow_state USING (recordID) ';

                                break;
                            default:
                                if (is_numeric($vars[':stepID' . $count]))
                                {
                                    $joins .= "INNER JOIN (SELECT * FROM records_workflow_state
                									WHERE stepID != :stepID{$count}) rj_stepID{$count}
                									USING (recordID) ";
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
                        $conditions .= "(lj_data{$count}.data {$operator} :data{$count} OR lj_data{$count}.data IS NULL)";
                    }
                    else
                    {
                        if ($operator == '!=' && $vars[':data' . $count] == '')
                        {
                            $conditions .= "(lj_data{$count}.data {$operator} :data{$count} OR lj_data{$count}.data IS NOT NULL)";
                        }
                        else
                        {
                            $dataTerm = "lj_data{$count}.data";
                            if ($joinSearchAllData
                            || $joinSearchOrgchartEmployeeData)
                            {
                                $dataTerm = 'lj_data.data';
                            }

                            $dataMatch = ":data{$count}";
                            switch ($tResTypeHint[0]['format']) {
                            case 'number':
                            case 'currency':
                                $dataTerm = "CAST({$dataTerm} as DECIMAL(21,5))";

                                break;
                            case 'date':
                                $dataTerm = "STR_TO_DATE({$dataTerm}, '%m/%d/%Y')";
                                $dataMatch = "STR_TO_DATE(:data{$count}, '%m/%d/%Y')";

                                break;
                            default:
                                break;
                        }

                            // catch default data
                            if (isset($tResTypeHint[0]['default'])
                            && $tResTypeHint[0]['default'] == $vars[':data' . $count])
                            {
                                $conditions .= "({$dataTerm} {$operator} $dataMatch OR {$dataTerm} IS NULL)";
                            }
                            else
                            {
                                $conditions .= "{$dataTerm} {$operator} $dataMatch";
                            }
                        }
                    }

                    break;
                case 'dependencyID':	//search records_dependencies
                    if (!isset($q['indicatorID']) || !is_numeric($q['indicatorID']))
                    {
                        return 0;
                    }
                    $vars[':indicatorID' . $count] = $q['indicatorID'];
                    $joins .= "INNER JOIN (SELECT *, time as `depTime_{$q['indicatorID']}` FROM records_dependencies
								WHERE dependencyID=:indicatorID{$count}
                                    AND filled{$operator}:dependencyID{$count}) lj_dependency{$count}
								USING (recordID) ";

                    break;
                default:
                    return 0;
            }
            $count++;
        }

        // End Check for Conditions Query
        if ($count) {
            $conditions = $conditions . ') ';
        } else {
            $conditions = '';
        }

        $joinCategoryID = false;
        $joinAllCategoryID = false;
        $joinRecords_Dependencies = false;
        $joinRecords_Step_Fulfillment = false;
        $joinActionHistory = false;
        $joinRecordResolutionData = false;
        $joinInitiatorNames = false;
        if (isset($query['joins']))
        {
            foreach ($query['joins'] as $table)
            {
                switch ($table) {
                    case 'service':
                        $joins .= 'LEFT JOIN services USING (serviceID) ';

                        break;
                    case 'status':
                        $joins .= 'LEFT JOIN (SELECT * FROM records_workflow_state GROUP BY recordID) lj_status USING (recordID)
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
                    case 'recordResolutionData':
                        $joinRecordResolutionData = true;

                        break;
                    case 'initiatorName':
                        $joinInitiatorNames = true;

                        break;
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

        if ($joinInitiatorNames)
        {
            $joins .= "LEFT JOIN (SELECT userName, lastName, firstName FROM {$this->oc_dbName}.employee) lj_OCinitiatorNames ON records.userID = lj_OCinitiatorNames.userName ";
        }

        $res = $this->db->prepared_query('SELECT * FROM records
    										' . $joins . '
                                            WHERE ' . $conditions . $sort . $limit, $vars);
        $data = array();
        $recordIDs = '';
        foreach ($res as $item)
        {
            $data[$item['recordID']] = $item;
            $recordIDs .= $item['recordID'] . ',';
        }
        $recordIDs = trim($recordIDs, ',');

        if ($joinCategoryID)
        {
            $res2 = $this->db->prepared_query('SELECT * FROM category_count
    											LEFT JOIN categories USING (categoryID)
    											WHERE recordID IN (' . $recordIDs . ')
    												AND disabled = 0
    												AND count > 0', array());
            foreach ($res2 as $item)
            {
                $data[$item['recordID']]['categoryNames'][] = $item['categoryName'];
                $data[$item['recordID']]['categoryIDs'][] = $item['categoryID'];
            }
        }

        if ($joinAllCategoryID)
        {
            $res2 = $this->db->prepared_query('SELECT * FROM category_count
    											LEFT JOIN categories USING (categoryID)
    											WHERE recordID IN (' . $recordIDs . ')
    												AND count > 0', array());
            foreach ($res2 as $item)
            {
                $data[$item['recordID']]['categoryNamesUnabridged'][] = $item['categoryName'];
                $data[$item['recordID']]['categoryIDsUnabridged'][] = $item['categoryID'];
            }
        }

        if ($joinRecordsDependencies)
        {
            $res2 = $this->db->prepared_query('SELECT * FROM records_dependencies
    											LEFT JOIN dependencies USING (dependencyID)
    											WHERE recordID IN (' . $recordIDs . ')
    												AND filled != 0', array());
            foreach ($res2 as $item)
            {
                $data[$item['recordID']]['recordsDependencies'][$item['dependencyID']]['time'] = $item['time'];
                $data[$item['recordID']]['recordsDependencies'][$item['dependencyID']]['description'] = $item['description'];
            }
        }

        if ($joinActionHistory)
        {
            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

            $res2 = $this->db->prepared_query('SELECT recordID, stepID, userID, time, description, actionTextPasttense, actionType, comment FROM action_history
    											LEFT JOIN dependencies USING (dependencyID)
    											LEFT JOIN actions USING (actionType)
    											WHERE recordID IN (' . $recordIDs . ')
                                                ORDER BY time', array());
            foreach ($res2 as $item)
            {
                $user = $dir->lookupLogin($item['userID']);
                $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $res[0]['userID'];
                $item['approverName'] = $name;

                $data[$item['recordID']]['action_history'][] = $item;
            }
        }

        if($joinRecordResolutionData)
        {
            $res2 = $this->db->prepared_query('SELECT recordID, lastStatus, records_step_fulfillment.stepID, fulfillmentTime FROM records
                    LEFT JOIN records_step_fulfillment USING (recordID)
                    LEFT JOIN records_workflow_state USING (recordID)
                    WHERE recordID IN (' . $recordIDs . ')
                        AND records_workflow_state.stepID IS NULL
                        AND submitted > 0
                        AND deleted = 0', array());
            foreach ($res2 as $item)
            {
                if($data[$item['recordID']]['recordResolutionData']['fulfillmentTime'] == null
                    || $data[$item['recordID']]['recordResolutionData']['fulfillmentTime'] < $item['fulfillmentTime']) {
                    $data[$item['recordID']]['recordResolutionData']['lastStatus'] = $item['lastStatus'];
                    $data[$item['recordID']]['recordResolutionData']['fulfillmentTime'] = $item['fulfillmentTime'];
                }
            }
        }

        if ($joinRecords_Step_Fulfillment)
        {
            $res2 = $this->db->prepared_query('SELECT * FROM records_step_fulfillment
    											LEFT JOIN workflow_steps USING (stepID)
    											WHERE recordID IN (' . $recordIDs . ')', array());
            foreach ($res2 as $item)
            {
                $data[$item['recordID']]['stepFulfillment'][$item['stepID']]['time'] = $item['fulfillmentTime'];
                $data[$item['recordID']]['stepFulfillment'][$item['stepID']]['step'] = $item['stepTitle'];
            }
        }

        // check needToKnow mode
        if ($this->isNeedToKnow())
        {
            $data = $this->checkReadAccess($data);
        }

        // check if data is being requested as part of the query
        if (isset($query['getData']))
        {
            $indicatorIDs = '';
            foreach ($query['getData'] as $indicatorID)
            {
                $indicatorIDs .= $indicatorID . ',';
            }

            return $this->getCustomData($data, $indicatorIDs);
        }

        return $data;
    }

    public function getDisabledIndicatorList($disabled)
    {
        $vars = array(':disabled' => (int)$disabled);
        $res = $this->db->prepared_query('SELECT * FROM indicators
											LEFT JOIN categories USING (categoryID)
						                    WHERE indicators.disabled >= :disabled
						    					AND categories.disabled = 0
						    				ORDER BY name', $vars);

        $data = array();
        foreach ($res as $item)
        {
            $temp = array();
            $temp['indicatorID'] = $item['indicatorID'];
            $temp['name'] = $item['name'];
            $temp['format'] = $item['format'];
            $temp['description'] = $item['description'];
            $temp['categoryName'] = $item['categoryName'];
            $data[] = $temp;
        }

        return $data;
    }

    /**
     * List of all available active indicators
     * @param string $sort
     * @param boolean $includeHeadings
     * @param string $formsFilter - csv list of forms to search for
     * @return array list of indicators
     */
    public function getIndicatorList($sort = 'name', $includeHeadings = false, $formsFilter = '')
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
        $query = 'SELECT *, COALESCE(NULLIF(description, ""), name) as name, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive FROM indicators
                    LEFT JOIN categories USING (categoryID)
                    WHERE indicators.disabled = 0
                        AND format != ""
                        AND name != ""
                        AND categories.disabled = 0' . $orderBy;
        if($includeHeadings) {
            $query = 'SELECT *, COALESCE(NULLIF(description, ""), name) as name, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive FROM indicators
            LEFT JOIN categories USING (categoryID)
            WHERE indicators.disabled = 0
                AND name != ""
                AND categories.disabled = 0' . $orderBy;
        }
        $res = $this->db->prepared_query($query, $vars);

        $resAll = $this->db->prepared_query('SELECT *, indicators.parentID as parentIndicatorID, categories.parentID as parentCategoryID, is_sensitive FROM indicators
													LEFT JOIN categories USING (categoryID)
								                    WHERE indicators.disabled = 0
								    					AND categories.disabled = 0' . $orderBy, $vars);

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
            $temp['description'] = $item['description'];
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
                    $temp['description'] = $item['description'];
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

        $res = $this->db->query(
            'SELECT indicatorID, name, format
                FROM indicators
                WHERE indicatorID IN ('. $indicatorList .')'
            );
        return $res;
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
                if ($series != null && $recordID != null && is_numeric($field['indicatorID']))
                {
                    $indicatorList .= "{$field['indicatorID']},";
                }
            }

            if ($series != null && $recordID != null)
            {
                $indicatorList = trim($indicatorList, ',');
                $var = array(':series' => (int)$series,
                             ':recordID' => (int)$recordID, );
                $res2 = $this->db->prepared_query('SELECT data, timestamp, indicatorID, groupID FROM data
                									LEFT JOIN indicator_mask USING (indicatorID)
                									WHERE indicatorID IN (' . $indicatorList . ') AND series=:series AND recordID=:recordID', $var);

                foreach ($res2 as $resIn)
                {
                    $idx = $resIn['indicatorID'];
                    $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                    $data[$idx]['timestamp'] = isset($resIn['timestamp']) ? $resIn['timestamp'] : 0;
                    $data[$idx]['groupID'] = isset($resIn['groupID']) ? $resIn['groupID'] : null;
                }
            }

            foreach ($res as $field)
            {
                $idx = $field['indicatorID'];

                // todo: cleanup required field
                $required = isset($field['required']) && $field['required'] == 1 ? ' required="true" ' : '';

                $child[$idx]['indicatorID'] = $field['indicatorID'];
                $child[$idx]['series'] = $series;
                $child[$idx]['name'] = $field['name'];
                $child[$idx]['default'] = $field['default'];
                $child[$idx]['description'] = $field['description'];
                $child[$idx]['html'] = $field['html'];
                $child[$idx]['htmlPrint'] = $field['htmlPrint'];
                $child[$idx]['required'] = $field['required'];
                $child[$idx]['is_sensitive'] = $field['is_sensitive'];
                $child[$idx]['isEmpty'] = (isset($data[$idx]['data']) && !is_array($data[$idx]['data']) && strip_tags($data[$idx]['data']) != '') ? false : true;
                $child[$idx]['value'] = (isset($data[$idx]['data']) && $data[$idx]['data'] != '') ? $data[$idx]['data'] : $child[$idx]['default'];
                $child[$idx]['value'] = @unserialize($data[$idx]['data']) === false ? $child[$idx]['value'] : unserialize($data[$idx]['data']);
                $child[$idx]['timestamp'] = isset($data[$idx]['timestamp']) ? $data[$idx]['timestamp'] : 0;
                $child[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $field['categoryID']);
                $child[$idx]['isMasked'] = isset($data[$idx]['groupID']) ? $this->isMasked($field['indicatorID'], $recordID) : 0;
                $child[$idx]['sort'] = $field['sort'];

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

                // special handling for org chart data types
                if ($field['format'] == 'orgchart_employee')
                {
                    $empRes = $this->employee->lookupEmpUID($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = '';
                    if (isset($empRes[0]))
                    {
                      $child[$idx]['displayedValue'] = ($child[$idx]['isMasked']) ? '[protected data]' : "{$empRes[0]['firstName']} {$empRes[0]['lastName']}";
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

                if($parseTemplate) {
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
     * @return int 1 for success, errors for failure
     */
    public function copyAttachment($indicatorID, $fileName, $recordID, $newRecordID, $series) {
        if (!is_numeric($recordID) || !is_numeric($indicatorID) || !is_numeric($series))
        {
            $errors = array('type' => 2);
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
        $vars = array(':categoryID'=>XSSHelpers::xscrub($categoryID));
        $data = $this->db->prepared_query('SELECT recordID, title, userID, categoryID, submitted
                                            FROM records
                                            JOIN category_count USING (recordID)
                                            WHERE categoryID=:categoryID', $vars);

        return $data;
    }
    
    public function permanentlyDeleteRecord($recordID) {
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
     * @throws SmartyException
     */
    function sendReminderEmail($recordID, $days) {

        // Lookup approvers of current record so we can notify
        $vars = array(':recordID' => $recordID);
        $strSQL = "SELECT users.userID AS approverID, sd.dependencyID, ser.serviceID, users.groupID ".
            "FROM records_workflow_state ".
            "LEFT JOIN records USING (recordID) ".
            "LEFT JOIN step_dependencies AS sd USING (stepID) ".
            "LEFT JOIN dependency_privs USING (dependencyID) ".
            "LEFT JOIN users USING (groupID) ".
            "LEFT JOIN services AS ser USING (serviceID) ".
            "WHERE recordID=:recordID AND (active=1 OR active IS NULL)";
        $approvers = $this->db->prepared_query($strSQL, $vars);

        if (count($approvers) > 0)  {

            require_once 'Email.php';
            $email = new Email();
            $email->setSender('leaf.noreply@va.gov');
            $email->setSubject('LEAF Action Requested - Record #'.$recordID.' - '.$days.'+ Day Reminder');

            $strHtmlOutput  = "Your review of following record is requested as it as been ".$days."+ days since it was ";
            $strHtmlOutput .= "assigned to you in LEAF:<br /><br />";
            $aryReferrer = explode('/', $_SERVER['REQUEST_URI']);
            $strReferrer = "";
            foreach($aryReferrer as $section) {
                if ($section !== 'api') {
                    $strReferrer .= $section . '/';
                } else {
                    break;
                }
            }
            $strURL = "https://". $_SERVER['SERVER_NAME'] ."/". $strReferrer . "index.php?a=printview&recordID=".$recordID;
            $strHtmlOutput .= "<a href='".$strURL."' target='_blank'>".$strURL."</a><br /><br />";
            $strHtmlOutput .= "Your review of this request would be appreciated at your earliest convenience.<br /><br />";
            $strHtmlOutput .= "<em>Sincerely,<br />LEAF Team</em><br /><br />";
            $email->setBody($strHtmlOutput);

            require_once 'VAMC_Directory.php';
            $dir = new VAMC_Directory;

            foreach ($approvers as $approver) {
                if (strlen($approver['approverID']) > 0) {
                    $tmp = $dir->lookupLogin($approver['approverID']);
                    $email->addRecipient($tmp[0]['Email']);
                }
            }

            // Special cases depending on dependency of record
            switch ($approvers[0]['dependencyID']) {
                // special case for service chiefs
                case 1:
                    $vars = array(':serviceID' => $approvers[0]['serviceID']);
                    $strSQL = "SELECT userID FROM service_chiefs WHERE serviceID=:serviceID AND active=1";
                    $chief = $this->db->prepared_query($strSQL, $vars);

                    foreach ($chief as $member) {
                        if (strlen($member['userID']) > 0) {
                            $tmp = $dir->lookupLogin($member['userID']);
                            $email->addRecipient($tmp[0]['Email']);
                        }
                    }
                    break;

                // special case for quadrads
                case 8:
                    $vars = array(':groupID' => $approvers[0]['groupID']);
                    $strSQL = "SELECT userID FROM users WHERE groupID=:groupID AND active=1";
                    $quadrad = $this->db->prepared_query($strSQL, $vars);
                    foreach ($quadrad as $member) {
                        if (strlen($member['userID']) > 0) {
                            $tmp = $dir->lookupLogin($member['userID']);
                            $email->addRecipient($tmp[0]['Email']);
                        }
                    }
                    break;

                // special case for a person designated by the requestor
                case -1:
                    require_once 'form.php';
                    $form = new Form($this->db, $this->login);

                    // find the next step
                    $varsStep = array(':stepID' => $approvers[0]['stepID']);
                    $strSQL = "SELECT indicatorID_for_assigned_empUID FROM workflow_steps WHERE stepID=:stepID";
                    $resStep = $this->db->prepared_query($strSQL, $varsStep);

                    $resEmpUID = $form->getIndicator($resStep[0]['indicatorID_for_assigned_empUID'], 1, $this->recordID);
                    $empUID = $resEmpUID[$resStep[0]['indicatorID_for_assigned_empUID']]['value'];

                    //check if the requester has any backups
                    $nexusDB = $this->login->getNexusDB();
                    $vars4 = array(':empId' => $empUID);
                    $strSQL = "SELECT backupEmpUID FROM relation_employee_backup WHERE empUID =:empId";
                    $backupIds = $nexusDB->prepared_query($strSQL, $vars4);

                    if ($empUID > 0) {
                        $tmp = $dir->lookupEmpUID($empUID);
                        $email->addRecipient($tmp[0]['Email']);
                    }

                    // add for backups
                    foreach ($backupIds as $row) {
                        $tmp = $dir->lookupEmpUID($row['backupEmpUID']);
                        if (isset($tmp[0]['Email']) && $tmp[0]['Email'] != '') {
                            $email->addCcBcc($tmp[0]['Email']);
                        }
                    }
                    break;

                // requestor followup
                case -2:
                    $vars = array(':recordID' => $this->recordID);
                    $strSQL = "SELECT userID FROM records WHERE recordID=:recordID";
                    $resRequestor = $this->db->prepared_query($strSQL, $vars);
                    $tmp = $dir->lookupLogin($resRequestor[0]['userID']);
                    $email->addRecipient($tmp[0]['Email']);
                    break;

                // special case for a group designated by the requestor
                case -3:
                    require_once 'form.php';
                    $form = new Form($this->db, $this->login);

                    // find the next step
                    $varsStep = array(':stepID' => $approvers[0]['stepID']);
                    $strSQL = "SELECT indicatorID_for_assigned_groupID FROM workflow_steps WHERE stepID=:stepID";
                    $resStep = $this->db->prepared_query($strSQL, $varsStep);

                    $resGroupID = $form->getIndicator($resStep[0]['indicatorID_for_assigned_groupID'], 1, $this->recordID);
                    $groupID = $resGroupID[$resStep[0]['indicatorID_for_assigned_groupID']]['value'];

                    if ($groupID > 0) {
                        $email->addGroupRecipient($groupID);
                    }
                    break;
            }

            $email->sendMail();
        }
    }
}
