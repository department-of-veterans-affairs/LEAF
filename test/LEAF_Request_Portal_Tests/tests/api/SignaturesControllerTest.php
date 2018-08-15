<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use LEAFTest\LEAFClient;

include '../../LEAF_Request_Portal/db_config.php';
include '../../LEAF_Request_Portal/db_mysql.php';

/**
 * Tests LEAF_Request_Portal/api/?a=signature API
 */
final class SignaturesControllerTest extends DatabaseTest
{
    private static $client = null;

    private static $db = null;

    public static function setUpBeforeClass()
    {
        $db_config = new DB_Config();
        self::$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        self::$client = LEAFClient::createRequestPortalClient();
    }

    protected function setUp()
    {
        $this->resetDatabase();
    }

    /**
     * Tests the `signature/create` endpoint
     */
    public function testCreateSignature_n() : void
    {
        $action = array('a' => 'signature/create');

        $testCases = array(
            '' => '',
            'TESTSIGNATURE' => 'TESTSIGNATURE',
            'TESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURE'=> 'TESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURETESTSIGNATURE',
            "TEST'S SIGNITURE" => "TEST&#039;S SIGNITURE",
            'SIGNITURE "SIGNITURE" SIGNITURE' => 'SIGNITURE &quot;SIGNITURE&quot; SIGNITURE',
            'SIGNITURE > SIGNITURE' => 'SIGNITURE &gt; SIGNITURE',
            'SIGNITURE < SIGNITURE' => 'SIGNITURE &lt; SIGNITURE',
            ' ' => ' ',
            '  ' => '  ',
            '    ' => '    ',
            0 => '0',
            123456789 => '123456789',
        );

        $id = 1;
        $recordID = 10;
        foreach ($testCases as $unsanitized => $sanitized)
        {
            $testPost = array(
                'signature' => $unsanitized,
                'recordID' => $recordID,
                'message' => $unsanitized,
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame($sanitized, $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame($sanitized, $res[0]['message']);
            $id++;
            $recordID++;
        }
    }

    /**
     * Tests the `signature/create` endpoint.
     */
    public function testCreateSignature_HTMLinput() : void
    {
        //tags that are sanitized or otherwise more complex than <TAG></TAG>
        $complexTags = array(
            '<script>Testing</script>' => '&lt;script&gt;Testing&lt;/script&gt;',
            "<a href='google.com'>T</a>" => '&lt;a href=&#039;google.com&#039;&gt;T&lt;/a&gt;',
            '<h1>Testing</h1>' => '&lt;h1&gt;Testing&lt;/h1&gt;',
            '<h2>Testing</h2>' => '&lt;h2&gt;Testing&lt;/h2&gt;',
            '<h3>Testing</h3>' => '&lt;h3&gt;Testing&lt;/h3&gt;',
            '<h4>Testing</h4>' => '&lt;h4&gt;Testing&lt;/h4&gt;',
            '<img>Testing</img>' => '&lt;img&gt;Testing&lt;/img&gt;',
            '<col>Testing</col>' => '&lt;col&gt;Testing&lt;/col&gt;',
            'Over<br />Under' => 'Over<br />Under',
            '<font color="red">Testing</font>' => '&lt;font color=&quot;red&quot;&gt;Testing&lt;/font&gt;',
            '<table>Test</table>' => '<table class="table">Test</table>',
            '<span>Testing</span>' => '&lt;span&gt;Testing&lt;/span&gt;'
        );

        //tags that conform to <TAG></TAG>
        $simpleTags = array(
            'b',
            'i',
            'u',
            'ol',
            'ul',
            'li',
            'p',
            'strong',
            'em',
            'td',
            'tr',
            'thead',
            'tbody',
        );

        $id = 1;
        $recordID = 10;
        foreach ($complexTags as $unsanitized => $sanitized)
        {
            $testPost = array(
                'signature' => $unsanitized,
                'recordID' => $recordID,
                'message' => $unsanitized,
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame($sanitized, $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame($sanitized, $res[0]['message']);
            $id++;
            $recordID++;
        }

        foreach ($simpleTags as $tag)
        {
            $testPost = array(
                'signature' => "<$tag>Testing</$tag>",
                'recordID' => $recordID,
                'message' => "<$tag>Testing</$tag>",
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame("<$tag>Testing</$tag>", $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame("<$tag>Testing</$tag>", $res[0]['message']);
            $id++;
            $recordID++;
        }

        foreach ($simpleTags as $tag)
        {
            $testPost = array(
                'signature' => "<$tag>Testing",
                'recordID' => "$recordID",
                'message' => "<$tag>Testing",
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame("<$tag>Testing</$tag>", $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame("<$tag>Testing</$tag>", $res[0]['message']);
            $id++;
            $recordID++;
        }

        foreach ($simpleTags as $tag)
        {
            $testPost = array(
                'signature' => "Testing</$tag>",
                'recordID' => $recordID,
                'message' => "Testing</$tag>",
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame("Testing</$tag>", $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame("Testing</$tag>", $res[0]['message']);
            $id++;
            $recordID++;
        }

        foreach ($simpleTags as $tag)
        {
            $testPost = array(
                'signature' => "<$tag>New Testing",
                'recordID' => $recordID,
                'message' => "<$tag>New Testing",
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame("<$tag>New Testing</$tag>", $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame("<$tag>New Testing</$tag>", $res[0]['message']);
            $id++;
            $recordID++;
        }

        foreach ($simpleTags as $tag)
        {
            $testPost = array(
                'signature' => "New Testing</$tag>",
                'recordID' => $recordID,
                'message' => "New Testing</$tag>",
            );

            $res = self::$client->postEncodedForm('?a=signature/create', $testPost);
            $this->assertNotNull($res);
            $this->assertSame("$id", $res);
            $res = self::$db->query("SELECT * FROM signatures WHERE recordID = $recordID");
            $this->assertTrue(array_key_exists(0, $res));
            $this->assertSame("$id", $res[0]['id']);
            $this->assertSame("New Testing</$tag>", $res[0]['signature']);
            $this->assertSame("$recordID", $res[0]['recordID']);
            $this->assertSame("New Testing</$tag>", $res[0]['message']);
            $id++;
            $recordID++;
        }
    }
}
