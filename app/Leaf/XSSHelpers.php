<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * Suite of helper functions to assist in mitigating XSS vulnerabilities.
 */

namespace App\Leaf;

class XSSHelpers
{
    private static $specialPattern = array(
        '/(\<\/p\>\<\/p\>){2,}/', // flatten extra <p>
        '/(\<p\>\<\/p\>){2,}/', // flatten extra <p>
        '/\<\/p\>(\s+)?\<br\>(\s+)?\<p\>/U', // scrub line breaks between paragraphs
        '/(<br \/?><br \/?><br \/?>)+/', // scrub excess linebreaks
    );

    private static $specialReplace = array(
        '',
        '',
        "</p>\n<p>",
        '<br />',
    );

    /**
     * Sanitize a string with the specified encoding (default 'UTF-8'), escapes all HTML tags.
     * Uses htmlspecialchars()
     *
     * @param   string  $data       the string to be sanitized
     *
     * @param   string  $encoding   the encoding to be used (default 'UTF-8')
     *
     * @return  string  the sanitized data
     */
    public static function xssafe($data = '', $encoding = 'UTF-8')
    {
        if(!empty($data)) {
            $data = htmlspecialchars((string) $data, ENT_QUOTES | ENT_HTML5, $encoding);
        }
        return $data;
    }

    /**
     * Sanitize a string using UTF-8 encoding, escapes all HTML tags.
     *
     * @param   string  $data   the string to be sanitized
     * @NOTE: (this is getting mixed types, INT, NULL)
     *
     * @return  string  the sanitized data
     */
    public static function xscrub($data = '')
    {
        if(!empty($data)) {
            $data = self::xssafe((string) $data);
        }
        return $data;
    }

    /**
     * Sanitize a HTML string, allows some tags for use in rich text editors.
     *
     * @param    string  $in the string to be sanitized
     * @param    string  $allowedTags list of allowed tags in strip_tags format
     * @param    string  $encoding define the character encoding
     *
     * @return   string  the sanitized string
     */
    public static function sanitizer($in = '', $allowedTags = array(), $encoding = 'UTF-8')
    {
        if(!empty($in)) {
            // hard character limit of 65535
            $in = strlen((string) $in) > 65535 ? substr((string) $in, 0, 65535) : (string) $in;

            $errorReportingLevel = error_reporting(E_ERROR);//turn off errors for the next few lines
            // replace linebreaks with <br /> if there's no html <p>'s
            if (strpos($in, '<p>') === false
                && strpos($in, '<table') === false)
            {
                $in = nl2br($in, true);
            }

            // strip excess tags if we detect copy/paste from MS Office
            if (strpos($in, '<meta name="Generator"') !== false
                || strpos($in, '<w:WordDocument>') !== false
                || strpos($in, '<font face') !== false)
            {
                $in = strip_tags($in, '<br>');
            }
            error_reporting($errorReportingLevel);//turn errors back on

            $pattern = array();
            $replace = array();
            foreach ($allowedTags as $tag)
            {
                switch ($tag) {
                    case 'br':
                        $pattern[] = '/&lt;(\/)?br(\s.+)?(\/)?&gt;/U';
                        $replace[] = '<br />';

                        break;
                    case 'table':
                        $pattern[] = '/&lt;table(\s.+)?&gt;/Ui';
                        $replace[] = '<table class="table">';
                        $pattern[] = '/&lt;\/table&gt;/Ui';
                        $replace[] = '</table>';

                        break;
                    case 'a':
                        $pattern[] = '/&lt;a href=&(quot|#039);(?!javascript)(.+)&(quot|#039);(\s.+)?&gt;/Ui';
                        $replace[] = '<a href="\2" target="_blank">';
                        $pattern[] = '/&lt;\/a&gt;/Ui';
                        $replace[] = '</a>';

                        break;
                    case 'p':
                        $pattern[] = '/&lt;p style=&(quot|#039);(\S.+)&(quot|#039);(\s.+)?&gt;/Ui';
                        $replace[] = '<p style="\2">';
                        $pattern[] = '/&lt;\/p&gt;/Ui';
                        $replace[] = '</p>';

                        // IE 11 workarounds
                        $pattern[] = '/&lt;p align=&quot;(\S.+)&quot;(\s.+)?&gt;/Ui';
                        $replace[] = '<p align="\1">';

                        // cleanup
                        $pattern[] = '/&lt;p(\s.+)?&gt;/Ui';
                        $replace[] = '<p>';

                        break;
                    case 'span':
                        $pattern[] = '/&lt;span style=&(quot|#039);(\S.+)&(quot|#039);(\s.+)?&gt;/Ui';
                        $replace[] = '<span style="\2">';
                        $pattern[] = '/&lt;\/span&gt;/Ui';
                        $replace[] = '</span>';

                        // cleanup
                        $pattern[] = '/&lt;span(\s.+)?&gt;/Ui';
                        $replace[] = '<span>';

                        break;
                    case 'img':
                        $pattern[] = '/&lt;img src=&(?:quot|#039);(?!javascript)(.+)&(?:quot|#039); alt=&(?:quot|#039);(.+)&(?:quot|#039);(\s.*)?\/?&gt;/Ui';
                        $replace[] = '<img src="\1" alt="\2" />';
                        $pattern[] = '/&lt;img src=&(?:quot|#039);(?!javascript)(.+)&(?:quot|#039);(\s.+)?\/?&gt;/Ui';
                        $replace[] = '<img src="\1" alt="" />';

                        break;
                    // Start IE 11 workarounds
                    case 'font':
                        $pattern[] = '/&lt;font color=&(quot|#039);(\S.+)&(quot|#039);(\s.+)?&gt;/Ui';
                        $replace[] = '<font color="\2">';
                        $pattern[] = '/&lt;\/font&gt;/Ui';
                        $replace[] = '</font>';

                        break;
                    // End IE 11 workarounds
                    // Start table related support
                    case 'col':
                        $pattern[] = '/&lt;col style=&(quot|#039);(.+)&(quot|#039); width=&(quot|#039);(.+)&(quot|#039); span=&(quot|#039);(.+)&(quot|#039);(\s.+)?&gt;/Ui';
                        $replace[] = '<col style="\2" width="\5" span="\8">';

                        break;
                    case 'td':
                        $pattern[] = '/&lt;td(\s.+)?&gt;/U';
                        $replace[] = '<td>';
                        $pattern[] = '/&lt;\/td(\s.+)?&gt;/U';
                        $replace[] = '</td>';

                        break;
                    // End table related support
                    default:
                        $pattern[] = '/&lt;(\/)?' . $tag . '(\s.+)?&gt;/U';
                        $replace[] = '<\1' . $tag . '>';

                        break;
                }
            }
            while ($in != html_entity_decode($in, ENT_QUOTES | ENT_HTML5, $encoding))
            {
                $in = html_entity_decode($in, ENT_QUOTES | ENT_HTML5, $encoding);
            }
            $in = preg_replace(self::$specialPattern, self::$specialReplace, $in); // modifiers to support features

            $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES, $encoding));

            // verify tag grammar
            $matches = array();
            preg_match_all('/\<(\/)?([A-Za-z]+)(\s.+)?\>/U', $in, $matches, PREG_PATTERN_ORDER);
            $openTags = array();
            $numTags = count($matches[2]);
            for ($i = 0; $i < $numTags; $i++)
            {
                if ($matches[2][$i] != 'br'
                    && $matches[2][$i] != 'img'
                    && $matches[2][$i] != 'col')
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
                            if ($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) || $openTags[$matches[2][$i]] <= 0)
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
        }
        return $in;
    }

    /**
     * Sanitize a HTML string, allows some tags for use in rich text editors.
     *
     * Allowed tags: <b><i><u><ol><ul><li><br><p><table><td><tr><thead><tbody>
     *
     * @param    string  $in the string to be sanitized
     *
     * @return   string  the sanitized string
     */
    public static function sanitizeHTML($in = '')
    {
        $allowedTags = array('b', 'i', 'u', 'ol', 'ul', 'li', 'br', 'p', 'table',
                        'td', 'tr', 'thead', 'tbody', 'span', 'strong', 'em',
                        'colgroup', 'col', );

        // IE 11 workarounds
        $allowedTags[] = 'font';
        $allowedTags[] = 'center';

        if(!empty($in)) {
            $in = self::sanitizer((string) $in, $allowedTags);
        }
        return $in;
    }

    /**
     * Sanitize a HTML string, allows some tags for use in rich text editors.
     * Used in form field headings, which include some links and formatted text
     *
     * Allowed tags: <b><i><u><ol><ul><li><br><p><table><td><tr><thead><tbody><a><span><strong><em><h1><h2><h3><h4><img><font>
     *
     * @param    string  $in the string to be sanitized
     *
     * @return   string  the sanitized string
     */
    public static function sanitizeHTMLRich($in = '')
    {
        $allowedTags = array('b', 'i', 'u', 'ol', 'ul', 'li', 'br', 'p', 'table',
                        'td', 'tr', 'thead', 'tbody', 'a', 'span', 'strong',
                        'em', 'h1', 'h2', 'h3', 'h4', 'img', 'colgroup',
                        'col', );

        // IE 11 workarounds
        $allowedTags[] = 'font';
        $allowedTags[] = 'center';

        if(!empty($in)) {
            $in = self::sanitizer((string) $in, $allowedTags);
        }
        return $in;
    }

    /**
     * Sanitize a URL string, removing new lines
     *
     * @param    string  $stringToScrub the string to be sanitized
     *
     * @return   string  the sanitized string
     */
    public static function scrubNewLinesFromURL($stringToSanitize = '')
    {
        $toRemove = ['%0a','%0A', '%0d','%0D', '\r', '\n'];

        return str_replace($toRemove, '', (string) $stringToSanitize);
    }

    /**
     * Sanitize a filename, removing anything that isn't a letter, number, underscore, dash, or whitespace
     *
     * @param    string  $stringToScrub the string to be sanitized
     *
     * @return   string  the sanitized string
     */
    public static function scrubFilename($stringToSanitize = '')
    {
        $pattern = "/[\/\:\*\?\"\<\>\|\\\]*/";

        return preg_replace($pattern, "" , (string) $stringToSanitize );
    }

    /**
     * Sanitize everything in an Object or Array
     *
     * @param    object  $objectToScrub the string to be sanitized
     *
     * @return   object  the sanitized object
     */
    public static function scrubObjectOrArray($objectToScrub = array())
    {
         foreach($objectToScrub as $key => &$value)
        {
            if(is_object($value) || is_array($value))
            {
                $value = self::scrubObjectOrArray($value);
            }
            else if(is_numeric($value))
            {
                $value = $value;
            }
            else
            {
                $value = self::xscrub($value);
            }
        }

        return $objectToScrub;
    }

    /**
     * Turn relative paths to absolute paths
     * @param string $relative_path
     * @return bool|string False if not a valid path or a full absolute path string
     */
    public static function absolutePath($relative_path) : bool|string
    {

        // check if this is a real path, if no good then this will return false.
        $real_path = realpath($relative_path);
        //var_dump(getcwd(),str_replace('../','',$filepath),$real_path,strstr($real_path.'/', str_replace('../','',$filepath)));
        // final url should have trailing / all of the urls that would be checked will have this.
        $real_path .= '/';

        // check against the relative path to make sure this is not going off to an invalid location
        if (strstr($real_path, str_replace('../','',$relative_path)) === false) {
             $real_path = false;
        }
        
        return $real_path;
    }

}
