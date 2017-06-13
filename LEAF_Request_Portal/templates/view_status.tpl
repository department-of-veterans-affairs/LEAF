<div><a href="?a=status&amp;recordID=<!--{$recordID}-->"><img src="../libs/dynicons/?img=printer.svg&amp;w=16" alt="Print status" /></a></div>
<div> <!-- main content -->
<span style="font-weight: bold; font-size: 16px">History of Request ID#: <!--{$recordID}--></span>
<br />
Service: <!--{$service}--><br />
Title of request: <a href="?a=printview&amp;recordID=<!--{$recordID}-->"><!--{$title}--></a><br /><br />

<div style="float: left; padding: 2px">
<table class="agenda" id="maintable">
<tr>
    <td>Timestamp</td>
    <td>Action Taken</td>
</tr>

<tr>
    <td><!--{$date|date_format:"%B %e, %Y. %l:%M %p"}--></td>
    <td>New Request Opened by <!--{$name}--></td>
</tr>

<!--{if $submitted > 0}-->
<tr>
    <td><!--{$submitted|date_format:"%B %e, %Y. %l:%M %p"}--></td>
    <td>Request Submitted by <!--{$name}--></td>
</tr>
<!--{/if}-->


<!--{foreach from=$agenda item=indicator}--><!--{strip}-->

<tr id="id_<!--{$indicator.recordID}-->">
    <td>
        <!--{$indicator.time|date_format:"%B %e, %Y. %l:%M %p"}-->
    </td>
    <td>
        <span><b><!--{$indicator.description}-->: <!--{$indicator.actionText}--></b> by <!--{$indicator.userName}-->
        <!--{if $indicator.comment != ''}-->
        <br />Comment: <!--{$indicator.comment}--></span>
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
        <span style="padding: 4px; margin: 4px; color: green; font-weight: bold"><img class="print" src="../libs/dynicons/?img=dialog-apply.svg&w=16" alt="checked" /> <!--{$dependency.description}--></span><br />
    <!--{elseif $dependency.filled==0}-->
        <span style="padding: 4px; margin: 4px; color: gray">[ ? ] <!--{$dependency.description}--> (Pending)</span><br />
    <!--{else}-->
        <span style="padding: 4px; margin: 4px; color: red"><img class="print" src="../libs/dynicons/?img=process-stop.svg&w=16" alt="not checked" /> <!--{$dependency.description}--></span><br />
    <!--{/if}-->
<!--{/strip}--><!--{/foreach}-->
</div>

</div> <!-- close main content -->