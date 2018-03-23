<?php

/**
 * Suite of helper functions to assist in mitigating XSS vulnerabilities.
 */
class XSSHelpers {

    static private $specialPattern = [
        '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
        '/(\<\/p\>\<\/p\>){2,}/', // flatten extra <p>
        '/(\<p\>\<\/p\>){2,}/', // flatten extra <p>
        '/\<\/p\>(\s+)?\<br\>(\s+)?\<p\>/U' // scrub line breaks between paragraphs
    ];
    static private $specialReplace = [
        '###-##-####',
        '',
        '',
        "</p>\n<p>"
    ];

    /**
     * Sanitize a string with the specified encoding (default 'UTF-8'), escapes all HTML tags.
     * Uses htmlspecialchars()
     * 
     * @param   string  $data       the string to be sanitized
     * @param   string  $encoding   the encoding to be used (default 'UTF-8')
     * 
     * @return  string  the sanitized data
     */
    static function xssafe($data, $encoding='UTF-8') {
        return htmlspecialchars($data, ENT_QUOTES | ENT_HTML5, $encoding);
    }

    /**
     * Sanitize a string using UTF-8 encoding, escapes all HTML tags.
     * 
     * @param   string  $data   the string to be sanitized
     * 
     * @return  string  the sanitized data
     */
    static function xscrub($data) {
        return XSSHelpers::xssafe($data);
    }

    /**
     * Sanitize a HTML string, allows some tags for use in rich text editors.
     *
     * @param    string  $in the string to be sanitized
     * @param    string  $allowedTags list of allowed tags in strip_tags format
     *
     * @return   string  the sanitized string
     */
    static public function sanitizer($in, $allowedTags, $encoding = 'UTF-8') {
        // replace linebreaks with <br /> if there's no html <p>'s
        if(strpos($in, '<p>') === false
            && strpos($in, '<table') === false) {
            $in = nl2br($in, true);
        }
        
        // strip out uncommon characters
        $in = preg_replace('/[^\040-\176]/', '', $in);
        
        // hard character limit of 65535
        $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;
        
        // strip excess tags if we detect copy/paste from MS Office
        if(strpos($in, '<meta name="Generator"') !== false
            || strpos($in, '<w:WordDocument>') !== false) {
            $in = strip_tags($in, '<br>');
        }

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
                case 'p':
                    $pattern[] = '/&lt;p style=&quot;(\S.+)&quot;(\s.+)?&gt;/Ui';
                    $replace[] = '<p style="\1">';
                    $pattern[] = '/&lt;\/p&gt;/Ui';
                    $replace[] = '</p>';
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
        $in = preg_replace(XSSHelpers::$specialPattern, XSSHelpers::$specialReplace, $in); // modifiers to support features

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
    
    /**
    * Sanitize a HTML string, allows some tags for use in rich text editors.
    * 
    * Allowed tags: <b><i><u><ol><li><br><p><table><td><tr>
    *
    * @param    string  $in the string to be sanitized
    *
    * @return   string  the sanitized string
    */
    static public function sanitizeHTML($in)
    {
        $allowedTags = ['b', 'i', 'u', 'ol', 'li', 'br', 'p', 'table', 'td', 'tr'];

        return XSSHelpers::sanitizer($in, $allowedTags);
    }

    /**
    * Sanitize a HTML string, allows some tags for use in rich text editors.
    * Used in form field headings, which include some links and formatted text
    * 
    * Allowed tags: <b><i><u><ol><li><br><p><table><td><tr><a><span><strong>
    *
    * @param    string  $in the string to be sanitized
    *
    * @return   string  the sanitized string
    */
    static public function sanitizeHTMLRich($in)
    {
        $allowedTags = ['b', 'i', 'u', 'ol', 'li', 'br', 'p', 'table', 'td', 'tr', 'a', 'span', 'strong', 'em'];

        return XSSHelpers::sanitizer($in, $allowedTags);
    }
}