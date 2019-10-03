<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

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
        //get current forms
        $forms = self::$client->get(array('a' => 'formStack/categoryList/all'));
        $oldForms = array();
        foreach($forms as $key => $val)
        {
            $oldForms[] = $val['categoryID'];
        }

        //create a form with no user input needed
        self::$client->post(array('a' => 'formEditor/new'));
        $forms = self::$client->get(array('a' => 'formStack/categoryList/all'));
        
        for($i=0; $i<sizeof($forms); $i++)
        {
            if(!in_array($forms[$i]['categoryID'], $oldForms))
            {
                $newCategoryID = $forms[$i]['categoryID'];
            }
        }
        $this->assertNotNull($newCategoryID);

        //fill values
        $vars = array('name' => 'test', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formName'), $vars);

        $vars = array('description' => '', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formDescription'), $vars);

        $vars = array('workflowID' => '1', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formWorkflow'), $vars);

        $vars = array('needToKnow' => '0', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formNeedToKnow'), $vars);

        $vars = array('sort' => '0', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formSort'), $vars);

        $vars = array('visible' => '1', 'categoryID' => $newCategoryID);
        self::$client->post(array('a' => 'formEditor/formVisible'), $vars);

        $vars = array('name' => '',
            'format' => '',
            'description' => '',
            'default' => '',
            'parentID' => '',
            'required' => '0',
            'categoryID' => $newCategoryID, );

        self::$client->post(array('a' => 'formEditor/newIndicator'), $vars);


        //fix workflow
        $response = self::$client->post(array('a' => 'workflow/1/initialStep'), array('stepID' => 1));
        self::$client->post(array('a' => 'workflow/step/1/dependencies'), array('dependencyID' => '5'));
        //create a new request with the generated indicator
        $vars = array('title' => 'test',
                        'num' . $newCategoryID => 1, );

        $result = self::$client->post(array('a' => 'form/new'), $vars);

        //checks to make sure the request creation was successful
        $this->assertNotNull($result);
        $this->assertEquals(2, $result);

        //submits the form
        self::$client->post(array('a' => 'form/2/submit'), array());

        //applies action type
        $vars = array('dependencyID' => '5',
            'actionType' => '6',
            'comment' => 'test', );

        $result = self::$client->post(array('a' => 'formWorkflow/2/apply'), $vars);

        //process finished with no errors
        $this->assertEquals('1', $result['status']);
        $this->assertEquals(0, count($result['errors']));
    }

    public function testSetStep() : void
    {
        $vars = array('stepID' => 1,
                    'comment' => 'TESTSTEP', );

        $result = self::$client->post(array('a' => 'formWorkflow/1/step'), $vars, '');

        //if true, setStep method executed successfully
        $this->assertTrue($result);
    }
}
