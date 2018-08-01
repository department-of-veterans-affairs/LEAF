<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

final class ServiceControllerTest extends DatabaseTest
{
    private static $client = null;

    public static function setUpBeforeClass()
    {
        self::$client = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the POST `service` endpoint
     */
    public function testService() : void
    {
        $newService1 = array(
            'service' => 'A_NEWSERVICEFORsysadmin',
            'groupID' => 1,
        );
        $newService2 = array(
            'service' => 'B_NEWSERVICEFORsysadmin',
            'groupID' => 1,
        );
        $newService3 = array(
            'service' => 'C_NEWSERVICEFORQuadrad',
            'groupID' => -1,
        );
        $newService4 = array(
            'service' => 'D_NEWSERVICEFORQuadrad',
            'groupID' => -1,
        );
        $newService5 = array(
            'service' => 'E_NEWSERVICEFORTestGroup',
            'groupID' => 2,
        );
        $newService6 = array(
            'service' => 'F_NEWSERVICEFORTestGroup',
            'groupID' => 2,
        );
        $newService7 = array(
            'service' => 'G_NEWSERVICEFORNoGroup',
            'groupID' => 0,
        );
        $newService8 = array(
            'service' => 'H_NEWSERVICEFORNoGroup',
            'groupID' => 0,
        );
        $newService9 = array(
            'service' => '',
            'groupID' => 3,
        );
        $newService10 = array(
            'service' => null,
            'groupID' => 3,
        );
        $newService11 = array(
            'service' => 'I_NEWSERVICEnull',
            'groupID' => null,
        );
        $newService12 = array(
            'service' => 'I_NEWSERVICEemptystr',
            'groupID' => '',
        );

        //assert empty
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEmpty($service);

        //add 1st service, groupID==1
        self::$client->postEncodedForm('?a=service', $newService1);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(1, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);

        //add 2nd service, groupID==1
        self::$client->postEncodedForm('?a=service', $newService2);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);

        //add 3rd service, groupID==-1
        self::$client->postEncodedForm('?a=service', $newService3);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(3, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);

        //add 4th service, groupID==2
        self::$client->postEncodedForm('?a=service', $newService5);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(4, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-4', $service[3]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('2', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);

        //add 5th service, groupID==-1, out of order
        self::$client->postEncodedForm('?a=service', $newService4);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(5, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);

        //add 6th service, groupID==2
        self::$client->postEncodedForm('?a=service', $newService6);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(6, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);

        //add 7th service, groupID==0(no matching group in database)
        self::$client->postEncodedForm('?a=service', $newService7);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(7, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[5]['members']);

        //add 8th service, groupID==0(no matching group in database)
        self::$client->postEncodedForm('?a=service', $newService8);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(8, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[6]['members']);
        $this->assertArrayHasKey(7, $service);
        $this->assertEquals('-8', $service[7]['serviceID']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service[7]['service']);
        $this->assertEquals('', $service[7]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[7]['members']);

        //add 9th service, empty string for service (won't add)
        self::$client->postEncodedForm('?a=service', $newService9);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(8, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[6]['members']);
        $this->assertArrayHasKey(7, $service);
        $this->assertEquals('-8', $service[7]['serviceID']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service[7]['service']);
        $this->assertEquals('', $service[7]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[7]['members']);

        //add 10th service, NULL for service (won't add)
        self::$client->postEncodedForm('?a=service', $newService10);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(8, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[6]['members']);
        $this->assertArrayHasKey(7, $service);
        $this->assertEquals('-8', $service[7]['serviceID']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service[7]['service']);
        $this->assertEquals('', $service[7]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[7]['members']);

        //add 11th service, NULL for groupID
        self::$client->postEncodedForm('?a=service', $newService11);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(9, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[6]['members']);
        $this->assertArrayHasKey(7, $service);
        $this->assertEquals('-8', $service[7]['serviceID']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service[7]['service']);
        $this->assertEquals('', $service[7]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[7]['members']);
        $this->assertArrayHasKey(8, $service);
        $this->assertEquals('-9', $service[8]['serviceID']);
        $this->assertEquals('I_NEWSERVICEnull', $service[8]['service']);
        $this->assertEquals('', $service[8]['abbreviatedService']);
        $this->assertNull($service[8]['groupID']);
        $this->assertEmpty($service[8]['members']);

        //add 12th service, empty string for groupID (casts to 0)
        self::$client->postEncodedForm('?a=service', $newService12);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(10, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('1', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('1', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
        $this->assertArrayHasKey(2, $service);
        $this->assertEquals('-3', $service[2]['serviceID']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service[2]['service']);
        $this->assertEquals('', $service[2]['abbreviatedService']);
        $this->assertEquals('-1', $service[2]['groupID']);
        $this->assertEmpty($service[2]['members']);
        $this->assertArrayHasKey(3, $service);
        $this->assertEquals('-5', $service[3]['serviceID']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service[3]['service']);
        $this->assertEquals('', $service[3]['abbreviatedService']);
        $this->assertEquals('-1', $service[3]['groupID']);
        $this->assertEmpty($service[3]['members']);
        $this->assertArrayHasKey(4, $service);
        $this->assertEquals('-4', $service[4]['serviceID']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service[4]['service']);
        $this->assertEquals('', $service[4]['abbreviatedService']);
        $this->assertEquals('2', $service[4]['groupID']);
        $this->assertEmpty($service[4]['members']);
        $this->assertArrayHasKey(5, $service);
        $this->assertEquals('-6', $service[5]['serviceID']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service[5]['service']);
        $this->assertEquals('', $service[5]['abbreviatedService']);
        $this->assertEquals('2', $service[5]['groupID']);
        $this->assertEmpty($service[5]['members']);
        $this->assertArrayHasKey(6, $service);
        $this->assertEquals('-7', $service[6]['serviceID']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service[6]['service']);
        $this->assertEquals('', $service[6]['abbreviatedService']);
        $this->assertEquals('0', $service[6]['groupID']);
        $this->assertEmpty($service[6]['members']);
        $this->assertArrayHasKey(7, $service);
        $this->assertEquals('-8', $service[7]['serviceID']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service[7]['service']);
        $this->assertEquals('', $service[7]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[7]['members']);
        $this->assertArrayHasKey(8, $service);
        $this->assertEquals('-10', $service[8]['serviceID']);
        $this->assertEquals('I_NEWSERVICEemptystr', $service[8]['service']);
        $this->assertEquals('', $service[8]['abbreviatedService']);
        $this->assertEquals('0', $service[7]['groupID']);
        $this->assertEmpty($service[8]['members']);
        $this->assertArrayHasKey(9, $service);
        $this->assertEquals('-9', $service[9]['serviceID']);
        $this->assertEquals('I_NEWSERVICEnull', $service[9]['service']);
        $this->assertEquals('', $service[9]['abbreviatedService']);
        $this->assertNull($service[9]['groupID']);
        $this->assertEmpty($service[9]['members']);
    }

    /**
     * Tests the POST `service` endpoint
     */
    public function testService_HTMLinput() : void
    {
        $newService1 = array(
            'service' => '<script>I_NEWSERVICEhtml</script>',
            'groupID' => 3,
        );
        $newService2 = array(
            'service' => '<b>J_NEWSERVICEhtml</b>',
            'groupID' => 3,
        );

        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEmpty($service);

        //with <script></script> tag, encodes
        self::$client->postEncodedForm('?a=service', $newService1);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(1, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('&lt;script&gt;I_NEWSERVICEhtml&lt;/script&gt;', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('3', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);

        //with <b></b> tag, doesn't encode
        self::$client->postEncodedForm('?a=service', $newService2);
        $service = self::$client->get('?a=service');
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey(0, $service);
        $this->assertEquals('-1', $service[0]['serviceID']);
        $this->assertEquals('&lt;script&gt;I_NEWSERVICEhtml&lt;/script&gt;', $service[0]['service']);
        $this->assertEquals('', $service[0]['abbreviatedService']);
        $this->assertEquals('3', $service[0]['groupID']);
        $this->assertEmpty($service[0]['members']);
        $this->assertArrayHasKey(1, $service);
        $this->assertEquals('-2', $service[1]['serviceID']);
        $this->assertEquals('<b>J_NEWSERVICEhtml</b>', $service[1]['service']);
        $this->assertEquals('', $service[1]['abbreviatedService']);
        $this->assertEquals('3', $service[1]['groupID']);
        $this->assertEmpty($service[1]['members']);
    }
}
