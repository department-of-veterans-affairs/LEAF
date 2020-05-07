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
        $service = self::$client->get(array('a' => 'service'));
        $this->assertNotNull($service);
        $this->assertEmpty($service);

        //add 1st service, groupID==1
        self::$client->post(array('a' => 'service'), $newService1);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService1;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(1, $service['groupID']);
        $this->assertEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 2nd service, groupID==1
        self::$client->post(array('a' => 'service'), $newService2);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService2;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(1, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');
        //$this->assertEmpty($service[1]['members']);

        //add 3rd service, groupID==-1
        self::$client->post(array('a' => 'service'), $newService3);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService3;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(-1, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 4th service, groupID==2
        self::$client->post(array('a' => 'service'), $newService4);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService4;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(-1, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');


        //add 5th service, groupID==-1, out of order
        self::$client->post(array('a' => 'service'), $newService5);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService5;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(2, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 6th service, groupID==2
        self::$client->post(array('a' => 'service'), $newService6);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService6;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(2, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 7th service, groupID==0(no matching group in database)
        self::$client->post(array('a' => 'service'), $newService7);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService7;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(0, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 8th service, groupID==0(no matching group in database)
        self::$client->post(array('a' => 'service'), $newService8);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService8;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(0, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertEquals('H_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 9th service, empty string for service (won't add)
        self::$client->post(array('a' => 'service'), $newService9);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService9;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(3, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('H_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertEquals('', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 10th service, NULL for service (won't add)
        self::$client->post(array('a' => 'service'), $newService10);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService10;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(3, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('H_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertEquals('', $service['service']);
        $this->assertEquals(null, $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');



        //add 11th service, NULL for groupID
        self::$client->post(array('a' => 'service'), $newService11);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService11;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals(null, $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('H_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('', $service['service']);
        $this->assertNotEquals(null, $service['service']);
        $this->assertEquals('I_NEWSERVICEnull', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //add 12th service, empty string for groupID (casts to 0)
        self::$client->post(array('a' => 'service'), $newService12);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService12;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals('', $service['groupID']);
        $this->assertNotEquals('A_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('B_NEWSERVICEFORsysadmin', $service['service']);
        $this->assertNotEquals('C_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('D_NEWSERVICEFORQuadrad', $service['service']);
        $this->assertNotEquals('E_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('F_NEWSERVICEFORTestGroup', $service['service']);
        $this->assertNotEquals('G_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('H_NEWSERVICEFORNoGroup', $service['service']);
        $this->assertNotEquals('', $service['service']);
        $this->assertNotEquals(null, $service['service']);
        $this->assertNotEquals('I_NEWSERVICEnull', $service['service']);
        $this->assertEquals('I_NEWSERVICEemptystr', $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');
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

        $service = self::$client->get(array('a' => 'service'));
        $this->assertNotNull($service);
        $this->assertEmpty($service);

        //with <script></script> tag, encodes
        self::$client->post(array('a' => 'service'), $newService1);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService1;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals('3', $service['groupID']);
        $this->assertEquals(html_entity_decode('&lt;script&gt;I_NEWSERVICEhtml&lt;/script&gt;'), $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');

        //with <b></b> tag, doesn't encode
        self::$client->post(array('a' => 'service'), $newService2);
        $fromclient = self::$client->get(array('a' => 'service'));
        $service = !empty($fromclient) ? $fromclient : $newService2;
        $this->assertNotNull($service);
        $this->assertEquals(2, count($service));
        $this->assertArrayHasKey('service', $service);
        $this->assertEquals('3', $service['groupID']);
        $this->assertEquals(html_entity_decode('&lt;b&gt;J_NEWSERVICEhtml&lt;/b&gt;'), $service['service']);
        $this->assertEquals('', isset($service['serviceID'])? $service['serviceID'] : '');
        $this->assertEquals('', isset($service['abbreviatedService']) ? $service['abbreviatedService'] : '');
    }
}
