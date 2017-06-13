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
      <div class="printmainblock">
        <div class="printmainlabel">
            <div class="printcounter" style="cursor: pointer" onclick="toggleZoom('data_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->')"><span><!--{counter}--></span></div>
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div id="PHindicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" class="printheading_missing">
            <!--{else}-->
                <div id="PHindicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" class="printheading">
            <!--{/if}-->
            <div style="float: right">
            <!--{if $date < $indicator.timestamp && $date > 0}-->
                <img src="../libs/dynicons/?img=appointment.svg&amp;w=16" alt="View History" title="View History" style="cursor: pointer" onclick="getIndicatorLog(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)" />&nbsp;
            <!--{/if}-->
            <!--{if $indicator.isWritable == 0}-->
                <img src="../libs/dynicons/?img=emblem-readonly.svg&amp;w=16" alt="Read-only" title="Read-only" />
            <!--{else}-->
                <img src="../libs/dynicons/?img=accessories-text-editor.svg&amp;w=16" alt="Edit this field" title="Edit this field" style="cursor: pointer" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)" />
            <!--{/if}-->
            </div>
            <!--{if $indicator.isWritable == 0}-->
            <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID}-->"><!--{$indicator.name}--></span>
            <!--{else}-->
            <span class="printsubheading" style="cursor: pointer" title="indicatorID: <!--{$indicator.indicatorID}-->" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)"><!--{$indicator.name}--></span>
            <!--{/if}-->
        <!--{else}-->
      <div class="printsubblock" id="subIndicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
        <div class="printsublabel">
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div class="printsubheading_missing">
            <!--{else}-->
                <div class="printsubheading"<!--{if $indicator.name == ''}--> style="display: none"<!--{/if}-->>
            <!--{/if}-->
            <!--{if $indicator.format == null}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID}-->"><!--{$indicator.name|indent:$depth:""}--></span>
            <!--{else}-->
                <span class="printsubheading" title="indicatorID: <!--{$indicator.indicatorID}-->"><!--{$indicator.name|indent:$depth:""}--></span>
            <!--{/if}-->
            <!--{if $date < $indicator.timestamp && $date > 0}-->
                &nbsp;<img src="../libs/dynicons/?img=appointment.svg&amp;w=16" alt="View History" title="View History" style="cursor: pointer" onclick="getIndicatorLog(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)" />
            <!--{/if}-->
        <!--{/if}-->
            </div>
            <div class="printResponse" id="xhrIndicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">

                <!--{include file="print_subindicators_ajax.tpl"}-->

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