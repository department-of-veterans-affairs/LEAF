<!DOCTYPE html>
<html>
<head>
    {if $tabText != ''}
    <title>{$tabText} - {$title} | {$city}</title>
    {else}
    <title>{$title} | {$city}</title>
    {/if}
    <style type="text/css" media="screen">
        {if $useDojo == true && $useDojoUI == true}
        @import "../../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        @import "../../libs/js/jquery/chosen/chosen.min.css";
        {/if}
        @import "../css/style.css";
{section name=i loop=$stylesheets}
        @import "../{$stylesheets[i]}";
{/section}
    </style>
    <style type="text/css" media="print">
        @import "../css/printer.css";
{section name=i loop=$stylesheets_print}
        @import "../{$stylesheets_print[i]}";
{/section}
    </style>
    {if $useDojo == true}
    <script type="text/javascript" src="../../libs/js/jquery/jquery.min.js"></script>
    {if $useDojoUI == true}<script type="text/javascript" src="../../libs/js/jquery/jquery-ui.custom.min.js"></script>{/if}
    {/if}
{section name=i loop=$javascripts}
    <script type="text/javascript" src="../{$javascripts[i]}"></script>
{/section}
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
</head>
<body>
<div id="header">
    {if $qrcodeURL != ''}
    <div style="float: left"><img class="print nodisplay" style="width: 72px" src="../../libs/qrcode/?encode={$qrcodeURL}" alt="QR code" /></div>
    {/if}
    <div style="cursor: pointer" onclick="window.location='./'">
      <span style="position: absolute">{$logo}</span>
      <span id="headerLabel">{$city}</span>
      <span id="headerDescription">{$title}</span>
    </div>
    <span id="headerHelp">
        {$login}
    </span>
    <span id="headerLogin"></span>
    <span id="headerTab">{$emergency}{$tabText}</span>
    <span id="headerTabImg"><img src="../images/tab.png" alt="tab" /></span>
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
