<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

final class FormStackControllerTest extends DatabaseTest
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
     * Tests the GET `formStack/version` endpoint.
     */
    public function testGetVersion() : void
    {
        $version = self::$client->get(array('a' => 'formStack/version'));
        $this->assertEquals(1, $version);
    }

    /**
     * Tests the DELETE `formStack/[text]` endpoint.
     */
    public function testDeleteForm() : void
    {
        $categories = self::$client->get(array('a' => 'formStack/categoryList/all'));

        $this->assertNotNull($categories);
        $this->assertEquals(3, count($categories));

        $delResponse = self::$client->Delete(array('a' => 'formStack/_form_f4687'));
        $this->assertNotNull($delResponse);
        $this->assertEquals(true, $delResponse);

        $categories = self::$client->get(array('a' => 'formStack/categoryList/all'));
        $this->assertEquals(2, count($categories));

        // ensure form was actually deleted
        foreach ($categories as $category)
        {
            $this->assertNotNull($category);
            $this->assertNotNull($category['categoryID']);
            $this->assertTrue('form_f4687' != $category['categoryID']);
        }
    }
}
