<link rel=stylesheet href="../../libs/js/codemirror/addon/merge/merge.css">
<script src="../../libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="../../libs/js/codemirror/addon/merge/merge.js"></script>
<style>

/* Glyph to improve usability of code compare */
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy {
    visibility: hidden;
}
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy::before {
    visibility: visible;
    content: '\25ba\25ba\25ba';
}
</style>

<div class="leaf-center-content">

        <div class="leaf-left-nav">
            <aside class="sidenav">
                <div id="fileBrowser">
                Templates:
                    <div id="fileList"></div>
                </div>
            </aside>
        </div>


        <main id="codeArea" class="main-content">
            <h2>Template Editor</h2>

            <div id="codeContainer" class="leaf-code-container">

                <div id="filename"></div>

                <div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
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
            <aside class="sidenav-right">

                <div id="controls" style="visibility: hidden">
                    
                    <button class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem" onclick="save();">
                        Save Changes<span id="saveStatus" class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>
                    
                    <button class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem  modifiedTemplate" onclick="restore();">
                        Restore Original
                    </button>
                    
                    <button class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem" id="btn_compareStop" style="display: none" onclick="loadContent();">
                        Stop Comparing
                    </button>
                    
                    <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem  modifiedTemplate" id="btn_compare" onclick="compare();">
                        Compare to Original
                    </button>
                    
                    <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem" target="_blank">
                        <a href="../../libs/dynicons/gallery.php">Icon Library</a>
                    </button>
                </div>

            </aside>

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
	        url: '../api/system/templates/_' + currentFile + '&CSRFToken=<!--{$CSRFToken}-->',
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
    codeWidth = $('#codeArea').width() - 66;
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
			var buffer = '<ul class="leaf-ul">';
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