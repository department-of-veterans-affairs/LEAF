<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

abstract class RESTfulResponse
{
    /**
     * Returns result for HTTP GET requests
     * @param array $actionList
     * @return mixed
     */
    public function get($actionList)
    {
        return 'Method not implemented';
    }

    /**
     * Returns result for HTTP POST requests
     * @param array $actionList
     * @return mixed
     */
    public function post($actionList)
    {
        return 'Method not implemented';
    }

    /**
     * Returns result for HTTP DELETE requests
     * @param array $actionList
     * @return mixed
     */
    public function delete($actionList)
    {
        return 'Method not implemented';
    }

    /**
     * Handles HTTP request
     * @param string $action
     */
    public function handler($action)
    {
        $action = $this->parseAction($action);
        switch ($_SERVER['REQUEST_METHOD']) {
            case 'GET':
                $this->output($this->get($action));

                break;
            case 'POST':
                if ($_POST['CSRFToken'] == $_SESSION['CSRFToken'])
                {
                    $this->output($this->post($action));
                }
                else
                {
                    $this->output('Invalid Token.');
                }

                break;
            case 'DELETE':
                if ($_GET['CSRFToken'] == $_SESSION['CSRFToken'])
                {
                    $this->output($this->delete($action));
                }
                else
                {
                    $this->output('Invalid Token.');
                }

                break;
            default:
                $this->output('unhandled method');

                break;
        }
    }

    /**
     * Outputs in specified format based on $_GET['format']
     * Default to JSON
     * @param string $out
     */
    public function output($out = '')
    {
        $out = $this->filterData($out);

        //header('Access-Control-Allow-Origin: *');
        $format = isset($_GET['format']) ? $_GET['format'] : '';
        switch ($format) {
            case 'json':
            default:
                header('Content-type: application/json');
                $jsonOut = json_encode($out);

                if ($_SERVER['REQUEST_METHOD'] === 'GET')
                {
                    $etag = md5($jsonOut);
                    header_remove('Pragma');
                    header_remove('Cache-Control');
                    header_remove('Expires');
                    if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
                           && $_SERVER['HTTP_IF_NONE_MATCH'] === $etag)
                    {
                        header("ETag: {$etag}", true, 304);
                        header('Cache-Control: must-revalidate, private');
                        exit;
                    }

                    header("ETag: {$etag}");
                    header('Cache-Control: must-revalidate, private');
                }

                echo $jsonOut;

                break;
            case 'php':
                echo serialize($out);

                break;
            case 'string':
                echo $out;

                break;
            case 'json-js-assoc':
                header('Content-type: application/json');
                $out2 = array();
                foreach ($out as $item)
                {
                    $out2[] = $item;
                }
                echo json_encode($out2);

                break;
            case 'jsonp':
                $callBackName = '';
                if (isset($_GET['callback']))
                {
                    $callBackName = htmlentities($_GET['callback']);
                }
                else
                {
                    if (isset($_GET['jsonpCallback']))
                    {
                        $callBackName = htmlentities($_GET['jsonpCallback']);
                    }
                    else
                    {
                        $callBackName = 'jsonpCallback';
                    }
                }
                echo "{$callBackName}(" . json_encode($out) . ')';

                break;
            case 'xml':
                header('Content-type: text/xml');
                $xml = new SimpleXMLElement('<?xml version="1.0"?><output></output>');
                $this->buildXML($out, $xml);
                echo $xml->asXML();

                break;
            case 'csv':
                //if $out is not an array, create one with the appropriate structure, preserving the original value of $out
                if (!is_array($out))
                {
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
                foreach ($columns as $column)
                {
                    $header .= '"' . $column . '",';
                }
                $header = trim($header, ',');
                $buffer = "{$header}\r\n";
                foreach ($out as $line)
                {
                    foreach ($columns as $column)
                    {
                        if (is_array($line[$column]))
                        {
                            $buffer .= '"';
                            foreach ($line[$column] as $tItem)
                            {
                                $buffer .= $tItem . "\r\n";
                            }
                            $buffer = trim($buffer);
                            $buffer .= '",';
                        }
                        else
                        {
                            $temp = strip_tags($line[$column]);
                            $temp = str_replace('"', '""', $temp);
                            $buffer .= '"' . $temp . '",';
                        }
                    }
                    $buffer .= "\r\n";
                }
                echo $buffer;

                break;
            case 'htmltable':
                $columns = $this->flattenStructure($out);

                $body = '<table>';
                $body .= '<thead><tr>';
                foreach ($columns as $column)
                {
                    $body .= '<th>' . $column . '</th>';
                }
                $body .= '</tr></thead>';
                $body .= '<tbody>';
                foreach ($out as $line)
                {
                    $body .= '<tr>';
                    foreach ($columns as $column)
                    {
                        if (isset($line[$column]) && is_array($line[$column]))
                        {
                            $body .= '<td>';
                            foreach ($line[$column] as $tItem)
                            {
                                $body .= $tItem . '<br />';
                            }
                            $body .= '</td>';
                        }
                        else
                        {
                            $temp = isset($line[$column]) ? strip_tags($line[$column]) : '';
                            $body .= '<td>' . $temp . '</td>';
                        }
                    }
                    $body .= '</tr>';
                }
                $body .= '</tbody>';
                echo $body;

                break;
            case 'x-visualstudio': // experimental mode for visual studio
                header('Content-type: application/json');
                $out2 = [];
                foreach($out as $item) {
                    $out2['r' . $item['recordID']] = $item;
                }

                $jsonOut = json_encode($out2);

                if ($_SERVER['REQUEST_METHOD'] === 'GET')
                {
                    $etag = md5($jsonOut);
                    header_remove('Pragma');
                    header_remove('Cache-Control');
                    header_remove('Expires');
                    if (isset($_SERVER['HTTP_IF_NONE_MATCH'])
                        && $_SERVER['HTTP_IF_NONE_MATCH'] === $etag)
                    {
                        header("ETag: {$etag}", true, 304);
                        header('Cache-Control: must-revalidate, private');
                        exit;
                    }

                    header("ETag: {$etag}");
                    header('Cache-Control: must-revalidate, private');
                }

                echo $jsonOut;
                break;
            case 'debug':
                echo '<pre>' . print_r($out, true) . '</pre>';

                break;
        }
    }

    /**
     * Parses url input into generic format
     * @param string api path
     * @return string parsed path
     */
    public function parseAction($action)
    {
        $actionList = explode('/', $action, 10);

        $key = '';
        $args = array();
        foreach ($actionList as $type)
        {
            if (is_numeric($type))
            {
                $key .= '[digit]/';
                $args[] = $type;
            }
            else
            {
                if (substr($type, 0, 1) == '_')
                {
                    $key .= '[text]/';
                    $args[] = substr($type, 1);
                }
                else
                {
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
     * Get API Version
     * @return int API_VERSION
     */
    public function getVersion()
    {
        return $this->API_VERSION;
    }

    /**
     * Aborts script if the referrer directory doesn't match the admin directory
     */
    public function verifyAdminReferrer()
    {
        if (!isset($_SERVER['HTTP_REFERER']))
        {
            echo 'Error: Invalid request. Missing Referer.';
            exit();
        }

        $tIdx = strpos($_SERVER['HTTP_REFERER'], '://');
        $referer = substr($_SERVER['HTTP_REFERER'], $tIdx);

        $url = '://' . HTTP_HOST;

        $script = $_SERVER['SCRIPT_NAME'];
        $apiOffset = strpos($script, '/api/');
        $script = substr($script, 0, $apiOffset + 1);

        $checkMe = strtolower($url . $script . 'admin');

        if (strncmp(strtolower($referer), $checkMe, strlen($checkMe)) !== 0)
        {
            echo 'Error: Invalid request. Mismatched Referer';
            exit();
        }
    }

    /**
     * Helper function to build an XML file
     */
    private function buildXML($out, $xml)
    {
        if (is_array($out))
        {
            $keys = array_keys($out);
            foreach ($keys as $key)
            {
                $tkey = is_numeric($key) ? "id_{$key}" : $key;
                if (is_array($out[$key]))
                {
                    $subXML = $xml->addChild($tkey);
                    $this->buildXML($out[$key], $subXML);
                }
                else
                {
                    $xml->addChild($tkey, $out[$key]);
                }
            }
        }
        else
        {
            $xml->addChild('text', $out);
        }
    }

    /**
     * flattenStructureGridInput performs an in-place restructure of gridInput data
     * within $out to fit 2D data structures
     * @param array  $out     Target data structure
     * @param int    $key     Current index
     * @param string $gridKey gridInput key
     */
    private function flattenStructureGridInput(&$out, $key, $gridKey)
    {
        $isGrid = strpos($gridKey, '_gridInput') !== false ? true : false;
        $table = isset($_GET['table']) ? $_GET['table'] : '';
        if($table == '' || $table != $gridKey) {
            if($isGrid) {
                $out[$key][$gridKey] = "Append &table={$gridKey} to URL";
            }
            return false;
        }

        $columns = ['recordID', $gridKey . '_id'];
        $gridIndex = array_flip($out[$key][$gridKey]['columns']);

        $gridFormatIndex = [];
        foreach($out[$key][$gridKey]['format'] as $gridFormat) {
            $columns[] = $gridFormat['name'];
            $gridFormatIndex[$gridIndex[$gridFormat['id']]] = $gridFormat['name'];
        }

        foreach($out[$key][$gridKey]['cells'] as $cKey => $row) {
            $newKey = $key . '.' . $cKey;
            $out[$newKey] = $out[$key];
            $out[$newKey][$gridKey . '_id'] = $newKey;
            foreach($row as $rKey => $item) {
                $out[$newKey][$gridFormatIndex[$rKey]] = $item;
            }
        }
        unset($out[$key]);

        return $columns;
    }

    /**
     * flattenStructureActionHistory performs an in-place restructure of action_history data
     * within $out to fit 2D data structures
     * @param array $out Target data structure
     * @param int   $key Current index
     */
    private function flattenStructureActionHistory(&$out, $key)
    {
        if(!isset($out[$key]['action_history'])) {
            return false;
        }
        $table = isset($_GET['table']) ? $_GET['table'] : '';
        if($table == '' || $table != 'action_history') {
            $out[$key]['action_history'] = 'Append &table=action_history to URL';
            return false;
        }

        if(isset($out[$key]['action_history'])) {
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
     * @param array $out   Target data structure
     * @param int   $index Current index
     */
    private function flattenStructureOrgchart(&$out, $index)
    {
        // flatten out orgchart_employee fields
        // delete orgchart_position extended content
        foreach(array_keys($out[$index]) as $id) {
            if(strpos($id, '_orgchart') !== false) {
                if(!isset($out[$index][$id]['positionID'])) {
                    $out[$index][$id . '_email'] = $out[$index][$id]['email'];
                    $out[$index][$id . '_userName'] = $out[$index][$id]['userName'];
                }
                unset($out[$index][$id]);
            }
        }
    }

    /**
     * flattenStructureCheckGrid is a wrapper for flattenStructureGridInput
     * @param array $out     Target data structure
     * @param array $key     Current index
     * @param array $hasGrid Signal for flattenStructure
     * @param array $columns Output columns
     */
    private function flattenStructureCheckGrid(&$out, $key, &$hasGrid, &$columns)
    {
        foreach(array_keys($out[$key]['s1']) as $tkey) {
            $gridCols = $this->flattenStructureGridInput($out, $key, $tkey);
            if($gridCols !== false) {
                $hasGrid = true;
                $columns = $gridCols;
            }
        }
    }

    /**
     * flattenStructure performs an in-place restructure of $out to fit 2D data structures
     * @param array $out Target data structure
     * @return array Column headers
     */
    private function flattenStructure(&$out)
    {
        $columns = ['recordID', 'serviceID', 'date', 'userID', 'title', 'lastStatus', 'submitted',
            'deleted', 'service', 'abbreviatedService', 'groupID'];

        $hasGrid = false;
        $hasActionHistory = false;
        foreach ($out as $key => $item)
        {
            // flatten out s1 and orgchart structures
            if (isset($item['s1']))
            {
                $out[$key] = array_merge($out[$key], $item['s1']);

                $this->flattenStructureOrgchart($out, $key);
                $this->flattenStructureCheckGrid($out, $key, $hasGrid, $columns);

                unset($out[$key]['s1']);
            }

            // flatten action_history data
            $actionCols = $this->flattenStructureActionHistory($out, $key);
            if($actionCols !== false) {
                $hasActionHistory = true;
                $columns = $actionCols;
            }

            if(isset($out[$key])) {
                foreach(array_keys($out[$key]) as $tkey) {
                    if(!in_array($tkey, $columns) && !$hasGrid && !$hasActionHistory) {
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
     */
    private function filterDataS1HtmlPrint($s1)
    {
        $sids = array_keys($s1);
        // iterate through keys within each s1 set
        foreach($sids as $sKey) {
            if(strpos($sKey, '_htmlPrint') !== false) {
                unset($s1[$sKey]);
            }
        }
        return $s1;
    }

    /**
     * filterDataS1Timestamp is a helper function to filter out timestamps
     * returned by form data fields
     */
    private function filterDataS1Timestamp($s1)
    {
        $sids = array_keys($s1);
        // iterate through keys within each s1 set
        foreach($sids as $sKey) {
            if(strpos($sKey, '_timestamp') !== false) {
                unset($s1[$sKey]);
            }
        }
        return $s1;
    }

    // filterDataActionHistory is a helper function for filterData
    private function filterDataActionHistory($actionHistory, $filter)
    {
        // iterate through keys within each action_history set
        foreach($actionHistory as $actionIdx => $actionItem) {
            $actionKeys = array_keys($actionItem);
            foreach($actionKeys as $actionKey) {
                if(!isset($filter['action_history.' . $actionKey])) {
                    unset($actionHistory[$actionIdx][$actionKey]);
                }
            }
        }
        return $actionHistory;
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
     */
    private function filterData($data)
    {
        if(isset($_GET['x-filterData'])) {
            $filter = explode(',', $_GET['x-filterData'], 32);
            $filter = array_flip($filter);
            // add data fields that are implicitly requested
            $filter['s1'] = 1;
            $filter['action_history'] = 1;

            // iterate through each record
            foreach($data as $key => $value) {
                $ids = array_keys($value);
                // iterate through keys within each record
                foreach($ids as $id) {
                    if(!isset($filter[$id])) {
                        unset($data[$key][$id]);
                    }

                    // filter out s1 timestamps if applicable
                    if(isset($data[$key]['s1'])
                        && !isset($filter['id_timestamp'])
                    ) {
                        $data[$key]['s1'] = $this->filterDataS1Timestamp($data[$key]['s1']);
                    }

                    // filter out s1 htmlPrint items if applicable
                    if(isset($data[$key]['s1'])
                        && !isset($filter['id_htmlPrint'])
                    ) {
                        $data[$key]['s1'] = $this->filterDataS1HtmlPrint($data[$key]['s1']);
                    }

                    // filter out action_history fields if applicable
                    if(isset($data[$key]['action_history'])) {
                        $data[$key]['action_history'] = $this->filterDataActionHistory($data[$key]['action_history'], $filter);
                    }
                }
            }
        }

        return $data;
    }
}
