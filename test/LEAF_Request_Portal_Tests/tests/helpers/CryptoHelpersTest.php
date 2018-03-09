<?php

declare(strict_types = 1);

include '../../libs/php-commons/CryptoHelpers.php';

use LEAFTest\LEAFClient;

/**
 * Tests libs/php-commons/CryptoHelpers.php
 */
final class CryptoHelpersTest extends DatabaseTest
{
    private static $portalClient = null;

    // the signing keys, in hexadecimal format
    private static $secretSignKey = "21f546c87d5b25335bf05ce81b28d662f517aa4520f409c9a76710273a35df167bd9ef2f1049e05ed8abb9fb497bf200e2f9e70451f3ad0e694cf778f001568e";
    private static $publicSignKey = "7bd9ef2f1049e05ed8abb9fb497bf200e2f9e70451f3ad0e694cf778f001568e";

    // signature of signed object
    private static $signature = "d134b276d0f858c78b35656e695344346c00e06f71f4eecee2e3f7b0992f2e9cca8db61b117e2bce39d9eb20b467c8c33dbc22972b3cc7791725fcac7c27bb0c";


    // runs before every test
    protected function setUp()
    {
        $this->resetDatabase();
        self::$portalClient = LEAFClient::createRequestPortalClient();
    }

    /**
     * Tests that libsodium is installed and enabled on the system
     * (module needs to be enabled in php.ini).
     */
    public function testSodiumInstalled() : void
    {
        $this->assertTrue(defined('SODIUM_LIBRARY_VERSION'));
    }

    /**
     * Tests CryptoHelpers::hashObject()
     */
    public function testHashObject() : void
    {
        $hexHash = "5940716038aa9c53f1fb6fc66b185b04d6d71222db10c1440c609576fa85b0c5";

        $formToSign = self::$portalClient->get('?a=form/1/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);

        $hashed = CryptoHelpers::hashObject($formObj);

        $this->assertEquals($hexHash, $hashed);
    }

    /**
     * Tests CryptoHelpers::signJSONObject()
     */
    public function testSignJSONObject() : void
    {
        $formToSign = self::$portalClient->get('?a=form/1/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);
        $sig = CryptoHelpers::signJSONObject($formObj, self::$secretSignKey);

        $this->assertEquals(self::$signature, $sig);

        $anotherFormToSign = self::$portalClient->get('?a=form/2/dataforsigning');
        $anotherFormObj = json_encode($anotherFormToSign, JSON_FORCE_OBJECT);
        $anotherSig = CryptoHelpers::signJSONObject($anotherFormObj, self::$secretSignKey);

        $this->assertTrue($sig != $anotherSig);
    }

    /**
     * Tests CryptoHelpers::verifySignature()
     * 
     * Tests an authentic signature.
     */
    public function testVerifySignature_authentic() : void
    {
        $formToSign = self::$portalClient->get('?a=form/1/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);

        $verified = CryptoHelpers::verifySignature(
            self::$signature,
            $formObj,
            self::$publicSignKey
        );

        $this->assertEquals(true, $verified);
    }

    /**
     * Tests CryptoHelpers::verifySignature()
     * 
     * Tests an inauthentic signature.
     */
    public function testVerifySignature_inauthentic(): void
    {
        $differentSignature = CryptoHelpers::signJSONObject(
            "somerandommjunkdatacanbeanythingdoesntneedtobejson", 
            self::$secretSignKey
        );

        $formToSign = self::$portalClient->get('?a=form/1/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);
        $verified = CryptoHelpers::verifySignature(
            $differentSignature,
            $formObj,
            self::$publicSignKey
        );

        $this->assertEquals(false, $verified);
    }

    /**
     * Tests CryptoHelpers::verifySignature()
     * 
     * Tests that an authentic signature does not authenticate against
     * a different message than it was generated for.
     */
    public function testVerifySignature_incorrectMessage(): void
    {
        $formToSign = self::$portalClient->get('?a=form/2/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);

        $verified = CryptoHelpers::verifySignature(
            self::$signature,
            $formObj,
            self::$publicSignKey
        );

        $this->assertEquals(false, $verified);
    }
}
