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
        @import "{$libsPath}js/jquery/css/dcvamc/jquery-ui.custom.min.css";
        @import "{$libsPath}js/jquery/chosen/chosen.min.css";
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
    {if $useDojo == true}<script type="text/javascript" src="{$libsPath}js/jquery/jquery.min.js"></script>
    {if $useDojoUI == true}<script type="text/javascript" src="{$libsPath}js/jquery/jquery-ui.custom.min.js"></script>{/if}
    {/if}
{section name=i loop=$javascripts}
    <script type="text/javascript" src="../{$javascripts[i]}"></script>
{/section}
    <link rel="icon" href="../vafavicon.ico" type="image/x-icon" />
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
</html>
