<?php
require 'vendor/autoload.php';
use MicrosoftAzure\Storage\Common\ServicesBuilder;
use MicrosoftAzure\Storage\Common\ServiceException;
use MicrosoftAzure\Storage\Common\Internal\Resources;
use Microsoft\Azure\KeyVault\KeyVaultClient;
use Microsoft\Azure\KeyVault\KeyVaultCredentials;
use GuzzleHttp\Client;
// Define your Azure Key Vault details
$vaultUrl = 'https://your-key-vault-name.vault.azure.net/';
$certificateName = 'your-certificate-name';
$tenantId = 'your-tenant-id';
$clientId = 'your-client-id';
// $clientSecret = 'your-client-secret';
// function getAccessToken($tenantId, $clientId=null, $clientSecret=null) {
//     $client = new Client();
//     $url = "https://login.microsoftonline.com/{$tenantId}/oauth2/v2.0/token";
//     $response = $client->post($url, [
//         'form_params' => [
//             'grant_type' => 'client_credentials',
//             'client_id' => $clientId,
//             'client_secret' => $clientSecret,
//             'scope' => 'https://vault.azure.net/.default'
//         ]
//     ]);
//     $data = json_decode($response->getBody(), true);
//     return $data['access_token'];
// }
// // Get the access token
// $accessToken = getAccessToken($tenantId, $clientId, $clientSecret);
// // Create a KeyVaultClient with the access token
// $credentials = new KeyVaultCredentials(
//     function ($httpMethod, $uri, $body, $headers) use ($accessToken) {
//         $headers['Authorization'] = 'Bearer ' . $accessToken;
//         return $headers;
//     }
// );
// $client = new KeyVaultClient($credentials);
// try {
//     // Retrieve the certificate
//     $certificateBundle = $client->getCertificate($vaultUrl, $certificateName);
//     $certificate = $certificateBundle->cer;
//     // Optionally, you can save the certificate to a file
//     file_put_contents('certificate.cer', $certificate);
//     echo "Certificate retrieved and saved successfully.";
// } catch (ServiceException $e) {
//     echo "Error retrieving certificate: " . $e->getMessage();
// }


$cert_content = file_get_contents($certificate_path);
openssl_pkcs12_read($cert_content, $cert_info, $certificate_password=null);
$cert = $cert_info['pkey'];
$client_assertion = generateClientAssertion($client_id, $ad_tenant, $cert);


function generateClientAssertion($client_id, $tenant_id, $cert) {
    $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $payload = base64_encode(json_encode([
        'aud' => "https://login.microsoftonline.com/{$tenant_id}/oauth2/v2.0/token",
        'exp' => time() + 3600,
        'iss' => $client_id,
        'sub' => $client_id,
        'jti' => base64_encode(random_bytes(16))
    ]));
    $data = "$header.$payload";
    openssl_sign($data, $signature, $cert, OPENSSL_ALGO_SHA256);
    return "$data." . base64_encode($signature);
}

//Fetch bearer token using client assertion
$content = "grant_type=authorization_code";
$content .= "&client_id=" . $client_id;
$content .= "&redirect_uri=" . urlencode($redirect_uri);
$content .= "&code=" . $_GET["code"];
$content .= "&client_assertion=" . urlencode($client_assertion);
$content .= "&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer";
$options = array(
    "http" => array(
        "method" => "POST",
        "header" => "Content-Type: application/x-www-form-urlencoded\r\n" .
            "Content-Length: " . strlen($content) . "\r\n",
        "content" => $content
    )
);
$context = stream_context_create($options);
$json = @file_get_contents("https://login.microsoftonline.com/" . $ad_tenant . "/oauth2/v2.0/token", false, $context);

if ($json === false) {
    errorhandler(array("Description" => "Error received during Bearer token fetch.", "PHP_Error" => error_get_last(), "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);
}
$authdata = json_decode($json, true);
if (isset($authdata["error"])) {
    errorhandler(array("Description" => "Bearer token fetch contained an error.", "\$authdata[]" => $authdata, "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);
}

// Fetch user data

$options = array(
    "http" => array(
        "method" => "GET",
        "header" => "Accept: application/json\r\n" .
            "Authorization: Bearer " . $authdata["access_token"] . "\r\n"
    )
);
$context = stream_context_create($options);
$json = @file_get_contents("https://graph.microsoft.com/v1.0/me", false, $context);
if ($json === false) {
    errorhandler(array("Description" => "Error received during user data fetch.", "PHP_Error" => error_get_last(), "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);
}
$userdata = json_decode($json, true);
if (isset($userdata["error"])) {
    errorhandler(array("Description" => "User data fetch contained an error.", "\$userdata[]" => $userdata, "\$authdata[]" => $authdata, "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);
}



?>
