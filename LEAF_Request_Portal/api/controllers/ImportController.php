<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../../libs/php-commons/spreadsheet/SpreadsheetUtil.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

/**
 * Controls endpoints for Importing data from various sources (e.g. Spreadsheets)
 */
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
            $results = SpreadSheetUtil::loadFileIntoArray(__DIR__ . '/../../files/' . $fileName, $hasColumnHeaders);

            return $results;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
