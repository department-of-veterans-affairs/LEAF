<?php

declare(strict_types = 1);

include '../../libs/php-commons/spreadsheet/SpreadsheetUtil.php';

use PHPUnit\Framework\TestCase;

/**
 * Tests libs/php-commons/spreadsheet/SpreadsheetUtil.php
 */
final class SpreadsheetUtilTest extends TestCase
{
    var $fileName = __DIR__ . DIRECTORY_SEPARATOR . "import_test.xlsx";

    /**
     * Tests SpreadsheetUtil::loadFile($fileName)
     */
    public function testLoadFile() : void
    {
        $spreadsheet = SpreadsheetUtil::loadFile($this->fileName);
        $this->assertNotNull($spreadsheet);

        $sheet = $spreadsheet->getActiveSheet();
        $this->assertNotNull($sheet);

        $this->assertEquals('Name', $sheet->getCell('A1'));
        $this->assertEquals('Occupation', $sheet->getCell('B1'));
        $this->assertEquals('Hobbies', $sheet->getCell('C1'));

        $this->assertEquals('Bruce Wayne', $sheet->getCell('A2'));
        $this->assertEquals('Billionaire', $sheet->getCell('B2'));
        $this->assertEquals('None', $sheet->getCell('C2'));

        $this->assertEquals('Oswald Cobblepot', $sheet->getCell('A3'));
        $this->assertEquals('Criminal', $sheet->getCell('B3'));
        $this->assertEquals('Wearing a monocle', $sheet->getCell('C3'));

        $this->assertEquals('Edward Nygma', $sheet->getCell('A4'));
        $this->assertEquals('Criminal', $sheet->getCell('B4'));
        $this->assertEquals('Crossword puzzles', $sheet->getCell('C4'));
    }

    /**
     * Tests SpreadsheetUtil::loadFile($fileName)
     * 
     * Tests with an invalid file name
     */
    public function testLoadFile_invalidFileName() : void
    {
        $spreadsheet = SpreadsheetUtil::loadFile('junk.xls');
        $this->assertNull($spreadsheet);
    }

    /**
     * Tests SpreadsheetUtil::loadFileIntoArray($filename, $hasHeaders)
     */
    public function testLoadFileIntoArray() : void
    {
        $arr = SpreadsheetUtil::loadFileIntoArray($this->fileName, true);
        $this->assertNotNull($arr);
        $this->assertEquals(2, count($arr));

        $headers = $arr['headers'];
        $this->assertNotNull($headers);
        $this->assertEquals(3, count($headers));
        $this->assertEquals("Name", $headers['A']);
        $this->assertEquals("Occupation", $headers['B']);
        $this->assertEquals("Hobbies", $headers['C']);

        $cells = $arr['cells'];
        $this->assertNotNull($cells);
        $this->assertEquals(3, count($cells));

        $bruce = $cells['0'];
        $this->assertNotNull($bruce);
        $this->assertEquals(3, count($bruce));
        $this->assertEquals("Bruce Wayne", $bruce['A']);
        $this->assertEquals("Billionaire", $bruce['B']);
        $this->assertEquals("None", $bruce['C']);

        $oswald = $cells['1'];
        $this->assertNotNull($oswald);
        $this->assertEquals(3, count($oswald));
        $this->assertEquals("Oswald Cobblepot", $oswald['A']);
        $this->assertEquals("Criminal", $oswald['B']);
        $this->assertEquals("Wearing a monocle", $oswald['C']);

        $edward = $cells['2'];
        $this->assertNotNull($edward);
        $this->assertEquals(3, count($edward));
        $this->assertEquals("Edward Nygma", $edward['A']);
        $this->assertEquals("Criminal", $edward['B']);
        $this->assertEquals("Crossword puzzles", $edward['C']);
    }
}