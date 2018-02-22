<div>
<b><!--{$totalNum|strip_tags|escape}--></b> requests tagged as '<!--{$tag|strip_tags|escape}-->'<br /><br />
<!--{foreach from=$requests item=request}-->
<<<<<<< HEAD
#<!--{$request.recordID|strip_tags}--> - <a href="index.php?a=printview&amp;recordID=<!--{$request.recordID|strip_tags}-->" style="color: black"><!--{$request.title|escape:'html'}--></a><br />
=======
#<!--{$request.recordID|strip_tags|escape}--> - <a href="index.php?a=printview&amp;recordID=<!--{$request.recordID|strip_tags|escape}-->" style="color: black"><!--{$request.title|escape:'html'}--></a><br />
>>>>>>> XSS fixes for Request Portal ajaxIndex.php
<!--{/foreach}-->
</div>