<div class="leaf-center-content">
    <form id="record" enctype="multipart/form-data" action="ajaxIndex.php?a=manualImportForm" method="post">
        <input name="CSRFToken" type="hidden" value="{$CSRFToken}" />
        <div id="file_control">Select LEAF Form Packet to import: <input id="formPacket" name="formPacket" type="file" /></div>
        <div id="file_status" style="visibility: hidden; display: none; background-color: #fffcae; padding: 4px"><img src="../images/indicator.gif" alt="" /> Importing form...</div>
    </form>
</div>

<script type="text/javascript">
$(function() {
    $('#formPacket').on('change', function() {
        $('#file_control').css('visibility', 'hidden');
        $('#file_control').css('display', 'none');
        $('#file_status').css('visibility', 'visible');
        $('#file_status').css('display', 'block');
        $('#record').submit();
    });
});
</script>
