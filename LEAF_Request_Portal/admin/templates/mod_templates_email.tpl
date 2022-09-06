<link rel=stylesheet href="/libs/js/codemirror/addon/merge/merge.css">
<script src="/libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="/libs/js/codemirror/addon/merge/merge.js"></script>
<style>
/* Glyph to improve usability of code compare */
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy {
    visibility: hidden;
}
.CodeMirror-merge-copybuttons-left > .CodeMirror-merge-copy::before {
    visibility: visible;
    content: '\25ba\25ba\25ba';
}
#subjectCompare .CodeMirror-merge, .CodeMirror-merge .CodeMirror {
}
#emailTemplateHeader {
    margin: 10px;
}
#emailLists fieldset legend {
    font-size: 1.2em;
}
.emailToCc {
    padding: 8px;
    font-weight: bold;
}
#divSubject .CodeMirror {
    height: 50px;
}
</style>

<div class="leaf-center-content">

    <div class="leaf-left-nav">
        <aside class="sidenav">
            <div id="fileBrowser"">
            Email Templates:
                <div id="fileList"></div>
            </div>
        </aside>
    </div>

    <main id="codeArea" class="main-content">

        <div id="codeContainer" class="leaf-code-container">

            <h2 id="emailTemplateHeader">Default Email Template</h2>
            <div id="emailLists">
                <fieldset><legend>Email To and CC</legend><br />
                    <p>
                        Enter email addresses, one per line.  Users will be
                        emailed each time this template is used in any workflow.
                    </p>
                    <div id="emailTo" class="emailToCc">Email To:</div>
                    <div id="divEmailTo">
                        <textarea id="emailToCode" style="width: 95%;" rows="5"></textarea>
                    </div>
                    <div id="emailCc" class="emailToCc">Email CC:</div>
                    <div id="divEmailCc">
                        <textarea id="emailCcCode" style="width: 95%;" rows="5"></textarea>
                    </div>
                </fieldset>
            </div>
            <div id="subject" style="padding: 8px; font-size: 140%; font-weight: bold">Subject</div>
            <div id="divSubject" style="border: 1px solid black">
                <textarea id="subjectCode"></textarea>
                <div id="subjectCompare"></div>
            </div>
            <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold">Email Content</div>
            <div id="divCode" style="border: 1px solid black">
                <textarea id="code"></textarea>
                <div id="codeCompare"></div>
            </div>
            <div>
                <fieldset><legend>Template Variables</legend><br />
                <table class="table">
                    <tr>
                        <td><b>{{$recordID}}</b></td>
                        <td>The ID number of the request</td>
                    </tr>
                    <tr>
                        <td><b>{{$fullTitle}}</b></td>
                        <td>The full title of the request</td>
                    </tr>
                    <tr>
                        <td><b>{{$truncatedTitle}}</b></td>
                        <td>A truncated version of the request title</td>
                    </tr>
                    <tr>
                        <td><b>{{$lastStatus}}</b></td>
                        <td>The last action taken for the request</td>
                    </tr>
                    <tr>
                        <td><b>{{$comment}}</b></td>
                        <td>The last comment associated with the request</td>
                    </tr>
                    <tr>
                        <td><b>{{$service}}</b></td>
                        <td>The service associated with the request</td>
                    </tr>
                    <tr>
                        <td><b>{{$siteRoot}}</b></td>
                        <td>The root URL of the LEAF site</td>
                    </tr>
                </table>
            </div>
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

    </main>

    <div class="leaf-right-nav">
        <aside class="sidenav-right">
            <div id="controls" style="padding-bottom: 4px">

                <button class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem" onclick="save();">
                    Save Changes<span id="saveStatus" class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                </button>

                <button class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate" onclick="restore();">
                    Restore Original
                </button>

                <button class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem" id="btn_compareStop" style="display: none" onclick="loadContent();">
                    Stop Comparing
                </button>
                
                <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate" id="btn_compare" onclick="compare();">
                    Compare to Original
                </button>

                <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem" id="btn_history" onclick="viewHistory()">
                    View History
                </button>

            </div>
        </aside>
    </div>

</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script>

/**
 * Function: save
 * Purpose: Save all fields to template files
 */
function save() {
	$('#saveIndicator').attr('src', '../images/indicator.gif');
	let data = '';
	let subject = '';
	// If any changes made to emailTo, emailCc, body or subject
    // then get edits, else get default values
	if(codeEditor.getValue == undefined) {
	    data = codeEditor.edit.getValue();
	}
	else {
	    data = codeEditor.getValue();
	}

	if (subjectEditor.getValue == undefined) {
		subject = subjectEditor.edit.getValue();
	}
	else {
		subject = subjectEditor.getValue();
	}

	let emailToData = document.getElementById('emailToCode').value;
	let emailCcData = document.getElementById('emailCcCode').value;

	// Send the email template data to the API to process
	$.ajax({
		type: 'POST',
		data: {
            CSRFToken: '<!--{$CSRFToken}-->',
			file: data,
			subjectFile: subject,
			subjectFileName: currentSubjectFile,
            emailToFile: emailToData,
            emailToFileName: currentEmailToFile,
            emailCcFile: emailCcData,
            emailCcFileName: currentEmailCcFile
        },
		url: '../api/emailTemplates/_' + currentFile,
		success: function(res) {
			$('#saveIndicator').attr('src', '../../libs/dynicons/?img=media-floppy.svg&w=32');
			$('.modifiedTemplate').css('display', 'block');
			if($('#btn_compareStop').css('display') != 'none') {
			    $('#btn_compare').css('display', 'none');
			}

			// Show saved time in "Save Changes" button and set current content
            var time = new Date().toLocaleTimeString();
            $('#saveStatus').html('<br /> Last saved: ' + time);
            currentFileContent = data;
            currentSubjectContent = subject;
            currentEmailToContent = emailToData;
            currentEmailCcContent = emailCcData;
            if(res != null) {
                alert(res);
            }
		}
	});
}

/**
 * Function: restore
 * Purpose: Restore function that removes changes made to template files
 */
function restore() {
	dialog.setTitle('Are you sure?');
	dialog.setContent('This will restore the template to the original version.');

	dialog.setSaveHandler(function() {
		$.ajax({
	        type: 'DELETE',
	        url: '../api/emailTemplates/_' + currentFile + '?' +
                $.param({'subjectFileName': currentSubjectFile,
                         'emailToFileName': currentEmailToFile,
                         'emailCcFileName': currentEmailCcFile,
                         'CSRFToken': '<!--{$CSRFToken}-->'}),
	        success: function() {
	            loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
	        }
	    });
		dialog.hide();
	});
	
	dialog.show();
}

/**
 * Function: compare
 * Purpose: Compare for subject and body when changes made
 *  Uses CodeMirror comparison JS code to show differences
 */
var dv;
function compare() {
    $('.CodeMirror').remove();
    $('#codeCompare').empty();
    $('#subjectCompare').empty();
    $('#btn_compare').css('display', 'none');
    $('#btn_compareStop').css('display', 'block');

    // Get default email template fields
    $.ajax({
        type: 'GET',
        url: '../api/emailTemplates/_' + currentFile + '/standard',
        success: function(standard) {
            // Set body changed and default content to show comparison
            codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                mode: "htmlmixed",
                lineNumbers: true,
                indentUnit: 4,
                value: currentFileContent.replace(/\r\n/g, "\n"),
                origLeft: standard.file.replace(/\r\n/g, "\n"),
                showDifferences: true,
                collapseIdentical: true,
                lineWrapping: true,
                extraKeys: {
                    "Ctrl-S": function(cm) {
                        save();
                    }
                  }
              });

            // Set changed subject and default subject to user to show comparison
            subjectEditor = CodeMirror.MergeView(document.getElementById("subjectCompare"), {
                mode: "htmlmixed",
                lineNumbers: true,
                indentUnit: 4,
                value: currentSubjectContent.replace(/\r\n/g, "\n"),
                origLeft: standard.subjectFile.replace(/\r\n/g, "\n"),
                showDifferences: true,
                collapseIdentical: true,
                lineWrapping: true,
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

var currentName = '';
var currentFile = '';
var currentSubjectFile = '';
var currentFileContent = '';
var currentSubjectContent = '';
var currentEmailToFile = '';
var currentEmailToContent = '';
var currentEmailCcFile = '';
var currentEmailCcContent = '';

/**
 * @todo - Convert to object for storing files & content not mulitple variables
 *  so can handle expanded data fields easily
 */

/**
 * loadContent Function
 * Purpose: Takes body and subject files and loads them with content
 *  either from default template or changed ones
 * @param file
 * @param subjectFile
 */
function loadContent(name, file, subjectFile, emailToFile, emailCcFile) {
    if(file == undefined) {
        name = currentName;
        file = currentFile;
        subjectFile = currentSubjectFile;
        emailToFile = currentEmailToFile;
        emailCcFile = currentEmailCcFile;
    }
    $('.CodeMirror').remove();
    $('#codeCompare').empty();
    $('#subjectCompare').empty();
    $('#btn_compareStop').css('display', 'none');
    
    initEditor();
    $('#codeContainer').css('display', 'none');
    $('#controls').css('visibility', 'visible');

    currentName = name;
    currentFile = file;
	currentSubjectFile = subjectFile;
	currentEmailToFile = emailToFile;
    currentEmailCcFile = emailCcFile;

    $('#emailTemplateHeader').html(currentName);
    if (typeof(subjectFile) == 'undefined' || subjectFile == 'null' || subjectFile == '')
	{
		$('#subject, #emailLists, #emailTo, #emailCc').hide();
        $('#divSubject, #divEmailTo, #divEmailCc').hide().attr('disabled', 'disabled');
		subjectEditor.setOption("readOnly", true);
	}
	else
	{
        $('#subject, #emailLists, #emailTo, #emailCc').show();
        $('#divSubject, #divEmailTo, #divEmailCc').show().removeAttr('disabled');
	}
	$.ajax({
		type: 'GET',
		url: '../api/emailTemplates/_' + file,
		success: function(res) {
		    currentFileContent = res.file;
		    currentSubjectContent = res.subjectFile;
		    currentEmailToContent = res.emailToFile;
		    currentEmailCcContent = res.emailCcFile;
		    $('#codeContainer').fadeIn();
			codeEditor.setValue(currentFileContent);
			if (currentSubjectContent !== null) {
                subjectEditor.setValue(currentSubjectContent);
            }
			$("#emailToCode").val(currentEmailToContent);
			$("#emailCcCode").val(currentEmailCcContent);

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

/**
 * updateEditorSize Function
 * Purpose: Upon any refresh or change in template fields, the editor's
 *  container will resize according to layout of page and fire refresh of all
 *  CodeMirror JS code within the template field
 */
function updateEditorSize() {
    codeWidth = $('#codeArea').width() - 30;
    $('#codeContainer').css('width', codeWidth + 'px');
    // Refresh CodeMirror
    $('.CodeMirror').each(function(i, el){
        el.CodeMirror.refresh();
    });
}

/**
 * initEditor Function
 * Purpose: Initiate the CodeMirror editor functions for the body and subject fields
 */
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

    subjectEditor = CodeMirror.fromTextArea(document.getElementById("subjectCode"), {
        mode: "htmlmixed",
        viewportMargin: 5,
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

function viewHistory() {
    dialog_message.setContent('');
    dialog_message.setTitle('Access Template History');
    dialog_message.show();
    dialog_message.indicateBusy();

    $.ajax({
        type: 'GET',
        url: 'ajaxIndex.php?a=gethistory&type=emailTemplate&id=' + currentFile,
        dataType: 'text',
        success: function(res) {
            dialog_message.setContent(res);
            dialog_message.indicateIdle();
            dialog_message.show();
        },
        fail: function() {
            dialog_message.setContent('Loading failed.');
            dialog_message.show();
        },
        cache: false
    });
}

/**
 * Actual start of page execution
 */
var codeEditor = null;
var subjectEditor = null;
$(function() {
	dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator', 'confirm_button_save', 'confirm_button_cancelchange');

    initEditor();

    $(window).on('resize', function() {
        updateEditorSize();
    });

    // Get initial email tempates for page from database
	$.ajax({
		type: 'GET',
		url: '../api/emailTemplates',
 		success: function(res) {
			var buffer = '<ul class="leaf-ul">';
			for(var i in res) {
			    buffer += '<li onclick="loadContent(\'' + res[i].displayName + '\', ' +
                    '\'' + res[i].fileName +'\'';
                if (res[i].subjectFileName != '') {
                    buffer += ', \'' + res[i].subjectFileName + '\', ' +
                        '\'' + res[i].emailToFileName + '\', ' +
                        '\'' + res[i].emailCcFileName + '\'';
                } else {
                    buffer += ', undefined, undefined, undefined';
                }
                buffer += ');"><a href="#">' + res[i].displayName + '</a></li>';
			}
			buffer += '</ul>';
			$('#fileList').html(buffer);
		},
		cache: false
	});

	// Load content from those templates to the current main template
	loadContent('Default Email Template', 'LEAF_main_email_template.tpl', undefined, undefined, undefined);

    // Refresh CodeMirror
    $('.CodeMirror').each(function(i, el) {
        el.CodeMirror.refresh();
    });

    dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator', 'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
});
</script>