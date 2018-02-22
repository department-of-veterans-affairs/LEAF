{$message}
<br />
<iframe id="fileIframe_{$recordID|strip_tags|escape}_{$indicatorID|strip_tags|escape}_{$series|strip_tags|escape}" style="display: none" src="ajaxIframe.php?a=getuploadprompt&amp;recordID={$recordID|strip_tags|escape}&amp;indicatorID={$indicatorID|strip_tags|escape}&amp;series={$series|strip_tags|escape}" frameborder="0" width="500px" height="85px"></iframe>
<span id="fileAdditional" class="buttonNorm" onclick="$('#fileIframe_{$recordID|strip_tags|escape}_{$indicatorID|strip_tags|escape}_{$series|strip_tags|escape}').css('display', 'block'); $('#fileAdditional').css('visibility', 'hidden')"><img src="../libs/dynicons/?img=document-open.svg&amp;w=32" /> Attach Additional File</span>
