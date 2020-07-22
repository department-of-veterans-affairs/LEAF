<div style="width: 90%; margin: auto">
    <div class="item" style="border: 2px solid black; float: left; margin: 4px; background-color: white; padding: 16px">
        <div class="item">
        <label for="heading">Site Heading:&nbsp;</label>
        <input id="heading" type="text" style="width: 300px" title="" value="<!--{$heading}-->" />
        </div>

        <div class="item">
        <label for="subHeading">Site Sub-heading:&nbsp;</label>
        <input id="subHeading" type="text" style="width: 300px" title="" value="<!--{$subheading}-->" />
        </div>

        <div class="item">
        <label for="leadershipName">Leadership Nomenclature:&nbsp;</label>
        <select id="leadershipName" style="width: 300px" title="">
            <option value="quadrad" <!--{if $serviceParent == 'quadrad'}-->selected<!--{/if}--> >Quadrad</option>
            <option value="pentad" <!--{if $serviceParent == 'pentad'}-->selected<!--{/if}--> >Pentad</option>
            <option value="ELT" <!--{if $serviceParent == 'ELT'}-->selected<!--{/if}--> >ELT</option>
            <option value="VISN" <!--{if $serviceParent == 'VISN'}-->selected<!--{/if}--> >VISN</option>
        </select>
        </div>

        <div class="item">
        <label for="timeZone">Time Zone:&nbsp;</label>
        <select id="timeZone">
            <!--{foreach from=$timeZones item=tz}-->
                <option 
                    value="<!--{$tz}-->" 
                
                    <!--{if $tz eq $timeZone}-->
                        selected
                    <!--{/if}-->
                    >
                    <!--{$tz}-->
                </option>
            <!--{/foreach}-->
        </select>
        </div>

        <button class="buttonNorm" onclick="saveSettings();">Save</button>
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
                    CSRFToken: CSRFToken},
                success: function(res) {
                }
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=system/settings/subHeading',
                data: {subHeading: $('#subHeading').val(),
                    CSRFToken: CSRFToken},
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
            }),
            $.ajax({
                type: 'POST',
                url: '../api/?a=tag/_service/parent',
                data: {parentTag: $('#leadershipName').val(),
                    CSRFToken: CSRFToken},
                success: function(res) {
                }
            })
         ).then(function() {
             location.reload();
         });
}

var dialog, dialog_confirm;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
    dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

});

</script>
