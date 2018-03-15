<style>
.item label {
    font-size: 120%;
    font-weight: bold;
    width: 250px;
}

.item {
    padding-bottom: 16px;
}
</style>

<h2 id="progress" style="color: red; text-align: center">
</h2>

<div style="width: 70%; margin: auto">
    <div style="border: 2px solid black; margin: 4px; background-color: white; padding: 16px">
        <div class="item">
        <label for="heading">Title of LEAF site:&nbsp;</label>
        <input id="heading" type="text" title="" value="<!--{$heading}-->" />
        </div>

        <div class="item">
        <label for="subHeading">Facility Name:&nbsp;</label>
        <input id="subHeading" type="text" title="" value="<!--{$subheading}-->" />
        </div>

        <div class="item">
        <label for="timeZone">Time Zone:&nbsp;</label>
        <select id="timeZone">
            <!--{foreach from=$timeZones item=tz}-->
                <!--{if $timeZone == $tz}-->
                    <option value="<!--{$tz}-->" selected="selected"><!--{$tz}--></option>
                <!--{else}-->
                    <option value="<!--{$tz}-->"><!--{$tz}--></option>
                <!--{/if}-->
            <!--{/foreach}-->
        </select>
        </div>

        <div class="item">
        <label for="requestLabel">Label for "Request":&nbsp;</label>
        <input id="requestLabel" type="text" title="" value="<!--{$requestLabel}-->" />
        </div>

<br />
        <div class="item">
        <label for="subHeading">Import Tags [<a href="#" title="Groups in the Org. Chart with any one of these tags will be imported for use">?</a>]:&nbsp;</label>
            <span style="font-style: italic">
            <!--{foreach from=$importTags item=importTag}-->
                <!--{$importTag}--><br />
            <!--{/foreach}-->
            </span>
        </div>

        <button class="buttonNorm" onclick="saveSettings();" style="float: right"><img src="../../libs/dynicons/?img=media-floppy.svg&w=32" alt="save icon" /> Save</button>
        <br /><br />
    </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script type="text/javascript">
var CSRFToken = '<!--{$CSRFToken}-->';

function saveSettings()
{
    $.when(
            $.ajax({
                type: 'POST',
                url: '../api/?a=system/settings/heading',
                data: {heading: $('#heading').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=system/settings/subHeading',
                data: {subHeading: $('#subHeading').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=system/settings/requestLabel',
                data: {requestLabel: $('#requestLabel').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=system/settings/timeZone',
                data: {timeZone: $('#timeZone').val(),
                    CSRFToken: '<!--{$CSRFToken}-->'},
                success: function(res) {
                }
            })
         ).then(function() {
        	 $('#progress').html('Settings saved.');
        	 $('#progress').fadeIn(10, function() {
                 $('#progress').fadeOut(2000);
        	 });
         });
}

var dialog, dialog_confirm;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

});

</script>
