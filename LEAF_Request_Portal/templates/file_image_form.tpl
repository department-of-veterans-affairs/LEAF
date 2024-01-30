<form id="record" enctype="multipart/form-data" action="ajaxIndex.php?a=doupload&amp;recordID={$recordID|strip_tags}" method="post">
    <input name="CSRFToken" type="hidden" value="{$CSRFToken}" />
    <input type="hidden" name="series" value="{$series|strip_tags}" />
    <input type="hidden" name="indicatorID" value="{$indicatorID|strip_tags}" />
    <div id="file{$indicatorID|strip_tags}_control">Select File to attach: 
    <input id="file{$indicatorID|strip_tags}" name="{$indicatorID|strip_tags}" type="file" accept="image/*" aria-labelledby="format_label_{$indicatorID|strip_tags}" /></div>
    <div id="file{$indicatorID|strip_tags}_status" style="visibility: hidden; display: none; background-color: #fffcae; padding: 4px"><img src="images/indicator.gif" alt="" /> Attaching file...</div>
<div style="font-family: verdana; font-size: 10px">
  <br />Maximum attachment size is <b>{$max_filesize}B.</b>
</div>
</form>

<script type="text/javascript">
$(function() {
	$('#file{$indicatorID}').on('change', function() {
		$('#file{$indicatorID}_control').css('visibility', 'hidden');
        $('#file{$indicatorID}_control').css('display', 'none');
        $('#file{$indicatorID}_status').css('visibility', 'visible');
        $('#file{$indicatorID}_status').css('display', 'block');
        $('#record').submit();
	});
});
</script>