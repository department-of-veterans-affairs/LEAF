<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/?a=signature API
 */
final class SignaturesControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createRequestPortalClient();
    }

    /**
     * Tests the `signature/new` endpoint
     */
    public function testCreateSignature() : void
    {
        $testParams = array(
            'signature' => 'TESTSIGNATURE',
            'recordID' => 1,
            'message' => 'TESTSIGNATUREMESSAGE',
        );

        $res = self::$client->postEncodedForm('?a=signature/create', $testParams);

        $this->assertNotNull($res);
        $this->assertEquals(1, $res);
    }
}
