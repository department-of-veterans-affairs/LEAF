<input name="series" type="hidden" value="<!--{$series|strip_tags|escape}-->" />
<input name="CSRFToken" type="hidden" value="<!--{$CSRFToken}-->" />
<div class="mainform">
    <!--{include file="subindicators.tpl" form=$form recordID=$recordID orgchartPath=$orgchartPath}-->
</div>
<script>
var recordID = <!--{$recordID|strip_tags|escape}-->;
var serviceID = <!--{$serviceID|strip_tags|escape}-->;
</script>