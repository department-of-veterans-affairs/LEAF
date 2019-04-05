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


    public function post($act)
    {
        $this->index['POST'] = new ControllerMap();

        $this->index['POST']->register('export/xls', function() {
            $data = XSSHelpers::scrubObjectOrArray($_POST['spreadsheetData'], true);

            header('Content-Type: application/json');

            // if $data is not set, return empty spreadsheet
            if (!isset($data)) {
                $spreadsheet = SpreadSheetUtil::createSpreadsheet();
            } else {
                $spreadsheet = SpreadsheetUtil::createSpreadsheet($data);
            }

            ob_start();
            SpreadSheetUtil::writeSpreadsheetToFile($spreadsheet, 'Xls'); // fileType is case sensitive
            $xlsData = ob_get_contents();
            ob_end_clean();

            $response = array(
                'op' => 'ok',
                'file' => "data:application/vnd.ms-excel;base64,".base64_encode($xlsData)
            );
            return json_encode($response);
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }
}
