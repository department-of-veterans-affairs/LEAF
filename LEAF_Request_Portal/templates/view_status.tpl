<div><a href="?a=status&amp;recordID=<!--{$recordID|strip_tags}-->"><img src="dynicons/?img=printer.svg&amp;w=16" alt="" /></a></div>
<div> <!-- main content -->
<span style="font-weight: bold; font-size: 16px">History of Request ID#: <!--{$recordID|sanitize}--></span>
<br />
Service: <!--{$service|sanitize}--><br />
Title of request: <a href="?a=printview&amp;recordID=<!--{$recordID|strip_tags|escape}-->"><!--{$title|sanitize}--></a><br /><br />

<div style="padding: 2px">
<table class="agenda" id="maintable">
<thead>
<tr>
    <th>Timestamp</th>
    <th>Action Taken</th>
</tr>
</thead>
<tr>
    <td><!--{$date|date_format:"%B %e, %Y. %l:%M %p"}--></td>
    <td>New Request Opened by <!--{$name|sanitize}--></td>
</tr>


<!--{foreach from=$agenda item=indicator}--><!--{strip}-->

<tr>
    <td>
        <!--{$indicator.time|date_format:"%B %e, %Y. %l:%M %p"}-->
    </td>
    <td>
        <b><!--{$indicator.description|sanitize}--></b>
        <!--{if $indicator.userName != ''}--> by <!--{/if}--><!--{$indicator.userName|sanitize}-->
        <!--{if $indicator.comment != ''}-->
            <!--{if $indicator.description|lower != 'email sent: '}-->
                <br />Comment: <!--{$indicator.comment|sanitize}-->
            <!--{else}-->
                <br /><!--{$indicator.comment|sanitize}-->
            <!--{/if}-->
        <!--{/if}-->
    </td>
</tr>


<!--{/strip}--><!--{/foreach}-->
</table>
</div>

<div style="float: left; padding: 2px">
Required Actions:<br />
<!--{foreach from=$dependencies item=dependency}--><!--{strip}-->
    <!--{if $dependency.filled==1}-->
        <span style="padding: 4px; margin: 4px; color: green; font-weight: bold"><img class="print" src="dynicons/?img=dialog-apply.svg&w=16" alt="checked" /> <!--{$dependency.description|sanitize}--></span><br />
    <!--{elseif $dependency.filled==0}-->
        <span style="padding: 4px; margin: 4px; color: gray">[ ? ] <!--{$dependency.description|sanitize}--> (Pending)</span><br />
    <!--{else}-->
        <span style="padding: 4px; margin: 4px; color: red"><img class="print" src="dynicons/?img=process-stop.svg&w=16" alt="not checked" /> <!--{$dependency.description|sanitize}--></span><br />
    <!--{/if}-->
<!--{/strip}--><!--{/foreach}-->
</div>

</div> <!-- close main content -->
