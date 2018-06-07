<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Nexus/api/?a=system API
 */
final class SystemControllerTest extends DatabaseTest
{
    private static $reqClient = null;

    public static function setUpBeforeClass()
    {
        self::$reqClient = LEAFClient::createNexusClient();
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
        $this->assertEquals("4232", $version);
    }
}