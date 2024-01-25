
<div class="leaf-center-content">

    <form id="record" enctype="multipart/form-data" action="ajaxIndex.php?a=uploadFile" method="post">
        
        <input name="CSRFToken" type="hidden" value="<!--{$CSRFToken}-->" />
        
        <div class="leaf-marginTop-1rem">
            <h3 id="file_control"><label for="file">Select file to upload</label></h3>
        </div>
        
        <div class="leaf-marginTop-1rem">
            <input id="file" name="file" type="file" />
        </div>
        
        <div class="leaf-marginTop-1rem" id="file_status" style="visibility: hidden; display: none; padding: 4px">
            <img src="../images/indicator.gif" alt="" /> Uploading file...
        </div>
        
        <div class="leaf-row-space"></div>
        
        <span class="leaf-bold">Supported file types:</span>
        <div class="leaf-marginTop-1rem leaf-width-24rem">
            <!--{foreach from=$fileExtensions item=extension}--><!--{$extension}--> <!--{/foreach}-->
        </div>
    </form>

</div>

<script type="text/javascript">
$(function() {
    $('#file').on('change', function() {
        $('#file_control').css('visibility', 'hidden');
        $('#file_control').css('display', 'none');
        $('#file_status').css('visibility', 'visible');
        $('#file_status').css('display', 'block');
        $('#record').submit();
    });
});
</script>
