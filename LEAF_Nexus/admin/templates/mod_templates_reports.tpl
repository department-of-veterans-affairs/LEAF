<div id="fileBrowser" style="float: left; width: 200px; margin: 4px">
    <button class="buttonNorm" onclick="newReport();" style="float: left; width: 200px; margin: 4px;"><img src="../dynicons/?img=document-new.svg&w=32" alt="" /> New File</button><br />
    <b>Files:</b>
    <div id="fileList"></div>
</div>
<div id="codeContainer" style="float: left; display: none">
    <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold"></div>
    <div style="border: 1px solid black">
        <textarea id="code"></textarea>
    </div>
</div>
<div id="controls" style="float: right; width: 170px; visibility: hidden">
    <div id="saveButton" class="buttonNorm" onclick="save();"><img id="saveIndicator" src="../dynicons/?img=media-floppy.svg&w=32" alt="" /> Save Changes</div><br /><br /><br />
    <div class="buttonNorm" onclick="runReport();"><img id="saveIndicator" src="../dynicons/?img=x-office-spreadsheet.svg&w=32" alt="" /> Open Report</div>
    <br /><br /><br /><br /><br /><br />
    <div id="deleteButton" class="buttonNorm" onclick="deleteReport();"><img src="../dynicons/?img=process-stop.svg&w=32" alt="" /> Delete Report</div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script>

function save() {
	$('#saveIndicator').attr('src', '../images/indicator.gif');
	$.ajax({
		type: 'POST',
		data: {CSRFToken: '<!--{$CSRFToken}-->',
			   file: codeEditor.getValue()},
		url: '../api/system/applet/_' + currentFile,
		success: function(res) {
			$('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
			$('.modifiedTemplate').css('display', 'block');
			if(res != null) {
				alert(res);
			}
		}
	});
}

function newReport() {
    dialog.setTitle('New File');
    dialog.setContent('Filename: <input type="text" id="newFilename"></input>');

    dialog.setSaveHandler(function() {
    	console.log($('#newFile').val());
    	var file = $('#newFilename').val();
        $.ajax({
            type: 'POST',
            url: '../api/system/applet',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
            	filename: file},
            success: function(res) {
            	if(res == 'CreateOK') {
            		loadContent(file);
            	}
            	else {
            	    alert(res);
            	}
            }
        });
        dialog.hide();
    });

    dialog.show();
}

function deleteReport() {
	dialog_confirm.setTitle('Are you sure?');
	dialog_confirm.setContent('This will irreversibly delete this report.');

	dialog_confirm.setSaveHandler(function() {
        $.ajax({
            type: 'DELETE',
            url: '../api/system/applet/_' + currentFile + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
            success: function() {
                location.reload();
            }
        });
        dialog_confirm.hide();
    });

	dialog_confirm.show();
}

function runReport() {
	window.open('../report.php?a='+ currentFile);
}

var currentFile = '';
function loadContent(file) {
	currentFile = file;
	$('#codeContainer').css('display', 'none');
	$('#controls').css('visibility', 'visible');
    if(file == 'example') {
    	$('#controls').css('visibility', 'hidden');
    }

	$('#filename').html(file.replace('.tpl', ''));
	$.ajax({
		type: 'GET',
		url: '../api/system/applet/_' + file,
		success: function(res) {
			$('#codeContainer').fadeIn();
			codeEditor.setValue(res.file);
		},
		cache: false
	});
}

var codeEditor = null;
var dialog, dialog_confirm;
$(function() {
	dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save', 'button_cancelchange');
	dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');
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
		url: '../api/system/applet',
		success: function(res) {
			var buffer = '<ul>';
			for(var i in res) {
				file = res[i].replace('.tpl', '');
				if(file != 'example') {
					buffer += '<li onclick="loadContent(\''+ file +'\');"><a href="#">' + file + '</a></li>';
				}
			}
			buffer += '</ul>';
			$('#fileList').html(buffer);
		},
		cache: false
	});

	loadContent('example');
});
</script>