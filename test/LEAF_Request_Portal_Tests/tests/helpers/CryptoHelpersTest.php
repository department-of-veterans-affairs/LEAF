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
    private static $signature = "59451fa9c8c666305977d47bb2b4e3341c952bdfbd57716018806c3dfda2d7275542b6f29c5775357cb728b26f5fb09033b78f85d25a087a64219f324da36308";

    public static function setUpBeforeClass()
    {
        self::$portalClient = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
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
        $hexHash = "71c7e92d4527c9172078c7ce8709d46c4156787a9dbda2e79ff4014988776393";

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
