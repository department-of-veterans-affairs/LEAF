<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

abstract class RESTfulResponse
{
    /**
     * Returns result for HTTP GET requests
     * @param array $actionList
     * @return mixed
     */
    abstract public function get(array $actionList);

    /**
     * Returns result for HTTP POST requests
     * @param array $actionList
     * @return mixed
     */
    abstract public function post(array $actionList);

    /**
     * Returns result for HTTP DELETE requests
     * @param array $actionList
     * @return mixed
     */
    abstract public function delete(array $actionList);

    /**
     * Handles HTTP request
     *
     * @param string $action
     *
     * @return string
     *
     * Created at: 3/23/2023, 8:49:06 AM (America/New_York)
     */
    public function handler(string $action): string
    {
        $action = $this->parseAction($action);

        switch ($_SERVER['REQUEST_METHOD']) {
            case 'GET':
                $return_value = $this->output($this->get($action));

                break;
            case 'POST':
                if (hash_equals($_SESSION['CSRFToken'], $_POST['CSRFToken'])) {
                    $return_value = $this->output($this->post($action));
                } else {
                    http_response_code(401);
                    $return_value = $this->output('Invalid Token.');
                }

                break;
            case 'DELETE':
                $DELETE_vars = [];
                parse_str(file_get_contents('php://input', false, null, 0, 8192), $DELETE_vars); // only parse the first 8192 characters (arbitrary limit)

                if (hash_equals($_SESSION['CSRFToken'], $_GET['CSRFToken']) // Deprecation warning: The _GET implementation should be removed in favor of $DELETE_vars
                    || hash_equals($_SESSION['CSRFToken'], $DELETE_vars['CSRFToken'])) {
                    $return_value = $this->output($this->delete($action));
                } else {
                    http_response_code(401);
                    $return_value = $this->output('Invalid Token.');
                }

                break;
            default:
                $return_value = $this->output('unhandled method');

                break;
        }

        return $return_value;
    }

    /**
     * Outputs in specified format based on $_GET['format']
     * Default to JSON
     *
     * @param array|string $out
     *
     * @return string
     *
     * Created at: 3/23/2023, 8:49:26 AM (America/New_York)
     */
    public function output(array|string|null $out = ''): string
    {
        $out = $this->filterData($out);

        //header('Access-Control-Allow-Origin: *');
        $format = isset($_GET['format']) ? $_GET['format'] : '';

        switch ($format) {
            case 'php':
                $return_value = serialize($out);

                break;
            case 'string':
                $return_value = $out;

                break;
            case 'json-js-assoc':
                header('Content-type: application/json');
                $out2 = array();

                foreach ($out as $item) {
                    $out2[] = $item;
                }

                $return_value = json_encode($out2);

                break;
            case 'jsonp':
                $callBackName = '';

                if (isset($_GET['callback'])) {
                    $callBackName = htmlentities($_GET['callback']);
                } else {
                    if (isset($_GET['jsonpCallback'])) {
                        $callBackName = htmlentities($_GET['jsonpCallback']);
                    } else {
                        $callBackName = 'jsonpCallback';
                    }
                }

                $return_value = "{$callBackName}(" . json_encode($out) . ')';

                break;
            case 'xml':
                header('Content-type: text/xml');
                $xml = new \SimpleXMLElement('<?xml version="1.0"?><output></output>');
                $this->buildXML($out, $xml);

                $return_value = $xml->asXML();

                break;
            case 'csv':
                //if $out is not an array, create one with the appropriate structure, preserving the original value of $out
                if (!is_array($out)) {
                    $out = array(
                                'column' => array('error'),
                                'row' => array('error' => $out),
                            );
                }

                $columns = $this->flattenStructure($out);

                $items = array_keys($out);
                $columns = array_keys($out[$items[0]]);

                header('Content-type: text/csv');
                header('Content-Disposition: attachment; filename="Exported_' . time() . '.csv"');
                $header = '';

                foreach ($columns as $column) {
                    $header .= '"' . $column . '",';
                }

                $header = trim($header, ',');
                $buffer = "{$header}\r\n";

                foreach ($out as $line) {
                    foreach ($columns as $column) {
                        if (is_array($line[$column])) {
                            $buffer .= '"';

                            foreach ($line[$column] as $tItem) {
                                $buffer .= $tItem . "\r\n";
                            }

                            $buffer = trim($buffer);
                            $buffer .= '",';
                        } else {
                            $temp = strip_tags($line[$column]);
                            $temp = str_replace('"', '""', $temp);
                            $buffer .= '"' . $temp . '",';
                        }
                    }

                    $buffer .= "\r\n";
                }

                $return_value = $buffer;

                break;
            case 'htmltable':
                $columns = $this->flattenStructure($out);

                $body = '<table>';
                $body .= '<thead><tr>';

                foreach ($columns as $column) {
                    $body .= '<th>' . $column . '</th>';
                }

                $body .= '</tr></thead>';
                $body .= '<tbody>';

                foreach ($out as $line) {
                    $body .= '<tr>';

                    foreach ($columns as $column) {
                        if (isset($line[$column]) && is_array($line[$column])) {
                            $body .= '<td>';

                            foreach ($line[$column] as $tItem) {
                                $body .= $tItem . '<br />';
                            }

                            $body .= '</td>';
                        } else {
                            $temp = isset($line[$column]) ? strip_tags($line[$column]) : '';
                            $body .= '<td>' . $temp . '</td>';
                        }
                    }

                    $body .= '</tr>';
                }

                $body .= '</tbody>';

                $return_value = $body;

                break;
            case 'x-visualstudio': // experimental mode for visual studio
                header('Content-type: application/json');
                $out2 = [];

                foreach ($out as $item) {
                    $out2['r' . $item['recordID']] = $item;
                }

                $jsonOut = json_encode($out2);

                if ($_SERVER['REQUEST_METHOD'] === 'GET') {
                    $etag = md5($jsonOut);
                    header_remove('Pragma');
                    header_remove('Cache-Control');
                    header_remove('Expires');

                    if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
                        && $_SERVER['HTTP_IF_NONE_MATCH'] === $etag) {
                        header("ETag: {$etag}", true, 304);
                        header('Cache-Control: must-revalidate, private');
                        exit;
                    }

                    header("ETag: {$etag}");
                    header('Cache-Control: must-revalidate, private');
                }

                $return_value = $jsonOut;

                break;
            case 'debug':
                $return_value = '<pre>' . print_r($out, true) . '</pre>';

                break;
            case 'json':
            default:
                header('Content-type: application/json');
                $jsonOut = json_encode($out);

                if ($_SERVER['REQUEST_METHOD'] === 'GET') {
                    $etag = '"' . md5($jsonOut) . '"';
                    header_remove('Pragma');
                    header_remove('Cache-Control');
                    header_remove('Expires');

                    if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
                           && $_SERVER['HTTP_IF_NONE_MATCH'] === $etag) {
                        header("ETag: {$etag}", true, 304);
                        header('Cache-Control: must-revalidate, private');
                        exit;
                    }

                    header("ETag: {$etag}");
                    header('Cache-Control: must-revalidate, private');
                }

                $return_value = $jsonOut;

                break;
        }

        return $return_value;
    }

    /**
     * Parses url input into generic format
     *
     * @param string $action
     *
     * @return array
     *
     * Created at: 3/22/2023, 2:45:39 PM (America/New_York)
     */
    public function parseAction(string $action): array
    {
        $actionList = explode('/', $action, 10);

        $key = '';
        $args = array();

        foreach ($actionList as $type) {
            if (is_numeric($type)) {
                $key .= '[digit]/';
                $args[] = $type;
            } else {
                if (substr($type, 0, 1) == '_') {
                    $key .= '[text]/';
                    $args[] = substr($type, 1);
                } else {
                    $key .= "{$type}/";
                }
            }
        }

        $key = rtrim($key, '/');

        $action = array();
        $action['key'] = $key;
        $action['args'] = $args;

        return $action;
    }

    /**
     * Aborts script if the referrer directory doesn't match the admin directory
     *
     * @return false|string
     *
     * Created at: 3/23/2023, 11:06:40 AM (America/New_York)
     */
    public function verifyAdminReferrer(): false|string
    {
        $return_value = false;

        if (!isset($_SERVER['HTTP_REFERER'])) {
            $return_value = 'Error: Invalid request. Missing Referer.';
        } else {
            $tIdx = strpos($_SERVER['HTTP_REFERER'], '://');
            $referer = substr($_SERVER['HTTP_REFERER'], $tIdx);

            $url = '://' . HTTP_HOST;

            $script = $_SERVER['SCRIPT_NAME'];
            $apiOffset = strpos($script, '/api/');
            $script = substr($script, 0, $apiOffset + 1);

            $checkMe = strtolower($url . $script . 'admin');

            if (strncmp(strtolower($referer), $checkMe, strlen($checkMe)) !== 0) {
                $return_value = 'Error: Invalid request. Mismatched Referer';
            }
        }

        return $return_value;
    }

    /**
     * Helper function to build an XML file
     *
     * @param array|string|null $out
     * @param \SimpleXMLElement $xml
     *
     * @return void
     *
     * Created at: 3/24/2023, 7:48:36 AM (America/New_York)
     */
    private function buildXML(array|string|null $out, \SimpleXMLElement $xml): void
    {
        if (is_array($out)) {
            $keys = array_keys($out);

            foreach ($keys as $key) {
                $tkey = is_numeric($key) ? "id_{$key}" : $key;

                if (is_array($out[$key])) {
                    $subXML = $xml->addChild($tkey);
                    $this->buildXML($out[$key], $subXML);
                } else {
                    $xml->addChild($tkey, $out[$key]);
                }
            }
        } else {
            $xml->addChild('text', $out);
        }
    }

    /**
     * flattenStructureGridInput performs an in-place restructure of gridInput data
     * within $out to fit 2D data structures
     *
     * @param array|string|null $out
     * @param string $key
     * @param string $gridKey
     *
     * @return false|array
     *
     * Created at: 3/24/2023, 8:00:37 AM (America/New_York)
     */
    private function flattenStructureGridInput(array|string|null &$out, string $key, string $gridKey): false|array
    {
        $isGrid = strpos($gridKey, '_gridInput') !== false ? true : false;
        $table = isset($_GET['table']) ? $_GET['table'] : '';

        if ($table == '' || $table != $gridKey) {
            if ($isGrid) {
                $out[$key][$gridKey] = "Append &table={$gridKey} to URL";
            }

            return false;
        }

        $columns = ['recordID', $gridKey . '_id'];
        $gridIndex = array_flip($out[$key][$gridKey]['columns']);

        $gridFormatIndex = [];

        foreach ($out[$key][$gridKey]['format'] as $gridFormat) {
            $columns[] = $gridFormat['name'];
            $gridFormatIndex[$gridIndex[$gridFormat['id']]] = $gridFormat['name'];
        }

        foreach ($out[$key][$gridKey]['cells'] as $cKey => $row) {
            $newKey = $key . '.' . $cKey;
            $out[$newKey] = $out[$key];
            $out[$newKey][$gridKey . '_id'] = $newKey;

            foreach ($row as $rKey => $item) {
                $out[$newKey][$gridFormatIndex[$rKey]] = $item;
            }
        }

        unset($out[$key]);

        return $columns;
    }

    /**
     * flattenStructureActionHistory performs an in-place restructure of action_history data
     * within $out to fit 2D data structures
     *
     * @param array|string|null $out
     * @param string $key
     *
     * @return false|array
     *
     * Created at: 3/24/2023, 8:00:52 AM (America/New_York)
     */
    private function flattenStructureActionHistory(array|string|null &$out, string $key): false|array
    {
        if (!isset($out[$key]['action_history'])) {
            return false;
        }

        $table = isset($_GET['table']) ? $_GET['table'] : '';

        if ($table == '' || $table != 'action_history') {
            $out[$key]['action_history'] = 'Append &table=action_history to URL';
            return false;
        }

        if (isset($out[$key]['action_history'])) {
            foreach ($out[$key]['action_history'] as $akey => $aval) {
                $newKey = $key . '.' . $akey;
                $out[$newKey] = $out[$key];
                $out[$newKey]['actionHistory_id'] = $newKey;
                $out[$newKey]['actionHistory_userID'] = $aval['userID'];
                $out[$newKey]['actionHistory_time'] = $aval['time'];
                $out[$newKey]['actionHistory_actionTextPasttense'] = $aval['actionTextPasttense'];
                $out[$newKey]['actionHistory_approverName'] = $aval['approverName'];
                $out[$newKey]['actionHistory_comment'] = $aval['comment'];
            }
        }

        unset($out[$key]);

        return ['recordID', 'actionHistory_id', 'actionHistory_userID', 'actionHistory_time',
            'actionHistory_actionTextPasttense', 'actionHistory_approverName', 'actionHistory_comment'];
    }

    /**
     * flattenStructureOrgchart performs an in-place restructure of orgchart data
     * within $out to fit 2D data structures
     *
     * @param array|string|null $out
     * @param string $index
     *
     * @return void
     *
     * Created at: 3/24/2023, 8:01:03 AM (America/New_York)
     */
    private function flattenStructureOrgchart(array|string|null &$out, string $index): void
    {
        // flatten out orgchart_employee fields
        // delete orgchart_position extended content
        foreach (array_keys($out[$index]) as $id) {
            if (strpos($id, '_orgchart') !== false) {
                if (!isset($out[$index][$id]['positionID'])) {
                    $out[$index][$id . '_email'] = $out[$index][$id]['email'];
                    $out[$index][$id . '_userName'] = $out[$index][$id]['userName'];
                }

                unset($out[$index][$id]);
            }
        }
    }

    /**
     * flattenStructureCheckGrid is a wrapper for flattenStructureGridInput
     *
     * @param array|string|null $out
     * @param string $key
     * @param bool $hasGrid
     * @param array $columns
     *
     * @return void
     *
     * Created at: 3/24/2023, 8:00:15 AM (America/New_York)
     */
    private function flattenStructureCheckGrid(array|string|null &$out, string $key, bool &$hasGrid, array &$columns): void
    {
        foreach (array_keys($out[$key]['s1']) as $tkey) {
            $gridCols = $this->flattenStructureGridInput($out, $key, $tkey);

            if ($gridCols !== false) {
                $hasGrid = true;
                $columns = $gridCols;
            }
        }
    }

    /**
     * flattenStructure performs an in-place restructure of $out to fit 2D data structures
     *
     * @param array|string|null $out
     *
     * @return array
     *
     * Created at: 3/24/2023, 8:01:27 AM (America/New_York)
     */
    private function flattenStructure(array|string|null &$out): array
    {
        $columns = ['recordID', 'serviceID', 'date', 'userID', 'title', 'lastStatus', 'submitted',
            'deleted', 'service', 'abbreviatedService', 'groupID'];

        $hasGrid = false;
        $hasActionHistory = false;

        foreach ($out as $key => $item) {
            // flatten out s1 and orgchart structures
            if (isset($item['s1'])) {
                $out[$key] = array_merge($out[$key], $item['s1']);

                $this->flattenStructureOrgchart($out, $key);
                $this->flattenStructureCheckGrid($out, $key, $hasGrid, $columns);

                unset($out[$key]['s1']);
            }

            // flatten action_history data
            $actionCols = $this->flattenStructureActionHistory($out, $key);

            if ($actionCols !== false) {
                $hasActionHistory = true;
                $columns = $actionCols;
            }

            if (isset($out[$key])) {
                foreach (array_keys($out[$key]) as $tkey) {
                    if (!in_array($tkey, $columns) && !$hasGrid && !$hasActionHistory) {
                        $columns[] = $tkey;
                    }
                }
            }
        }

        return $columns;
    }

    /**
     * filterDataS1HtmlPrint is a helper function to filter out htmlPrint data
     * returned by form data fields
     *
     * @param array $s1
     *
     * @return array
     *
     * Created at: 3/24/2023, 8:07:44 AM (America/New_York)
     */
    private function filterDataS1HtmlPrint(array $s1): array
    {
        $sids = array_keys($s1);

        // iterate through keys within each s1 set
        foreach ($sids as $sKey) {
            if (strpos($sKey, '_htmlPrint') !== false) {
                unset($s1[$sKey]);
            }
        }

        return $s1;
    }

    /**
     * filterDataS1Timestamp is a helper function to filter out timestamps
     * returned by form data fields
     *
     * @param array $s1
     *
     * @return array
     *
     * Created at: 3/24/2023, 8:08:15 AM (America/New_York)
     */
    private function filterDataS1Timestamp(array $s1): array
    {
        $sids = array_keys($s1);

        // iterate through keys within each s1 set
        foreach ($sids as $sKey) {
            if (strpos($sKey, '_timestamp') !== false) {
                unset($s1[$sKey]);
            }
        }

        return $s1;
    }

    /**
     * filterSubkeys is a helper function for filterData
     *
     * @param string $keyName Name of the child key
     * @param array $subKey Content of the child key
     * @param array $filter User's filter
     *
     * @return array
     *
     * Created at: 3/24/2023, 8:09:01 AM (America/New_York)
     */
    private function filterSubkeys(string $keyName, array $subKey, array $filter): array
    {
        // iterate through keys within each subset
        foreach ($subKey as $keyIdx => $item) {
            $keys = array_keys($item);

            foreach ($keys as $key) {
                if (!isset($filter[$keyName . '.' . $key])) {
                    unset($subKey[$keyIdx][$key]);
                }
            }
        }

        return $subKey;
    }

    /**
     * filterData is an experimental output filter used to lower data transfer to clients.
     * $_GET['x-filterData'] is a CSV of desired array keys. All other keys will be filtered out.
     *
     * id_timestamp is a special key to signal a need for s1.id##_timestamp values.
     * id_htmlPrint is a special key to signal a need for s1.id##_htmlPrint values.
     *
     * Arrays nested within first level keys can be retrieved via [key].[subkey]
     * For example, action_history.approverName would enable all approverNames within
     * each action_history item.
     *
     * The experimental parameter x-filterData is subject to change and use of this
     * should be limited.
     *
     * @param array|null $data
     *
     * @return array
     *
     * Created at: 3/24/2023, 8:20:12 AM (America/New_York)
     */
    private function filterData(array|string|null $data): array|string|null
    {
        if (isset($_GET['x-filterData'])) {
            $filter = explode(',', $_GET['x-filterData'], 32);
            $filter = array_flip($filter);
            // add data fields that are implicitly requested
            $filter['s1'] = 1;
            $filter['action_history'] = 1;
            $filter['child'] = 1;

            // iterate through each record
            foreach ($data as $key => $value) {
                $ids = array_keys($value);

                // iterate through keys within each record
                foreach ($ids as $id) {
                    if (!isset($filter[$id])) {
                        unset($data[$key][$id]);
                    }

                    // filter out s1 timestamps if applicable
                    if (isset($data[$key]['s1'])
                        && !isset($filter['id_timestamp'])
                    ) {
                        $data[$key]['s1'] = $this->filterDataS1Timestamp($data[$key]['s1']);
                    }

                    // filter out s1 htmlPrint items if applicable
                    if (isset($data[$key]['s1'])
                        && !isset($filter['id_htmlPrint'])
                    ) {
                        $data[$key]['s1'] = $this->filterDataS1HtmlPrint($data[$key]['s1']);
                    }

                    // filter out action_history fields if applicable
                    if (isset($data[$key]['action_history'])) {
                        $data[$key]['action_history'] = $this->filterSubkeys('action_history', $data[$key]['action_history'], $filter);
                    }

                    // filter out child fields (e.g. form/[id]data/tree) if applicable
                    if (isset($data[$key]['child'])) {
                        $data[$key]['child'] = $this->filterSubkeys('child', $data[$key]['child'], $filter);
                    }
                }
            }
        }

        return $data;
    }
}
