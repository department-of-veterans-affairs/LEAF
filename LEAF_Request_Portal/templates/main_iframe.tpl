{strip}<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    {if $tabText != ''}
    <title>{$tabText|sanitize} - {$title|sanitize} | {$city|sanitize}</title>
    {else}
    <title>{$title|sanitize} | {$city|sanitize}</title>
    {/if}
    <style type="text/css" media="screen">
        @import "../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
{section name=i loop=$stylesheets}
        @import "{$stylesheets[i]}";
{/section}
        @import "css/style.css";
        @import "../libs/js/jquery/chosen/chosen.min.css";
        @import "../libs/js/jquery/trumbowyg/ui/trumbowyg.min.css";
        @import "../libs/js/jquery/icheck/skins/square/blue.css";
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
{section name=i loop=$javascripts}
    <script type="text/javascript" src="{$javascripts[i]}"></script>
{/section}
</head>
<body>
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
</body>
</html>{/strip}
