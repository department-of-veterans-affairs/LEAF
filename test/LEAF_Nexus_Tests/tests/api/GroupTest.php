<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/?a=group API
 */
class GroupTest extends DatabaseTest
{
    private static $reqClient = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$reqClient = LEAFClient::createNexusClient();
    }

    /**
     * Tests the `group/<id>/employees/detailed` endpoint
     */
    public function testListGroupEmployees() : void
    {
        $results = self::$reqClient->get('?a=group/1/employees/detailed');

        $users = $results['users'];
        $meta = $results['querymeta'];

        $this->assertNotNull($users);
        $this->assertNotNull($meta);

        $this->assertEquals(1, $meta['totalusers']);

        $this->assertEquals(1, count($users));

        $emp1 = $users[0];
        $this->assertEquals(1, $emp1['empUID']);
        $this->assertEquals(1, $emp1['groupID']);
        $this->assertEquals('tester', $emp1['userName']);
        $this->assertNotNull($emp1['data']);
        $this->assertEquals(7, count($emp1['data']));
        $this->assertNotNull($emp1['positions']);
    }
}
