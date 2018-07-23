<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

final class FormStackControllerTest extends DatabaseTest
{
    private static $client = null;

    public static function setUpBeforeClass()
    {
        self::$client = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the GET `formStack/version` endpoint.
     */
     public function testGetVersion() : void
     {
         $version = self::$client->get('?a=formStack/version');
         $this->assertEquals(1, $version);
     }

     /**
      * Tests the DELETE `formStack/[text]` endpoint.
      */
      public function testDeleteForm() : void
      {
        $delResponse = self::$client->Delete('?a=formStack/_form_f4687');
        $this->assertNotNull($delResponse);
        $this->assertEquals(true, $delResponse);

        $category = self::$client->get('?a=formStack/categoryList/all');
        $this->assertEquals(null, $category[1]);
      }

}
