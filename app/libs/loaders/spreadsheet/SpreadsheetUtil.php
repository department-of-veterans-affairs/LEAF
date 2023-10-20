<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require_once __DIR__ . '/../../loaders/Psr_autoloader.php';
require_once __DIR__ . '/../../loaders/PhpSpreadsheet_autoloader.php';

use PhpOffice\PhpSpreadsheet\IOFactory;

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
}
