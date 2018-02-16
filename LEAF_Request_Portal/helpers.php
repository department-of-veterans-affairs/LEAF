<?php

/**
 * Suite of helper functions to assist in mitigating XSS vulnerabilities.
 */
class XSSHelpers {

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
        return htmlspecialchars($data, ENT_QUOTES | ENT_HTML401,$encoding);
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
    * Sanitize a HTML string, allows some tags.
    *
    * @param    string  $in the string to be sanitized
    *
    * @return   string  the sanitized string
    */
    static public function sanitizeHTML($in)
    {
        // replace linebreaks with <br /> if there's no html <p>'s
        if(strpos($in, '<p>') === false
            && strpos($in, '<table') === false) {
            $in = nl2br($in, true);
        }

        // strip out uncommon characters
        $in = preg_replace('/[^\040-\176]/', '', $in);

        // hard character limit of 65535
        $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;

        $pattern = array('/&lt;table(\s.+)?&gt;/Ui',
                            '/&lt;\/table&gt;/Ui',
                            '/&lt;(\/)?br(\s.+)?\s\/&gt;/Ui',
                            '/&lt;(\/)?(\S+)(\s.+)?&gt;/U', // all other allowed tags
                            '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
                            '/(\<\/p\>\<\/p\>){2,}/',
                            '/(\<p\>\<\/p\>){2,}/',
                            '/\<\/p\>(\s+)?\<br\>(\s+)?\<p\>/U' // scrub line breaks between paragraphs
        );

        $replace = array('<table class="table">',
                            '</table>',
                            '<\1br />',
                            '<\1\2>',
                            '###-##-####',
                            '',
                            '',
                            "</p>\n<p>"
        );

        $in = html_entity_decode($in);
        $in = strip_tags($in, '<b><i><u><ol><li><br><p><table><td><tr>');
        $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES));

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
}