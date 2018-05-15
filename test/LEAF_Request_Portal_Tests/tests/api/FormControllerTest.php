<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/?a=form API
 */
final class FormTest extends DatabaseTest
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
     * Tests the `form/<recordID>/dataforsigning` endpoint.
     */
    public function testDataForSigning() : void
    {
        $results = self::$reqClient->get('?a=form/1/dataforsigning');

        $this->assertNotNull($results);
        $this->assertTrue(isset($results['form_id']));
        $this->assertTrue(isset($results['record_id']));
        $this->assertTrue(isset($results['indicators']));

        $this->assertEquals('form_f4687', $results['form_id']);
        $this->assertEquals('1', $results['record_id']);
        $this->assertEquals('', $results['limit_category']);

        $indicators = $results['indicators'];
        $this->assertEquals(7, sizeof($indicators));

        // Spot check a few indicators of different formats

        // no format
        $ind1 = $indicators['1']['1'];
        $this->assertEquals('1', $ind1['indicatorID']);
        $this->assertEquals('A Very Simple Form', $ind1['name']);
        $this->assertNull($ind1['parentID']);
        $this->assertEquals('0', $ind1['required']);
        $this->assertTrue($ind1['isEmpty']);
        $this->assertEquals('', $ind1['format']);

        // text format
        $ind2 = $indicators['2']['1'];
        $this->assertEquals('2', $ind2['indicatorID']);
        $this->assertEquals('First Name', $ind2['name']);
        $this->assertEquals('First Name', $ind2['description']);
        $this->assertNull($ind2['parentID']);
        $this->assertEquals('1', $ind2['required']);
        $this->assertFalse($ind2['isEmpty']);
        $this->assertEquals('text', $ind2['format']);
        $this->assertEquals('1520268869', $ind2['timestamp']);
        $this->assertEquals('Bruce', $ind2['value']);

        // textarea format
        $ind5 = $indicators['5']['1'];
        $this->assertEquals('5', $ind5['indicatorID']);
        $this->assertEquals('Hobbies', $ind5['name']);
        $this->assertEquals('Hobbies', $ind5['description']);
        $this->assertNull($ind5['parentID']);
        $this->assertEquals('0', $ind5['required']);
        $this->assertFalse($ind5['isEmpty']);
        $this->assertEquals('textarea', $ind5['format']);
        $this->assertEquals('1520268912', $ind5['timestamp']);
        $this->assertEquals('<li>Fighting Crime</li><li>Wearing Capes</li><li>Ninja Stuff<br></li>', $ind5['value']);

        // date format
        $ind6 = $indicators['6']['1'];
        $this->assertEquals('6', $ind6['indicatorID']);
        $this->assertEquals('Favorite Day', $ind6['name']);
        $this->assertEquals('favorite day', $ind6['description']);
        $this->assertNull($ind6['parentID']);
        $this->assertEquals('1', $ind6['required']);
        $this->assertFalse($ind6['isEmpty']);
        $this->assertEquals('date', $ind6['format']);
        $this->assertEquals('1520268896', $ind6['timestamp']);
        $this->assertEquals('05/23/1934', $ind6['value']);
    }

}
