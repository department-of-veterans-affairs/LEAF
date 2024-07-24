<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

final class FormEditorControllerTest extends DatabaseTest
{
    private static $client = null;

    private static $testEndpointClient = null;

    private static $db;

    public static function setUpBeforeClass()
    {
        $db_config = new DB_Config();
        self::$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        self::$client = LEAFClient::createRequestPortalClient();
        self::$testEndpointClient = LEAFClient::createRequestPortalClient('http://localhost/test/LEAF_test_endpoints/request_portal/', '../../../LEAF_Request_Portal/auth_domain/');
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the POST `formEditor/setFormat` endpoint.
     */
    public function testSetFormat() : void
    {
        $action = 'formEditor/setFormat';

        $queryParams = array('a' => $action);
        $formParams = array('indicatorID' => '1', 'format' => 'whatever');
        self::$testEndpointClient->post($queryParams, $formParams);

        $var = array(':indicatorID' => 1);
        $res = self::$db->prepared_query('SELECT format
                                            FROM indicators
                                            WHERE indicatorID=:indicatorID', $var);

        $this->assertFalse(empty($res));
        $this->assertEquals('whatever', $res[0]['format']);
    }

    /**
     * Tests the POST `formEditor/setFormat` endpoint.
     */
    public function testSetFormatGeneric() : void
    {
        $action = 'formEditor/genericFunctionCall/_setFormat';

        $queryParams = array('a' => $action);
        $formParams = array('indicatorID' => '1', 'format' => 'whatevero');
        self::$testEndpointClient->post($queryParams, $formParams);

        $var = array(':indicatorID' => 1);
        $res = self::$db->prepared_query('SELECT format
                                            FROM indicators
                                            WHERE indicatorID=:indicatorID', $var);

        $this->assertFalse(empty($res));
        $this->assertEquals('whatevero', $res[0]['format']);
    }

    /**
     * Tests the GET `formEditor/version` endpoint.
     */
    public function testGetVersion() : void
    {
        $version = self::$client->get(array('a' => 'formEditor/version'));
        $this->assertEquals(1, $version);
    }

    /**
     * Tests the GET `formEditor/indicator/[digit]` endpoint.
     */
    public function testGetIndicator() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $ind = $indicator['6'];
        $this->assertEquals('6', $ind['indicatorID']);
        $this->assertEquals(1, $ind['series']);
        $this->assertEquals('Favorite Day', $ind['name']);
        $this->assertEquals('favorite day', $ind['description']);
        $this->assertEquals('', $ind['default']);
        $this->assertEquals(null, $ind['parentID']);
        $this->assertEquals(null, $ind['html']);
        $this->assertEquals(null, $ind['htmlPrint']);
        $this->assertEquals('1', $ind['required']);
        $this->assertEquals('0', $ind['is_sensitive']);
        $this->assertEquals(true, $ind['isEmpty']);
        $this->assertEquals('', $ind['value']);
        $this->assertEquals('', $ind['displayedValue']);
        $this->assertEquals(0, $ind['timestamp']);
        $this->assertEquals(1, $ind['isWritable']);
        $this->assertEquals(0, $ind['isMasked']);
        $this->assertEquals('1', $ind['sort']);
        $this->assertEquals('date', $ind['format']);
        $this->assertEquals(null, $ind['child']);
    }

    /**
     * Tests the GET `formEditor/indicator/[digit]` endpoint.
     *
     * Tests for nonexistent indicator
     */
    public function testGetIndicator_nonexistentIndicator() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/8'));

        $this->assertNotNull($indicator);
        $ind = $indicator[''];
        $this->assertEquals(null, $ind['indicatorID']);
        $this->assertEquals(1, $ind['series']);
        $this->assertEquals(null, $ind['name']);
        $this->assertEquals(null, $ind['description']);
        $this->assertEquals(null, $ind['default']);
        $this->assertEquals(null, $ind['parentID']);
        $this->assertEquals(null, $ind['html']);
        $this->assertEquals(null, $ind['htmlPrint']);
        $this->assertEquals(null, $ind['required']);
        $this->assertEquals(null, $ind['is_sensitive']);
        $this->assertEquals(true, $ind['isEmpty']);
        $this->assertEquals(null, $ind['value']);
        $this->assertEquals('', $ind['displayedValue']);
        $this->assertEquals(0, $ind['timestamp']);
        $this->assertEquals(1, $ind['isWritable']);
        $this->assertEquals(0, $ind['isMasked']);
        $this->assertEquals(null, $ind['sort']);
        $this->assertEquals('', $ind['format']);
        $this->assertEquals(null, $ind['child']);
    }

    public function testGetIndicator_nondigitParam() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/nondigit'));
        $this->assertEquals('Controller is undefined.', $indicator);
    }

    /**
     * Tests the GET `formEditor/[text]/privileges
     */
    public function testGetCategoryPrivileges() : void
    {
        $privs = self::$client->get(array('a' => 'formEditor/_form_f4687/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals('2', $privs[0]['groupID']);
        $this->assertEquals('form_f4687', $privs[0]['categoryID']);
        $this->assertEquals('1', $privs[0]['readable']);
        $this->assertEquals('1', $privs[0]['writable']);
        $this->assertEquals(null, $privs[0]['parentGroupID']);
        $this->assertEquals('Test Group', $privs[0]['name']);
        $this->assertEquals('A Group for Testing', $privs[0]['groupDescription']);
    }

    /**
     * Tests the `formEditor/newIndicator` endpoint
     */
    public function testNewIndicator() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/8'));

        // returns an empty "null" indicator
        $this->assertNotNull($indicator);
        $this->assertNull($indicator['']['indicatorID']);

        $newIndicator = array(
            'name' => 'NEWTESTINDICATOR',
            'format' => 'text',
            'description' => 'NEWTESTINDICATORDESCRIPTION',
            'default' => '',
            'parentID' => '',
            'categoryID' => 'form_f4687',
            'html' => null,
            'htmlPrint' => null,
            'required' => 0,
            'is_sensitive' => 0,
            'sort' => 1,
        );

        self::$client->post(array('a' => 'formEditor/newIndicator'), $newIndicator);

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/8'));

        $this->assertNotNull($indicator);
        $this->assertEquals('8', $indicator['8']['indicatorID']);
        $this->assertEquals($newIndicator['name'], $indicator['8']['name']);
        $this->assertEquals($newIndicator['format'], $indicator['8']['format']);
        $this->assertEquals($newIndicator['description'], $indicator['8']['description']);
        $this->assertEquals($newIndicator['default'], $indicator['8']['default']);
        $this->assertEquals(null, $indicator['8']['parentID']);
        $this->assertEquals(null, $indicator['8']['html']);
        $this->assertEquals(null, $indicator['8']['htmlPrint']);
        $this->assertEquals(0, $indicator['8']['required']);
        $this->assertEquals(0, $indicator['8']['is_sensitive']);
        $this->assertEquals(1, $indicator['8']['sort']);
    }

    /**
     * Tests the `formEditor/newIndicator` endpoint
     *
     * Tests input that contains HTML.
     */
    public function testNewIndicator_HTMLinput() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/8'));

        // returns an empty "null" indicator
        $this->assertNotNull($indicator);
        $this->assertNull($indicator['']['indicatorID']);

        $newIndicator = array(
            'name' => "<script lang='javascript'>alert('hi')</script><b>NEWTESTINDICATOR</b>",
            'format' => "<script lang='javascript'>alert('hi')</script>text",
            'description' => '<strong>NEWTESTINDICATORDESCRIPTION</strong>',
            'default' => '',
            'parentID' => '',
            'categoryID' => 'form_f4687',
            'html' => "<script lang='javascript'>alert('hi')</script><b>the html</b>",
            'htmlPrint' => "<script lang='javascript'>alert('hi')</script><b>the html</b>",
            'required' => 0,
            'is_sensitive' => 0,
            'sort' => 1,
        );

        self::$client->post(array('a' => 'formEditor/newIndicator'), $newIndicator);

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/8'));

        $this->assertNotNull($indicator);
        $this->assertEquals('8', $indicator['8']['indicatorID']);
        $this->assertEquals('&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>NEWTESTINDICATOR</b>', $indicator['8']['name']);
        $this->assertEquals("alert('hi')text", $indicator['8']['format']);
        $this->assertEquals('<strong>NEWTESTINDICATORDESCRIPTION</strong>', $indicator['8']['description']);
        $this->assertEquals($newIndicator['default'], $indicator['8']['default']);
        $this->assertEquals(null, $indicator['8']['parentID']);
        $this->assertEquals("<script lang='javascript'>alert('hi')</script><b>the html</b>", $indicator['8']['html']); // Advanced Option allows HTML/JS
        $this->assertEquals("<script lang='javascript'>alert('hi')</script><b>the html</b>", $indicator['8']['htmlPrint']); // Advanced Option allows HTML/JS
        $this->assertEquals(0, $indicator['8']['required']);
        $this->assertEquals(0, $indicator['8']['is_sensitive']);
        $this->assertEquals(1, $indicator['8']['sort']);
    }

    /**
     * Tests the `formEditor/formName` endpoint.
     */
    public function testSetFormName() : void
    {
        $form = self::$client->get(array('a' => 'form/1'));

        $this->assertNotNull($form);
        $this->assertEquals('Sample Form', $form['items'][0]['name']);

        $result = self::$client->post(
            array('a' => 'formEditor/formName'),
            array(
                'categoryID' => 'form_f4687',
                'name' => 'Test Form',
            )
        );

        $form = self::$client->get(array('a' => 'form/1'));

        $this->assertNotNull($form);
        $this->assertEquals('Test Form', $form['items'][0]['name']);
    }

    /**
     * Tests the `formEditor/[digit]/name` endpoint.
     */
    public function testSetIndicatorName() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('Favorite Day', $indicator['6']['name']);

        self::$client->post(array('a' => 'formEditor/6/name'), array('name' => 'New Indicator Name'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('New Indicator Name', $indicator['6']['name']);
    }

    /**
     * Tests the `formEditor/[digit]/name` endpoint.
     *
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorName_HTMLinput() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('Favorite Day', $indicator['6']['name']);

        self::$client->post(array('a' => 'formEditor/6/name'), array(
            'name' => "<script lang='javascript'>alert('hi')</script><b>new name</b>",
        ));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(
            "<script lang='javascript'>alert('hi')</script><b>new name</b>",
            $indicator['6']['name']
        );
    }

    /**
     * Tests the `formEditor/[digit]/format` endpoint.
     */
    public function testSetIndicatorFormat() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('date', $indicator['6']['format']);

        self::$client->post(array('a' => 'formEditor/6/format'), array('format' => 'text'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('text', $indicator['6']['format']);
    }

    /**
     * Tests the `formEditor/[digit]/format` endpoint.
     *
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorFormat_HTMLinput() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('date', $indicator['6']['format']);

        self::$client->post(array('a' => 'formEditor/6/format'), array(
            'format' => "<script lang='javascript'>alert('hi')</script>text",
        ));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals("alert('hi')text", $indicator['6']['format']);
    }

    /**
     * Tests the `formEditor/[digit]/description` endpoint.
     */
    public function testSetIndicatorDescription() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('favorite day', $indicator['6']['description']);

        self::$client->post(array('a' => 'formEditor/6/description'), array('description' => 'a changed description'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('a changed description', $indicator['6']['description']);
    }

    /**
     * Tests the `formEditor/[digit]/description` endpoint.
     *
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorDescription_HTMLinput() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('favorite day', $indicator['6']['description']);

        self::$client->post(array('a' => 'formEditor/6/description'), array(
            'description' => "<script lang='javascript'>",
        ));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('&lt;script lang=&#039;javascript&#039;&gt;', $indicator['6']['description']);
    }

    /**
     * Tests the `formEditor/[digit]/default` endpoint.
     */
    public function testSetIndicatorDefault() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('', $indicator['6']['default']);

        self::$client->post(array('a' => 'formEditor/6/default'), array('default' => 'some default'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('some default', $indicator['6']['default']);
    }

    /**
     * Tests the `formEditor/[digit]/default` endpoint.
     */
    public function testSetIndicatorDefault_HTMLinput() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('', $indicator['6']['default']);

        self::$client->post(array('a' => 'formEditor/6/default'), array(
            'default' => "<script lang='javascript'>alert('hi')</script><b>stuff</b>",
        ));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>stuff</b>', $indicator['6']['default']);
    }

    /**
     * Tests the `formEditor/[digit]/parentID` endpoint.
     */
    public function testSetIndicatorParentID() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator['6']['parentID']);

        self::$client->post(array('a' => 'formEditor/6/parentID'), array('parentID' => 7));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(7, $indicator['6']['parentID']);
    }

    /**
     * Tests the `formEditor/[digit]/required` endpoint.
     */
    public function testSetIndicatorRequired() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('1', $indicator['6']['required']);

        self::$client->post(array('a' => 'formEditor/6/required'), array('required' => '0'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('0', $indicator['6']['required']);
    }

    /**
     * Tests the `formEditor/[digit]/sensitive` endpoint.
     */
    public function testSetIndicatorSensitive() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('0', $indicator['6']['is_sensitive']);

        self::$client->post(array('a' =>'formEditor/6/sensitive'), array('is_sensitive' => '1'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('1', $indicator['6']['is_sensitive']);
    }

    /**
     * Tests the `formEditor/[digit]/disabled` endpoint.
     */
    public function testSetIndicatorDisabled() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('Favorite Day', $indicator['6']['name']);

        self::$client->post(array('a' => 'formEditor/6/disabled'), array('disabled' => '1'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator['']['indicatorID']);
    }

    /**
     * Tests the `formEditor/[digit]/sort` endpoint.
     */
    public function testSetIndicatorSort() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('1', $indicator['6']['sort']);

        self::$client->post(array('a' => 'formEditor/6/sort'), array('sort' => '0'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('0', $indicator['6']['sort']);
    }

    /**
     * Tests the `formEditor/[digit]/html` endpoint.
     */
    public function testSetIndicatorHTML() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator['6']['html']);

        self::$client->post(array('a' => 'formEditor/6/html'), array('html' => '<strong>html</strong>'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('<strong>html</strong>', $indicator['6']['html']);
    }

    /**
     * Tests the `formEditor/[digit]/htmlPrint` endpoint.
     */
    public function testSetIndicatorHTMLPrint() : void
    {
        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator['6']['htmlPrint']);

        self::$client->post(array('a' => 'formEditor/6/htmlPrint'), array('htmlPrint' => '<b>html</b>'));

        $indicator = self::$client->get(array('a' => 'formEditor/indicator/6'));

        $this->assertNotNull($indicator);
        $this->assertEquals('<b>html</b>', $indicator['6']['htmlPrint']);
    }

    /**
     * Tests the `formEditor/new` endpoint.
     */
    public function testNewForm() : void
    {
        $categoryID = self::$client->post(
            array('a' => 'formEditor/new'),
            array(
                'name' => 'Unit Test Form',
                'description' => 'Unit test description',
                'parentID' => '',
            )
        );

        $this->assertNotNull($categoryID);
        $this->assertEquals('form_', substr($categoryID, 0, 5));

        $form = self::$client->get(array('a' => 'form/_' . $categoryID));

        $this->assertNotNull($form);
        $this->assertEquals(0, count($form));
    }

    /**
     * Tests the `formEditor/formDescription` endpoint.
     */
    public function testSetCategoryDescription() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('A Simple Sample Form', $category['categoryDescription']);

        self::$client->post(array('a' => 'formEditor/formDescription'), array(
            'categoryID' => $category['categoryID'],
            'description' => 'Some new Description',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('Some new Description', $category['categoryDescription']);
    }

    /**
     * Tests the `formEditor/formWorkflow` endpoint.
     */
    public function testSetCategoryWorkflow() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('1', $category['workflowID']);

        self::$client->post(array('a' => 'formEditor/formWorkflow'), array(
            'categoryID' => $category['categoryID'],
            'workflowID' => '2',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('2', $category['workflowID']);
    }

    /**
     * Tests the `formEditor/formNeedToKnow` endpoint.
     */
    public function testSetCategoryNeedToKnow() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('0', $category['needToKnow']);

        self::$client->post(array('a' => 'formEditor/formNeedToKnow'), array(
            'categoryID' => $category['categoryID'],
            'needToKnow' => '1',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('1', $category['needToKnow']);
    }

    /**
     * Tests the `formEditor/formSort` endpoint.
     */
    public function testSetCategorySort() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('0', $category['sort']);

        self::$client->post(array('a' => 'formEditor/formSort'), array(
            'categoryID' => $category['categoryID'],
            'sort' => '1',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[2];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('1', $category['sort']);
    }

    /**
     * Tests the `formEditor/formVisible` endpoint.
     */
    public function testSetCategoryVisible() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('1', $category['visible']);

        self::$client->post(array('a' => 'formEditor/formVisible'), array(
            'categoryID' => $category['categoryID'],
            'visible' => '0',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('0', $category['visible']);
    }

    /**
     * Tests the `formEditor/[text]/privileges` endpoint.
     *
     * Tests adding a category group privilege.
     */
    public function testSetCategoryPrivileges_addPriv() : void
    {
        $privs = self::$client->get(array('a' => 'formEditor/_form_f4687/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));

        $priv = $privs[0];

        $this->assertEquals('2', $priv['groupID']);
        $this->assertEquals('form_f4687', $priv['categoryID']);

        self::$client->post(array('a' => 'formEditor/_form_f4687/privileges'), array(
            'groupID' => '3',
            'read' => '1',
            'write' => '1',
        ));

        $privs = self::$client->get(array('a' => 'formEditor/_form_f4687/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(2, count($privs));

        $priv = $privs[1];

        $this->assertEquals('3', $priv['groupID']);
        $this->assertEquals('form_f4687', $priv['categoryID']);
    }

    /**
     * Tests the `formEditor/[text]/stapled` endpoint.
     *
     * Tests add  stapled category
     */
    public function testAddStapledCategory() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('A Simple Sample Form', $category['categoryDescription']);

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[2];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);
        $this->assertEquals('A Staple form', $category['categoryDescription']);

        self::$client->post(array('a' => 'formEditor/_form_f4687/stapled'), array(
          'stapledCategoryID' => $category['categoryID'],
      ));

        $category = self::$client->get(array('a' => 'formEditor/_form_f4687/stapled'))[0];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);
    }

    /**
     * Tests the GET `formEditor/[text]/stapled` endpoint.
     */
    public function testGetStapledCategories() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('A Simple Sample Form', $category['categoryDescription']);

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[2];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);
        $this->assertEquals('A Staple form', $category['categoryDescription']);

        self::$client->post(array('a' => 'formEditor/_form_f4687/stapled'), array(
          'stapledCategoryID' => $category['categoryID'],
      ));

        $category = self::$client->get(array('a' => 'formEditor/_form_f4687/stapled'))[0];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);
    }

    /**
     * Tests the DELETE `formEditor/[text]/stapled/[text]` endpoint.
     */
    public function testRemoveStapledCategory() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('A Simple Sample Form', $category['categoryDescription']);

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[2];

        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);
        $this->assertEquals('A Staple form', $category['categoryDescription']);

        self::$client->post(array('a' => 'formEditor/_form_f4687/stapled'), array(
          'stapledCategoryID' => $category['categoryID'],
      ));

        $category = self::$client->get(array('a' => 'formEditor/_form_f4687/stapled'))[0];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4689', $category['categoryID']);

        $delResponse = self::$client->delete(array('a' => 'formEditor/_form_f4687/stapled/_form_f4689/'));

        $this->assertNotNull($delResponse);
        $this->assertEquals(1, $delResponse);
    }

    /**
     * Tests the `formEditor/[text]/privileges` endpoint.
     *
     * Tests removing a category group privilege.
     */
    public function testSetCategoryPrivileges_removePriv() : void
    {
        $privs = self::$client->get(array('a' => 'formEditor/_form_f4687/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));

        $priv = $privs[0];

        $this->assertEquals('2', $priv['groupID']);
        $this->assertEquals('form_f4687', $priv['categoryID']);

        self::$client->post(array('a' => 'formEditor/_form_f4687/privileges'), array(
            'groupID' => '2',
            'read' => '1',
            'write' => '0',
        ));

        $privs = self::$client->get(array('a' => 'formEditor/_form_f4687/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(0, count($privs));
    }

    /**
     * Tests the `form/indicator/<indicatorID>/privileges` endpoint
     *
     * Tests getting the privileges of an indicator
     */
    public function testIndicatorPrivileges_getPrivileges() : void
    {
        $privs = self::$client->get(array('a' => 'formEditor/indicator/7/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));
        $this->assertEquals(1, $privs[0]['id']);
    }

    /**
     * Tests the `form/indicator/<indicatorID>/privileges` endpoint
     *
     * Tests setting the privileges of an indicator with invalid input
     */
    public function testIndicatorPrivileges_setPrivileges() : void
    {
        $res = self::$client->post(
            array('a' => 'formEditor/indicator/7/privileges'),
            array(
                'groupIDs' => array(2, 3),
            )
        );

        $this->assertNotNull($res);
        $this->assertTrue($res);

        $privs = self::$client->get(array('a' => 'formEditor/indicator/7/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(3, count($privs));
        $this->assertEquals(1, $privs[0]['id']);
        $this->assertEquals(2, $privs[1]['id']);
        $this->assertEquals(3, $privs[2]['id']);
    }

    /**
     * Tests the `form/indicator/<indicatorID>privileges` endpoint
     *
     * Tests removing an indicator privilege.
     */
    public function testIndicatorPrivileges_removePrivilege() : void
    {
        $privs = self::$client->get(array('a' => 'formEditor/indicator/7/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));

        $res = self::$client->post(
            array('a' => 'formEditor/indicator/7/privileges/remove'),
            array(
                'groupID' => 1,
            )
        );

        $privs = self::$client->get(array('a' => 'formEditor/indicator/7/privileges'));

        $this->assertNotNull($privs);
        $this->assertEquals(0, count($privs));
    }

    /**
     * Tests the `form/indicator/<indicatorID>/groups` endpoint
     *
     * Tests setting the privileges of an indicator with invalid input
     */
    public function testIndicatorPrivileges_setPrivileges_invalidInput() : void
    {
        $res = self::$client->post(
            array('a' => 'formEditor/indicator/7/privileges'),
            array(
                'groupIDs' => 'NotAnArray',
            )
        );

        $this->assertNotNull($res);
        $this->assertFalse($res);
    }

    /**
     * Tests the `formEditor/[digit]/formType` endpoint.
     */
    public function testSetFormType() : void
    {
        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('', $category['type']);

        self::$client->post(array('a' => 'formEditor/formType'), array(
            'categoryID' => $category['categoryID'],
            'type' => 'parallel_processing',
        ));

        $category = self::$client->get(array('a' => 'formStack/categoryList/all'))[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('parallel_processing', $category['type']);
    }
}
