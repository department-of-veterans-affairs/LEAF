<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests the LEAF_Nexus/api/tag API
 */
class TagControllerTest extends DatabaseTest
{
    private static $client = null;

    protected function setUp()
    {
        $this->resetDatabase();
        self::$client = LEAFClient::createNexusClient();
    }
    /**
    * Tests the 'tag/[text]/parent' endpoint
    */
    public function testAddParentTag() : void
    {
        //initial value
        $parentTag = self::$client->get('tag/_service/parent');
        $this->assertEquals('quadrad', $parentTag);

        //create a tag
        self::$client->postEncodedForm('?a=group/13/tag', array('tag' => "TESTTAG"));

        $group = self::$client->get('?a=group/tag&tag=TESTTAG');
        $this->assertEquals('TESTTAG', $group[0]['tag']);

        //set service to have the created tag as a parent
        self::$client->postEncodedForm('tag/_service/parent', array('parentTag' => 'TESTTAG'));

        //checks to make sure the change was successful
        $parentTag = self::$client->get('tag/_service/parent');
        $this->assertEquals('TESTTAG', $parentTag);
    }
}
