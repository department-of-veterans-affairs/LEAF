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
            <div class="printcounter" style="cursor: pointer"><span tabindex="0" aria-label="<!--{$indicator.indicatorID}-->"><!--{counter}--></span></div>
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div id="PHindicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" class="printheading_missing">
            <!--{else}-->
                <div id="PHindicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" class="printheading">
            <!--{/if}-->
            <div style="float: right">

            <span onkeydown="onKeyPressClick(event)" class="buttonNorm" tabindex="0" onclick="newQuestion(<!--{$indicator.indicatorID}-->);"><img src="../dynicons/?img=list-add.svg&amp;w=16" alt="" title="Add Sub-question"/> Add Sub-question</span>

            </div>
            <span class="printsubheading" style="cursor: pointer" title="indicatorID: <!--{$indicator.indicatorID}-->" >
            <!--{if $indicator.is_sensitive == 1}-->
                &nbsp;<img src="../dynicons/?img=eye_invisible.svg&amp;w=16" alt="This field is sensitive" title="This field is sensitive" />&nbsp;
            <!--{/if}-->
                <span onkeydown="onKeyPressClick(event)" tabindex="0" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)">
            <!--{if trim($indicator.name) != ''}-->
                <!--{$indicator.name|sanitizeRichtext|strip_tags}-->
            <!--{else}-->
                [ blank ]
            <!--{/if}-->
                </span>

            &nbsp;<img src="../dynicons/?img=accessories-text-editor.svg&amp;w=16" tabindex="0" onkeydown="onKeyPressClick(event)" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)" alt="Edit this field" title="Edit this field" style="cursor: pointer" />
            &nbsp;<img src="../dynicons/?img=emblem-readonly.svg&amp;w=16" tabindex="0" onkeydown="onKeyPressClick(event)" onclick="editIndicatorPrivileges(<!--{$indicator.indicatorID}-->);" alt="Edit indicator privileges" title="Edit indicator privileges" style="cursor: pointer" />
            <!--{if $indicator.has_code}-->
                &nbsp;<img src="../dynicons/?img=document-properties.svg&amp;w=16" tabindex="0" alt="Advanced Options present" title="Advanced Options present" style="cursor: pointer" />
            <!--{/if}-->
            </span>
        <!--{else}-->
      <div class="printsubblock" id="subIndicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">
        <div class="printsublabel">
            <!--{if $indicator.required == 1 && $indicator.isEmpty == true}-->
                <div class="printsubheading_missing">
            <!--{else}-->
                <div class="printsubheading">
            <!--{/if}-->
                <span class="printsubheading" style="cursor: pointer" title="indicatorID: <!--{$indicator.indicatorID}-->">
                    <!--{if $indicator.is_sensitive == 1}-->
                        &nbsp;<img src="../dynicons/?img=eye_invisible.svg&amp;w=16" alt="This field is sensitive" title="This field is sensitive" />&nbsp;
                    <!--{/if}-->
                    <span onkeydown="onKeyPressClick(event)" tabindex="0" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)">
                    <!--{if trim($indicator.name) != ''}-->
                        <!--{$indicator.name|sanitizeRichtext|strip_tags|indent:$depth:""}-->
                    <!--{else}-->
                        [ blank ]
                    <!--{/if}-->
                    </span>

                    &nbsp;<img src="../dynicons/?img=accessories-text-editor.svg&amp;w=16" tabindex="0" onkeydown="onKeyPressClick(event)" onclick="getForm(<!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->)" alt="Edit this field" title="Edit this field" style="cursor: pointer" />
                    &nbsp;<img src="../dynicons/?img=emblem-readonly.svg&amp;w=16" tabindex="0" onkeydown="onKeyPressClick(event)" onclick="editIndicatorPrivileges(<!--{$indicator.indicatorID}-->);" alt="Edit indicator privileges" title="Edit indicator privileges" style="cursor: pointer" />
                    <!--{if !$indicator.format|in_array:['raw_data']}-->
                        &nbsp;<img id="edit_conditions_<!--{$indicator.indicatorID}-->" src="../dynicons/?img=preferences-system.svg&amp;w=16" tabindex="0" onkeydown="onKeyPressClick(event)" onclick="updateVueData(<!--{$indicator.indicatorID}-->,<!--{$indicator.required}-->);" alt="Edit Conditions" title="Edit conditions" style="cursor: pointer" />
                    <!--{/if}-->
                    <!--{if $indicator.has_code}-->
                        &nbsp;<img src="../dynicons/?img=document-properties.svg&amp;w=16" tabindex="0" alt="Advanced Options present" title="Advanced Options present" style="cursor: pointer" />
                    <!--{/if}-->
                <br /><br /><span tabindex="0" class="buttonNorm" onkeydown="onKeyPressClick(event)" onclick="newQuestion(<!--{$indicator.indicatorID}-->);"><img src="../dynicons/?img=list-add.svg&amp;w=16" alt="" title="Add Sub-question"/> Add Sub-question</span>
                </span>
        <!--{/if}-->
            </div>
            <div tabindex="0" class="printResponse" id="xhrIndicator_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->">

<!--{if $indicator.format == 'grid'}-->
    <!--{$indicator.format}-->
    </br></br>
    <div id="grid<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->" style="width: 100%; max-width: 100%;">
    </div>
    <script>
        var gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}--> = new gridInput(<!--{$indicator.options[0]}-->, <!--{$indicator.indicatorID}-->, <!--{$indicator.series}-->, <!--{$recordID}-->);
        gridInput_<!--{$indicator.indicatorID}-->_<!--{$indicator.series}-->.preview();
    </script>
<!--{else}-->
    <!--{$indicator.format}-->
    <!--{if $indicator.options != ''}-->
    <ul>
        <!--{assign var="numOptions" value=0}-->
        <!--{foreach from=$indicator.options item=option}-->
        <li><!--{$option}--></li>

        <!--{if $numOptions > 5}-->
        <li>...</li>
        <!--{break}-->
        <!--{/if}-->
        <!--{assign var="numOptions" value=$numOptions+1}-->
        <!--{/foreach}-->
    </ul>
    <!--{/if}-->
<!--{/if}-->

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