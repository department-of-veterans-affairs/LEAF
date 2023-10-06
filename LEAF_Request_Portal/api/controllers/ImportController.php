<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\XSSHelpers;

class ImportController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;

    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('import/xls', function () {
            if (!isset($_GET['importFile']) || $_GET['importFile'] == '')
            {
                return array();
            }

            $hasColumnHeaders = (isset($_GET['hasHeaders']) && $_GET['hasHeaders'] == '1') ? true : false;
            $fileName = XSSHelpers::xscrub(strip_tags($_GET['importFile']));
            $results = \SpreadSheetUtil::loadFileIntoArray(__DIR__ . '/../../files/' . $fileName, $hasColumnHeaders);

            return $results;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
