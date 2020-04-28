{strip}<!DOCTYPE html>
<html lang="en">
<head>
    {if $tabText != ''}
        <title>{$tabText|sanitize} - {$title|sanitize} | {$city|sanitize}</title>
    {else}
        <title>{$title|sanitize} | {$city|sanitize}</title>
    {/if}
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css" media="screen">
        @import "../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        {section name=i loop=$stylesheets}
            @import "{$stylesheets[i]}";
        {/section}
        @import "../libs/js/jquery/chosen/chosen.min.css";
        @import "../libs/js/jquery/trumbowyg/ui/trumbowyg.min.css";
        @import "../libs/js/jquery/icheck/skins/square/blue.css";
        @import "css/style.css";
        @import "../../libs/css/leaf.css";
    </style>
    <style type="text/css" media="print">
        @import "css/printer.css";
    </style>
    <script type="text/javascript" src="../libs/js/jquery/jquery.min.js"></script>
    {if $useUI == true}
        <script type="text/javascript" src="../libs/js/jquery/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="js/dialogController.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/trumbowyg/trumbowyg.min.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/icheck/icheck.js"></script>
    {else if $useLiteUI == true}
        <script type="text/javascript" src="js/dialogController.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/trumbowyg/trumbowyg.min.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/icheck/icheck.js"></script>
    {/if}
    {if $leafSecure >= 1}
        <script type="text/javascript" src="../libs/js/LEAF/sessionTimeout.js"></script>
    {/if}
    {section name=i loop=$javascripts}
        <script type="text/javascript" src="{$javascripts[i]}"></script>
    {/section}
    <link rel="icon" href="vafavicon.ico" type="image/x-icon" />
</head>

<body>

    <header id="header" class="usa-header site-header">
        <div class="usa-navbar site-header-navbar">
            <div class="usa-logo site-logo" id="logo">
                <em class="usa-logo__text">
                    <a onclick="window.location='./'" title="Home" aria-label="LEAF home" class="leaf-cursor-pointer">
                        <span class="leaf-logo"><img src="images/VA_icon_small.png" alt="VA logo" /></span>
                        <span class="leaf-site-title">{$city|sanitize}</span>
                        <span id="headerDescription" class="leaf-header-description">{$title|sanitize}</span>
                    </a>
                </em>
                {if $qrcodeURL != ''}
                    <div><img class="print nodisplay" style="width: 72px" src="../../libs/qrcode/?encode={$qrcodeURL}" alt="QR code" /></div>
                {/if}
            </div>
            <div class="leaf-header-right">
                <div class="leaf-hdr-top">
                    <span id="headerHelp">
                        {if $leafSecure == 0}
                            <span class="usa-tag bg-accent-warm-dark leaf-hdr-alert">Do not enter PHI/PII</span>
                        {/if}
                        {$login}
                    </span>
                    <span id="headerLogin"></span>
                </div>
                <div class="leaf-hdr-bot">
                    <span id="headerTab" class="leaf-hdr-section">{$emergency}{$tabText|sanitize}</span>
                    <span id="headerMenu" class="noprint">{$menu}</span>
                </div>
            </div>
        </div>
    </header>


    <div id="body">
        <div id="content">
            {if $status != ''}
                <div class="alert"><span>{$status}</span></div>
            {/if}
            <div id="bodyarea" class="default-container">
                {$body}
            </div>
        </div>
    </div>

    <div class="usa-footer leaf-footer noprint" id="footer"{if $hideFooter == true} style="visibility: hidden; display: none"{/if}>
        <a id="versionID" href="?a=about">{$smarty.const.PRODUCT_NAME}<br />Version {$smarty.const.VERSION_NUMBER} r{$revision}</a>
    </div>
</body>
</html>{/strip}
