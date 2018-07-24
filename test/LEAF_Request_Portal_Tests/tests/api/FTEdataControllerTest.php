<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

final class FTEdataControllerTest extends DatabaseTest
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
     * Tests the GET `FTEdata/selecteeSheetDateRange` endpoint.
     */
    public function testSelecteeSheetDateRange() : void
    {
        $dateRange = self::$client->get('?a=FTEdata/selecteeSheetDateRange&startDate=date&endDate=date');
        $this->assertEquals('Invalid Date', $dateRange);
    }
}
