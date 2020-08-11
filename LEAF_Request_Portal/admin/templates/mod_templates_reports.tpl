<style>
/* Grid of 6 */
.group:after,.section{clear:both}.section{padding:0;margin:0}.col{display:block;float:left;margin:1% 0 1% 1.6%}.col:first-child{margin-left:0}.group:after,.group:before{content:"";display:table}.group{zoom:1}.span_6_of_6{width:100%}.span_5_of_6{width:83.06%}.span_4_of_6{width:66.13%}.span_3_of_6{width:49.2%}.span_2_of_6{width:32.26%}.span_1_of_6{width:15.33%}@media only screen and (max-width:480px){.col{margin:1% 0}.span_1_of_6,.span_2_of_6,.span_3_of_6,.span_4_of_6,.span_5_of_6,.span_6_of_6{width:100%}}
</style>

<div class="section group">
    <div class="col span_1_of_6">
        <div id="fileBrowser" style="float: left; width: 200px; margin: 4px">
            <div class="buttonNorm" onclick="newReport();"><img src="../../libs/dynicons/?img=document-new.svg&w=32" alt="New File" /> New File</div><br />
            <b>Files:</b>
            <div id="fileList"></div>
        </div>
    </div>
    <div id="codeArea" class="col span_4_of_6">
        <div id="codeContainer" class="card" style="float: left; padding: 8px; width: 90%; display: none">
            <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold"></div>
            <div id="reportURL" style="padding-left: 8px;"></div><br />
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
    </div>
    <div class="col span_1_of_6">
        <div id="controls" style="float: right; visibility: hidden">
            <div id="saveButton" class="buttonNorm" onclick="save();"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=32" alt="Save" /> Save Changes<span id="saveStatus"></span></div><br /><br /><br />
            <div class="buttonNorm" onclick="runReport();"><img id="saveIndicator" src="../../libs/dynicons/?img=x-office-spreadsheet.svg&w=32" alt="Open Report" /> Open Report</div>
            <br /><br /><br /><br /><br /><br />
            <div id="deleteButton" class="buttonNorm" onclick="deleteReport();"><img src="../../libs/dynicons/?img=process-stop.svg&w=32" alt="Delete Report" /> Delete Report</div>
        </div>
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
            url: '../api/system/reportTemplates/_' + currentFile + '?CSRFToken=<!--{$CSRFToken}-->',
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
            var buffer = '<ul>';
            var bufferExamples = '<br /><br /><b>Examples:</b><br /><ul>';
			for(var i in res) {
				file = res[i].replace('.tpl', '');
				if(!isExcludedFile(file)) {
					buffer += '<li onclick="loadContent(\''+ file +'\');"><a href="#'+ file +'">' + file + '</a></li>';
                }
                else {
                    bufferExamples += '<li onclick="loadContent(\''+ file +'\');"><a href="#'+ file +'">' + file + '</a></li>';
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