<input name="series" type="hidden" value="<!--{$series}-->" />
<input name="CSRFToken" type="hidden" value="<!--{$CSRFToken}-->" />
<div class="mainform">
    <!--{include file="subindicators.tpl" form=$form categoryID=$categoryID|strip_tags|escape UID=$UID}-->
</div>