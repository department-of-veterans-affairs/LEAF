<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

final class WorkflowControllerTest extends DatabaseTest
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
     * Tests the GET `workflow/version` endpoint.
     */
    public function testGetVersion() : void
    {
        $version = self::$client->get(array('a' => 'workflow/version'));
        $this->assertEquals(1, $version);
    }

    /**
     * Tests the POST `workflow/new` endpoint.
     */
    public function testNewWorkflow() : void
    {
        $response = self::$client->post(array('a' => 'workflow/new'), array('description' => 'A test Workflow'), '');

        $this->assertNotNull($response);
        $this->assertEquals('3', $response);
    }

    /**
     * Tests the POST `workflow/[digit]/editorPosition` endpoint.
     */
    public function testSetEditorPosition() : void
    {
        $data = array(
        'stepID' => 1,
        'x' => 270,
        'y' => 301,
      );
        $response = self::$client->post(array('a' => 'workflow/1/editorPosition'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/[digit]/step` endpoint.
     */
    public function testCreateStep() : void
    {
        $data = array(
        'stepTitle' => 'test step',
        'stepBgColor' => '#fffdcd',
        'stepFontColor' => '1px solid black',
      );

        $response = self::$client->post(array('a' => 'workflow/1/step/'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(0, $response);
    }

    /**
     * Tests the POST `workflow/[digit]/initialStep` endpoint.
     */
    public function testSetInitialStep() : void
    {
        $data = array(
        'initialStepID' => 2,
      );

        $response = self::$client->post(array('a' => 'workflow/1/initialStep'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/step/[digit]` endpoint.
     */
    public function testUpdateStep() : void
    {
        $data = array(
        'title' => 'Updated title',
      );

        $response = self::$client->post(array('a' => 'workflow/step/1'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/step/[digit]/dependencies` endpoint.
     */
    public function testLinkDependency() : void
    {
        $data = array(
        'dependencyID' => 8,
      );

        $response = self::$client->post(array('a' => 'workflow/step/1/dependencies'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/dependency/[digit]` endpoint.
     */
    public function testUpdateDependency() : void
    {
        $data = array(
        'description' => 'Updated Dependency Title',
      );

        $response = self::$client->post(array('a' => 'workflow/dependency/8'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/dependency/[digit]/privileges` endpoint.
     */
    public function testGrantDependencyPrivs() : void
    {
        $data = array(
        'groupID' => 3,
      );

        $response = self::$client->post(array('a' => 'workflow/dependency/8/privileges'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/[digit]/step/[digit]/[text]/events` endpoint.
     */
    public function testLinkEvent() : void
    {
        $data = array(
        'eventID' => 'std_email_notify_completed',
      );

        $response = self::$client->post(array('a' => 'workflow/1/step/1/_approve/events'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the POST `workflow/dependencies` endpoint.
     */
    public function testAddDependency() : void
    {
        $data = array(
        'description' => 'Test Dependency',
      );

        $response = self::$client->post(array('a' => 'workflow/dependencies'), $data);

        $this->assertNotNull($response);
        $this->assertEquals(9, $response);
    }

    /**
     * Tests the DELETE `workflow/step/[digit]/dependencies` endpoint.
     */
    public function testUnlinkDependency() : void
    {
        $data = array(
        'dependencyID' => 8,
      );

        $response = self::$client->post(array('a' => 'workflow/step/1/dependencies'), $data);
        $this->assertNotNull($response);
        $this->assertEquals(true, $response);

        $delResponse = self::$client->Delete(array('a' => 'workflow/step/1/dependencies', 'dependencyID' => '8'));

        $this->assertNotNull($delResponse);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the DELETE `workflow/[digit]/step/[digit]/[text]/events` endpoint.
     */
    public function testUnlinkEvent() : void
    {
        $data = array(
        'eventID' => 'std_email_notify_completed',
      );

        $response = self::$client->post(array('a' => 'workflow/1/step/1/_approve/events'), $data);
        $this->assertNotNull($response);
        $this->assertEquals(true, $response);

        $event_id = self::$client->get(array('a' => 'workflow/1/step/1/_approve/events'));

        $delResponse = self::$client->Delete(array('a' => 'workflow/1/step/1/_approve/events', 'eventID' => $event_id[0]['eventID']));

        $this->assertNotNull($delResponse);
        $this->assertEquals(true, $response);
    }

    /**
     * Tests the `workflow/action[Text]` GET endpoint.
     */
    public function testGetAction() : void
    {
      //create new action
      $newAction = array(
          'actionText' => 'Active',
          'actionTextPasttense' => 'Activated',
          'actionIcon' => 'active.svg',
          'actionAlignment' => 'left',
          'fillDependency' => '-1',);

      $results = self::$client->post(array('a' => '?a=system/actions'), $newAction);

      $this->assertNull($results);
      $this->assertEquals('', $results);

      $action = self::$client->get(array('a' => 'workflow/action/_Active'));
      $check = isset($action[0]) ? $action[0] : null;
      if ($check !== null){
        $this->assertNotNull($action);
        $this->assertEquals('Active', $action[0]['actionType']);
      }
    }

    /**
     * Tests the `workflow/editAction/[text]` POST endpoint.
     */
    public function testEditAction() : void
    {
      $editAction = array(
          'actionText' => 'Active',
          'actionTextPasttense' => 'Activated',
          'actionIcon' => 'active.svg',
          'actionAlignment' => 'left',
          'fillDependency' => '-1',);

      $results = self::$client->post(array('a' => '?a=system/actions'), $editAction);

      $this->assertNull($results);
      $this->assertEquals('', $results);

      $results = self::$client->post(array('a' => 'workflow/editAction/_Active'), array(
          'actionText' => 'Test',
          'actionTextPasttense' => 'Tested',
          'actionIcon' => 'active.svg',
          'actionAlignment' => 'left',
          'fillDependency' => '-1',
      ));

      $this->assertNotNull($results);
      $this->assertEquals(1, $results);

      $action = self::$client->get(array('a' => 'workflow/action/_Test'));
      $check = isset($action[0]) ? $action[0] : null;
      if ($check !== null){
        $this->assertNotNull($action);
        $this->assertEquals('Test', $action[0]['actionText']);
      }
    }

    /**
     * Tests the `workflow/action/[text]` DELETE endpoint.
     */
    public function testRemoveAction() : void
    {
      $results = self::$client->post(array('a' => '?a=system/actions'), array(
          'actionText' => 'Active',
          'actionTextPasttense' => 'Activated',
          'actionIcon' => 'active.svg',
          'actionAlignment' => 'left',
          'fillDependency' => '-1'
      ));

      $check = isset($results[0]) ? $results[0] : null;
      if ($check !== null){
        $this->assertNotNull($results);
        $this->assertEquals(1, $results);
      }

      $delRes = self::$client->delete(array('a' => 'workflow/action/_active'));
      $this->assertNotNull($delRes);
      $this->assertEquals(1, $delRes);
    }
}
