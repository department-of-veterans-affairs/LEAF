<div class="leaf-center-content">

    <div class="leaf-left-nav">
        <aside class="sidenav" id="fileBrowser">
            <button class="usa-button leaf-btn-med leaf-width-13rem" onclick="newReport();">New File</button>
            <p class="leaf-bold leaf-marginTop-1rem">Files</p>
            <div id="fileList"></div>
        </aside>
    </div>

    <main id="codeArea" class="main-content">
        <h2>LEAF Programmer</h2>
        
        <div id="codeContainer" class="leaf-code-container">
            <div id="filename"></div>
            <div id="reportURL"></div>
            <div>
                <textarea id="code"></textarea>
            </div>
            <div>
                <table class="usa-table">
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
    </main>
    
    <div class="leaf-right-nav"> 
        <aside class="sidenav-right" id="controls">
            <button id="saveButton" class="usa-button leaf-btn-med leaf-display-block leaf-width-14rem" onclick="save();">Save Changes<span id="saveStatus" class="leaf-display-block leaf-font0-5rem"></span></button>
            <button class="usa-button usa-button--accent-cool leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="runReport();">Open Report</button>
            <button id="deleteButton" class="usa-button usa-button--secondary leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="deleteReport();">Delete Report</button>
        </aside>
    </div>

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
		url: '../api/system/reportTemplates/_' + currentFile,
		success: function(res) {
			$('#saveIndicator').attr('src', '../../libs/dynicons/?img=media-floppy.svg&w=32');
			$('.modifiedTemplate').css('display', 'block');
			var time = new Date().toLocaleTimeString();
			$('#saveStatus').html('<br /> Last saved: ' + time);
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
    	var file = $('#newFilename').val();
        $.ajax({
            type: 'POST',
            url: '../api/system/reportTemplates',
            data: {CSRFToken: '<!--{$CSRFToken}-->',
            	filename: file},
            success: function(res) {
            	if(res == 'CreateOK') {
                    updateFileList();
            		loadContent(file);
            	}
            	else {
            	    alert(res);
            	}
            }
        });
        dialog.hide();
    });

    $('#newFilename').on('keyup change', function(e) {
        $('#newFilename').val($('#newFilename').val().replace(/[^a-z0-9\.\/]/gi, '_'));
    });

    dialog.show();
}

function deleteReport() {
	dialog_confirm.setTitle('Are you sure?');
	dialog_confirm.setContent('This will irreversibly delete this report.');
    
	dialog_confirm.setSaveHandler(function() {
        $.ajax({
            type: 'DELETE',
            url: '../api/system/reportTemplates/_' + currentFile + '&CSRFToken=<!--{$CSRFToken}-->',
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

function isExcludedFile(file) {
    if(file == 'example'
        || file.substr(0, 5) == 'LEAF_'
    ) {
        return true;
    }
    return false;
}

var currentFile = '';
function loadContent(file) {
	currentFile = file;
	$('#codeContainer').css('display', 'none');
	
	var reportURL = window.location.origin + window.location.pathname;
	reportURL = reportURL.replace('admin/', '') + 'report.php?a=' + file.replace('.tpl', '');
	
	$('#reportURL').html('URL: <a href="'+ reportURL +'" target="_blank">'+ reportURL +'</a>');
	$('#controls').css('visibility', 'visible');
    if(isExcludedFile(file)) {
    	$('#controls').css('visibility', 'hidden');
    }

	$('#filename').html(file.replace('.tpl', ''));
	$.ajax({
		type: 'GET',
		url: '../api/system/reportTemplates/_' + file,
		success: function(res) {
			$('#codeContainer').fadeIn();
			codeEditor.setValue(res.file);
		},
		cache: false
	});
	$('#saveStatus').html('');
}

function updateEditorSize() {
    codeWidth = $('#codeArea').width() - 30;
    $('#codeContainer').css('width', codeWidth + 'px');
    $('.CodeMirror, .CodeMirror-merge').css('height', $(window).height() - 160 + 'px');
}

function updateFileList() {
	$.ajax({
		type: 'GET',
		url: '../api/system/reportTemplates',
		success: function(res) {
            var buffer = '<ul class="leaf-ul">';
            var bufferExamples = '<div class="leaf-bold">Examples</div><ul class="leaf-ul">';
			for(var i in res) {
				file = res[i].replace('.tpl', '');
				if(!isExcludedFile(file)) {
					buffer += '<li onclick="loadContent(\''+ file +'\');" style="display: block; width: 12rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><a href="#'+ file +'">' + file + '</a></li>';
                }
                else {
                    bufferExamples += '<li onclick="loadContent(\''+ file +'\');" style="display: block; width: 12rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><a href="#'+ file +'">' + file + '</a></li>';
                }
			}
            buffer += '</ul>';
            bufferExamples += '</ul>';
			$('#fileList').html(buffer + bufferExamples);
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
	updateEditorSize();
    $(window).on('resize', function() {
        updateEditorSize();
    });

    updateFileList();
	loadContent('example');
});
</script>