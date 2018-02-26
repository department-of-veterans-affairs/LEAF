<div>
<b><!--{$totalNum}--></b> requests tagged as '<!--{$tag}-->'<br /><br />
<!--{foreach from=$requests item=request}-->
#<!--{$request.recordID|strip_tags}--> - <a href="index.php?a=printview&amp;recordID=<!--{$request.recordID|strip_tags}-->" style="color: black"><!--{$request.title|escape:'html'}--></a><br />
<!--{/foreach}-->
</div>