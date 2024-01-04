<!DOCTYPE html>
<html>
<head>
    <script>
    if(navigator.userAgent.indexOf("Trident") != -1) {
        alert('Please use Microsoft Edge or Google Chrome to access this site.');
    }
    </script>
    {if $tabText != ''}
    <title>{$tabText} - {$title} | {$city}</title>
    {else}
    <title>{$title} | {$city}</title>
    {/if}
    <style type="text/css" media="screen">
        {if $useDojo == true && $useDojoUI == true}
        @import "{$app_js_path}/jquery/css/dcvamc/jquery-ui.custom.min.css";
        @import "{$app_js_path}/jquery/chosen/chosen.min.css";
        {/if}
        @import "../css/style.css";
{section name=i loop=$stylesheets}
        @import "{$stylesheets[i]}";
{/section}
    </style>
    <style type="text/css" media="print">
        @import "../css/printer.css";
{section name=i loop=$stylesheets_print}
        @import "../{$stylesheets_print[i]}";
{/section}
    </style>
    {if $useDojo == true}
    <script type="text/javascript" src="{$app_js_path}/jquery/jquery.min.js"></script>
    {if $useDojoUI == true}<script type="text/javascript" src="{$app_js_path}/jquery/jquery-ui.custom.min.js"></script>{/if}
    {/if}
{section name=i loop=$javascripts}
    <script type="text/javascript" src="{$javascripts[i]}"></script>
{/section}
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
</head>
<body>
{if $smarty.server.HTTP_HOST === 'leaf-preprod.va.gov'}
    <div style="position: fixed; z-index: 9999; width: 100%; background-color: rgba(255,255,100,0.75); text-align: center;">PREPROD TESTING</div>
{/if}
<div id="header">
    {if $qrcodeURL != ''}
    <div style="float: left"><img class="print nodisplay" style="width: 72px" src="{$abs_portal_path}/qrcode/?encode={$qrcodeURL}" alt="QR code" /></div>
    {/if}
    <div style="cursor: pointer" onclick="window.location='./'">
      <span style="position: absolute">{$logo}</span>
      <span id="headerLabel">{$city}</span>
      <h1 id="headerDescription">{$title}</h1>
    </div>
    <span id="headerHelp">
        {$login}
    </span>
    <span id="headerLogin"></span>
    <span id="headerTab">{$emergency}{$tabText}</span>
    <span id="headerTabImg"><img src="../images/tab.png" alt="" /></span>
    <span id="headerMenu">{$menu}</span>
</div>
<div id="body">
    <div id="content">
        {if $status != ''}
        <div class="alert"><span>{$status}</span></div>
        {/if}
        <div id="bodyarea">
            {$body}
        </div>
    </div>
</div>
<div id="footer"{if $hideFooter == true} style="visibility: hidden; display: none"{/if}>
    <br /><br /><a id="versionID" href="../?a=about">{$smarty.const.PRODUCT_NAME}<br />Version {$smarty.const.VERSION_NUMBER} r{$revision}</a>
</div>
</body>
</html>