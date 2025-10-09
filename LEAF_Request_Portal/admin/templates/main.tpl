{strip}<!DOCTYPE html>
<html lang="en">
<head>
    <script>
    if(navigator.userAgent.indexOf("Trident") != -1) {
        alert('Please use Microsoft Edge or Google Chrome to access this site.');
    }
    </script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {if $tabText != ''}
        <title>{$tabText} - {$title}, {$city}</title>
    {else}
        <title>{$title}, {$city}</title>
    {/if}
    <style type="text/css" media="screen">
        @import "{$app_js_path}/jquery/css/dcvamc/jquery-ui.custom.min.css";
        {section name=i loop=$stylesheets}
            @import "{$stylesheets[i]}";
        {/section}
        @import "{$app_js_path}/jquery/chosen/chosen.min.css";
        @import "{$app_js_path}/jquery/trumbowyg/ui/trumbowyg.min.css";
        @import "css/style.css";
        @import "{$app_css_path}/leaf.css";
    </style>
    <style type="text/css" media="print">
        @import "css/printer.css";
        #qrcode-js {
            display: block !important;
        }
        #qrcode-js * {
            display: block !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
    </style>
    <script type="text/javascript" src="{$app_js_path}/jquery/jquery.min.js"></script>
    {if $useUI == true}
        <script type="text/javascript" src="{$app_js_path}/jquery/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="../js/dialogController.js"></script>
        <script type="text/javascript" src="{$app_js_path}/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="{$app_js_path}/jquery/trumbowyg/trumbowyg.min.js"></script>
    {else if $useLiteUI == true}
        <script type="text/javascript" src="../js/dialogController.js"></script>
        <script type="text/javascript" src="{$app_js_path}/jquery/chosen/chosen.jquery.min.js"></script>
        <script type="text/javascript" src="{$app_js_path}/jquery/trumbowyg/trumbowyg.min.js"></script>
    {/if}
    {if $leafSecure >= 1}
        <script type="text/javascript" src="{$app_js_path}/LEAF/sessionTimeout.js"></script>
    {else}
        <script type="text/javascript" src="{$app_js_path}/LEAF/sessionAnnounce.js"></script>
    {/if}
    {section name=i loop=$javascripts}
        <script type="text/javascript" src="{$javascripts[i]}"></script>
    {/section}
    {if $qrcodeURL != ''}
    <script type="text/javascript" src="{$app_js_path}/qrcode.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            new QRCode(document.getElementById("qrcode-js"), {
                text: "{$qrcodeURL}",
                width: 72,
                height: 72,
                colorDark: "#000000",
                colorLight: "#ffffff",
                correctLevel: QRCode.CorrectLevel.H
            });
        });
    </script>
    {/if}
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
</head>

<body>
    <a href="#bodyarea" id="nav-skip-link">Skip to main content</a>
    {if $smarty.server.HTTP_HOST === 'leaf-preprod.va.gov'}
        <div style="position: fixed; z-index: 9999; width: 100%; background-color: rgba(255,255,100,0.75); text-align: center;">PREPROD TESTING</div>
    {/if}
    {if $leafSecure == 0}
    <section class="usa-banner bg-orange-topbanner" aria-label="Official government website">
        <header class="usa-banner__header">
            <div class="grid-col-fill tablet:grid-col-auto">
                <p class="usa-banner__header-text text-white lf-alert">
                    &nbsp;Do not enter PHI/PII
                </p>
            </div>
        </header>
    </section>
    {/if}

    <header id="header" class="usa-header site-header">
        <div class="usa-navbar site-header-navbar" style="position:relative;">
            <div class="usa-logo site-logo" id="logo">
                <em class="usa-logo__text">
                    <a tabindex="0" onclick="window.location='./'" title="Admin Home" class="leaf-cursor-pointer">
                        <span class="leaf-logo">{$logo}</span>
                        <span id="headerLabel" class="leaf-site-title">{$city}</span>
                        <span id="headerDescription" class="leaf-header-description">{$title}</span>
                    </a>
                </em>
                <div style="float: left;"><div id="qrcode-js" style="width: 72px; display: none;" ></div></div>
            </div>
            <div style="position:absolute;right:0;top:0;padding:0 0.75rem;font-size:14px;">
                Welcome, <b>{$display_name|sanitize}</b>! | <a href="../?a=logout" style="color:#00bde3">Sign out</a>
            </div>
            <div class="leaf-header-right">
                {$emergency}<!--{$login}-->
                <nav aria-label="main menu" id="nav">{$menu}</nav>
            </div>
        </div>
    </header>

    <main id="body">
        {if $status != ''}
            <div class="lf-alert">{$status}</div>
        {/if}
        <div id="bodyarea" class="default-container">
            {$body}
        </div>
    </main>

    <footer class="usa-footer leaf-footer noprint" id="footer" {if $hideFooter == true} style="visibility: hidden; display: none"{/if}>
        <a id="versionID" href="../?a=about">{$smarty.const.PRODUCT_NAME}<br />Version {$smarty.const.VERSION_NUMBER} r{$revision}</a>
    </footer>

</body>
</html>{/strip}
