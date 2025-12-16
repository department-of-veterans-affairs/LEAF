<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Generic Data (mirror of Data without write functions)
    Date: September 23, 2016

*/

namespace Orgchart;

use App\Leaf\Setting;

abstract class NationalData
{
    protected $db;

    protected $login;

    protected $dataTable = '';

    protected $dataHistoryTable = '';

    protected $dataTagTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    private $cache = array();

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->initialize();
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

    /**
     * Retrieve all data if no indicatorID is given
     * @param int $UID
     * @param int $indicatorID
     * @return array
     */
    public function getAllData($UID, $indicatorID = 0)
    {
        $vars = array();
        $res = array();

        $cacheHash = "getAllData_{$UID}_{$indicatorID}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        if (!isset($this->cache["getAllData_{$indicatorID}"]))
        {
            if ($indicatorID != 0)
            {
                $vars = array(':indicatorID' => $indicatorID);
                $res = $this->db->prepared_query("SELECT * FROM indicators
                                                    WHERE categoryID={$this->dataTableCategoryID}
                                                        AND disabled=0
                                                        AND indicatorID=:indicatorID
                                                    ORDER BY sort", $vars);
            }
            else
            {
                $res = $this->db->prepared_query("SELECT * FROM indicators
                                                    WHERE categoryID={$this->dataTableCategoryID}
                                                        AND disabled=0
                                                    ORDER BY sort", $vars);
            }
            $this->cache["getAllData_{$indicatorID}"] = $res;
        }
        else
        {
            $res = $this->cache["getAllData_{$indicatorID}"];
        }

        $data = array();

        foreach ($res as $item)
        {
            $idx = $item['indicatorID'];
            $data[$idx]['indicatorID'] = $item['indicatorID'];
            $data[$idx]['name'] = isset($item['name']) ? $item['name'] : '';
            $data[$idx]['format'] = isset($item['format']) ? $item['format'] : '';
            if (isset($item['description']))
            {
                $data[$idx]['description'] = $item['description'];
            }
            if (isset($item['default']))
            {
                $data[$idx]['default'] = $item['default'];
            }
            if (isset($item['html']))
            {
                $data[$idx]['html'] = $item['html'];
            }
            $data[$idx]['required'] = $item['required'];
            if ($item['encrypted'] != 0)
            {
                $data[$idx]['encrypted'] = $item['encrypted'];
            }
            $data[$idx]['data'] = '';
            $data[$idx]['isWritable'] = 0; //temp
            //$data[$idx]['author'] = '';
            //$data[$idx]['timestamp'] = 0;

            // handle checkboxes/radio buttons
            $inputType = explode("\n", $item['format']);
            $numOptions = count($inputType) > 1 ? count($inputType) : 2;
            if (count($inputType) != 1)
            {
                for ($i = 1; $i < $numOptions; $i++)
                {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    $data[$idx]['options'][] = $inputType[$i];
                }
            }

            $data[$idx]['format'] = trim($inputType[0]);
        }

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
            $var = array(':id' => $UID);
            $res2 = $this->db->prepared_query("SELECT data, timestamp, indicatorID FROM {$this->dataTable}
                									WHERE indicatorID IN ({$indicatorList}) AND {$this->dataTableUID}=:id", $var);

            foreach ($res2 as $resIn)
            {
                $idx = $resIn['indicatorID'];
                $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                $decoded = Setting::safeDecodeData($data[$idx]['data']);
                $data[$idx]['data'] = $decoded !== false ? $decoded : $data[$idx]['data'];
                if ($data[$idx]['format'] == 'json')
                {
                    $data[$idx]['data'] = html_entity_decode($data[$idx]['data']);
                }
                if ($data[$idx]['format'] == 'fileupload')
                {
                    $tmpFileNames = explode("\n", $data[$idx]['data']);
                    $data[$idx]['data'] = array();
                    foreach ($tmpFileNames as $tmpFileName)
                    {
                        if (trim($tmpFileName) != '')
                        {
                            $data[$idx]['data'][] = $tmpFileName;
                        }
                    }
                }
                if (isset($resIn['author']))
                {
                    $data[$idx]['author'] = $resIn['author'];
                }
                if (isset($resIn['timestamp']))
                {
                    $data[$idx]['timestamp'] = $resIn['timestamp'];
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
        // strip out uncommon characters
        $in = preg_replace('/^\011[^\040-\176]/', '', $in);

        // hard character limit of 65535
        $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;

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

        // verify tag grammar
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
}
