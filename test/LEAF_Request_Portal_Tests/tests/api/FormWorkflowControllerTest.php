<?php

declare(strict_types = 1);

use LEAFTest\LEAFClient;

/**
 * Tests LEAF_Request_Portal/api/?a=form API
 */
final class FormWorkflowControllerTest extends DatabaseTest
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
     * Tests the `formWorkflow/[digit]/apply` endpoint.
     */
    public function testFormWorkflow() : void
    {
        //create a form with no user input needed
        self::$client->postEncodedForm('formEditor/new', array());
        $forms = self::$client->get('formStack/categoryList/all');
        $newCategoryID = $forms[0]['categoryID'];
        $this->assertNotNull($newCategoryID);
        $vars = array('name' => 'test', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formName', $vars);

        $vars = array('description' => '', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formDescription', $vars);

        $vars = array('workflowID' => '1', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formWorkflow', $vars);

        $vars = array('needToKnow' => '0', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formNeedToKnow', $vars);

        $vars = array('sort' => '0', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formSort', $vars);

        $vars = array('visible' => '1', 'categoryID' => $newCategoryID);
        self::$client->postEncodedForm('formEditor/formVisible', $vars);

        $vars = array('name' => '',
            'format' => '',
            'description' => '',
            'default' => '',
            'parentID' => '',
            'required' => '0',
            'categoryID' => $newCategoryID);

        self::$client->postEncodedForm('formEditor/newIndicator', $vars);

        //create a new request with the generated indicator
        $vars = array('title' => "test",
                        'num'.$newCategoryID => 1);
        $result = self::$client->postEncodedForm('form/new', $vars);

        //checks to make sure the request creation was successful
        $this->assertNotNull($result);
        $this->assertEquals(2, $result);

        //submits the form
        self::$client->postEncodedForm('form/2/submit', array());

        //applies action type
        $vars = array('dependencyID' => '5',
            'actionType' => '6',
            'comment' => 'test');
        $result = self::$client->postEncodedForm('formWorkflow/2/apply', $vars);

        //process finished with no errors
        $this->assertEquals('1', $result['status']);
        $this->assertEquals(0 , count($result['errors']));
    }

    public function testSetStep() : void
    {
        $vars = array('stepID' => 1,
                    'comment' => 'TESTSTEP');
        $result = self::$client->postEncodedForm('formWorkflow/1/step', $vars);

        //if true, setStep method executed successfully
        $this->assertTrue($result);
    }
}
