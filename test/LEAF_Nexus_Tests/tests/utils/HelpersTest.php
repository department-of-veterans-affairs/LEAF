<?php

declare(strict_types=1);

include "../../LEAF_Nexus/helpers.php";

use PHPUnit\Framework\TestCase;

/**
 * Tests LEAF_Nexus/helpers.php
 */
final class HelpersTest extends TestCase
{
    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests processing line breaks (\n, \r) within the HTML input 
     */
    public function testSanitizeHTML_LineBreaks(): void
    {
        $linebreaks = "text\nwith\nbreaks";
        $linebreaks2 = "text\rwith\rbreaks";
        $linebreaks3 = "text\r\nwith\r\nbreaks";
        $linebreaks4 = "text\n\rwith\n\rbreaks";
        $linebreaks5 = "text\n\nwith\n\nbreaks";
        $linebreaks6 = "<p>text\nwith\nbreaks\nin\nparagraph</p>";

        $expectedOutput = "text<br />with<br />breaks";
        $expectedOutput2 = "text<br /><br />with<br /><br />breaks";
        $expectedOutput3 = "<p>textwithbreaksinparagraph</p>";

        $this->assertEquals($expectedOutput, XSSHelpers::sanitizeHTML($linebreaks));
        $this->assertEquals($expectedOutput, XSSHelpers::sanitizeHTML($linebreaks2));
        $this->assertEquals($expectedOutput, XSSHelpers::sanitizeHTML($linebreaks3));
        $this->assertEquals($expectedOutput, XSSHelpers::sanitizeHTML($linebreaks4));

        $this->assertEquals($expectedOutput2, XSSHelpers::sanitizeHTML($linebreaks5));

        $this->assertEquals($expectedOutput3, XSSHelpers::sanitizeHTML($linebreaks6));
    }

    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests the length of the HTML input
     */
    public function testSanitizeHTML_Length(): void
    {
        $shortStr = str_repeat(".", 12345);
        $maxStr = str_repeat(".", 65535);
        $tooLongStr = str_repeat(".", 70000);

        $this->assertEquals(12345, strlen(XSSHelpers::sanitizeHTML($shortStr)));
        $this->assertEquals(65535, strlen(XSSHelpers::sanitizeHTML($maxStr)));

        // Any string over 65535 should be shortened to 65535
        $this->assertEquals(65535, strlen(XSSHelpers::sanitizeHTML($tooLongStr)));
    }
    
    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests Ordered Lists within the HTML input
     */
    public function testSanitizeHTML_OL(): void
    {
        $str1 = "<ol><li>an</li><li>ordered</li><li>list</li></ol>";
        $out1 = "<ol><li>an</li><li>ordered</li><li>list</li></ol>";

        $this->assertEquals($out1, XSSHelpers::sanitizeHTML($str1));
    }

    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests Tables within the HTML input
     */
    public function testSanitizeHTML_Table(): void
    {
        $str1 = "<table><tr><td></td></tr></table>";
        $out1 = "<table class=\"table\"><tr><td></td></tr></table>";

        $this->assertEquals($out1, XSSHelpers::sanitizeHTML($str1));
    }

    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests formatting tabs (<b><i><u>) within the HTML input
     */
    public function testSanitizeHTML_TextFormatting(): void
    {
        $str1 = "<b>Some <i>formatted</i> <u>text</u>."; // closing </b> left out intentionally 
        $out1 = "<b>Some <i>formatted</i> <u>text</u>.</b>";

        $this->assertEquals($out1, XSSHelpers::sanitizeHTML($str1));
    }

    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests any unclosed element tags within the HTML input
     */
    public function testSanitizeHTML_UnclosedTags(): void
    {
        $str1 = "<table><tr><td><p><b>unclosed<i>tags";
        $out1 = "<table class=\"table\"><tr><td><p><b>unclosed<i>tags</i></b></p></td></tr></table>";

        $str2 = "<table><tr><td>unclosed tr</td></table>";
        $out2 = "<table class=\"table\"><tr><td>unclosed tr</td></tr></table>";

        $this->assertEquals($out1, XSSHelpers::sanitizeHTML($str1));
        $this->assertEquals($out2, XSSHelpers::sanitizeHTML($str2));
    }

    /**
     * Tests XSSHelpers::sanitizeHTML()
     * 
     * Tests Unordered Lists within the HTML input
     */
    public function testSanitizeHTML_UL(): void
    {
        $str1 = "<ul><li>an</li><li>unordered</li><li>list</li></ul>";
        $out1 = "<li>an</li><li>unordered</li><li>list</li>";

        $this->assertEquals($out1, XSSHelpers::sanitizeHTML($str1));
    }

    /**
     * Tests XSSHelpers::xscrub()
     * 
     * Tests escaping HTML tags
     */
    public function testXscrub_tags(): void
    {
        $str1 = "<table><tr><td></td></tr></table>";
        $out1 = "&lt;table&gt;&lt;tr&gt;&lt;td&gt;&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;";

        $this->assertEquals($out1, XSSHelpers::xscrub($str1));
    }

    /**
     * Tests XSSHelpers::xscrub()
     * 
     * Tests escaping HTML tags
     */
    public function testXscrub_InlineJS(): void
    {
        $str1 = "<a onmouseover=\"alert('xss')\">test</a>";
        $out1 = "&lt;a onmouseover=&quot;alert(&#039;xss&#039;)&quot;&gt;test&lt;/a&gt;";

        $this->assertEquals($out1, XSSHelpers::xscrub($str1));
    }
}