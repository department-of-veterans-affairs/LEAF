<!-- form -->
<br />
<div class="printmainform" style="border-bottom: 0px; min-height: 64px">
    <div id="requestTitle"><!--{$title|sanitize}--> <!--{$subtype|sanitize}-->
    <!--{if $submitted == 0 || $is_admin}-->
        <button style="cursor: pointer; background-image: url(../libs/dynicons/?img=accessories-text-editor.svg&w=16); border: none; background-repeat: no-repeat; display:inline-block; width: 30px; display:inline-block; height: 30px; background-position: bottom; background-color: #FEFEFE;" alt="Edit Title" title="Edit Title" onclick="changeTitle()" />
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
                        <button style="cursor: pointer; background-image: url(../libs/dynicons/?img=accessories-text-editor.svg&w=16); border: none; background-repeat: no-repeat; display:inline-block; width: 30px; display:inline-block; height: 30px; background-position: bottom; background-color: #FEFEFE;" alt="Edit Service" title="Edit Service" onclick="changeService()" />
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
    <!--{include file="print_subindicators.tpl" form=$form orgchartPath=$orgchartPath}-->
</div>


<br /><br />
