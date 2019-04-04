<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once __DIR__ . '/../../loaders/Psr_autoloader.php';
require_once __DIR__ . '/../../loaders/PhpSpreadsheet_autoloader.php';

use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;

/**
 * Utility class for working with Spreadsheets
 */
class SpreadsheetUtil
{
    /**
     * Load file into a PHPOffice\PhpSpreadsheet\Spreadsheet
     *
     * @param fileName  string  path to the spreadsheet file
     * @return the Spreadsheet object, or null if the file is invalid
     */
    public static function loadFile($filename) : ?PhpOffice\PhpSpreadSheet\Spreadsheet
    {
        try
        {
            return IOFactory::load($filename);
        }
        catch (InvalidArgumentException $iae)
        {
            return null;
        }
    }

    /**
     * Load file into an associative array that contains the file contents.
     *
     * The parent array has two keys: "headers" and "cells". The "headers" key is still present
     * even if $hasHeaders is false.
     *
     * Each key of the "headers" array is the column (e.g. "A", "B", "C")
     *
     * Each key of the "cells" array is the row number (e.g. 0, 1, 2). The rows are a zero-index
     * array. Each key of the array that represents a row is the column (e.g. "A", "B", "C").
     *
     * To access cell "A1", where $sheetData is the result of this function:
     *
     *  $sheetData['cells'][0]['A']
     *
     * @param filename      string  path to the spreadsheet file
     * @param hasHeaders    bool    If the first row of the file is column names (default = false)
     *
     * @return array An associative array
     */
    public static function loadFileIntoArray($filename, $hasHeaders = false) : array
    {
        $spreadsheet = self::loadFile($filename);
        if ($spreadsheet == null)
        {
            return array();
        }

        $sheet = $spreadsheet->getActiveSheet();
        if ($sheet == null)
        {
            return array();
        }

        $cells = $sheet->toArray(null, true, true, true);

        $result = array();
        $result['headers'] = $hasHeaders ? array_shift($cells) : array();
        $result['cells'] = $cells;

        return $result;
    }

    // Write functions

    /**
     * Write file into a php output
     *
     * @param spreadsheet Spreadsheet data to write to file
     * @param fileType String of file export type (i.e xls, xlsx, csv, etc.) case-sensitive
     * @return null if errors writing file
     */
    public static function writeSpreadsheetToFile($spreadsheet, $fileType)
    {
        try {
            $writer = IOFactory::createWriter($spreadsheet, $fileType);
            $writer->save('php://output');
        }
        catch (Exception $e)
        {
            return null;
        }
    }

    /**
     * Create a spreadsheet/workbook from data into a PHPOffice\PhpSpreadsheet\Spreadsheet
     *
     * @param data the data to create spreadsheet with
     * @return the Spreadsheet object
     */
    public static function createSpreadsheet($data = null): Spreadsheet
    {
        /** Create a new Spreadsheet Object **/
        $spreadsheet = new Spreadsheet();

        if (!isset($data)) {
            return $spreadsheet;
        }

//        $spreadsheet->setActiveSheetIndex(0)
//            ->setCellValue('A1', 'Hello')
//            ->setCellValue('B2', 'world!')
//            ->setCellValue('C1', 'Hello')
//            ->setCellValue('D2', 'world!');

//        $spreadsheet->getProperties()->setCreator('Maarten Balliauw')
//            ->setLastModifiedBy('Maarten Balliauw')
//            ->setTitle('Office 2007 XLSX Test Document')
//            ->setSubject('Office 2007 XLSX Test Document')
//            ->setDescription('Test document for Office 2007 XLSX, generated using PHP classes.')
//            ->setKeywords('office 2007 openxml php')
//            ->setCategory('Test result file');

        $spreadsheet->getActiveSheet()->setTitle('Simple');

        return $spreadsheet;
    }
}
