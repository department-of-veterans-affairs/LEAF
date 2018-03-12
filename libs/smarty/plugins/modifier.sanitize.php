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
 * This is a copy of LEAF_Request_Portal/sources/XSSHelpers.php sanitizeHTML().
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
    $allowedTags = ['b', 'i', 'u', 'ol', 'li', 'br', 'p', 'table', 'td', 'tr'];
    $specialPattern = [
        '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
        '/(\<\/p\>\<\/p\>){2,}/', // flatten extra <p>
        '/(\<p\>\<\/p\>){2,}/', // flatten extra <p>
        '/\<\/p\>(\s+)?\<br\>(\s+)?\<p\>/U' // scrub line breaks between paragraphs
    ];
    $specialReplace = [
        '###-##-####',
        '',
        '',
        "</p>\n<p>"
    ];
    
    // replace linebreaks with <br /> if there's no html <p>'s
    if(strpos($in, '<p>') === false
        && strpos($in, '<table') === false) {
            $in = nl2br($in, true);
    }
    
    // strip out uncommon characters
    $in = preg_replace('/[^\040-\176]/', '', $in);
    
    // hard character limit of 65535
    $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;
    
    $pattern = [];
    $replace = [];
    foreach($allowedTags as $tag) {
        switch($tag) {
            case 'table':
                $pattern[] = '/&lt;table(\s.+)?&gt;/Ui';
                $replace[] = '<table class="table">';
                $pattern[] = '/&lt;\/table&gt;/Ui';
                $replace[] = '</table>';
                break;
            case 'a':
                $pattern[] = '/&lt;a href=&quot;(?!javascript)(\S+)&quot;(\s.+)?&gt;/Ui';
                $replace[] = '<a href="\1" target="_blank">';
                $pattern[] = '/&lt;\/a&gt;/Ui';
                $replace[] = '</a>';
                break;
            case 'span':
                $pattern[] = '/&lt;span style=&quot;(\S.+)&quot;(\s.+)?&gt;/Ui';
                $replace[] = '<span style="\1">';
                $pattern[] = '/&lt;\/span&gt;/Ui';
                $replace[] = '</span>';
                break;
            default:
                $pattern[] = '/&lt;(\/)?'. $tag .'(\s.+)?&gt;/U';
                $replace[] = '<\1'. $tag .'>';
                break;
        }
    }
    while($in != html_entity_decode($in, ENT_QUOTES | ENT_HTML5, $encoding)) {
        $in = html_entity_decode($in, ENT_QUOTES | ENT_HTML5, $encoding);
    }
    $in = preg_replace($specialPattern, $specialReplace, $in); // modifiers to support features
    
    $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES, $encoding));
    
    // verify tag grammar
    $matches = array();
    preg_match_all('/\<(\/)?([A-Za-z]+)(\s.+)?\>/U', $in, $matches, PREG_PATTERN_ORDER);
    $openTags = array();
    $numTags = count($matches[2]);
    for($i = 0; $i < $numTags; $i++) {
        if($matches[2][$i] != 'br') {
            //echo "examining: {$matches[1][$i]}{$matches[2][$i]}\n";
            // proper closure
            if($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] > 0) {
                $openTags[$matches[2][$i]]--;
                // echo "proper\n";
            }
            // new open tag
            else if($matches[1][$i] == '') {
                if(!isset($openTags[$matches[2][$i]])) {
                    $openTags[$matches[2][$i]] = 0;
                }
                $openTags[$matches[2][$i]]++;
                // echo "open\n";
            }
            // improper closure
            else if($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] <= 0) {
                $in = '<' . $matches[2][$i] . '>' . $in;
                $openTags[$matches[2][$i]]--;
                // echo "improper\n";
            }
            // print_r($openTags);
        }
    }
        
    // close tags
    $tags = array_reverse(array_keys($openTags));
    foreach($tags as $tag) {
        while($openTags[$tag] > 0) {
            $in = $in . '</' . $tag . '>';
            $openTags[$tag]--;
        }
    }
        
    return $in;
}
