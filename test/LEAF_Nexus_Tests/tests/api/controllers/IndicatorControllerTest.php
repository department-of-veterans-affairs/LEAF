<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/indicator API
 */
class IndicatorControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createNexusClient();
    }

    /**
     * Tests the `indicator/[digit]/permissions` endpoint and the
     * 'indicator/[digit]/permission/[text]/[digit]/[text]/toggle' endpoint
     */
    public function testAddAndTogglePermission() : void
    {
        //create a new group with groupID 14
        $newGroup = array(
            'title' => "NEWTESTGROUPTITLE<script lang='javascript'>alert('hi')</script>",
        );
        self::$client->post(array('a' => 'group'), $newGroup);

        //check creation if creation was successful
        $group = self::$client->get(array('a' => 'group/14'));
        $this->assertNotNull($group['title']);
        $this->assertEquals('NEWTESTGROUPTITLEalert(&#039;hi&#039;)', $group['title']);

        //add email permissions to group
        self::$client->post(array('a' => 'indicator/6/permissions/addGroup'), array('groupID' => '14'));
        $indicator = self::$client->get(array('a' => 'indicator/6/permissions'));

        //new groupID is 14, so if true, change was successful
        $this->assertEquals('14', $indicator[2]['UID']);

        //initial permissions for group 14
        $indicator = self::$client->get(array('a' => 'indicator/6/permissions'));
        $this->assertEquals('1', $indicator[2]['read']);
        $this->assertEquals('0', $indicator[2]['write']);
        $this->assertEquals('0', $indicator[2]['grant']);

        //toggle write and grant on
        self::$client->post(array('a' => 'indicator/6/permission/_group/14/_write/toggle'), array());
        self::$client->post(array('a' => 'indicator/6/permission/_group/14/_grant/toggle'), array());

        //checks to see that the toggle was successful
        $indicator = self::$client->get(array('a' => 'indicator/6/permissions'));
        $this->assertEquals('1', $indicator[2]['read']);
        $this->assertEquals('1', $indicator[2]['write']);
        $this->assertEquals('1', $indicator[2]['grant']);

        //toggle write and grant off
        self::$client->post(array('a' => 'indicator/6/permission/_group/14/_write/toggle'), array());
        self::$client->post(array('a' => 'indicator/6/permission/_group/14/_grant/toggle'), array());

        //checks to see that the toggle was successful
        $indicator = self::$client->get(array('a' => 'indicator/6/permissions'));
        $this->assertEquals('1', $indicator[2]['read']);
        $this->assertEquals('0', $indicator[2]['write']);
        $this->assertEquals('0', $indicator[2]['grant']);
    }
}
