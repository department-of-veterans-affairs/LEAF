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
        //checks initial value
        $results = self::$client->get('position/3/supervisor');
        $this->assertEquals("Medical Center Director", $results[0]["positionTitle"]);

        //changes supervisor from med center director to test position super
        $newSupervisor = array("positionID" => "2");
        self::$client->postEncodedForm('position/3/supervisor', $newSupervisor);

        //checks that the change was successful
        $results = self::$client->get('position/3/supervisor');
        $this->assertEquals("Test Position Title Super", $results[0]["positionTitle"]);
    }

    /**
     * Tests the `position/<id>` endpoint
     */
    public function testDeletePosition(): void
    {
        //checks initial value
        $results = self::$client->get('position/3');
        $this->assertEquals("Test Subordinate Position", $results['title']);

        //deletes position
        self::$client->delete('position/3');

        //checks to make sure position has been deleted
        //will be false if deleted
        $results = self::$client->get('position/3');
        $this->assertFalse($results['title']);
    }

    /**
     * Tests the `position/<id>/title` endpoint
     */
    public function testPositionEditTitle() : void
    {
        //checks initial value
        $results = self::$client->get('position/3');
        $this->assertEquals("Test Subordinate Position", $results['title']);

        //changes position title
        $newPositionTitle = array('title' => 'anotherNewTitle');
        self::$client->postEncodedForm('position/3/title', $newPositionTitle);

        //checks to make sure the change was successful
        $results = self::$client->get('position/3');
        $this->assertEquals("anotherNewTitle", $results['title']);
    }

    /**
     * Tests the `position/<id1>/employee/<id2>` endpoint
     */
    public function testAddAndRemoveEmployee() : void
    {
        //checks initial value
        $results = self::$client->get('position/3/employees');
        $this->assertEquals(0, count($results));

        //adds tester employee to test position sub
        $employee = array('empUID' => '1', "isActing" => '0');
        self::$client->postEncodedForm('position/3/employee', $employee);

        //checks to make sure the change was successful and tester is in the position
        $results = self::$client->get('position/3/employees');
        $this->assertEquals('1', $results[0]['empUID']);

        //deletes tester from position
        self::$client->delete('position/3/employee/1');

        //checks to make sure change was successful
        $results = self::$client->get('position/3/employees');
        $this->assertEquals(0, count($results));
    }
}
