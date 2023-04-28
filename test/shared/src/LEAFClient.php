<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * @package LEAFTest
 */

namespace LEAFTest;

use GuzzleHttp\Client;

/**
 * Simple HTTP client that wraps GuzzleHttp\Client.
 *
 * Configures the Guzzle client to work with LEAF.
 */
class LEAFClient
{
    private $client;

    private $CSRFToken;

    private function __construct($client)
    {
        $this->client = $client;
        $this->CSRFToken = self::getCSRFToken();
    }

    /**
     * Get a HTTP Client configured for LEAF and authenticated to make
     * API calls against the Nexus.
     *
     * @param string    $baseURI    The base URI for the Nexus API (default: "http://localhost/LEAF_Nexus/api/")
     *
     * @return LEAFClient   a HTTP Client configured for LEAF
     */
    public static function createNexusClient($baseURI = 'http://localhost/LEAF_Nexus/api/', $authURL = '../auth_domain/') : self
    {
        $leafClient = new self(self::getBaseClient($baseURI, $authURL));

        return $leafClient;
    }

    /**
     * Get a HTTP Client configured for LEAF and authenticated to make
     * API calls against the Request Portal.
     *
     * @param string    $baseURI    The base URI for the Request Portal API (default: "http://localhost/LEAF_Request_Portal/api/")
     * @return LEAFClient   a HTTP Client configured for LEAF
     */
    public static function createRequestPortalClient($baseURI = 'http://localhost/LEAF_Request_Portal/api/', $authURL = '../auth_domain/') : self
    {
        $headers['Referer'] = 'http://localhost/LEAF_Request_Portal/admin';
        $leafClient = new self(self::getBaseClient($baseURI, $authURL, $headers));

        return $leafClient;
    }

    /**
     * GET request.
     *
     * @param array             $queryParams an array that contains key=>values of the query data.
     * @param array             $formParams an array that contains key=>values of the form data.
     * @param string            $url the URL to request with trailing slash, relative to the $baseURI passed to getBaseClient
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public function get($queryParams = array(), $formParams = array(), $url = '', $returnType = LEAFResponseType::JSON)
    {
        $response = $this->client->get($url, array(
            'query' => $queryParams,
            'form_params' => $formParams,
        ));

        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * POST request. Handles `application/x-www-form-urlencoded` requests.
     *
     * @param array             $queryParams an array that contains key=>values of the query data.
     * @param array             $formParams an array that contains key=>values of the form data.
     * @param string            $url the URL to request with trailing slash, relative to the $baseURI passed to getBaseClient
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public function post($queryParams = array(), $formParams = array(), $url = '', $returnType = LEAFResponseType::JSON)
    {
        //add CSRFToken to POST
        $formParams['CSRFToken'] = $this->CSRFToken;

        $response = $this->client->post($url, array(
            'query' => $queryParams,
            'form_params' => $formParams,
        ));

        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * DELETE request.
     *
     * @param array             $queryParams an array that contains key=>values of the query data.
     * @param array             $formParams an array that contains key=>values of the form data.
     * @param string            $url the URL to request with trailing slash, relative to the $baseURI passed to getBaseClient
     * @param LEAFResponseType  $returnType the LEAFTest\\LEAFResponseType to format the response as (default: JSON)
     *
     * @return object           the formatted response
     */
    public function delete($queryParams = array(), $formParams = array(), $url = '', $returnType = LEAFResponseType::JSON)
    {
        //add CSRFToken to query parameters
        $queryParams['CSRFToken'] = $this->CSRFToken;

        $response = $this->client->delete($url, array(
            'query' => $queryParams,
            'form_params' => $formParams,
        ));

        return ResponseFormatter::format($response->getBody(), $returnType);
    }

    /**
     * Return CSRFToken associated with this client
     *
     * @return string           the CSRFToken string
     */
    public function getCSRFToken()
    {
        // Due to how database access classes/configs are setup, these should be included/required
        // only within this function to prevent the same classes from being included more than once.
        // Requiring/including them within this function keeps their scope to just this function.
        require_once __DIR__ . '/../../../LEAF_Request_Portal/globals.php';
        require_once LIB_PATH . '/loaders/Leaf_autoloader.php';

        $config = new Config();
        $db_phonebook = new \Leaf\Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, $config->phonedbName);
        $cookieJar = $this->client->getConfig('cookies');
        $cookie = $cookieJar->getCookieByName('PHPSESSID');
        if (is_null($cookie))
        {
            trigger_error('PHPSESSID cookie not set', E_USER_WARNING);
        }
        $sessionID = $cookie->getValue();

        $vars = array(':sessionID' => $sessionID);
        $res = $db_phonebook->prepared_query('SELECT * FROM sessions WHERE sessionKey=:sessionID', $vars);

        $CSRFToken = '';
        if (array_key_exists(0, $res) && array_key_exists('data', $res[0]))
        {
            $sessionStr = $res[0]['data'];
            $data = SessionDecoder::decode($sessionStr);
            $CSRFToken = array_key_exists('CSRFToken', $data) ? $data['CSRFToken'] : '';
        }
        else
        {
            trigger_error('Session data not found', E_USER_WARNING);
        }

        return $CSRFToken;
    }

    /** Get a GuzzleHttp\Client configured for LEAF.
     *
     * @param string    $baseURI    The base URI of the API
     * @param string    $authURL    URL to authenticate against
     *
     * @return Client   a GuzzleHttp\Client
     */
    private static function getBaseClient($baseURI, $authURL = null, $headers = []) : Client
    {
        $config = array(
            'base_uri' => $baseURI,
            'cookies' => true,
        );

        if(!empty($headers))
        {
            $config['headers'] = $headers;
        }

        $guzzle = new Client($config);

        if ($authURL != null)
        {
            $guzzle->get($authURL);
        }

        return $guzzle;
    }
}
