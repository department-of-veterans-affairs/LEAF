<form id="record" enctype="multipart/form-data" action="ajaxIndex.php?a=doupload&amp;recordID={$recordID}" method="post">
    <input name="CSRFToken" type="hidden" value="{$CSRFToken}" />
    <input type="hidden" name="series" value="{$series}" />
    <input type="hidden" name="indicatorID" value="{$indicatorID}" />
    <div id="file{$indicatorID}_control">Select File to attach: <input id="file{$indicatorID}" name="{$indicatorID}" type="file" /></div>
    <div id="file{$indicatorID}_status" style="visibility: hidden; display: none; background-color: #fffcae; padding: 4px"><img src="images/indicator.gif" alt="loading..." /> Attaching file...</div>
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