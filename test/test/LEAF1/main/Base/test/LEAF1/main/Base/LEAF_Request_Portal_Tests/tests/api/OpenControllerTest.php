<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

final class OpenControllerTest extends DatabaseTest
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
     * Tests the GET `open/version` endpoint.
     */
    public function testGetVersion() : void
    {
        $version = self::$client->get(array('a' => 'open/version'));
        $this->assertEquals(1, $version);
    }

    /**
     * Tests the POST `open/report` endpoint.
     */
    public function testNewReportLink() : void
    {
        $response = self::$client->post(array('a' => 'open/report'), array('data' => 'http://somelink'));

        $this->assertNotNull($response);
        $this->assertEquals('32wmT', $response);
    }

    /**
     * Tests the GET `open/report` endpoint.
     */
    public function testGetReportLink() : void
    {
        $response = self::$client->get(array('a' => 'open/report/_32wmT'));
        $this->assertNotNull($response);
    }
}
