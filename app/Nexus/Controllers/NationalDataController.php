<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Generic Data (mirror of Data without write functions)
    Date: September 23, 2016

*/

namespace App\Nexus\Controllers;

use App\Nexus\Model\Indicators;

abstract class NationalDataController
{
    protected $indicator;

    protected $dataTable = '';

    protected $dataHistoryTable = '';

    protected $dataTagTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    protected $workingDataClass;

    private $cache = array();

    public function __construct(Indicators $indicators)
    {
        $this->indicator = $indicators;
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
     *
     * @param int $UID
     * @param int $indicatorID
     *
     * @return array
     *
     * Created at: 10/25/2023, 10:51:53 AM (America/New_York)
     */
    public function getAllData(int $UID, int $indicatorID = 0): array
    {
        $cacheHash = "getAllData_{$UID}_{$indicatorID}";

        if (!isset($this->cache[$cacheHash])) {
            if (!isset($this->cache["getAllData_{$indicatorID}"])) {
                if ($indicatorID != 0) {
                    $res = $this->indicator->getIndicatorsById($indicatorID, $this->dataTableCategoryID);
                } else {
                    $res = $this->indicator->getAllIndicators($this->dataTableCategoryID);
                }

                $this->cache["getAllData_{$indicatorID}"] = $res['data'];
            } else {
                $res['data'] = $this->cache["getAllData_{$indicatorID}"];
            }

            $data = array();

            foreach ($res['data'] as $item) {
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
                $data[$idx]['isWritable'] = 0;

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

            if (count($res['data']) > 0) {
                $indicatorList = '';

                foreach ($res['data'] as $field) {
                    if (is_numeric($field['indicatorID'])) {
                        $indicatorList .= "{$field['indicatorID']},";
                    }
                }

                $indicatorList = trim($indicatorList, ',');

                $res2 = $this->workingDataClass->getData($UID, $indicatorList, $this->dataTableUID);

                foreach ($res2['data'] as $resIn) {
                    $idx = $resIn['indicatorID'];
                    $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                    $data[$idx]['data'] = @unserialize($data[$idx]['data']) === false ? $data[$idx]['data'] : unserialize($data[$idx]['data']);

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
            }

            $this->cache[$cacheHash] = $data;
        }



        return $this->cache[$cacheHash];
    }

    /**
     * Clean up html input, allow some tags
     *
     * @param string $in
     *
     * @return string
     *
     * Created at: 10/25/2023, 11:05:15 AM (America/New_York)
     */
    public function sanitizeInput(string $in): string
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

        for ($i = 0; $i < $numTags; $i++) {
            if ($matches[2][$i] != 'br') {
                if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] > 0) {
                    $openTags[$matches[2][$i]]--;
                } else {
                    if ($matches[1][$i] == '') {
                        if (!isset($openTags[$matches[2][$i]])) {
                            $openTags[$matches[2][$i]] = 0;
                        }

                        $openTags[$matches[2][$i]]++;
                    } else {
                        if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] <= 0) {
                            $in = '<' . $matches[2][$i] . '>' . $in;
                            $openTags[$matches[2][$i]]--;
                        }
                    }
                }
            }
        }

        $tags = array_keys($openTags);

        foreach ($tags as $tag) {
            while ($openTags[$tag] > 0) {
                $in = $in . '</' . $tag . '>';
                $openTags[$tag]--;
            }
        }

        return $in;
    }

    /**
     * @param int $categoryID
     * @param int $uid
     * @param int $indicatorID
     * @param string $fileName
     * @param string $salt
     *
     * @return string
     *
     * Created at: 10/12/2023, 8:15:41 AM (America/New_York)
     */
    public function getFileHash(int $categoryID, int $uid, int $indicatorID, string $fileName, string $salt = ''): string
    {
        $return_value = '';

        if (is_numeric($categoryID) && is_numeric($uid) && is_numeric($indicatorID)) {
            $fileName = md5($fileName . $salt);
            $return_value = "{$categoryID}_{$uid}_{$indicatorID}_{$fileName}";
        }

        return $return_value;
    }
}
