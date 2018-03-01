<?php
/**
 * Smarty plugin
 *
 * @package    Smarty
 * @subpackage PluginsModifier
 */

/**
 * Smarty HTML sanitation modifier plugin
 * Type:     modifier<br>
 * Name:     sanitize<br>
 * Purpose:  Simple HTML sanitation, allows some tags for use in rich text editors. 
 * 
 * Allowed tags: <a><b><i><u><ol><li><br><p><table><td><tr>
 *
 * This is an exact copy of LEAF_Request_Portal/sources/XSSHelpers.php sanitizeHTML().
 * TODO: Load XSSHelpers from shared code location, currently Nexus/RequestPortal can be arbitrary paths.  
 * 
 * @author Nathan Sullivan
 *
 * @param string $in    input string
 *
 * @return string
 */
function smarty_modifier_sanitize($in)
{
    // replace linebreaks with <br /> if there's no html <p>'s
    if (strpos($in, '<p>') === false
            && strpos($in, '<table') === false)
    {
        $in = nl2br($in, true);
    }

    // strip out uncommon characters
    $in = preg_replace('/[^\040-\176]/', '', $in);

    // // hard character limit of 65535
    $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;

    $pattern = array('/&lt;table(\s.+)?&gt;/Ui',
                            '/&lt;\/table&gt;/Ui',
                            '/&lt;(\/)?br(\s.+)?\s\/&gt;/Ui',
                            '/&lt;(\/)?(\S+)(\s.+)?&gt;/U', // all other allowed tags
                            '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
                            '/(\<\/p\>\<\/p\>){2,}/',
                            '/(\<p\>\<\/p\>){2,}/',
                            '/\<\/p\>(\s+)?\<br\>(\s+)?\<p\>/U', // scrub line breaks between paragraphs
        );

    $replace = array('<table class="table">',
                            '</table>',
                            '<\1br />',
                            '<\1\2>',
                            '###-##-####',
                            '',
                            '',
                            "</p>\n<p>",
        );

    // $in = html_entity_decode($in);
    $in = html_entity_decode($in, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $in = strip_tags($in, '<a><b><i><u><ol><li><br><p><table><td><tr>');
    $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES));

    // verify tag grammar
    $matches = array();
    preg_match_all('/\<(\/)?([A-Za-z]+)(\s.+)?\>/U', $in, $matches, PREG_PATTERN_ORDER);
    $openTags = array();
    $numTags = count($matches[2]);
    for ($i = 0; $i < $numTags; $i++)
    {
        if ($matches[2][$i] != 'br')
        {
            //echo "examining: {$matches[1][$i]}{$matches[2][$i]}\n";
            // proper closure
            if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] > 0)
            {
                $openTags[$matches[2][$i]]--;
            // echo "proper\n";
            }
            // new open tag
            else
            {
                if ($matches[1][$i] == '')
                {
                    if (!isset($openTags[$matches[2][$i]]))
                    {
                        $openTags[$matches[2][$i]] = 0;
                    }
                    $openTags[$matches[2][$i]]++;
                // echo "open\n";
                }
                // improper closure
                else
                {
                    if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] <= 0)
                    {
                        $in = '<' . $matches[2][$i] . '>' . $in;
                        $openTags[$matches[2][$i]]--;
                        // echo "improper\n";
                    }
                }
            }
            // print_r($openTags);
        }
    }

    // close tags
    $tags = array_reverse(array_keys($openTags));
    foreach ($tags as $tag)
    {
        while ($openTags[$tag] > 0)
        {
            $in = $in . '</' . $tag . '>';
            $openTags[$tag]--;
        }
    }

    return $in;
}
