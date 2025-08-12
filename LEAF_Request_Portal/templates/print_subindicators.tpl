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
                <!--{if $indicator.conditions != '' && $indicator.conditions !== 'null'}-->
                <script type="text/javascript">
                    if (typeof formPrintConditions !== 'undefined') {
                        formPrintConditions["id<!--{$indicator.indicatorID}-->"] = {
                            conditions:<!--{$indicator.conditions|strip_tags}-->,
                            format:'<!--{$indicator.format}-->'
                        };
                    }
                </script>
                <!--{/if}-->
                <!--{if $indicator.format == null || $indicator.format == 'textarea'}-->
                <!--{assign var='colspan' value=2}-->
                <!--{else}-->
                <!--{assign var='colspan' value=1}-->
                <!--{/if}-->
        <!--{if $depth == 0}-->
      <div class="printmainblock">
        <div class="printmainlabel">
            <div class="printcounter" style="cursor: pointer" onclick="toggleZoom('data_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->')"><span><!--{counter}--></span></div>
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div id="PHindicator_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" class="printheading_missing">
            <!--{else}-->
                <div id="PHindicator_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->" class="printheading">
            <!--{/if}-->
            <div style="float: right">
            <!--{if $date < $indicator.timestamp && $date > 0}-->
                <img src="dynicons/?img=appointment.svg&amp;w=16" alt="View History" title="View History" style="cursor: pointer" onclick="getIndicatorLog(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->)" tabindex="0" role="button" onkeydown="if (event.keyCode==13){ getIndicatorLog(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->); }"/>&nbsp;
            <!--{/if}-->
            <!--{if $indicator.isWritable == 0}-->
                <img src="dynicons/?img=emblem-readonly.svg&amp;w=16" alt="Read-only" title="Read-only" tabindex="0" role="button" />
            <!--{else}-->
                <button type="button"
                    style="width: 16px; height: 16px; padding: 0; border: 0; background-image: url('dynicons/?img=accessories-text-editor.svg&amp;w=16'); cursor: pointer;"
                    alt="Edit <!--{$indicator.name|sanitizeRichtext|strip_tags}--> field"
                    title="Edit <!--{$indicator.name|sanitizeRichtext|strip_tags}--> field"
                    onclick="getForm(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->)" tabindex="0" role="button">
                </button>
            <!--{/if}-->
            </div>
            <!--{if $indicator.isWritable == 0}-->
            <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags}-->"><!--{$indicator.name|sanitizeRichtext|strip_tags}--></span>
            <!--{else}-->
            <span class="printsubheading" style="cursor: pointer" title="indicatorID: <!--{$indicator.indicatorID|strip_tags}-->" onclick="getForm(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->)"><!--{$indicator.name|sanitizeRichtext|strip_tags}--></span>
            <!--{/if}-->
        <!--{else}-->
      <div class="printsubblock" id="subIndicator_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->">
        <div class="printsublabel">
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div class="printsubheading_missing">
            <!--{else}-->
                <div class="printsubheading"<!--{if $indicator.name == ''}--> style="display: none"<!--{/if}-->>
            <!--{/if}-->
            <!--{if $indicator.format == null}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags}-->"><!--{$indicator.name|sanitizeRichtext|strip_tags|indent:$depth:""}--></span>
            <!--{else}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID|strip_tags}-->"><!--{$indicator.name|sanitizeRichtext|strip_tags|indent:$depth:""}--></span>
            <!--{/if}-->
            <!--{if $date < $indicator.timestamp && $date > 0}-->
                &nbsp;<img src="dynicons/?img=appointment.svg&amp;w=16" alt="View History" title="View History" style="cursor: pointer" onclick="getIndicatorLog(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->)" tabindex="0" role="button" onkeydown="if (event.keyCode==13){ getIndicatorLog(<!--{$indicator.indicatorID|strip_tags}-->, <!--{$indicator.series|strip_tags}-->); }"/>
            <!--{/if}-->
        <!--{/if}-->
            </div>
            <div class="printResponse<!--{if $indicator.is_sensitive == 1}--> sensitiveIndicator<!--{/if}-->" id="xhrIndicator_<!--{$indicator.indicatorID|strip_tags}-->_<!--{$indicator.series|strip_tags}-->">

                <!--{include file=$printSubindicatorsAjaxTemplate}-->
            </div><!-- end print reponse -->
        </div><!-- end print sublabel -->
        </div><!-- end print block -->
        <!--{if $depth == 0}-->
        <br style="clear: both" />
        <!--{/if}-->
    <!--{/foreach}-->
    </div>
    <br />
    <!--{/if}-->
<!--{/strip}-->
