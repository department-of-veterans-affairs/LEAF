    {if !isset($depth)}
    {assign var='depth' value=0}
    {/if}

    {if $depth == 0}
    {assign var='color' value='#e0e0e0'}
    {else}
    {assign var='color' value='white'}
    {/if}

    {if $form}
    <div class="formblock">
    {foreach from=$form item=indicator}
    {strip}
                {if $indicator.format == null || $indicator.format == 'textarea'}
                {assign var='colspan' value=2}
                {else}
                {assign var='colspan' value=1}
                {/if}

                {if $depth == 0}
        <div class="mainlabel">
            <div>
            <span>
                <b>{$indicator.name}</b><br />
            </span>
            </div>
                {else}
        <div class="sublabel">
            <span>
                    {if $indicator.format == null}
                        <br /><b>{$indicator.name|indent:$depth:""}</b>
                    {else}
                        <br />{$indicator.name|indent:$depth:""}
                    {/if}
            </span>
                {/if}
        </div>
        <div class="response">
        {if $indicator.isMasked == 1 && $indicator.data != ''}
            <span class="text">
                [protected data]
            </span>
        {/if}
        {if $indicator.format == 'textarea' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><div style="width: 99%" dojoType="dijit.Editor" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" plugins="['undo', 'redo', '|', 'copy', 'cut', 'paste', '|', 'bold', 'italic', 'underline', '|', 'insertOrderedList', 'insertUnorderedList', 'indent', 'outdent']">{$indicator.data}</div>
            </span>
        {/if}
        {if $indicator.format == 'radio' && ($indicator.isMasked == 0 || $indicator.data == '')}
                <span id="parentID_{$indicator.parentID}">
            {foreach from=$indicator.options item=option}
                {if is_array($option)}
                    {assign var='option' value=$option[0]}
                    {if $option == $indicator.data}
                        <br /><input dojoType="dijit.form.RadioButton" type="radio" name="{$indicator.indicatorID}" value="{$option}" checked="checked" />
                        {$option}
                    {else}
                        <br /><input dojoType="dijit.form.RadioButton" type="radio" name="{$indicator.indicatorID}" value="{$option}" />
                        {$option}
                    {/if}
                {elseif $option == $indicator.data}
                    <br /><input dojoType="dijit.form.RadioButton" type="radio" name="{$indicator.indicatorID}" value="{$option}" checked="checked" />
                    {$option}
                {else}
                    <br /><input dojoType="dijit.form.RadioButton" type="radio" name="{$indicator.indicatorID}" value="{$option}" />
                    {$option}
                {/if}
            {/foreach}
                </span>
        {/if}
        {if $indicator.format == 'dropdown' && ($indicator.isMasked == 0 || $indicator.data == '')}
                <span><select name="{$indicator.indicatorID}" dojoType="dijit.form.FilteringSelect" style="width: 50%">
            {foreach from=$indicator.options item=option}
                {if is_array($option)}
                    {assign var='option' value=$option[0]}
                    {if $option == $indicator.data}
                        <option value="{$option}" selected="selected">{$option}</option>
                    {else}
                        <option value="{$option}">{$option}</option>
                    {/if}
                {elseif $option == $indicator.data}
                    <option value="{$option}" selected="selected">{$option}</option>
                    {$option}
                {else}
                    <option value="{$option}">{$option}</option>
                {/if}
            {/foreach}
                </select></span>
        {/if}
        {if $indicator.format == 'text' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.ValidationTextBox" type="text" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" value="{$indicator.data}" trim="true" style="width: 50%" {$indicator.html} />
            </span>
        {/if}
        {if $indicator.format == 'number' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.NumberTextBox" type="text" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" value="{$indicator.data}" {$indicator.html} />
            </span>
        {/if}
        {if $indicator.format == 'numberspinner' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.NumberSpinner" type="text" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" value="{$indicator.data}" {$indicator.html} />
            </span>
        {/if}
        {if $indicator.format == 'date' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.DateTextBox" type="text" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" value="{$indicator.data}" {$indicator.html} />
            </span>
        {/if}
        {if $indicator.format == 'time' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.TimeTextBox" type="text" name="{$indicator.indicatorID}" value="{$indicator.data}" {$indicator.html} />
            </span>
        {/if}
        {if $indicator.format == 'currency' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <span class="text">
                <br /><input dojoType="dijit.form.CurrencyTextBox" currency="USD" invalidMessage="Please enter an amount in USD" type="text" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" value="{$indicator.data}" {$indicator.html} /> (Amount in USD)
            </span>
        {/if}
        {if $indicator.format == 'checkbox' && ($indicator.isMasked == 0 || $indicator.data == '')}
                <span id="parentID_{$indicator.parentID}">
                    <input type="hidden" name="{$indicator.indicatorID}" value="no" /> <!-- dumb workaround -->
            {foreach from=$indicator.options item=option}
                {if $option == $indicator.data}
                    <br /><input dojoType="dijit.form.CheckBox" type="checkbox" name="{$indicator.indicatorID}" value="{$option}" checked="checked" />
                    {$option}
                {else}
                    <br /><input dojoType="dijit.form.CheckBox" type="checkbox" name="{$indicator.indicatorID}" value="{$option}" />
                    {$option}
                {/if}
            {/foreach}
                </span>
        {/if}
        {if $indicator.format == 'checkboxes' && ($indicator.isMasked == 0 || $indicator.data == '')}
                <span id="parentID_{$indicator.parentID}">
            {assign var='idx' value=0}
            {foreach from=$indicator.options item=option}
                    <input type="hidden" name="{$indicator.indicatorID}[{$idx}]" value="no" /> <!-- dumb workaround -->
                    {if $option == $indicator.data[$idx]}
                        <br /><input dojoType="dijit.form.CheckBox" type="checkbox" name="{$indicator.indicatorID}[{$idx}]" value="{$option}" checked="checked" />
                        {$option}
                    {else}
                        <br /><input dojoType="dijit.form.CheckBox" type="checkbox" name="{$indicator.indicatorID}[{$idx}]" value="{$option}" />
                        {$option}
                    {/if}
                    {assign var='idx' value=$idx+1}
            {/foreach}
                </span>
        {/if}
        {if $indicator.format == 'fileupload' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <fieldset>
                <legend>File Attachment</legend>
                <span class="text">
                <iframe src="ajaxIframe.php?a=getuploadprompt&amp;categoryID={$categoryID}&amp;UID={$UID}&amp;indicatorID={$indicator.indicatorID}" frameborder="0" width="440px" height="85px"></iframe><br />
                {if $indicator.data != ''}
                <span style="background-color: #b7c5ff; padding: 4px; line-height: 20px"><img src="dynicons/?img=mail-attachment.svg&amp;w=16"  alt="" /> <b>File Attached:</b> <a href="" target="_blank">{$indicator.data}</a></span>
                {/if}
                </span>
            </fieldset>
        {/if}
        {if $indicator.format == 'image' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <fieldset>
                <legend>Photo Attachment</legend>
                <span class="text">
                <iframe src="ajaxIframe.php?a=getuploadprompt&amp;categoryID={$categoryID}&amp;UID={$UID}&amp;indicatorID={$indicator.indicatorID}" frameborder="0" width="440px" height="85px"></iframe><br />
                {if $indicator.data != ''}
                <span style="background-color: #b7c5ff; padding: 4px; line-height: 20px"><img src="dynicons/?img=mail-attachment.svg&amp;w=16" alt="" /> <b>File Attached:</b> <a href="" target="_blank">{$indicator.data}</a></span>
                {/if}
                </span>
            </fieldset>
        {/if}
        {if $indicator.format == 'table' && ($indicator.isMasked == 0 || $indicator.data == '')}
            {foreach from=$indicator.options item=option}
                {if is_array($option)}
                    {assign var='option' value=$option[0]}
                    {$option} <input type="checkbox" name="{$indicator.indicatorID}[]" value="{$option}" checked="checked" /><br />
                {else}
                    {$option} <input type="checkbox" name="{$indicator.indicatorID}[]" value="{$option}" /><br />
                {/if}
            {/foreach}
        {/if}
        {if $indicator.format == 'position' && ($indicator.isMasked == 0 || $indicator.data == '')}
            <div id="posSel_{$indicator.indicatorID}"></div>
            <div dojoType="dijit.form.TextBox" id="{$indicator.indicatorID}" name="{$indicator.indicatorID}" style="visibility: hidden">
            {literal}
            <script type="dojo/method">
            	if(typeof positionSelector == 'undefined') {
                    // I am so upset with IE7
                    if(document.createStyleSheet) {
                        document.createStyleSheet('css/positionSelector.css');
                    }
                    else {
                        dojo.create('style', {type: 'text/css', media: 'screen', innerHTML: '@import "css/positionSelector.css";'}, document.getElementsByTagName('head')[0]);
                    }
/*
                    $.getScript("./js/positionSelector.js", function() {
                        var posSel = new positionSelector('posSel_{/literal}{$indicator.indicatorID}{literal}');

                        posSel.setSelectHandler(function() {
                            dojo.byId('{/literal}{$indicator.indicatorID}{literal}').value = posSel.selection;
                        });

                        posSel.initialize();
                    });
*/
                    dojo.xhrGet({
                        url: "./js/positionSelector.js",
                        handleAs: 'text',
                        load: function(response) {
                            eval(response);
                            posSel = new positionSelector('posSel_{/literal}{$indicator.indicatorID}{literal}');

                            posSel.setSelectHandler(function() {
                                dojo.byId('{/literal}{$indicator.indicatorID}{literal}').value = posSel.selection;
                            });

                            posSel.initialize();
                        }
                    });
            	}
                else {
                    posSel = new positionSelector('posSel_{/literal}{$indicator.indicatorID}{literal}');

                    posSel.setSelectHandler(function() {
                        dojo.byId('{/literal}{$indicator.indicatorID}{literal}').value = posSel.selection;
                    });

                    posSel.initialize();
                }
            </script>
            {/literal}
            </div>
        {/if}
        {include file="subindicators.tpl" form=$indicator.child depth=$depth+4 recordID=$recordID}
    {/strip}
        </div>
    {/foreach}
    </div>
    {/if}
