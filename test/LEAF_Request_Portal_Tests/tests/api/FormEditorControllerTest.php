<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

final class FormEditorControllerTest extends DatabaseTest
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
     * Tests the GET `formEditor/version` endpoint.
     */
    public function testGetVersion() : void
    {
        $version = self::$client->get('?a=formEditor/version');
        $this->assertEquals(1, $version);
    }

    /**
     * Tests the GET `formEditor/indicator/[digit]` endpoint.
     */
    public function testGetIndicator() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $ind = $indicator["6"];
        $this->assertEquals("6", $ind['indicatorID']);
        $this->assertEquals(1, $ind['series']);
        $this->assertEquals("Favorite Day", $ind['name']);
        $this->assertEquals("favorite day", $ind['description']);
        $this->assertEquals("", $ind['default']);
        $this->assertEquals(null, $ind['parentID']);
        $this->assertEquals(null, $ind['html']);
        $this->assertEquals(null, $ind['htmlPrint']);
        $this->assertEquals("1", $ind['required']);
        $this->assertEquals(true, $ind['isEmpty']);
        $this->assertEquals("", $ind['value']);
        $this->assertEquals("", $ind['displayedValue']);
        $this->assertEquals(0, $ind['timestamp']);
        $this->assertEquals(1, $ind['isWritable']);
        $this->assertEquals(0, $ind['isMasked']);
        $this->assertEquals("1", $ind['sort']);
        $this->assertEquals("date", $ind['format']);
        $this->assertEquals(null, $ind['child']);
    }

    /**
     * Tests the GET `formEditor/indicator/[digit]` endpoint.
     *
     * Tests for nonexistent indicator
     */
    public function testGetIndicator_nonexistentIndicator() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/7');

        $this->assertNotNull($indicator);
        $ind = $indicator[""];
        $this->assertEquals(null, $ind['indicatorID']);
        $this->assertEquals(1, $ind['series']);
        $this->assertEquals(null, $ind['name']);
        $this->assertEquals(null, $ind['description']);
        $this->assertEquals(null, $ind['default']);
        $this->assertEquals(null, $ind['parentID']);
        $this->assertEquals(null, $ind['html']);
        $this->assertEquals(null, $ind['htmlPrint']);
        $this->assertEquals(null, $ind['required']);
        $this->assertEquals(true, $ind['isEmpty']);
        $this->assertEquals(null, $ind['value']);
        $this->assertEquals("", $ind['displayedValue']);
        $this->assertEquals(0, $ind['timestamp']);
        $this->assertEquals(1, $ind['isWritable']);
        $this->assertEquals(0, $ind['isMasked']);
        $this->assertEquals(null, $ind['sort']);
        $this->assertEquals("", $ind['format']);
        $this->assertEquals(null, $ind['child']);
    }

    public function testGetIndicator_nondigitParam() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/nondigit');
        $this->assertEquals("Controller is undefined.", $indicator);
    }

    /**
     * Tests the GET `formEditor/[text]/privileges
     */
    public function testGetCategoryPrivileges() : void
    {
        $privs = self::$client->get('?a=formEditor/_form_f4687/privileges');

        $this->assertNotNull($privs);
        $this->assertEquals("2", $privs[0]['groupID']);
        $this->assertEquals("form_f4687", $privs[0]['categoryID']);
        $this->assertEquals("1", $privs[0]['readable']);
        $this->assertEquals("1", $privs[0]['writable']);
        $this->assertEquals(null, $privs[0]['parentGroupID']);
        $this->assertEquals("Test Group", $privs[0]['name']);
        $this->assertEquals("A Group for Testing", $privs[0]['groupDescription']);
    }

    /**
     * Tests the `formEditor/newIndicator` endpoint
     */
    public function testNewIndicator() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/7');

        // returns an empty "null" indicator
        $this->assertNotNull($indicator);
        $this->assertNull($indicator[""]['indicatorID']);

        $newIndicator = array(
            "name" => "NEWTESTINDICATOR",
            "format" => "text",
            "description" => "NEWTESTINDICATORDESCRIPTION",
            "default" => "",
            "parentID" => "",
            "categoryID" => "form_f4687",
            "html" => null,
            "htmlPrint" => null,
            "required" => 0,
            "sort" => 1
        );

        self::$client->postEncodedForm('?a=formEditor/newIndicator', $newIndicator);

        $indicator = self::$client->get('?a=formEditor/indicator/7');

        $this->assertNotNull($indicator);
        $this->assertEquals("7", $indicator["7"]['indicatorID']);
        $this->assertEquals($newIndicator['name'], $indicator["7"]['name']);
        $this->assertEquals($newIndicator['format'], $indicator["7"]['format']);
        $this->assertEquals($newIndicator['description'], $indicator["7"]['description']);
        $this->assertEquals($newIndicator['default'], $indicator["7"]['default']);
        $this->assertEquals(null, $indicator["7"]['parentID']);
        $this->assertEquals(null, $indicator["7"]['html']);
        $this->assertEquals(null, $indicator["7"]['htmlPrint']);
        $this->assertEquals(0, $indicator["7"]['required']);
        $this->assertEquals(1, $indicator["7"]['sort']);
    }

    /**
     * Tests the `formEditor/newIndicator` endpoint
     * 
     * Tests input that contains HTML.
     */
    public function testNewIndicator_HTMLinput() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/7');

        // returns an empty "null" indicator
        $this->assertNotNull($indicator);
        $this->assertNull($indicator[""]['indicatorID']);

        $newIndicator = array(
            "name" => "<script lang='javascript'>alert('hi')</script><b>NEWTESTINDICATOR</b>",
            "format" => "<script lang='javascript'>alert('hi')</script>text",
            "description" => "<strong>NEWTESTINDICATORDESCRIPTION</strong>",
            "default" => "",
            "parentID" => "",
            "categoryID" => "form_f4687",
            "html" => "<script lang='javascript'>alert('hi')</script><b>the html</b>",
            "htmlPrint" => "<script lang='javascript'>alert('hi')</script><b>the html</b>",
            "required" => 0,
            "sort" => 1
        );

        self::$client->postEncodedForm('?a=formEditor/newIndicator', $newIndicator);

        $indicator = self::$client->get('?a=formEditor/indicator/7');

        $this->assertNotNull($indicator);
        $this->assertEquals("7", $indicator["7"]['indicatorID']);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>NEWTESTINDICATOR</b>", $indicator["7"]['name']);
        $this->assertEquals("alert('hi')text", $indicator["7"]['format']);
        $this->assertEquals("&lt;strong&gt;NEWTESTINDICATORDESCRIPTION&lt;/stro", $indicator["7"]['description']);
        $this->assertEquals($newIndicator['default'], $indicator["7"]['default']);
        $this->assertEquals(null, $indicator["7"]['parentID']);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>the html</b>", $indicator["7"]['html']);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>the html</b>", $indicator["7"]['htmlPrint']);
        $this->assertEquals(0, $indicator["7"]['required']);
        $this->assertEquals(1, $indicator["7"]['sort']);
    }

    /**
     * Tests the `formEditor/formName` endpoint.
     */
    public function testSetFormName() : void
    {
        $form = self::$client->get('?a=form/1');

        $this->assertNotNull($form);
        $this->assertEquals("Sample Form", $form['items'][0]['name']);

        $result = self::$client->postEncodedForm(
            '?a=formEditor/formName',
            [
                "categoryID" => "form_f4687",
                "name" => "Test Form"
            ]
        );

        $form = self::$client->get('?a=form/1');

        $this->assertNotNull($form);
        $this->assertEquals("Test Form", $form['items'][0]['name']);
    }

    /**
     * Tests the `formEditor/[digit]/name` endpoint.
     */
    public function testSetIndicatorName() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("Favorite Day", $indicator["6"]["name"]);

        self::$client->postEncodedForm('?a=formEditor/6/name', ["name" => "New Indicator Name"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("New Indicator Name", $indicator["6"]["name"]);
    }

    /**
     * Tests the `formEditor/[digit]/name` endpoint.
     * 
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorName_HTMLinput() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("Favorite Day", $indicator["6"]["name"]);

        self::$client->postEncodedForm('?a=formEditor/6/name', [
            "name" => "<script lang='javascript'>alert('hi')</script><b>new name</b>"
        ]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>new name</b>", $indicator["6"]["name"]);
    }

    /**
     * Tests the `formEditor/[digit]/format` endpoint.
     */
    public function testSetIndicatorFormat() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("date", $indicator["6"]["format"]);

        self::$client->postEncodedForm('?a=formEditor/6/format', ["format" => "text"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("text", $indicator["6"]["format"]);
    }

    /**
     * Tests the `formEditor/[digit]/format` endpoint.
     * 
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorFormat_HTMLinput() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("date", $indicator["6"]["format"]);

        self::$client->postEncodedForm('?a=formEditor/6/format', [
            "format" => "<script lang='javascript'>alert('hi')</script>text"
        ]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("alert('hi')text", $indicator["6"]["format"]);
    }

    /**
     * Tests the `formEditor/[digit]/description` endpoint.
     */
    public function testSetIndicatorDescription() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("favorite day", $indicator["6"]["description"]);

        self::$client->postEncodedForm('?a=formEditor/6/description', ["description" => "a changed description"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("a changed description", $indicator["6"]["description"]);
    }

    /**
     * Tests the `formEditor/[digit]/description` endpoint.
     * 
     * Tests the endpoint with input containing HTML.
     */
    public function testSetIndicatorDescription_HTMLinput() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("favorite day", $indicator["6"]["description"]);

        self::$client->postEncodedForm('?a=formEditor/6/description', [
            "description" => "<script lang='javascript'>alert('hi')</script><b>stuff</b>"
        ]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#", $indicator["6"]["description"]);
    }

    /**
     * Tests the `formEditor/[digit]/default` endpoint.
     */
    public function testSetIndicatorDefault() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("", $indicator["6"]["default"]);

        self::$client->postEncodedForm('?a=formEditor/6/default', ["default" => "some default"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("some default", $indicator["6"]["default"]);
    }

    /**
     * Tests the `formEditor/[digit]/default` endpoint.
     */
    public function testSetIndicatorDefault_HTMLinput() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("", $indicator["6"]["default"]);

        self::$client->postEncodedForm('?a=formEditor/6/default', [
            "default" => "<script lang='javascript'>alert('hi')</script><b>stuff</b>"
        ]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("&lt;script lang=&#039;javascript&#039;&gt;alert(&#039;hi&#039;)&lt;/script&gt;<b>stuff</b>", $indicator["6"]["default"]);
    }

    /**
     * Tests the `formEditor/[digit]/parentID` endpoint.
     */
    public function testSetIndicatorParentID() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator["6"]["parentID"]);

        self::$client->postEncodedForm('?a=formEditor/6/parentID', ["parentID" => 7]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals(7, $indicator["6"]["parentID"]);
    }

    /**
     * Tests the `formEditor/[digit]/required` endpoint.
     */
    public function testSetIndicatorRequired() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("1", $indicator["6"]["required"]);

        self::$client->postEncodedForm('?a=formEditor/6/required', ["required" => "0"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("0", $indicator["6"]["required"]);
    }

    /**
     * Tests the `formEditor/[digit]/disabled` endpoint.
     */
    public function testSetIndicatorDisabled() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("Favorite Day", $indicator["6"]["name"]);

        self::$client->postEncodedForm('?a=formEditor/6/disabled', ["disabled" => "1"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator[""]["indicatorID"]);
    }

    /**
     * Tests the `formEditor/[digit]/sort` endpoint.
     */
    public function testSetIndicatorSort() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("1", $indicator["6"]["sort"]);

        self::$client->postEncodedForm('?a=formEditor/6/sort', ["sort" => "0"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("0", $indicator["6"]["sort"]);
    }

    /**
     * Tests the `formEditor/[digit]/html` endpoint.
     */
    public function testSetIndicatorHTML() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator["6"]["html"]);

        self::$client->postEncodedForm('?a=formEditor/6/html', ["html" => "<strong>html</strong>"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("&lt;strong&gt;html&lt;/strong&gt;", $indicator["6"]["html"]);
    }

    /**
     * Tests the `formEditor/[digit]/htmlPrint` endpoint.
     */
    public function testSetIndicatorHTMLPrint() : void
    {
        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals(null, $indicator["6"]["htmlPrint"]);

        self::$client->postEncodedForm('?a=formEditor/6/htmlPrint', ["htmlPrint" => "<b>html</b>"]);

        $indicator = self::$client->get('?a=formEditor/indicator/6');

        $this->assertNotNull($indicator);
        $this->assertEquals("<b>html</b>", $indicator["6"]["htmlPrint"]);
    }

    /**
     * Tests the `formEditor/new` endpoint.
     */
    public function testNewForm() : void
    {
        $categoryID = self::$client->postEncodedForm(
            '?a=formEditor/new',
            [
                "name" => "Unit Test Form",
                "description" => "Unit test description",
                "parentID" => ""
            ]
        );

        $this->assertNotNull($categoryID);
        $this->assertEquals("form_", substr($categoryID, 0, 5));

        $form = self::$client->get('?a=form/_'.$categoryID);

        $this->assertNotNull($form);
        $this->assertEquals(0, count($form));
    }

    /**
     * Tests the `formEditor/formDescription` endpoint.
     */
    public function testSetCategoryDescription() : void
    {
        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('A Simple Sample Form', $category['categoryDescription']);

        self::$client->postEncodedForm('?a=formEditor/formDescription', [
            'categoryID' => $category['categoryID'],
            'description' => 'Some new Description'
        ]);

        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals('Some new Description', $category['categoryDescription']);
    }

    /**
     * Tests the `formEditor/formWorkflow` endpoint.
     */
    public function testSetCategoryWorkflow() : void
    {
        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("1", $category['workflowID']);

        self::$client->postEncodedForm('?a=formEditor/formWorkflow', [
            'categoryID' => $category['categoryID'],
            'workflowID' => '2'
        ]);

        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("2", $category['workflowID']);
    }

    /**
     * Tests the `formEditor/formNeedToKnow` endpoint.
     */
    public function testSetCategoryNeedToKnow() : void
    {
        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("0", $category['needToKnow']);

        self::$client->postEncodedForm('?a=formEditor/formNeedToKnow', [
            'categoryID' => $category['categoryID'],
            'needToKnow' => '1'
        ]);

        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("1", $category['needToKnow']);
    }

    /**
     * Tests the `formEditor/formSort` endpoint.
     */
    public function testSetCategorySort() : void
    {
        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("0", $category['sort']);

        self::$client->postEncodedForm('?a=formEditor/formSort', [
            'categoryID' => $category['categoryID'],
            'sort' => '1'
        ]);

        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("1", $category['sort']);
    }

    /**
     * Tests the `formEditor/formVisible` endpoint.
     */
    public function testSetCategoryVisible() : void
    {
        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("1", $category['visible']);

        self::$client->postEncodedForm('?a=formEditor/formVisible', [
            'categoryID' => $category['categoryID'],
            'visible' => '0'
        ]);

        $category = self::$client->get('?a=formStack/categoryList/all')[1];
        $this->assertNotNull($category);
        $this->assertEquals('form_f4687', $category['categoryID']);
        $this->assertEquals("0", $category['visible']);
    }

    /**
     * Tests the `formEditor/[text]/privileges` endpoint.
     * 
     * Tests adding a category group privilege.
     */
    public function testSetCategoryPrivileges_addPriv() : void
    {
        $privs = self::$client->get('?a=formEditor/_form_f4687/privileges');

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));

        $priv = $privs[0];

        $this->assertEquals("2", $priv['groupID']);
        $this->assertEquals("form_f4687", $priv['categoryID']);

        self::$client->postEncodedForm('?a=formEditor/_form_f4687/privileges', [
            "groupID" => "3",
            "read" => "1",
            "write" => "1"
        ]);

        $privs = self::$client->get('?a=formEditor/_form_f4687/privileges');

        $this->assertNotNull($privs);
        $this->assertEquals(2, count($privs));

        $priv = $privs[1];

        $this->assertEquals("3", $priv["groupID"]);
        $this->assertEquals("form_f4687", $priv['categoryID']);
    }

    /**
     * Tests the `formEditor/[text]/privileges` endpoint.
     * 
     * Tests removing a category group privilege.
     */
    public function testSetCategoryPrivileges_removePriv() : void
    {
        $privs = self::$client->get('?a=formEditor/_form_f4687/privileges');

        $this->assertNotNull($privs);
        $this->assertEquals(1, count($privs));

        $priv = $privs[0];

        $this->assertEquals("2", $priv['groupID']);
        $this->assertEquals("form_f4687", $priv['categoryID']);

        self::$client->postEncodedForm('?a=formEditor/_form_f4687/privileges', [
            "groupID" => "2",
            "read" => "1",
            "write" => "0"
        ]);

        $privs = self::$client->get('?a=formEditor/_form_f4687/privileges');

        $this->assertNotNull($privs);
        $this->assertEquals(0, count($privs));
    }
}
