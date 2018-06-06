<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/?a=system API
 */
final class SystemControllerTest extends DatabaseTest
{
    private static $reqClient = null;

    public static function setUpBeforeClass()
    {
        self::$reqClient = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the `system/dbversion` endpoint.
     */
    public function testGetDatabaseVersion() : void
    {
        $version = self::$reqClient->get('?a=system/dbversion');

        $this->assertNotNull($version);
        $this->assertEquals("3848", $version);
    }
}