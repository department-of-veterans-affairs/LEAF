<?php
session_start();
error_reporting(-1);
ini_set("display_errors", "on");

$client_id = "00000000-0000-0000-0000-000000000000";  // Application (client) ID
$ad_tenant = "00000000-0000-0000-0000-000000000000";  // Entra ID Tenant ID
$redirect_uri = "https://your-server.your-domain.com/this-page.php";  // This needs to match exactly what is set in Entra ID
$error_email = "your.email@your-domain.com";  // Your email
// Path to your certificate and its password
$certificate_path = "/path/to/your/certificate.pfx";
$certificate_password = "your-certificate-password";

function errorhandler($input, $email) {
    $output = "PHP Session ID: " . session_id() . PHP_EOL;
    $output .= "Client IP Address: " . getenv("REMOTE_ADDR") . PHP_EOL;
    $output .= "Client Browser: " . $_SERVER["HTTP_USER_AGENT"] . PHP_EOL;
    $output .= PHP_EOL;
    ob_start();
    var_dump($input);
    $output .= ob_get_contents();
    ob_end_clean();
    mb_send_mail($email, "Your Entra ID OAuth2 script faced an error!", $output, "X-Priority: 1\nContent-Transfer-Encoding: 8bit\nX-Mailer: PHP/" . phpversion());
    echo "<p>" . $input["Description"] . "</p>" . PHP_EOL;
    exit;
}

if (isset($_GET["code"])) echo "<pre>";

if (!isset($_GET["code"]) && !isset($_GET["error"])) {
    // Initial authentication step - redirect to Entra ID authorization endpoint
    $url = "https://login.microsoftonline.com/" . $ad_tenant . "/oauth2/v2.0/authorize?";
    $url .= "state=" . session_id();
    $url .= "&scope=User.Read";
    $url .= "&response_type=code";
    $url .= "&approval_prompt=auto";
    $url .= "&client_id=" . $client_id;
    $url .= "&redirect_uri=" . urlencode($redirect_uri);
    header("Location: " . $url);
} elseif (isset($_GET["error"])) {
    echo "Error handler activated:\n\n";
    var_dump($_GET);
    errorhandler(array("Description" => "Error received at the beginning of the second stage.", "\$_GET[]" => $_GET, "\$_SESSION[]" => $_SESSION), $error_email);
} elseif (strcmp(session_id(), $_GET["state"]) == 0) {
    // Verify the authorization code and obtain tokens
    $content = "grant_type=authorization_code";
    $content .= "&client_id=" . $client_id;
    $content .= "&redirect_uri=" . urlencode($redirect_uri);
    $content .= "&code=" . $_GET["code"];

    // Load the certificate
    $cert_content = file_get_contents($certificate_path);
    openssl_pkcs12_read($cert_content, $cert_info, $certificate_password);
    $cert = $cert_info['pkey'];
    
    // Use the certificate for client assertion
    $client_assertion = generateClientAssertion($client_id, $ad_tenant, $cert);
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
        $error = error_get_last();
        errorhandler(array("Description" => "Error received during Bearer token fetch.", "PHP_Error" => $error, "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);
    }

    $authdata = json_decode($json, true);
    if (isset($authdata["error"])) errorhandler(array("Description" => "Bearer token fetch contained an error.", "\$authdata[]" => $authdata, "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);

    var_dump($authdata);

    // Fetch the basic user information
    $options = array(
        "http" => array(
            "method" => "GET",
            "header" => "Accept: application/json\r\n" .
                "Authorization: Bearer " . $authdata["access_token"] . "\r\n"
        )
    );
    $context = stream_context_create($options);
    $json = @file_get_contents("https://graph.microsoft.com/v1.0/me", false, $context);

    if ($json === false) errorhandler(array("Description" => "Error received during user data fetch.", "PHP_Error" => error_get_last(), "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);

    $userdata = json_decode($json, true);
    if (isset($userdata["error"])) errorhandler(array("Description" => "User data fetch contained an error.", "\$userdata[]" => $userdata, "\$authdata[]" => $authdata, "\$_GET[]" => $_GET, "HTTP_msg" => $options), $error_email);

    var_dump($userdata);
} else {
    echo "Hey, please don't try to hack us!\n\n";
    echo "PHP Session ID used as state: " . session_id() . "\n";
    var_dump($_GET);
    errorhandler(array("Description" => "Likely a hacking attempt, due state mismatch.", "\$_GET[]" => $_GET, "\$_SESSION[]" => $_SESSION), $error_email);
}

echo "\n<a href=\"" . $redirect_uri . "\">Click here to redo the authentication</a>";

// Function to generate client assertion using the certificate
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
    $jwt = "$data." . base64_encode($signature);
    return $jwt;
}
?>
