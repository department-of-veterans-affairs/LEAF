<?php
header('X-UA-Compatible: IE=edge');

// For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//$https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? true : false;
$https = true;
setcookie('PHPSESSID', '', time() - 3600, '/', null, $https, true);

include '../db_mysql.php';
include '../config.php';
include '../globals.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}

$config = new Orgchart\Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
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

$authURL = $protocol . AUTH_URL . '/auth_token/index.php?r=' . base64_encode(getBaseDir());

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Secure Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css" media="screen">
        @import "../css/style.css";
    </style>
    <link rel="icon" href="vafavicon.ico" type="image/x-icon" />
</head>
<body>
<div id="header">
    <div>
      <span style="position: absolute"><img src="../images/VA_icon_small.png" style="width: 80px" alt="VA logo" /></span>
      <span id="headerLabel"><?php echo htmlentities($settings['subHeading']); ?></span>
      <span id="headerDescription"><?php echo htmlentities($settings['heading']); ?></span>
    </div>
    <span id="headerTab">Secure Login</span>
    <span id="headerTabImg"><img src="../images/tab.png" alt="tab" /></span>
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

   <a href="<?php echo $authURL; ?>" style="text-decoration: none"><div class="buttonNorm" style="text-align: center">Login with <b>PIV/CAC card</b><img src="../../libs/dynicons/?img=contact-new.svg&amp;w=32" style="padding-left: 8px" alt="Icon for PIV/CAC card" title="Icon for PIV/CAC card" /></div></a>

</div>

<div class="noprint" id="footer">
    <br /><br />Powered by VA LEAF</a>
</div>
</body>
</html>
