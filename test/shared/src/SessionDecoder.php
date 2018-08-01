<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * @package LEAFTest
 */

namespace LEAFTest;

/**
 * Class for decoding encoded session data
 */
class SessionDecoder
{
    /**
     * Decode an encoded string of session data using the method defined in php.ini (session.serialize_handler)
     *
     * @param string    $session_data   encoded session data
     *
     * @return array    an array with key=>value of the decoded $session_data
     */
    public static function decode($session_data)
    {
        $method = ini_get('session.serialize_handler');
        switch ($method) {
            case 'php':
                return self::decode_php($session_data);

                break;
            case 'php_binary':
                return self::decode_phpbinary($session_data);

                break;
            case 'php_serialize':
                return self::decode_phpserialize($session_data);
            default:
            trigger_error('Unsupported session.serialize_handler: ' . $method . '. Supported: php, php_binary, php_serialize' . substr($session_data, $offset), E_USER_WARNING);
        }
    }

    /**
     * Decode an encoded string of session data where php.ini has session.serialize_handler=php
     *
     * @param string    $session_data   encoded session data
     *
     * @return array    an array with key=>value of the decoded $session_data
     */
    private static function decode_php($session_data)
    {
        $return_data = array();
        $offset = 0;
        while ($offset < strlen($session_data))
        {
            if (!strstr(substr($session_data, $offset), '|'))
            {
                trigger_error('invalid data, remaining: ' . substr($session_data, $offset), E_USER_WARNING);
            }
            $pos = strpos($session_data, '|', $offset);
            $num = $pos - $offset;
            $varname = substr($session_data, $offset, $num);
            $offset += $num + 1;
            $data = unserialize(substr($session_data, $offset));
            $return_data[$varname] = $data;
            $offset += strlen(serialize($data));
        }

        return $return_data;
    }

    /**
     * Decode an encoded string of session data where php.ini has session.serialize_handler=php_binary
     *
     * @param string    $session_data   encoded session data
     *
     * @return array    an array with key=>value of the decoded $session_data
     */
    private static function decode_phpbinary($session_data)
    {
        $return_data = array();
        $offset = 0;
        while ($offset < strlen($session_data))
        {
            $num = ord($session_data[$offset]);
            $offset += 1;
            $varname = substr($session_data, $offset, $num);
            $offset += $num;
            $data = unserialize(substr($session_data, $offset));
            $return_data[$varname] = $data;
            $offset += strlen(serialize($data));
        }

        return $return_data;
    }

    /**
     * Decode an encoded string of session data where php.ini has session.serialize_handler=php_serialize
     *
     * @param string    $session_data   encoded session data
     *
     * @return array    an array with key=>value of the decoded $session_data
     */
    private static function decode_phpserialize($session_data)
    {
        $return_data = unserialize($session_data);
        if (!is_array($return_data))
        {
            //default to empty array
            $return_data = array();
        }

        return $return_data;
    }
}
