<!--{strip}-->
    <!--{if !isset($depth)}-->
    <!--{assign var='depth' value=0}-->
    <!--{/if}-->

    <!--{if $depth == 0}-->
    <!--{assign var='color' value='#e0e0e0'}-->
    <!--{else}-->
    <!--{assign var='color' value='white'}-->
    <!--{/if}-->

    <!--{if $form}-->
    <div class="printformblock">
    <!--{foreach from=$form item=indicator}-->
                <!--{if $indicator.format == null || $indicator.format == 'textarea'}-->
                <!--{assign var='colspan' value=2}-->
                <!--{else}-->
                <!--{assign var='colspan' value=1}-->
                <!--{/if}-->
        <!--{if $depth == 0}-->
      <div id="mainblock_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$uid}-->" class="printmainblock<!--{if ($indicator.required == 0 && $indicator.data == '') || $indicator.format == 'json'}--> notrequired<!--{/if}-->">
        <div class="printmainlabel">
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div role="button" tabindex="0" id="PHindicator_<!--{$indicator.indicatorID|strip_tags|escape}-->" class="printheading_missing" style="cursor: pointer" onkeydown="triggerClick(event, 'PHindicator_<!--{$indicator.indicatorID|strip_tags|escape}-->')" onclick="orgchartForm.getForm(<!--{$uid|strip_tags|escape}-->, <!--{$categoryID|strip_tags|escape}-->, <!--{$indicator.indicatorID|strip_tags|escape}-->);">
            <!--{else}-->
                <div role="button" tabindex="0" id="PHindicator_<!--{$indicator.indicatorID|strip_tags|escape}-->" class="printheading" style="cursor: pointer" onkeydown="triggerClick(event, 'PHindicator_<!--{$indicator.indicatorID|strip_tags|escape}-->')" onclick="orgchartForm.getForm(<!--{$uid|strip_tags|escape}-->, <!--{$categoryID|strip_tags|escape}-->, <!--{$indicator.indicatorID|strip_tags|escape}-->);">
            <!--{/if}-->
            <div style="float: left">
            <!--{if $date < $indicator.timestamp && $date > 0}-->
                <img src="dynicons/?img=appointment.svg&amp;w=16" alt="View History" title="View History" style="cursor: pointer" onclick="getIndicatorLog(<!--{$indicator.indicatorID|escape}-->); $('#histdialog1').dialog('open')" />&nbsp;
            <!--{/if}-->
            <!--{if $indicator.isWritable == 0}-->
                <img src="dynicons/?img=emblem-readonly.svg&amp;w=16" alt="Read-only" title="Read-only" />&nbsp;
            <!--{else}-->
                <img src="dynicons/?img=accessories-text-editor.svg&amp;w=16" alt="Edit this field" title="Edit this field" style="cursor: pointer" />&nbsp;
            <!--{/if}-->
            </div>
            <!--{if $indicator.isWritable == 0}-->
            <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags|escape}-->"><!--{$indicator.name|strip_tags|escape}-->: </span>
            <!--{else}-->
            <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags|escape}-->"><!--{$indicator.name|strip_tags|escape}-->: </span>
            <!--{/if}-->
            <span class="printResponse" id="xhrIndicator_<!--{$indicator.indicatorID|strip_tags|escape}-->_<!--{$categoryID|strip_tags|escape}-->_<!--{$uid}-->">
                <!--{include file="print_subindicators_ajax.tpl"}-->
            </span>

        <!--{else}-->
      <div class="printsubblock">
        <div class="printsublabel">
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div class="printsubheading_missing">
            <!--{else}-->
                <div class="printsubheading">
            <!--{/if}-->
            <!--{if $indicator.format == null}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags|escape}-->"><!--{$indicator.name|strip_tags|escape|indent:$depth:""}--></span>
            <!--{else}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags|escape}-->"><!--{$indicator.name|strip_tags|escape|indent:$depth:""}--></span>
            <!--{/if}-->
        <!--{/if}-->
            <br style="clear: both" />
            </div>
        </div><!-- end print sublabel -->
        </div><!-- end print block -->
        <!--{if $depth == 0}-->

        <!--{/if}-->
    <!--{/foreach}-->
    </div>

    <span role="button" tabindex="0" class="tempText" id="showallfields" style="float: right; text-decoration: underline; font-size: 80%; cursor: pointer" onkeydown="triggerClick(event, 'showallfields')" onclick="showAllFields(); announceAction('showing all fields');">Show_all_fields</span>
    <br />
    <!--{/if}-->
<!--{/strip}-->
<script type="text/javascript">
    function triggerClick(e, id) {
        if(e.keyCode === 13) {
            $('#' + id).trigger('click');
        }
    }
    function announceAction(actionName) {
        $('#buttonClick').attr('aria-label', actionName);
    }
    function showAllFields() {
        $('.printformblock').css('display', 'inline');
        $('.notrequired:not(#tools button.options)').css('display', 'inline');
        $('.tempText').css('display', 'none');
    }
</script>
