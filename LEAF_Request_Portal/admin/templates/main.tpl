{strip}<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {if $tabText != ''}
        <title>{$tabText} - {$title} | {$city}</title>
    {else}
        <title>{$title} | {$city}</title>
    {/if}
    <style type="text/css" media="screen">
        @import "../../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        {section name=i loop=$stylesheets}
            @import "{$stylesheets[i]}";
        {/section}
        @import "../../libs/js/jquery/chosen/chosen.min.css";
        @import "../../libs/js/jquery/trumbowyg/ui/trumbowyg.min.css";
        @import "../../libs/js/jquery/icheck/skins/square/blue.css";
        @import "css/style.css";
        @import "../../libs/css/leaf.css";
    </style>
    <style type="text/css" media="print">
        @import "css/printer.css";
    </style>

    <script type="text/javascript" src="../../libs/js/jquery/jquery.min.js"></script>

    {if $useUI == true}
        <script type="text/javascript" src="../../libs/js/jquery/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="../js/dialogController.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/trumbowyg/trumbowyg.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/icheck/icheck.js"></script>
    {else if $useLiteUI == true}
        <script type="text/javascript" src="../js/dialogController.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/trumbowyg/trumbowyg.min.js"></script>
        <script type="text/javascript" src="../../libs/js/jquery/icheck/icheck.js"></script>
    {/if}
    {if $leafSecure >= 1}
        <script type="text/javascript" src="../../libs/js/LEAF/sessionTimeout.js"></script>
    {/if}
    {section name=i loop=$javascripts}
        <script type="text/javascript" src="{$javascripts[i]}"></script>
    {/section}
    <script type="text/javascript" src="../../libs/js/vue-dest/leaf-vue-main.js" defer></script>
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
</head>

<body>
    <div id="vue-app-mount">
        <transition name="warn">
        <scrolling-leaf-warning v-show="windowTop > 0" prop-secure='{$leafSecure}'>Do Not Enter PHI / PII</scrolling-leaf-warning>
        </transition>

        <header id="vue-leaf-header" aria-label="Official government website">
            <header-top v-if="!retracted.refBool" prop-secure='{$leafSecure}' qrcode-url='{$qrcodeURL}'
                        title='{$title}' city='{$city}' logo='{$logo}'></header-top>
            {$emergency}
            <header-nav main-view='portalAdmin' orgchart-path='{$orgchartPath}' site-type='{$siteType}'
                        name='{$name}' :inner-width="windowInnerWidth"></header-nav>
        </header>
    </div>

    <div id="body">
        {if $status != ''}
            <div class="lf-alert">{$status}</div>
        {/if}
        <div id="bodyarea" class="default-container">
            {$body}
        </div>
    </div>

    <footer class="usa-footer leaf-footer noprint" id="footer" {if $hideFooter == true} style="visibility: hidden; display: none"{/if}>
        <a id="versionID" href="../?a=about">{$smarty.const.PRODUCT_NAME}<br />Version {$smarty.const.VERSION_NUMBER} r{$revision}</a>
    </footer>
</body>
</html>{/strip}
