<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/?a=group API
 */
class GroupControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createNexusClient();
    }

    /**
     * Tests the `group/<id>/employees/detailed` endpoint
     */
    public function testListGroupEmployees() : void
    {
        $results = self::$client->get('?a=group/1/employees/detailed');

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

    /**
     * Tests the `group` endpoint.
     */
    public function testNewGroup() : void
    {
        $group = self::$client->get('?a=group/14');
        // group with id 14 does not exist, so it's title will be false
        $this->assertFalse($group['title']);

        $newGroup = array(
            'title' => "NEWTESTGROUPTITLE<script lang='javascript'>alert('hi')</script>",
        );

        self::$client->postEncodedForm('?a=group', $newGroup);

        $group = self::$client->get('group/14');

        $this->assertNotNull($group['title']);
        $this->assertEquals('NEWTESTGROUPTITLEalert(&#039;hi&#039;)', $group['title']);
    }

    /**
     * Tests the `group/[digit]/title` endpoint.
     */
    public function testEditTitle() : void
    {
        $group = self::$client->get('group/13');
        $this->assertEquals('Test Group Title 2', $group['title']);

        self::$client->postEncodedForm('?a=group/13/title', array('title' => "NEWTITLE<script lang='javascript'>alert('hi')</script>"));

        $group = self::$client->get('group/13');
        $this->assertEquals('NEWTITLEalert(&#039;hi&#039;)', $group['title']);
    }
}
