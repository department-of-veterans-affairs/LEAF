{strip}<!DOCTYPE html>
<html lang="en">
<head>
    {if $tabText != ''}
    <title>{$tabText|sanitize} - {$title|sanitize} | {$city|sanitize}</title>
    {else}
    <title>{$title|sanitize} | {$city|sanitize}</title>
    {/if}
    <style type="text/css" media="screen">
        {if $useDojo == true && $useDojoUI == true}
        @import "../libs/js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        @import "../libs/js/jquery/chosen/chosen.min.css";
        {/if}
        @import "css/style.css";
{section name=i loop=$stylesheets}
        @import "{$stylesheets[i]}";
{/section}
    </style>
    <style type="text/css" media="print">
        @import "css/printer.css";
{section name=i loop=$stylesheets_print}
        @import "{$stylesheets_print[i]}";
{/section}
    </style>
    {if $useDojo == true}
    <script type="text/javascript" src="../libs/js/jquery/jquery.min.js"></script>
        {if $useDojoUI == true}<script type="text/javascript" src="../libs/js/jquery/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="../libs/js/jquery/chosen/chosen.jquery.min.js"></script>
        {/if}
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
