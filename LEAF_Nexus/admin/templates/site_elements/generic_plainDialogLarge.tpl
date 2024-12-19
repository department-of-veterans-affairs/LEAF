<div id="plainDialogLarge" style="visibility: hidden">
<form id="recordLarge" enctype="multipart/form-data" action="javascript:void(0);">
    <div>
        <span id="button_cancelchangeplainLarge" style="display: none"></span>
        <span id="button_saveplainLarge" style="display: none"></span>
        <div id="loadIndicatorplainLarge" style="visibility: hidden; position: absolute; text-align: center; font-size: 24px; font-weight: bold; background: white; padding: 16px; height: 200px; width: 460px">Loading... <img src="../images/largespinner.gif" alt="" /></div>
        <div id="plainLarge" style="width: 800px; height: 600px; padding: 8px; overflow: auto; font-size: 12px"></div>
    </div>
</form>
</div>

<script>
$(function() {
	$('#plainLarge').css({
		width: $(window).width() * 0.8,
		height: $(window).height() * 0.8
	});

});
</script>