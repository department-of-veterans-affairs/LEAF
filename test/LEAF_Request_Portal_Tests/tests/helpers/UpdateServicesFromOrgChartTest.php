<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;


/**
 * Tests LEAF_Request_Portal/api/system API
 */
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

final class UpdateServicesFromOrgChartTest extends DatabaseTest
{
    private static $reqClient = null;

    private static $db;

    public static function setUpBeforeClass()
    {
        $db_config = new DB_Config();
        self::$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        self::$reqClient = LEAFClient::createRequestPortalClient('http://localhost/LEAF_Request_Portal/', 'auth_domain/');
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests updateServicesFromOrgChart.php
     */
    public function testGroupRemoval() : void
    {
        //CASE 1, REMOVE groups, user, AND category_privs:
            //insert new group with no corresponding group in nexus
            self::$db->query("INSERT INTO groups (`groupID`, `parentGroupID`, `name`, `groupDescription`)
                                VALUES ('20', NULL, 'faker', 'faker')");
            //add employee to group
            self::$db->query("INSERT INTO users (`userID`, `groupID`)
                                VALUES ('tester', '20')");
            //add group to category_privs
            self::$db->query("INSERT INTO category_privs (`categoryID`, `groupID`, `readable`, `writable`)
                                VALUES ('form_f4687', '20', '1', '1')");
            //assert they are inserted
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($groups) > 0);
            $this->assertTrue(count($users) > 0);
            $this->assertTrue(count($category_privs) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($groups) == 0);
            $this->assertTrue(count($users) == 0);
            $this->assertTrue(count($category_privs) == 0);

        //CASE 2, REMOVE groups and users, no category_privs:
            //insert new group with no corresponding group in nexus
            self::$db->query("INSERT INTO groups (`groupID`, `parentGroupID`, `name`, `groupDescription`)
                                VALUES ('20', NULL, 'faker', 'faker')");
            //add employee to group
            self::$db->query("INSERT INTO users (`userID`, `groupID`)
                                VALUES ('tester', '20')");
            //assert they are inserted
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $this->assertTrue(count($groups) > 0);
            $this->assertTrue(count($users) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $this->assertTrue(count($groups) == 0);
            $this->assertTrue(count($users) == 0);

        //CASE 3, REMOVE groups and category_privs, no user:
            //insert new group with no corresponding group in nexus
            self::$db->query("INSERT INTO groups (`groupID`, `parentGroupID`, `name`, `groupDescription`)
                                VALUES ('20', NULL, 'faker', 'faker')");
            //add group to category_privs
            self::$db->query("INSERT INTO category_privs (`categoryID`, `groupID`, `readable`, `writable`)
                                VALUES ('form_f4687', '20', '1', '1')");
            //assert they are inserted
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($groups) > 0);
            $this->assertTrue(count($category_privs) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($groups) == 0);
            $this->assertTrue(count($category_privs) == 0);

        //CASE 4, REMOVE user AND category_privs, no groups:
            //add employee to group
            self::$db->query("INSERT INTO users (`userID`, `groupID`)
                                VALUES ('tester', '20')");
            //add group to category_privs
            self::$db->query("INSERT INTO category_privs (`categoryID`, `groupID`, `readable`, `writable`)
                                VALUES ('form_f4687', '20', '1', '1')");
            //assert they are inserted
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($users) > 0);
            $this->assertTrue(count($category_privs) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($users) == 0);
            $this->assertTrue(count($category_privs) == 0);

        //CASE 5, REMOVE groups only:
            //insert new group with no corresponding group in nexus
            self::$db->query("INSERT INTO groups (`groupID`, `parentGroupID`, `name`, `groupDescription`)
                                VALUES ('20', NULL, 'faker', 'faker')");
            //assert they are inserted
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $this->assertTrue(count($groups) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $groups = self::$db->query("SELECT * FROM `groups` WHERE groupID = '20'");
            $this->assertTrue(count($groups) == 0);

        //CASE 6, REMOVE users only:
            //add employee to group
            self::$db->query("INSERT INTO users (`userID`, `groupID`)
                                VALUES ('tester', '20')");
            //assert they are inserted
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $this->assertTrue(count($users) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $users = self::$db->query("SELECT * FROM users WHERE groupID = '20'");
            $this->assertTrue(count($users) == 0);

        //CASE 7, REMOVE category_privs only:
            //add group to category_privs
            self::$db->query("INSERT INTO category_privs (`categoryID`, `groupID`, `readable`, `writable`)
                                VALUES ('form_f4687', '20', '1', '1')");
            //assert they are inserted
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($category_privs) > 0);

            //call update, this should remove all since the group isn't in nexus
            self::$reqClient->get(array(),array(),'scripts/updateServicesFromOrgChart.php');

            //assert they are gone
            $category_privs = self::$db->query("SELECT * FROM category_privs WHERE groupID = '20'");
            $this->assertTrue(count($category_privs) == 0);

    }
}