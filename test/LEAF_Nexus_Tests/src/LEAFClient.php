<?php
/**
 * @package LEAFTest
 */

namespace LEAFTest;

use GuzzleHttp\Client;

use LEAFTest\LEAFResponseType;
use LEAFTest\ResponseFormatter;


/**
 * Simple HTTP client that wraps GuzzleHttp\Client.
 *
 * Configures the Guzzle client to work with LEAF.
 */
class LEAFClient
{
    private static $client = null;

    /**
     * Get a GuzzleHttp\Client configured for LEAF and authenticated to make
     * API calls.
     *
     * @return Client   a GuzzleHttp\Client configured for LEAF
     */
    public static function getClient(): Client
    {
        if (self::$client == null) {
            self::$client = new Client([
              'base_uri' => 'http://localhost/',
              'cookies' => true
            ]);

            // get PHPSESSIONID so requests are authenticated
            self::$client->get('/LEAF_Nexus/auth_domain/?');
        }

        return self::$client;
    }

    /**
     * GET request.
     *
     * @param string            $url the URL to request
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public static function get($url, $returnType = LEAFResponseType::JSON)
    {
        $response = self::getClient()->get($url);
        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * POST request. Handles `application/x-www-form-urlencoded` requests.
     *
     * @param string            $url the URL to request
     * @param array             $formParams an array that contains key=>values of the form data.
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public static function postEncodedForm($url, $formParams, $returnType = LEAFResponseType::JSON)
    {
        $response = self::getClient()->post($url, [
          'form_params' => $formParams
        ]);
        return ResponseFormatter::format($response->getBody(), $returnType);
    }
}
