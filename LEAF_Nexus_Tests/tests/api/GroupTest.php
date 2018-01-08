<?php

declare(strict_types=1);

use LEAFTest\LEAFClient;
use GuzzleHttp\Client;
use PHPUnit\Framework\TestCase;

/**
 * Tests the LEAF_Nexus/api/?a=group API
 */
final class GroupTest extends TestCase
{
    /**
     * Tests the `group/<id>/employees/detailed` endpoint
     */
    public function testListGroupEmployees(): void
    {
        $results = LEAFClient::get('/LEAF_Nexus/api/?a=group/1/employees/detailed');

        $this->assertNotNull($results);

        $users = $results['users'];
        $meta = $results['querymeta'];

        $this->assertNotNull($users);
        $this->assertNotNull($meta);

        // TODO: this depends on what's in the developer dev database, eventually this will need
        // to reflect users created specifically for this
        $this->assertEquals(2, count($users));

        $emp1 = $users[0];
        $this->assertEquals(1, $emp1['empUID']);
        $this->assertEquals(1, $emp1['groupID']);
        $this->assertEquals("tester", $emp1['userName']);
        $this->assertNotNull($emp1['data']);
        $this->assertEquals(8, count($emp1['data']));
        $this->assertNotNull($emp1['positions']);

        $emp2 = $users[1];
        $this->assertEquals(2, $emp2['empUID']);
        $this->assertEquals(1, $emp2['groupID']);
        $this->assertEquals("tester2", $emp2['userName']);
        $this->assertNotNull($emp2['data']);
        $this->assertEquals(8, count($emp2['data']));
        $this->assertNotNull($emp2['positions']);
    }
}
