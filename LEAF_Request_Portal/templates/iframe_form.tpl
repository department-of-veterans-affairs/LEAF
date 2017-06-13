<script type="text/javascript">

function iframeTrigger(func) {
    if(dialog.isValid() == 1) {
        $.ajax({
            type: 'POST',
            url: 'ajaxIndex.php?a=domodify',
            dataType: 'text',
            data: $('#record').serialize(),
            success: function(res) {
                func();
            },
            cache: false
        });
    	return true;
    }
    return false;
}

$(function() {
	window.focus();
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
});
</script>

<form id="record" enctype="multipart/form-data" action="#">
<input name="recordID" type="hidden" value="<!--{$recordID}-->" />
<!--{$ajaxForm}-->
</form>

<div id="xhrDialog" style="display: none"></div>
<div id="xhr" style="display: none"></div>
<div id="loadIndicator" style="display: none"></div>
<div id="button_save" style="display: none"></div>
<div id="button_cancelchange" style="display: none"></div>