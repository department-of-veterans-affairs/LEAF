<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Api\v1;

abstract class RESTfulResponseApi
{
    protected const API_VERSION = 1;

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
     *
     * @param string $action
     *
     * @return void
     *
     * Created at: 12/2/2022, 1:26:20 PM (America/New_York)
     */
    public function handler(string $action): void
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
                $DELETE_vars = [];
                parse_str(file_get_contents('php://input', false, null, 0, 8192), $DELETE_vars); // only parse the first 8192 characters (arbitrary limit)

                if ($_GET['CSRFToken'] == $_SESSION['CSRFToken'] // Deprecation warning: The _GET implementation should be removed in favor of $DELETE_vars
                    || $DELETE_vars['CSRFToken'] == $_SESSION['CSRFToken']) {
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
     *
     * @param string|array|null $out
     *
     * @return void
     *
     * Created at: 12/2/2022, 1:27:24 PM (America/New_York)
     * Updated at: 12/16/2022, 7:12:01 AM (America/New_York)
     */
    public function output(null|string|array $out = ''): void
    {
        //header('Access-Control-Allow-Origin: *');
        $format = isset($_GET['format']) ? $_GET['format'] : '';
        switch ($format) {
            case 'json':
            default:
                header('Content-type: application/json');
                $jsonOut = json_encode($out);

                if ($_SERVER['REQUEST_METHOD'] === 'GET')
                {
                    $etag = '"' . md5($jsonOut) . '"';
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
                $xml = new \SimpleXMLElement('<?xml version="1.0"?><output></output>');
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
                echo "{$header}\r\n";
                foreach ($out as $line)
                {
                    foreach ($columns as $column)
                    {
                        if (is_array($line[$column]))
                        {
                            echo '"';
                            foreach ($line[$column] as $tItem)
                            {
                                echo $tItem . ' ';
                            }
                            echo '",';
                        }
                        else
                        {
                            $temp = strip_tags($line[$column]);
                            $temp = str_replace('"', '""', $temp);
                            echo '"' . $temp . '",';
                        }
                    }
                    echo "\r\n";
                }

                break;
            case 'debug':
                echo '<pre>' . print_r($out, true) . '</pre>';

                break;
        }
    }

    /**
     * Parses url input into generic format
     *
     * @param string $action
     *
     * @return array
     *
     * Created at: 12/2/2022, 1:25:51 PM (America/New_York)
     */
    public function parseAction(string $action): array
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
        return self::API_VERSION;
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
}
