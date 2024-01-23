{$message}
<br />
<iframe id="fileIframe_{$recordID|strip_tags}_{$indicatorID|strip_tags}_{$series|strip_tags}" style="display: none" src="ajaxIframe.php?a=getuploadprompt&amp;recordID={$recordID|strip_tags}&amp;indicatorID={$indicatorID|strip_tags}&amp;series={$series|strip_tags}" frameborder="0" width="500px" height="85px"></iframe>
<button type="button" id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_{$recordID|strip_tags}_{$indicatorID|strip_tags}_{$series|strip_tags}').css('display', 'block'); $('#fileAdditional').css('visibility', 'hidden')"><img src="dynicons/?img=document-open.svg&amp;w=32" alt="" /> Attach Additional File</button>
