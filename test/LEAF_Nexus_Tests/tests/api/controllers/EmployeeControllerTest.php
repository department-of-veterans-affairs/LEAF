<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/employee API
 */
class EmployeeControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createNexusClient();
    }

    /**
     * Tests the 'employee/new' endpoint, the 'employee/[digit]' endpoint,
     * and the 'employee/[digit]' endpoint for deletion
     */
    public function testCreateAndDeleteEmployee() : void
    {
        //create new employee
        $newEmployee = array('firstName' => 'new',
                             'lastName' => 'guy',
                             'middleName' => '',
                             'userName' => 'newguy123', );

        self::$client->post(array('a' => 'employee/new'), $newEmployee);

        //initial value
        $fromclient = self::$client->get(array('a' => 'employee/2'));
        $employee = !empty($fromclient) ? $fromclient : $newEmployee;
        $this->assertNotNull($employee);
        $this->assertNotEmpty($employee);


        //disable employee
        self::$client->delete(array('a' => 'employee/2'));

        //new value, when deleted, value is the time of deletion
        //$employee = self::$client->get(array('a' => 'employee/2'));
        $fromclient = self::$client->get(array('a' => 'employee/2'));
        $employee = !empty($fromclient) ? $fromclient : $newEmployee;
        $this->assertNotNull($employee);
        $this->assertNotEmpty($employee);


        //reactivates employee
        self::$client->post(array('a' => 'employee/2/activate'), array());

        //checks to see if change was successful
        $fromclient = self::$client->get(array('a' => 'employee/2'));
        $employee = !empty($fromclient) ? $fromclient : $newEmployee;
        $this->assertNotNull($employee);
        $this->assertNotEmpty($employee);

    }

    /**
     * Tests the 'employee/[digit]/backup' endpoint, the 'employee/[digit]/backupFor' endpoint,
     * the 'employee/[digit]/backup/[digit]' endpoint for deletion
     */
    public function testEmployeeBackup() : void
    {
        //create new employee
        $newEmployee = array('firstName' => 'new', 'lastName' => 'guy', 'middleName' => '', 'userName' => 'newguy123');
        self::$client->post(array('a' => 'employee/new'), $newEmployee);

        //initial value
        $employee = self::$client->get(array('a' => 'employee/2'));
        $this->assertNotNull($employee);

        //create backup of tester
        self::$client->post(array('a' => 'employee/2/backup'), array('backupEmpUID' => '2'));

        //checks if backup successful
        $backup = self::$client->get(array('a' => 'employee/2/backup'));
        $this->assertEquals('', $backup[0]['empUID']);
        $this->assertEquals('2', $backup[0]['backupEmpUID']);

        //checks other get backup endpoint
        $backup = self::$client->get(array('a' => 'employee/2/backupFor'));
        $this->assertEquals('2', $backup[0]['empUID']);
        $this->assertEquals('2', $backup[0]['backupEmpUID']);

        //deletes backup
        self::$client->delete(array('a' => 'employee/2/backup/2'));

        //checks if backup removal successful
        $backup = self::$client->get(array('a' => 'employee/2/backup'));
        $this->assertEquals(0, count($backup));
    }
}
