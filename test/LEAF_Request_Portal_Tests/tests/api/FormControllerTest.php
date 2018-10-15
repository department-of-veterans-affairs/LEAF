<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/?a=form API
 */
final class FormControllerTest extends DatabaseTest
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
        $results = self::$reqClient->get(array('a' => 'form/1/dataforsigning'));

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

    /**
     * Tests the `form/categories` endpoint.
     */
    public function testGetAllCategories() : void
    {
        $results = self::$reqClient->get(array('a' => 'form/categories'));

        $this->assertNotNull($results);
        $this->assertEquals(3, count($results));
        $this->assertEquals('form_f4687', $results[0]['categoryID']);
        $this->assertEquals('form_f4688', $results[1]['categoryID']);
        $this->assertEquals('form_f4689', $results[2]['categoryID']);
    }

    /**
     * Tests the `form/[digit]` endpoint.
     */
    public function testGetForm() : void
    {
        $results = self::$reqClient->get(array('a' => 'form/1'));

        $this->assertNotNull($results);
        $this->assertNotNull($results['items']);
        $this->assertEquals(1, count($results['items']));

        $form = $results['items'][0];

        $this->assertEquals('Sample Form', $form['name']);

        $this->assertNotNull($form['children']);
        $this->assertEquals(7, count($form['children']));
        $this->assertEquals('form_f4687', $form['children'][0]['type']);
    }

    /**
     * Tests the `form/category&id=[categoryID]` endpoint.
     */
    public function testGetFormByCategory() : void
    {
        $results = self::$reqClient->get(array(
            'a' => 'form/category',
            'id' => 'form_f4687',
        ));

        $this->assertNotNull($results);
        $this->assertEquals(7, count($results));
    }

    /**
     * Tests the `form/category&id=[categoryID]` endpoint.
     *
     * Tests the endpoint with a nonexistent ID.
     */
    public function testGetFormByCategory_nonexistentID() : void
    {
        $results = self::$reqClient->get(array(
            'a' => 'form/category',
            'id' => 'I_DO_NOT_EXIST',
        ));

        $this->assertNotNull($results);
        $this->assertEquals(0, count($results));
    }

    /**
     * Tests the `form/[digit]/[digit]/[digit]/history` endpoint.
     */
    public function testGetIndicatorLog() : void
    {
        $results = self::$reqClient->get(array('a' => 'form/1/2/1/history'));

        $this->assertNotNull($results);
        $this->assertEquals(1, count($results));
        $this->assertEquals('Bruce', $results[0]['data']);
    }

    /**
     * Tests the `form/[text]/workflow` endpoint.
     */
    public function testGetWorkflow() : void
    {
        $results = self::$reqClient->get(array('a' => 'form/_form_f4687/workflow'));

        $this->assertNotNull($results);
        $this->assertEquals(1, count($results));
        $this->assertEquals(1, $results[0]['workflowID']);
        $this->assertEquals('form_f4687', $results[0]['categoryID']);
    }

    /**
     * Tests the `form/[text]/workflow` endpoint.
     *
     * Tests with invalid category ID
     */
    public function testGetWorkflow_invalidCategory() : void
    {
        $results = self::$reqClient->get(array('a' => 'form/_form_junk/workflow'));

        $this->assertNotNull($results);
        $this->assertEquals(0, count($results));
    }

    /**
     * Tests the `form/new` endpoint.
     */
    public function testNewForm() : void
    {
        $results = self::$reqClient->post(array('a' => 'form/new'), array(
            'title' => 'Junk Title',
            'numform_f4687' => 1,
        ));

        $this->assertNotNull($results);
        $this->assertEquals(2, $results);
    }

    /**
     * Tests the `form/[digit]/indicator/formatSearch` endpoint
     */
    public function testGetIndicatorsByRecordAndFormat() : void
    {
        //gets all indicators for recordID=1 where format is text or textarea
        $indicators = self::$client->get(array('a' => 'form/1/indicator/formatSearch', 'formats' => array('text', 'textarea')));
        
        //checks text indicators for recordID=1
        $this->assertEquals('2', $indicators[0]['indicatorID']);
        $this->assertEquals('First Name', $indicators[0]['name']);
        $this->assertEquals('text', $indicators[0]['format']);
        
        $this->assertEquals('3', $indicators[1]['indicatorID']);
        $this->assertEquals('Last Name', $indicators[1]['name']);
        $this->assertEquals('text', $indicators[1]['format']);
        
        $this->assertEquals('4', $indicators[2]['indicatorID']);
        $this->assertEquals('Occupation', $indicators[2]['name']);
        $this->assertEquals('text', $indicators[2]['format']);
        
        $this->assertEquals('5', $indicators[3]['indicatorID']);
        $this->assertEquals('Hobbies', $indicators[3]['name']);
        $this->assertEquals('textarea', $indicators[3]['format']);
        
        $this->assertEquals('7', $indicators[4]['indicatorID']);
        $this->assertEquals('Masked', $indicators[4]['name']);
        $this->assertEquals('text', $indicators[4]['format']);
    }
}
