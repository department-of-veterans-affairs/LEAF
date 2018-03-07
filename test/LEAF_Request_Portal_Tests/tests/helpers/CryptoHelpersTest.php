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
     * Tests CryptoHelpers::signJSON()
     */
    public function testSignJSON() : void
    {
        $hexkey = '7847e3dc727339dc7553e80a59ba6431de2aa5d8de6208136371cc220c245c43397e6ee461cdb2f5429d6ac788e3a65813368dcbc2d1ac9bb7b64f3573684f0f';
        $signature = 'd9c0007d02ebcc2cb24e521ba3e96758fbb04054ebfba7c770f9f93724b0f971';

        $formToSign = self::$portalClient->get('?a=form/1/dataforsigning');
        $formObj = json_encode($formToSign, JSON_FORCE_OBJECT);
        $sig = CryptoHelpers::signJSONObject($formObj, $hexkey);

        $this->assertEquals($signature, $sig);

        $anotherFormToSign = self::$portalClient->get('?a=form/2/dataforsigning');
        $anotherFormObj = json_encode($anotherFormToSign, JSON_FORCE_OBJECT);
        $anotherSig = CryptoHelpers::signJSONObject($anotherFormObj, $hexkey);

        $this->assertTrue($sig != $anotherSig);
    }
}
