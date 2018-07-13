<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/?a=group API
 */
class PositionControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createNexusClient();
    }

    /**
     * Tests the `position/<id>/supervisor` endpoint
     */
    public function testSetSupervisor() : void
    {
        $results = self::$client->get('position/3/supervisor');
        $this->assertEquals("Medical Center Director", $results[0]["positionTitle"]);
        //initial value

        $newSupervisor = array("positionID" => "2");
        self::$client->postEncodedForm('position/3/supervisor', $newSupervisor);
        //changes supervisor from med center director to test position super

        $results = self::$client->get('position/3/supervisor');
        $this->assertEquals("Test Position Title Super", $results[0]["positionTitle"]);
        //checks that the change was successful
    }

    /**
     * Tests the `position/<id>` endpoint
     */
    public function testDeletePosition(): void
    {
        $results = self::$client->get('position/3');
        $this->assertEquals("Test Subordinate Position", $results['title']);
        //initial value

        self::$client->delete('position/3');
        //deletes position

        $results = self::$client->get('position/3');
        $this->assertFalse($results['title']);
        //checks to make sure position has been deleted
        //will be false if deleted
    }

    /**
     * Tests the `position/<id>/title` endpoint
     */
    public function testPositionEditTitle() : void
    {
        $results = self::$client->get('position/3');
        $this->assertEquals("Test Subordinate Position", $results['title']);
        //initial value

        $newPositionTitle = array('title' => 'anotherNewTitle');
        self::$client->postEncodedForm('position/3/title', $newPositionTitle);
        //changes position title

        $results = self::$client->get('position/3');
        $this->assertEquals("anotherNewTitle", $results['title']);
        //checks to make sure the change was successful
    }

    /**
     * Tests the `position/<id1>/employee/<id2>` endpoint
     */
    public function testAddAndRemoveEmployee() : void
    {
        $results = self::$client->get('position/3/employees');
        $this->assertNull($results[0]);
        //initial value

        $employee = array('empUID' => '1', "isActing" => '0');
        self::$client->postEncodedForm('position/3/employee', $employee);
        //adds tester employee to test position sub

        $results = self::$client->get('position/3/employees');
        $this->assertEquals('1', $results[0]['empUID']);
        //checks to make sure the change was successful and tester is in the position

        self::$client->delete('position/3/employee/1');
        //deletes tester from position

        $results = self::$client->get('position/3/employees');
        $this->assertNull($results[0]);
        //checks to make sure change was successful
    }
}