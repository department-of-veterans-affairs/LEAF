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
 * Controls endpoints for Exporting data into various formats  (e.g. Spreadsheets)
 */
class ExportController extends RESTfulResponse
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

        $this->index['GET']->register('export/xls', function () {
            $results ='';

            return $results;
        });

        $this->index['GET']->register('export/csv', function() {
//            $results = SpreadsheetUtil::
//            return $results;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }
}
