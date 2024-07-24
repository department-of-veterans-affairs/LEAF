<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Nexus/api/system API
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
        $version = self::$reqClient->get(array('a' => 'system/dbversion'));
        $this->assertNotNull($version);
        $this->assertEquals('4030', $version);
    }
}
