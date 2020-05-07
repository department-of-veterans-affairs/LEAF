<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;
use PHPUnit\Framework\TestCase;

/**
 * Tests LEAF_Request_Portal/api?a=import API
 */
final class ImportControllerTest extends TestCase
{
    private static $reqClient = null;

    private static $testFilePath = null;

    private static $testFileDest = null;

    // private static $testFileName = 'import_test2.xlsx';
    private static $testFileName = null;

    public static function setUpBeforeClass()
    {
        // to prevent overwriting any existing files
        self::$testFileName = uniqid() . '.xlsx';

        self::$reqClient = LEAFClient::createRequestPortalClient();
        self::$testFilePath = __DIR__ . DIRECTORY_SEPARATOR . '../../../libs/tests/php-commons/spreadsheet/import_test.xlsx';
        self::$testFileDest = __DIR__ . DIRECTORY_SEPARATOR . '../../../../LEAF_Request_Portal/files/' . self::$testFileName;

        $success = copy(self::$testFilePath, self::$testFileDest);
    }

    public static function tearDownAfterClass()
    {
        // delete the test file
        $success = unlink(self::$testFileDest);
    }

    /**
     * Tests the `import/xls&importFile=[fileName]&hasHeaders=[digit]` endpoint
     */
    public function testImportXLS() : void
    {
        $arr = self::$reqClient->get(array(
            'a' => 'import/xls',
            'importFile' => self::$testFileName,
            'hasHeaders' => 1,
        ));

          $this->assertNotNull($arr);
          $this->assertEquals(2, count($arr));

          $headers = $arr['headers'];
          $this->assertNotNull($headers);
          $this->assertEquals(3, count($headers));
          $this->assertEquals('Name', $headers['A']);
          $this->assertEquals('Occupation', $headers['B']);
          $this->assertEquals('Hobbies', $headers['C']);

          $cells = $arr['cells'];
          $this->assertNotNull($cells);
          $this->assertEquals(3, count($cells));

          $bruce = $cells['0'];
          $this->assertNotNull($bruce);
          $this->assertEquals(3, count($bruce));
          $this->assertEquals('Bruce Wayne', $bruce['A']);
          $this->assertEquals('Billionaire', $bruce['B']);
          $this->assertEquals('None', $bruce['C']);

          $oswald = $cells['1'];
          $this->assertNotNull($oswald);
          $this->assertEquals(3, count($oswald));
          $this->assertEquals('Oswald Cobblepot', $oswald['A']);
          $this->assertEquals('Criminal', $oswald['B']);
          $this->assertEquals('Wearing a monocle', $oswald['C']);

          $edward = $cells['2'];
          $this->assertNotNull($edward);
          $this->assertEquals(3, count($edward));
          $this->assertEquals('Edward Nygma', $edward['A']);
          $this->assertEquals('Criminal', $edward['B']);
          $this->assertEquals('Crossword puzzles', $edward['C']);
      }

      /**
       * Tests the `import/xls&importFile=[fileName]&hasHeaders=[digit]` endpoint
       *
       * Tests the endpoint with an invalid file name
       */
      public function testImportXLS_invalidFile() : void
      {
          $arr = self::$reqClient->get(array(
              'a' => 'import/xls',
              'importFile' => 'I_DO_NOT_EXIST',
              'hasHeaders' => 1,
          ));

          $this->assertEquals(0, count($arr));
      }
}
