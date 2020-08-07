<link rel=stylesheet href="../../libs/js/codemirror/addon/merge/merge.css">
<script src="../../libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="../../libs/js/codemirror/addon/merge/merge.js"></script>
<style>
/* Grid of 6 */
.group:after,.section{clear:both}.section{padding:0;margin:0}.col{display:block;float:left;margin:1% 0 1% 1.6%}.col:first-child{margin-left:0}.group:after,.group:before{content:"";display:table}.group{zoom:1}.span_6_of_6{width:100%}.span_5_of_6{width:83.06%}.span_4_of_6{width:66.13%}.span_3_of_6{width:49.2%}.span_2_of_6{width:32.26%}.span_1_of_6{width:15.33%}@media only screen and (max-width:480px){.col{margin:1% 0}.span_1_of_6,.span_2_of_6,.span_3_of_6,.span_4_of_6,.span_5_of_6,.span_6_of_6{width:100%}}

/* Glyph to improve usability of code compare */
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy {
    visibility: hidden;
}
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy::before {
    visibility: visible;
    content: '\25ba\25ba\25ba';
}
</style>


<div class="section group">
    <div class="col span_1_of_6">
        <div id="fileBrowser" style="float: left; width: 200px; margin: 4px">
        Templates:
            <div id="fileList"></div>
        </div>
    </div>
    <div id="codeArea" class="col span_4_of_6">
        <div id="codeContainer" class="card" style="float: left; padding: 8px; display: none">
            <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold"></div>
            <div style="border: 1px solid black">
                <textarea id="code"></textarea>
                <div id="codeCompare"></div>
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
        <div id="controls" style="float: right; width: 170px; visibility: hidden">
            <div class="buttonNorm" onclick="save();"><img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=32" alt="Save" /> Save Changes<span id="saveStatus"></span></div><br /><br /><br />
            <div class="buttonNorm modifiedTemplate" onclick="restore();"><img src="../../libs/dynicons/?img=x-office-document-template.svg&w=32" alt="Restore" /> Restore Original</div><br />
            <div class="buttonNorm" id="btn_compareStop" style="display: none" onclick="loadContent();"><img src="../../libs/dynicons/?img=text-x-generic.svg&w=32" alt="Normal view" /> Stop Comparing</div>
            <div class="buttonNorm modifiedTemplate" id="btn_compare" onclick="compare();"><img src="../../libs/dynicons/?img=edit-copy.svg&w=32" alt="Compare" /> Compare with Original</div><br /><br /><br />
            <a class="buttonNorm" href="../../libs/dynicons/gallery.php" target="_blank" style="padding: 8px; text-decoration: none"><img src="../../libs/dynicons/?img=image-x-generic.svg&w=32" alt="Icon Library" /> Icon Library</a>
        </div>
    </div>
</div>



<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->

<script>

function save() { 
	$('#saveIndicator').attr('src', '../images/indicator.gif');
	var data = '';
	if(codeEditor.getValue == undefined) {
	    data = codeEditor.edit.getValue();
	}
	else {
	    data = codeEditor.getValue();
	}
	$.ajax({
		type: 'POST',
		data: {CSRFToken: '<!--{$CSRFToken}-->',
			   file: data},
		url: '../api/system/templates/_' + currentFile,
		success: function(res) {
			$('#saveIndicator').attr('src', '../../libs/dynicons/?img=media-floppy.svg&w=32');
			$('.modifiedTemplate').css('display', 'block');
			if($('#btn_compareStop').css('display') != 'none') {
			    $('#btn_compare').css('display', 'none');
			}

            var time = new Date().toLocaleTimeString();
            $('#saveStatus').html('<br /> Last saved: ' + time);
            currentFileContent = data;
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
	        url: '../api/?a=system/templates/_' + currentFile + '&CSRFToken=<!--{$CSRFToken}-->',
	        success: function() {
	            loadContent(currentFile);
	        }
	    });
		dialog.hide();
	});
	
	dialog.show();
}

var dv;
function compare() {
    $('.CodeMirror').remove();
    $('#codeCompare').empty();
    $('#btn_compare').css('display', 'none');
    $('#btn_compareStop').css('display', 'block');

    $.ajax({
        type: 'GET',
        url: '../api/system/templates/_' + currentFile + '/standard',
        success: function(standard) {
            codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                mode: "htmlmixed",
                lineNumbers: true,
                indentUnit: 4,
                value: currentFileContent.replace(/\r\n/g, "\n"),
                origLeft: standard.file.replace(/\r\n/g, "\n"),
                showDifferences: true,
                collapseIdentical: true,
                extraKeys: {
                    "Ctrl-S": function(cm) {
                        save();
                    }
                  }
              });
            updateEditorSize();
        },
        cache: false
    });
}

var currentFile = '';
var currentFileContent = '';
function loadContent(file) {
    if(file == undefined) {
        file = currentFile;
    }
    $('.CodeMirror').remove();
    $('#codeCompare').empty();
    $('#btn_compareStop').css('display', 'none');
    
    initEditor();
	currentFile = file;
	$('#codeContainer').css('display', 'none');
	$('#controls').css('visibility', 'visible');
	$('#filename').html(file.replace('.tpl', ''));
	$.ajax({
		type: 'GET',
		url: '../api/system/templates/_' + file,
		success: function(res) {
		    currentFileContent = res.file;
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
	$('#saveStatus').html('');
}

function updateEditorSize() {
    codeWidth = $('#codeArea').width() - 30;
    $('#codeContainer').css('width', codeWidth + 'px');
    $('.CodeMirror, .CodeMirror-merge').css('height', $(window).height() - 160 + 'px');
}

function initEditor () {
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
}

var codeEditor = null;
$(function() {
	dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    initEditor();

    $(window).on('resize', function() {
        updateEditorSize();
    });

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