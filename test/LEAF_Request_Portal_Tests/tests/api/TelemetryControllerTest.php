<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/telemetry API
 */
final class TelemetryControllerTest extends DatabaseTest
{
    private static $reqClient = null;

    public static function setUpBeforeClass()
    {
        self::$reqClient = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the GET `telemetry/simple/requests` endpoint.
     */
    public function testGetRequestsSimple() : void
    {
        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '0', 'endTime' => '0'));
        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268853', 'endTime' => '1520268853'));
        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268852', 'endTime' => '1520268853'));

        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268853', 'endTime' => '1520268854'));

        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268852', 'endTime' => '1520268854'));

        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '0', 'endTime' => '1520268854'));
        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268852', 'endTime' => '0'));

        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => 'HELLO', 'endTime' => 'GOODBYE'));
        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '', 'endTime' => ''));
        $this->assertNotNull($result);
        $res = $result[0];
        $this->assertEquals($res, array(
            'recordID' => '1',
            'categoryName' => 'Sample Form',
            'submitted' => '1520268930',
        ));

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268852', 'endTime' => '1520268852'));
        $this->assertNotNull($result);
        $this->assertEquals($result, array());

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268854', 'endTime' => '1520268854'));

        $this->assertNotNull($result);
        $this->assertEquals($result, array());

        $result = self::$reqClient->get(array('a' => 'telemetry/simple/requests', 'startTime' => '1520268854', 'endTime' => '1520268852'));
        $this->assertNotNull($result);
        $this->assertEquals($result, array());
    }
}
