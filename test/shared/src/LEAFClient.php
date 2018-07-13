<?php
/**
 * @package LEAFTest
 */

namespace LEAFTest;
use GuzzleHttp\Client;
require 'db/db_session.php';
use Session;

/**
 * Simple HTTP client that wraps GuzzleHttp\Client.
 *
 * Configures the Guzzle client to work with LEAF.
 */
class LEAFClient
{
    private $client;

    private function __construct($client)
    {
        $this->session = new Session();
        $this->client = $client;
    }

    /**
     * Get a HTTP Client configured for LEAF and authenticated to make
     * API calls against the Nexus.
     *
     * @param string    $baseURI    The base URI for the Nexus API (default: "http://localhost/LEAF_Nexus/api/")
     *
     * @return LEAFClient   a HTTP Client configured for LEAF
     */
    public static function createNexusClient($baseURI = 'http://php/LEAF_Nexus/api/') : self
    {
        $leafClient = new self(self::getBaseClient($baseURI, '../auth_domain/?'));

        return $leafClient;
    }

    /**
     * Get a HTTP Client configured for LEAF and authenticated to make
     * API calls against the Request Portal.
     *
     * @param string    $baseURI    The base URI for the Request Portal API (default: "http://localhost/LEAF_Request_Portal/api/")
     * @return LEAFClient   a HTTP Client configured for LEAF
     */
    public static function createRequestPortalClient($baseURI = 'http://php/LEAF_Request_Portal/api/') : self
    {
        $leafClient = new self(self::getBaseClient($baseURI, '../auth_domain/?'));

        return $leafClient;
    }

    /**
     * GET request.
     *
     * @param string            $url the URL to request
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public function get($url, $returnType = LEAFResponseType::JSON)
    {
        $response = $this->client->get($url);

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
    public function postEncodedForm($url, $formParams, $returnType = LEAFResponseType::JSON)
    {
      $token = $this->getToken();
      $formParams['CSRFToken'] = $token['CSRFToken'];
        $response = $this->client->post($url, array(
          'form_params' => $formParams,
        ));
        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * DELETE request.
     *
     * @param string            $url the URL to request
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public function delete($url, $returnType = LEAFResponseType::JSON)
    {
        $response = $this->client->delete($url);
        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * Get a GuzzleHttp\Client configured for LEAF.
     *
     * @param string    $baseURI    The base URI of the API
     * @param string    $authURL    URL to authenticate against
     *
     * @return Client   a GuzzleHttp\Client
     */
    private static function getBaseClient($baseURI, $authURL = null) : Client
    {
        $guzzle = new Client(array(
            'base_uri' => $baseURI,
            'cookies' => true,
        ));

        if ($authURL != null)
        {
            $guzzle->get($authURL);
        }

        return $guzzle;
    }

    private function getToken(){
      $cookieJar = $this->client->getConfig('cookies');
      $cookieJar->toArray();

      foreach($cookieJar as $cookie){
        return $this->session->getSessionData($cookie->getValue());
      }
    }
}
