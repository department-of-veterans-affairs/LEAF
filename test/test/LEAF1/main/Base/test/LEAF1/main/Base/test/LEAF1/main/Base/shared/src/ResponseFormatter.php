<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * @package LEAFTest
 */

namespace LEAFTest;

/**
 * Types that can be returned by LEAFClient. Ensures it is in the proper format
 * and type before the response is returned.
 */
class LEAFResponseType
{
    const JSON = 0;
}

/**
 * Formats a HTTP Response
 */
class ResponseFormatter
{
    /**
     * Formats a response based on the LEAFResponseType, default is JSON.
     *
     * @param string            $data the response data to be formatted
     * @param LEAFResponseType  $responseType the LEAFTest\\LEAFResponseType to format the response as
     *
     * @return object           the formatted response
     */
    public static function format($data, $responseType = LEAFResponseType::JSON)
    {
        switch ($responseType) {
          case LEAFResponseType::JSON:
            return self::JSON($data);
          default:
            return 'Unknown LEAFResponseType';
        }
    }

    /**
     * Format the response as JSON.
     *
     * @param string  $data the response data to format
     *
     * @return object the formatted response
     */
    public static function JSON($data)
    {
        return json_decode((string)$data, true);
    }
}
