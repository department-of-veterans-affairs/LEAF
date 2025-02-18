<?php

use App\Leaf\XSSHelpers;

header('X-UA-Compatible: IE=edge');

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
$https = true;
setcookie('PHPSESSID', '', time() - 3600, '/', null, $https, true);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

//$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
$settings['heading'] = XSSHelpers::sanitizeHTMLRich($settings['heading'] == '' ? $config->title : $settings['heading']);
$settings['subHeading'] = XSSHelpers::sanitizeHTMLRich($settings['subHeading'] == '' ? $config->city : $settings['subHeading']);

function getBaseDir()
{
    $dir = dirname($_SERVER['PHP_SELF']);

    return str_replace('login', '', $dir);
}

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https://' : 'http://';
$protocol = 'https://';

$authURL = $protocol . HTTP_HOST . getBaseDir() . '/auth_cookie/index.php?r=' . base64_encode(getBaseDir());
$authCertURL = $protocol . AUTH_CERT_URL . '/auth_token/index.php?r=' . base64_encode(getBaseDir());

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Secure Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css" media="screen">
        @import "../css/style.css";
    </style>
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
</head>
<body>
<div id="header">
    <div>
      <span style="position: absolute"><img src="../images/VA_icon_small.png" style="width: 80px" alt="VA seal, U.S. Department of Veterans Affairs" /></span>
      <span id="headerLabel"><?php echo htmlentities($settings['subHeading']); ?></span>
      <span id="headerDescription"><?php echo htmlentities($settings['heading']); ?></span>
    </div>
    <span id="headerTab">Secure Login</span>
    <span id="headerTabImg"><img src="../images/tab.png" alt="" /></span>
</div>

<div class="card" style="max-width: 500px; padding: 16px; margin: auto">
When logging into this system, you agree to the following:<br />
<br />
    You are accessing a U.S. Government information system, which includes:<br />
    <ul>
    <li>(1) this computer,</li>
    <li>(2) this computer network,</li>
    <li>(3) all computers connected to this network, and</li>
    <li>(4) all devices and storage media attached to this network or to a computer on this network.</li>
    </ul>
    This information system is provided for U.S. Government-authorized use only. Unauthorized or improper use of this system may result in disciplinary action, as well as civil and criminal penalties.<br /><br />

    <div style="font-size: 150%">
        <a href="<?php echo $authCertURL; ?>" style="text-decoration: none"><div class="buttonNorm" style="text-align: center">Login with <b>PIV/CAC card</b><img src="../dynicons/?img=contact-new.svg&amp;w=32" style="padding-left: 8px" title="Icon for PIV/CAC card" alt="" /></div></a>
        <br>
        <a href="<?php echo $authURL; ?>" style="text-decoration: none"><div class="buttonNorm" style="text-align: center">Login with <b>Windows Login</b><img src="../dynicons/?img=system-log-out.svg&amp;w=32" style="padding-left: 8px" title="Icon for Windows Login" alt="" /></div></a>
    </div>
</div>

<div class="noprint" id="footer">
    <br /><br />Powered by VA LEAF</a>
</div>
</body>
</html>
