
<div> <!-- main content -->
<span style="font-weight: bold; font-size: 16px"><!--{$dataType}--> Name : <!--{$dataName|sanitize}--></span>
<br />
History of <!--{$dataType}--> ID : <!--{$dataID|sanitize}-->
<br /><br />

<div style="float: left; padding: 2px">
<table class="agenda" id="maintable">
<thead>
<tr>
    <th>Timestamp</th>
    <th>Action Taken</th>
</tr>
</thead>


<!--{foreach from=$history item=log}--><!--{strip}-->

<tr>
    <td>
        <!--{$log.timestamp|date_format:"%B %e, %Y. %l:%M %p"}-->
    </td>
    <td>
        <span><b><!--{$log.action|sanitize}--></b> by <!--{$log.userName|sanitize}-->
        <br /><!--{$log.history|sanitize}--></span>
    </td>
</tr>


<!--{/strip}--><!--{/foreach}-->
</table>
</div>


</div> <!-- close main content -->

