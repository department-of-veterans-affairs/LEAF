<div id="fileBrowser" style="float: left; width: 200px; margin: 4px">
Templates:
    <div id="fileList"></div>
</div>
<div id="codeContainer" class="card" style="float: left; padding: 8px; display: none">
    <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold"></div>
    <div style="border: 1px solid black">
        <textarea id="code"></textarea>
    </div>
    <br />
    <div>
        <table class="table">
            <tr>
                <td colspan="2">Keyboard Shortcuts within coding area</td>
            </tr>
            <tr>
                <td>Save</td>
                <td>Ctrl + S</td>
            </tr>
            <tr>
                <td>Fullscreen</td>
                <td>F11</td>
            </tr>
        </table>
    </div>
</div>
<div id="controls" style="float: right; width: 170px; visibility: hidden">
    <div class="buttonNorm" onclick="save();"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=32" alt="Save" /> Save Changes</div><br /><br /><br />
    <div class="buttonNorm modifiedTemplate" onclick="restore();"><img src="../../libs/dynicons/?img=x-office-document-template.svg&w=32" alt="Restore" /> Restore Original</div><br /><br /><br />
    <a class="buttonNorm" href="../../libs/dynicons/gallery.php" target="_blank" style="padding: 8px; text-decoration: none"><img src="../../libs/dynicons/?img=image-x-generic.svg&w=32" alt="Icon Library" /> Icon Library</a>
</div>

<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script>

function save() { 
	$('#saveIndicator').attr('src', '../images/indicator.gif');
	$.ajax({
		type: 'POST',
		data: {CSRFToken: '<!--{$CSRFToken}-->',
			   file: codeEditor.getValue()},
		url: '../api/system/templates/_' + currentFile,
		success: function(res) {
			$('#saveIndicator').attr('src', '../../libs/dynicons/?img=media-floppy.svg&w=32');
			$('.modifiedTemplate').css('display', 'block');
            if(res != null) {
                alert(res);
            }
		}
	});
}

function restore() {
	dialog.setTitle('Are you sure?');
	dialog.setContent('This will restore the template to the original version.');
	
	dialog.setSaveHandler(function() {
		$.ajax({
	        type: 'DELETE',
	        url: '../api/system/templates/_' + currentFile + '&CSRFToken=<!--{$CSRFToken}-->',
	        success: function() {
	            loadContent(currentFile);
	        }
	    });
		dialog.hide();
	});
	
	dialog.show();
}

var currentFile = '';
function loadContent(file) {
	currentFile = file;
	$('#codeContainer').css('display', 'none');
	$('#controls').css('visibility', 'visible');
	$('#filename').html(file.replace('.tpl', ''));
	$.ajax({
		type: 'GET',
		url: '../api/system/templates/_' + file,
		success: function(res) {
			$('#codeContainer').fadeIn();
			codeEditor.setValue(res.file);
			if(res.modified == 1) {
				$('.modifiedTemplate').css('display', 'block');
			}
			else {
				$('.modifiedTemplate').css('display', 'none');
			}
		},
		cache: false
	});
}

var codeEditor = null;
$(function() {
	dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
	codeWidth = $(document).width() - 420;
	$('#codeContainer').css('width', codeWidth + 'px');

	codeEditor = CodeMirror.fromTextArea(document.getElementById("code"), {
		mode: "htmlmixed",
	    lineNumbers: true,
	    scrollbarStyle: "simple",
	    indentUnit: 4,
	    extraKeys: {
	        "F11": function(cm) {
	          cm.setOption("fullScreen", !cm.getOption("fullScreen"));
	        },
	        "Esc": function(cm) {
	          if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
	        },
	        "Ctrl-S": function(cm) {
                save();
            }
	      }
	  });
	codeEditor.setSize(codeWidth - 2 + 'px', $(document).height() - 80);
	
	$.ajax({
		type: 'GET',
		url: '../api/system/templates',
		success: function(res) {
			var buffer = '<ul>';
			for(var i in res) {
				file = res[i].replace('.tpl', '');
				buffer += '<li onclick="loadContent(\''+ res[i] +'\');"><a href="#">' + file + '</a></li>';
			}
			buffer += '</ul>';
			$('#fileList').html(buffer);
		},
		cache: false
	});
	
	loadContent('view_homepage.tpl');
});
</script>