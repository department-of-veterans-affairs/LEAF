{$message}
<br />
<iframe id="fileIframe_{$recordID}_{$indicatorID}_{$series}" style="display: none" src="ajaxIframe.php?a=getuploadprompt&amp;recordID={$recordID}&amp;indicatorID={$indicatorID}&amp;series={$series}" frameborder="0" width="500px" height="85px"></iframe>
<span id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_{$recordID}_{$indicatorID}_{$series}').css('display', 'block'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</span>
