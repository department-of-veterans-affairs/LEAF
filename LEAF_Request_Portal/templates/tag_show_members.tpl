<div>
<b><!--{$totalNum}--></b> requests tagged as '<!--{$tag}-->'<br /><br />
<!--{foreach from=$requests item=request}-->
#<!--{$request.recordID}--> - <a href="index.php?a=printview&amp;recordID=<!--{$request.recordID}-->" style="color: black"><!--{$request.title|escape:'html'}--></a><br />
<!--{/foreach}-->
</div>