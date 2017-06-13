<input name="series" type="hidden" value="<!--{$series}-->" />
<input name="CSRFToken" type="hidden" value="<!--{$CSRFToken}-->" />
<div class="mainform">
    <!--{include file="subindicators.tpl" form=$form recordID=$recordID orgchartPath=$orgchartPath}-->
</div>
<script>
var recordID = <!--{$recordID}-->;
var serviceID = <!--{$serviceID}-->;
</script>