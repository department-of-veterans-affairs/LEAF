<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Nexus/api/?a=system API
 */
final class SystemControllerTest extends DatabaseTest
{
    private static $reqClient = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$reqClient = LEAFClient::createNexusClient();
    }

    /**
     * Tests the `system/dbversion` endpoint.
     */
    public function testGetDatabaseVersion() : void
    {
        $version = self::$reqClient->get(array('a'=>'system/dbversion'));
        $this->assertNotNull($version);
        $this->assertEquals("4030", $version);
    }
}