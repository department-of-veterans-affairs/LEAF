<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Generic Data
    Date: August 18, 2011

*/

namespace Orgchart;

use App\Leaf\CommonConfig;
use App\Leaf\Logger\DataActionLogger;
use App\Leaf\XSSHelpers;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;
use App\Leaf\Setting;

abstract class Data
{
    protected $db;

    protected $login;

    protected $dataTable = '';

    protected $dataHistoryTable = '';

    protected $dataTagTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    protected $dataActionLogger;

    protected $cache = array();

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->initialize();
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    /**
     * Initialize data table variables
     */
    abstract public function initialize();

    public function setDataTable($tableName)
    {
        $this->dataTable = $this->dataTable == '' ? $tableName : $this->dataTable;
    }

    public function setDataHistoryTable($tableName)
    {
        $this->dataHistoryTable = $this->dataHistoryTable == '' ? $tableName : $this->dataHistoryTable;
    }

    public function setDataTagTable($tableName)
    {
        $this->dataTagTable = $this->dataTagTable == '' ? $tableName : $this->dataTagTable;
    }

    public function setDataTableUID($uid)
    {
        $this->dataTableUID = $this->dataTableUID == '' ? $uid : $this->dataTableUID;
    }

    public function setDataTableDescription($desc)
    {
        $this->dataTableDescription = $this->dataTableDescription == '' ? $desc : $this->dataTableDescription;
    }

    public function setDataTableCategoryID($categoryID)
    {
        $this->dataTableCategoryID = $this->dataTableCategoryID == 0 ? $categoryID : $this->dataTableCategoryID;
    }

    public function getDataTableCategoryID()
    {
        return $this->dataTableCategoryID;
    }

    public function getDataTableDescription()
    {
        return $this->dataTableDescription;
    }

    /**
     * Retrieve all data if no indicatorID is given
     * @param int $UID
     * @param int $indicatorID
     * @return array
     */
    public function getAllData($UID, $indicatorID = 0)
    {
        if (!is_numeric($indicatorID)) {
            return array();
        }

        $vars = array();
        $res = array();

        $cacheHash = "getAllData_{$UID}_{$indicatorID}";

        if (isset($this->cache[$cacheHash])) {
            return $this->cache[$cacheHash];
        }

        if (!isset($this->cache["getAllData_{$indicatorID}"])) {
            if ($indicatorID != 0) {
                $vars = array(':indicatorID' => $indicatorID);
                $sql = "SELECT *
                        FROM `indicators`
                        WHERE `categoryID` = {$this->dataTableCategoryID}
                        AND `disabled` = 0
                        AND `indicatorID` = :indicatorID
                        ORDER BY `sort`";
                $res = $this->db->prepared_query($sql, $vars);
            } else {
                $sql = "SELECT *
                        FROM `indicators`
                        WHERE `categoryID` = {$this->dataTableCategoryID}
                        AND `disabled` = 0
                        ORDER BY `sort`";
                $res = $this->db->prepared_query($sql, $vars);
            }
            $this->cache["getAllData_{$indicatorID}"] = $res;
        } else {
            $res = $this->cache["getAllData_{$indicatorID}"];
        }

        $data = array();

        foreach ($res as $item) {
            $idx = $item['indicatorID'];
            $data[$idx]['indicatorID'] = $item['indicatorID'];
            $data[$idx]['name'] = isset($item['name']) ? $item['name'] : '';
            $data[$idx]['format'] = isset($item['format']) ? $item['format'] : '';

            if (isset($item['description'])) {
                $data[$idx]['description'] = $item['description'];
            }

            if (isset($item['default'])) {
                $data[$idx]['default'] = $item['default'];
            }

            if (isset($item['html'])) {
                $data[$idx]['html'] = $item['html'];
            }

            $data[$idx]['required'] = $item['required'];

            if ($item['encrypted'] != 0) {
                $data[$idx]['encrypted'] = $item['encrypted'];
            }

            $data[$idx]['data'] = '';
            $data[$idx]['isWritable'] = 0; //temp

            // handle checkboxes/radio buttons
            $inputType = explode("\n", $item['format']);
            $numOptions = count($inputType) > 1 ? count($inputType) : 2;

            if (count($inputType) != 1) {
                for ($i = 1; $i < $numOptions; $i++) {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    $data[$idx]['options'][] = $inputType[$i];
                }
            }

            $data[$idx]['format'] = trim($inputType[0]);
        }

        if (count($res) > 0) {
            $indicatorList = '';

            foreach ($res as $field) {
                if (is_numeric($field['indicatorID'])) {
                    $indicatorList .= "{$field['indicatorID']},";
                }
            }

            $indicatorList = trim($indicatorList, ',');
            $var = array(':id' => $UID);
            $sql = "SELECT `data`, `timestamp`, `indicatorID`
                    FROM {$this->dataTable}
                	WHERE `indicatorID` IN ({$indicatorList})
                    AND {$this->dataTableUID} = :id";
            $res2 = $this->db->prepared_query($sql, $var);

            foreach ($res2 as $resIn) {
                $idx = $resIn['indicatorID'];
                $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';

                $decoded = Setting::safeDecodeData($data[$idx]['data']);
                $data[$idx]['data'] = $decoded !== false ? $decoded : $data[$idx]['data'];

                if ($data[$idx]['format'] == 'json') {
                    $data[$idx]['data'] = html_entity_decode($data[$idx]['data']);
                }

                if ($data[$idx]['format'] == 'fileupload') {
                    $tmpFileNames = explode("\n", $data[$idx]['data']);
                    $data[$idx]['data'] = array();
                    foreach ($tmpFileNames as $tmpFileName) {
                        if (trim($tmpFileName) != '') {
                            $data[$idx]['data'][] = $tmpFileName;
                        }
                    }
                }

                if (isset($resIn['author'])) {
                    $data[$idx]['author'] = $resIn['author'];
                }

                if (isset($resIn['timestamp'])) {
                    $data[$idx]['timestamp'] = $resIn['timestamp'];
                }
            }

            // apply access privileges
            $privilegesData = $this->login->getIndicatorPrivileges(array_keys($data), $this->dataTableUID, $UID);
            $privileges = array_keys($privilegesData);

            foreach ($privileges as $id) {
                if ($privilegesData[$id]['read'] == 0
                    && $data[$id]['data'] != ''
                ) {
                    $data[$id]['data'] = '[protected data]';
                }

                if ($privilegesData[$id]['write'] != 0) {
                    $data[$id]['isWritable'] = 1;
                }
            }
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }

    /**
     * Clean up html input, allow some tags
     * @param string $in
     * @return string
     */
    public function sanitizeInput($in)
    {
        // strip out unused characters
        $in = preg_replace('/^\011[^\040-\176]/', '', $in);

        $pattern = array('/&lt;table(\s.+)?&gt;/Ui',
                             '/&lt;\/table&gt;/Ui',
                             '/&lt;(\/)?br(\s.+)?\s\/&gt;/Ui',
                             '/&lt;(\/)?(\S+)(\s.+)?&gt;/U',
                             '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
                             '/(\<\/p\>\<\/p\>){2,}/',
                             '/(\<p\>\<\/p\>){2,}/', );

        $replace = array('<table class="table">',
                             '</table>',
                             '<\1br />',
                             '<\1\2>',
                             '###-##-####',
                             '',
                             '', );

        $in = strip_tags(html_entity_decode($in), '<b><i><u><ol><li><br><p><table><td><tr>');
        $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES));

        // check tag grammar
        $matches = array();
        preg_match_all('/\<(\/)?([A-Za-z]+)(\s.+)?\>/U', $in, $matches, PREG_PATTERN_ORDER);
        $openTags = array();
        $numTags = count($matches[2]);
        for ($i = 0; $i < $numTags; $i++)
        {
            if ($matches[2][$i] != 'br')
            {
                //echo "examining: {$matches[1][$i]}{$matches[2][$i]}\n";
                // proper closure
                if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] > 0)
                {
                    $openTags[$matches[2][$i]]--;
                // echo "proper\n";
                }
                // new open tag
                else
                {
                    if ($matches[1][$i] == '')
                    {
                        if (!isset($openTags[$matches[2][$i]]))
                        {
                            $openTags[$matches[2][$i]] = 0;
                        }
                        $openTags[$matches[2][$i]]++;
                    // echo "open\n";
                    }
                    // improper closure
                    else
                    {
                        if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] <= 0)
                        {
                            $in = '<' . $matches[2][$i] . '>' . $in;
                            $openTags[$matches[2][$i]]--;
                            // echo "improper\n";
                        }
                    }
                }
                // print_r($openTags);
            }
        }

        // close tags
        $tags = array_keys($openTags);
        foreach ($tags as $tag)
        {
            while ($openTags[$tag] > 0)
            {
                $in = $in . '</' . $tag . '>';
                $openTags[$tag]--;
            }
        }

        return $in;
    }

    public function getFileHash($categoryID, $uid, $indicatorID, $fileName)
    {
        if (!is_numeric($categoryID) || !is_numeric($uid) || !is_numeric($indicatorID))
        {
            return '';
        }
        $res = $this->db->prepared_query('SELECT * FROM settings WHERE setting="salt"', array());
        $salt = isset($res[0]['data']) ? $res[0]['data'] : '';

        $fileName = md5($fileName . $salt);

        return "{$categoryID}_{$uid}_{$indicatorID}_{$fileName}";
    }

    /**
     * Modify data using $_POST superglobal
     * $_POST Format: $_POST[indicatorID] = value
     * @param int $UID Unique ID of the current table (aka "record ID", empUID/groupID/positionID)
     * @throws Exception
     */
    public function modify($UID)
    {
        if (!is_numeric($UID)) {
            throw new Exception($this->dataTableDescription . ' ID required');
        }

        if (!isset($_POST['CSRFToken']) || $_POST['CSRFToken'] != $_SESSION['CSRFToken']) {
            throw new Exception($this->dataTableDescription . ' invalid token');
        }

        // Check for file uploads
        if (is_array($_FILES)) {
            $commonConfig = new CommonConfig();
            $fileExtensionWhitelist = $commonConfig->requestWhitelist;
            $fileIndicators = array_keys($_FILES);

            foreach ($fileIndicators as $indicator) {
                if (is_int($indicator)){
                    // check write access
                    $privilegesData = $this->login->getIndicatorPrivileges(array($indicator), $this->dataTableUID, $UID);

                    if (isset($privilegesData[$indicator]['write']) && $privilegesData[$indicator]['write'] == 0) {
                        throw new Exception($this->dataTableDescription . ' write access denied');
                    }

                    $_POST[$indicator] = $_FILES[$indicator]['name'];

                    $filenameParts = explode('.', $_FILES[$indicator]['name']);
                    $fileExtension = array_pop($filenameParts);
                    $fileExtension = strtolower($fileExtension);

                    if (in_array($fileExtension, $fileExtensionWhitelist)) {
                        $sanitizedFileName = $this->getFileHash($this->dataTableCategoryID, $UID, $indicator, $this->sanitizeInput($_FILES[$indicator]['name']));

                        // $sanitizedFileName = XSSHelpers::scrubFilename($sanitizedFileName);
                        if (!is_dir(Config::$uploadDir)) {
                            mkdir(Config::$uploadDir, 0755, true);
                        }
                        move_uploaded_file($_FILES[$indicator]['tmp_name'], Config::$uploadDir . $sanitizedFileName);
                    } else {
                        throw new Exception($this->dataTableDescription . ' file extension not supported');
                    }
                }
            }
        }

        $keys = array_keys($_POST);

        foreach ($keys as $key) {
            if (is_numeric($key)) {
                $vars = array(':UID' => $UID,
                              ':indicatorID' => $key, );
                $sql = "SELECT `data`, `format`
                        FROM {$this->dataTable}
                        LEFT JOIN `indicators` USING (`indicatorID`)
                        WHERE {$this->dataTableUID} = :UID
                        AND `indicatorID` = :indicatorID";
                $res = $this->db->prepared_query($sql, $vars);

                // handle JSON indicator type
                if (isset($res[0]['format']) && $res[0]['format'] == 'json') {
                    $res_temp = XSSHelpers::scrubObjectOrArray(json_decode(html_entity_decode($res[0]['data']), true));

                    if (is_array($res_temp)) {
                        $_POST[$key] = XSSHelpers::scrubObjectOrArray(json_decode($_POST[$key], true));

                        $jsonKeys = array_keys($res_temp);

                        foreach ($jsonKeys as $jsonKey) {
                            if (isset($_POST[$key][$jsonKey])) {
                                $_POST[$key][$jsonKey] = $_POST[$key][$jsonKey] + $res_temp[$jsonKey]; // array union, first term takes precedence
                            } else {
                                $_POST[$key] = $_POST[$key] + $res_temp;
                            }
                        }

                        $_POST[$key] = json_encode($_POST[$key]);
                    }
                }

                if (is_array($_POST[$key])) {
                    $_POST[$key] = json_encode($_POST[$key]); // special case for radio/checkbox items
                } else {
                    $_POST[$key] = preg_replace('/[^\040-\176]/', '', $this->sanitizeInput($_POST[$key]));
                }

                // handle fileupload indicator type
                if (isset($res[0]['format']) && $res[0]['format'] == 'fileupload') {
                    if (!isset($_POST['overwrite'])
                        && strpos($res[0]['data'], $_POST[$key]) === false
                    ) {
                        $_POST[$key] = trim($res[0]['data'] . "\n" . $_POST[$key]);
                    } else {
                        if (!isset($_POST['overwrite'])
                            && strpos($res[0]['data'], $_POST[$key]) !== false
                        ) {
                            $_POST[$key] = trim($res[0]['data']);
                        }
                    }
                }

                $duplicate = false;

                if (isset($res[0]['data']) && $res[0]['data'] == trim($_POST[$key])) {
                    $duplicate = true;
                }

                // check write access
                $privilegesData = $this->login->getIndicatorPrivileges(array($key), $this->dataTableUID, $UID);

                if (isset($privilegesData[$key]['write']) && $privilegesData[$key]['write'] == 0) {
                    throw new Exception($this->dataTableDescription . ' write access denied');
                }

                $vars = array(':UID' => $UID,
                              ':indicatorID' => $key,
                              ':data' => trim($_POST[$key]),
                              ':timestamp' => time(),
                              ':author' => $this->login->getUserID(), );
                $sql = "INSERT INTO {$this->dataTable} ({$this->dataTableUID}, `indicatorID`, `data`, `timestamp`, `author`)
                            VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                            ON DUPLICATE KEY UPDATE `data` = :data, `timestamp` = :timestamp, `author` = :author";
                $res = $this->db->prepared_query($sql, $vars);

                if (!$duplicate) {
                    $sql = "INSERT INTO {$this->dataHistoryTable} ({$this->dataTableUID}, `indicatorID`, `data`, `timestamp`, `author`)
                            VALUES (:UID, :indicatorID, :data, :timestamp, :author)";
                    $res2 = $this->db->prepared_query($sql, $vars);
                }
            }
        }

        $this->updateLastModified();

        return 1;
    }

    public function getAllTags($uid)
    {
        $vars = array(':UID' => $uid);

        $tags = array();
        $res = $this->db->prepared_query("SELECT * FROM {$this->dataTagTable} WHERE {$this->dataTableUID} = :UID", $vars);
        foreach ($res as $tag)
        {
            $tags[$tag['tag']] = $tag['tag'];
        }

        return $tags;
    }

    public function addTag($uid, $tag)
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            $tagObj = new Tag($this->db, $this->login);
            $tags = $tagObj->getAll();
            foreach ($tags as $item)
            {
                if (strtolower($tag) == strtolower($item['tag']))
                {
                    throw new Exception('Administrator access required to add reserved tags');
                }
            }
        }

        // prevent tags from being added to the admin group
        if ($this->dataTagTable == 'group_tags'
            && $uid == 1)
        {
            throw new Exception('Tags may not be added to the Administrator group');
        }

        if (strlen($tag) == 0)
        {
            throw new Exception('Cannot add empty tag');
        }

        $vars = array(':UID' => $uid,
                      ':tag' => $this->sanitizeInput($tag), );

        $res = $this->db->prepared_query("INSERT INTO {$this->dataTagTable} ({$this->dataTableUID}, tag)
                                            VALUES (:UID, :tag)", $vars);

        $this->updateLastModified();

        $this->logAction(DataActions::ADD, LoggableTypes::TAG, [
            new LogItem($this->dataTagTable, $this->dataTableUID, $uid),
            new LogItem($this->dataTagTable, "tag", $this->sanitizeInput($tag))
        ]);

        return true;
    }

    public function deleteTag($uid, $tag)
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            throw new Exception('Administrator access required to delete tags');
        }

        $vars = array(':UID' => $uid,
                      ':tag' => $tag, );

        $res = $this->db->prepared_query("DELETE FROM {$this->dataTagTable}
                                            WHERE {$this->dataTableUID}=:UID
                                                AND tag=:tag", $vars);

        $this->updateLastModified();

        $this->logAction(DataActions::DELETE, LoggableTypes::TAG, [
            new LogItem($this->dataTagTable, $this->dataTableUID, $uid),
            new LogItem($this->dataTagTable, "tag", $this->sanitizeInput($tag))
        ]);

        return true;
    }

    // Locally delete tags
    public function deleteLocalTag($uid, $tag)
    {
        $vars = array(':UID' => $uid,
            ':tag' => $tag, );

        $res = $this->db->prepared_query("DELETE FROM {$this->dataTagTable}
                                            WHERE {$this->dataTableUID}=:UID
                                                AND tag=:tag", $vars);

        $this->updateLastModified();

        $this->logAction(DataActions::DELETE, LoggableTypes::TAG, [
            new LogItem($this->dataTagTable, $this->dataTableUID, $uid),
            new LogItem($this->dataTagTable, "tag", $this->sanitizeInput($tag))
        ]);

        return true;
    }

    // deletes old tags, inserts new ones
    /*public function parseTags($recordID, $input)
    {
        $vars = array(':recordID' => $recordID,
                ':userID' => $this->login->getUserID());
        $res = $this->db->prepared_query('DELETE FROM tags WHERE recordID=:recordID AND userID=:userID', $vars);

        $tags = explode(' ', trim($input));
        foreach($tags as $tag) {
            if(trim($tag) != '') {
                $this->addTag($recordID, trim($tag));
            }
        }
    }*/

    /**
     * Delete file/image attachment
     * @param int $categoryID
     * @param int $UID
     * @param int $indicatorID
     * @return int 1 for success, 0 for fail
     */
    public function deleteAttachment($categoryID, $UID, $indicatorID, $file)
    {
        if (!is_numeric($categoryID) || !is_numeric($UID) || !is_numeric($indicatorID) || $file == '')
        {
            return 0;
        }
        if (!isset($_POST['CSRFToken']) || $_POST['CSRFToken'] != $_SESSION['CSRFToken'])
        {
            return 'Invalid token';
        }

        $privilegesData = $this->login->getIndicatorPrivileges(array($indicatorID), $this->dataTableUID, $UID);
        if (isset($privilegesData[$indicatorID]['write']) && $privilegesData[$indicatorID]['write'] == 0)
        {
            return 0;
        }

        $data = $this->getAllData($UID, $indicatorID);
        $value = $data[$indicatorID]['data'];
        $inputFilename = html_entity_decode($this->sanitizeInput($file));
        $file = $this->getFileHash($categoryID, $UID, $indicatorID, $inputFilename);

        $uploadDir = Config::$uploadDir;

        if (!is_array($value))
        {
            $value = array($value);
        }
        if (array_search($inputFilename, $value) !== false)
        {
            $_POST['overwrite'] = true;
            $_POST[$indicatorID] = '';
            foreach ($value as $files)
            {
                if ($inputFilename != $files)
                {
                    $_POST[$indicatorID] .= $files . "\n";
                }
            }
            $this->modify($UID);
            if (file_exists($uploadDir . $file))
            {
                unlink($uploadDir . $file);
            }

            return 1;
        }

        return 0;
    }

    /**
     * Updates last modified cache timestamp
     * @return boolean
     */
    public function updateLastModified()
    {
        $time = time();

        if (isset($this->cache['updateLastModified'])
            && $this->cache['updateLastModified'] == $time)
        {
            return true;
        }

        $vars = array(':cacheID' => 'lastModified',
                ':data' => $time,
                ':cacheTime' => $time, );
        $this->db->prepared_query('INSERT INTO cache (cacheID, data, cacheTime)
        									VALUES (:cacheID, :data, :cacheTime)
        									ON DUPLICATE KEY UPDATE data=:data, cacheTime=:cacheTime', $vars);
        $this->cache['updateLastModified'] = $time;

        return true;
    }

    /**
     * Adds action to Data Action log table.
     *
     * @param string $verb
     * @param string $type
     * @param array $data
     *
     * @return void
     *
     * Created at: 12/2/2022, 3:12:35 PM (America/New_York)
     */
    public function logAction(string $verb, string $type, array $data): void
    {
        $this->dataActionLogger->logAction($verb, $type, $data);
    }

    public function getHistory($filterById){
        return $this->dataActionLogger->getHistory($filterById, $this->dataTableUID, LoggableTypes::GROUP);
    }

    /**
     * Returns all history ids for all groups
     *
     * @return array all history ids for all groups
     */
    public function getAllHistoryIDs()
    {
        // this method doesn't accept any arguments
        // return $this->dataActionLogger->getAllHistoryIDs($this->dataTableUID, LoggableTypes::GROUP);
        return $this->dataActionLogger->getAllHistoryIDs();
    }

}
