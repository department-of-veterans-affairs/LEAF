<input name="series" type="hidden" value="<!--{$series|sanitize}-->" />
<input name="CSRFToken" type="hidden" value="<!--{$CSRFToken}-->" />
<div class="mainform">
    <!--{include file=$subindicatorsTemplate form=$form recordID=$recordID orgchartPath=$orgchartPath}-->
</div>
<script>
var recordID = <!--{$recordID|strip_tags}-->;
var serviceID = <!--{$serviceID|strip_tags}-->;
var orgchartPath = '<!--{$orgchartPath|strip_tags}-->';
</script>