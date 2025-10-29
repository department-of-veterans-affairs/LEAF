{strip}<!DOCTYPE html>
<html lang="en">
<head>
    <script>
        if(navigator.userAgent.indexOf("Trident") != -1) {
            alert('Please use Microsoft Edge or Google Chrome to access this site.');
        }
    </script>
    {if $tabText != ''}
    <title>{$tabText|sanitize} - {$title|sanitize}, {$city|sanitize}</title>
    {else}
    <title>{$title|sanitize}, {$city|sanitize}</title>
    {/if}
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css" media="screen">
        @import "{$app_js_path}/jquery/css/dcvamc/jquery-ui.custom.min.css";
{section name=i loop=$stylesheets}
        @import "{$stylesheets[i]}";
{/section}
        @import "css/style.css";

        @import "{$app_js_path}/jquery/chosen/chosen.min.css";
        @import "{$app_js_path}/jquery/trumbowyg/ui/trumbowyg.min.css";
        /* backwards compat */
        @import "{$app_js_path}/jquery/icheck/skins/square/blue.css";

    </style>
    <style type="text/css" media="print">
        @import "css/printer.css";
    </style>
    <script type="text/javascript" src="{$app_js_path}/jquery/jquery.min.js"></script>
    {if $useUI == true}
    <script type="text/javascript" src="{$app_js_path}/jquery/jquery-ui.custom.min.js"></script>
    <script type="text/javascript" src="js/dialogController.js"></script>
    <script type="text/javascript" src="{$app_js_path}/jquery/chosen/chosen.jquery.min.js"></script>
    <script type="text/javascript" src="{$app_js_path}/jquery/trumbowyg/trumbowyg.min.js"></script>
    <!--backwards compat -->
    <script type="text/javascript" src="{$app_js_path}/jquery/icheck/icheck.js"></script>
    {else if $useLiteUI == true}
    <script type="text/javascript" src="js/dialogController.js"></script>
    <script type="text/javascript" src="{$app_js_path}/jquery/chosen/chosen.jquery.min.js"></script>
    <script type="text/javascript" src="{$app_js_path}/jquery/trumbowyg/trumbowyg.min.js"></script>
    <!--backwards compat -->
    <script type="text/javascript" src="{$app_js_path}/jquery/icheck/icheck.js"></script>
    {/if}
    {if !$logout}
        {if $leafSecure >= 1}
        <script type="text/javascript" src="{$app_js_path}/LEAF/sessionTimeout.js"></script>
        {else}
        <script type="text/javascript" src="{$app_js_path}/LEAF/sessionAnnounce.js"></script>
        {/if}
    {/if}
{section name=i loop=$javascripts}
    <script type="text/javascript" src="{$javascripts[i]}"></script>
{/section}
    <link rel="icon" href="vafavicon.ico" type="image/x-icon" />
</head>
<body>
{if $smarty.get.a == ''}
    <a href="#searchContainer" id="nav-skip-link">Skip to Search</a>
{else}
    <a href="#bodyarea" id="nav-skip-link">Skip to main content</a>
{/if}

{if $smarty.server.HTTP_HOST === 'leaf-preprod.va.gov'}
    <div style="position: fixed; z-index: 9999; width: 100%; background-color: rgba(255,255,100,0.75); text-align: center;">PREPROD TESTING</div>
{/if}
{if $smarty.server.HTTP_HOST === 'leaf.apps.vapo-aws-ppd.va.gov'}
    <div style="position: fixed; z-index: 9999; width: 100%; background-color: rgba(255,255,100,0.75); text-align: center;">VAPO TESTING</div>
{/if}
<header id="header">
    {if $qrcodeURL != ''}
    <div style="float: left"><img class="print nodisplay" style="width: 72px" src="{$abs_portal_path}/qrcode/?encode={$qrcodeURL}" alt="QR code" /></div>
    {/if}
    <a href="./" style="cursor:pointer">
      <img src="images/VA_icon_small.png" style="width: 80px" alt="VA seal, U.S. Department of Veterans Affairs" />
      <span id="headerLabel">{$city|sanitize}</span>
      <h1 id="headerDescription">{$title|sanitize}</h1>
    </a>
    <span id="headerHelp">
        {if $leafSecure == 0}
        <div class="warning" style="display: inline">
            <i class="fas fa-exclamation-circle" alt=""></i>
            <span>Do not enter PHI/PII.</span>
        </div>
        {/if}
        {$login}</span>
    <span id="headerLogin"></span>
    <span id="headerTab">{$emergency}{$tabText|sanitize}</span>
    <span id="headerTabImg"><img src="images/tab.png" alt="" /></span>
    <span id="headerMenu" class="noprint">{$menu}</span>
</header>

<main id="body">
    <div id="content">
        {if $status != ''}
        <div class="alert"><span>{$status}</span></div>
        {/if}
        <div id="bodyarea">
            {$body}
        </div>
    </div>
</main>

<footer class="noprint" id="footer"{if $hideFooter == true} style="visibility: hidden; display: none"{/if}>
    <br /><br /><a id="versionID" href="?a=about">{$smarty.const.PRODUCT_NAME}<br />Version {$smarty.const.VERSION_NUMBER} r{$revision}</a>
</footer>
</body>
</html>{/strip}
