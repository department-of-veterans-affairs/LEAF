<?php
header('X-UA-Compatible: IE=edge');

include '../db_mysql.php';
include '../config.php';
$config = new Orgchart\Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
$settings = $db->query_kv('SELECT * FROM settings', 'setting', 'data');
$settings['heading'] = $settings['heading'] == '' ? $config->title : $settings['heading'];
$settings['subheading'] = $settings['subheading'] == '' ? $config->city : $settings['subheading'];

function getBaseDir()
{
    $dir = dirname($_SERVER['PHP_SELF']);

    return str_replace('login', '', $dir);
}

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
      <span id="headerLabel"><?php echo $settings['subheading']; ?></span>
      <span id="headerDescription"><?php echo $settings['heading']; ?></span>
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

    <a href="<?php echo 'https://' . $_SERVER['SERVER_NAME'] . ':444' . getBaseDir() . 'auth_token/?' . htmlentities($_SERVER['QUERY_STRING']); ?>"><div class="buttonNorm" style="text-align: center">Login with your VA PIV card<img src="../../libs/dynicons/?img=go-next.svg&amp;w=32" alt="Icon for Login" title="Icon for Login" /></div></a><br />
    <a href="<?php if (Orgchart\Config::$leafSecure == false)
{
    echo 'https://' . $_SERVER['SERVER_NAME'] . getBaseDir() . 'auth_domain/?' . htmlentities($_SERVER['QUERY_STRING']);
} ?>"><?php if (Orgchart\Config::$leafSecure == false)
{
    echo '<div class="buttonNorm" style="text-align: center">Login with Username and Password</div>';
} ?></a>

</div>

</body>
</html>
