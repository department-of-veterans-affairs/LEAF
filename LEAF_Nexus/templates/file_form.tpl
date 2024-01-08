<form id="record" enctype="multipart/form-data" action="ajaxIndex.php?a=doupload&amp;categoryID={$categoryID}&amp;UID={$UID}" method="post">
    <div id="file{$categoryID}_{$UID}_{$indicatorID}_control">
        <label for="file{$categoryID}_{$UID}_{$indicatorID}">Select File to attach: </label>
        <input id="file{$categoryID}_{$UID}_{$indicatorID}" name="{$indicatorID}" type="file" />
    </div>
    <div id="file{$categoryID}_{$UID}_{$indicatorID}_status" style="visibility: hidden; display: none; background-color: #fffcae; padding: 4px"><img src="images/indicator.gif" alt="" /> Attaching file...</div>
<div style="font-family: verdana; font-size: 10px">
  <br />Maximum attachment size is <b>{$max_filesize}B.</b>
  <br />Limit <b>1</b> attachment.<br />
</div>
<input type="hidden" id="CSRFToken" name="CSRFToken" value="{$CSRFToken}" />
</form>

<script type="text/javascript">
/* <![CDATA[ */

$(function() {
    $('#file{$categoryID}_{$UID}_{$indicatorID}').on('change', function() {
        $('#file{$categoryID}_{$UID}_{$indicatorID}_control').css('visibility', 'hidden');
        $('#file{$categoryID}_{$UID}_{$indicatorID}_control').css('display', 'none');
    	$('#file{$categoryID}_{$UID}_{$indicatorID}_status').css('visibility', 'visible');
    	$('#file{$categoryID}_{$UID}_{$indicatorID}_status').css('display', 'block');
        $('#record').submit();
    });
});
/* ]]> */
</script>