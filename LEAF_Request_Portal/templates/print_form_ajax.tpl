<!-- form -->
<br />
<div class="printmainform" style="border-bottom: 0px; min-height: 64px">
    <div id="requestTitle"><!--{$title|sanitize}--> <!--{$subtype|sanitize}-->
    <!--{if $submitted == 0 || $is_admin}-->
        <img src="dynicons/?img=accessories-text-editor.svg&amp;w=16" style="cursor: pointer" alt="" title="Edit Title" onclick="changeTitle()" tabindex="0" role="button" onkeydown="if (event.keyCode==13){ changeTitle(); }" />
    <!--{/if}-->

    <br /><span style="font-weight: normal; color: #686868; font-style: italic"><!--{$categoryText|sanitize}--></span>
    </div>
    <div id="requestInfo">
        <table>
            <tr>
                <td><!--{if $service != ''}-->Service<!--{else}-->&nbsp;<!--{/if}-->
                </td>
                <td><b><!--{$service|sanitize}--></b>
                    <!--{if $submitted == 0}-->
                        <img src="dynicons/?img=accessories-text-editor.svg&amp;w=16" style="cursor: pointer" alt="Edit Service" title="Edit Service" onclick="changeService()" role="button" tabindex="0" onkeydown="if (event.keyCode==13){ changeService(); }"/>
                    <!--{/if}-->
                </td>
            </tr>
            <tr>
                <td>Initiated by</td>
                <td><b><!--{$name|sanitize}--></b></td>
            </tr>
            <tr<!--{if $date == 0}--> style="display: none"<!--{/if}-->>
                <td>Submitted</td>
                <td><b><!--{if $date > 0}--><!--{$date|date_format:"%A, %B %e, %Y"}--><!--{else}-->Not submitted<!--{/if}--></b></td>
            </tr>
        </table>
    </div>
    <br class="noprint" style="clear: both"/>
</div>
<div class="tags<!--{if count($tags) == 0}--> noprint<!--{/if}-->" id="tags" style="border: 1px solid black; padding: 2px; text-align: right" role="status" aria-live="polite">
    <!--{include file="print_form_ajax_tags.tpl" tags=$tags}-->
</div>

<div class="printmainform">
    <!--{include file=$printSubindicatorsTemplate form=$form orgchartPath=$orgchartPath}-->
</div>


<br /><br />
