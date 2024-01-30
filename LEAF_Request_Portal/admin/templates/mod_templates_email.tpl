<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates_email.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Email Template Editor</h2>
        <div class="mobileToolsNav">
            <button type="button" class="mobileToolsNavBtn" onclick="openRightNavTools('leaf-right-nav')">Template Tools</button>
        </div>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav">
                <div id="fileBrowser">

                    <button type="button"
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_history" onclick="viewHistory()">View History</button>
                </div>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <h2 id="emailTemplateHeader">Default Email Template</h2>
                <div id="emailNotificationInfo" style="display: none; padding-top: 3px; gap: 0.25rem; flex-wrap:wrap; font-size:90%;"></div>
                <div id="emailLists">
                    <fieldset>
                        <legend>Email To and CC</legend>
                        <p>
                            Enter email addresses, one per line. Users will be
                            emailed each time this template is used in any workflow.&nbsp;
                            <div id="field_use_notice" style="display: none; color:#c00000;">
                            Please note that only orgchart employee formats are supported in this section.
                            </div>
                        </p>
                        <label for="emailToCode" id="emailTo" class="emailToCc">Email To:</label>
                        <div id="divEmailTo">
                            <textarea id="emailToCode" style="width: 95%;" rows="5" onchange="checkFieldEntries()"></textarea>
                        </div>
                        <label for="emailCcCode" id="emailCc" class="emailToCc">Email CC:</label>
                        <div id="divEmailCc">
                            <textarea id="emailCcCode" style="width: 95%;" rows="5" onchange="checkFieldEntries()"></textarea>
                        </div>
                    </fieldset>
                </div>
                <label for="subjectCode" id="subject" style="padding: 8px; font-size: 140%; font-weight: bold">Subject</label>
                <div id="divSubject">
                    <textarea id="subjectCode"></textarea>
                    <div id="subjectCompare"></div>
                </div>
                <label for="code" id="filename" style="padding: 8px; font-size: 140%; font-weight: bold">Body</label>
                <div id="divCode">
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label">(Old File)</div>
                        <div class="CodeMirror-merge-pane-label">(Current File)</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
                <div class="email-template-variables">
                    <fieldset>
                        <legend>Template Variables</legend>
                        <br />
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
                            <tr>
                                <td><b>{{$field.&lt;fieldID&gt;}}</fieldID>
                                </td>
                                <td>The value of the field by ID. <span style="color:#c00000;">Sensitive data fields may
                                        not be included in email templates.</span></td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <fieldset id="quick_field_search_container">
                    <legend>Quick Field Search</legend>
                    <div id="quick_field_search">
                        <div id="form-select">
                            <label for="form-select-dropdown">Select Form:</label>
                            <select id="form-select-dropdown" onchange="getIndicators(this.value)"></select>
                        </div>
                        <div id="indicator-select">
                            <label for="indicator-select-dropdown">Select Question:</label>
                            <select id="indicator-select-dropdown"
                                onchange="showIndicator(this.value, this.options[this.selectedIndex].dataset.isSensitive)"></select>
                        </div>
                        <div id="indicator-id-label">
                            <span>Your field ID is: </span><span id="indicator-id"
                                style="font-weight: 700; margin-right: 1rem;"></span>
                            <button type="button" id="copy-field-id" style="width: auto; display: inline-block;"
                                class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med"><i
                                    class="fas fa-copy"></i> Copy</button>
                        </div>
                        <span id="sensitive-warning">*This field is marked as sensitive! The field value will not show
                            in sent emails*</span>
                    </div>
                </fieldset>

                <div class="keyboard_shortcuts">
                    <div class="keboard_shortcuts_main_title">
                        <h3>Keyboard Shortcuts within the Code Editor:</h3>
                    </div>
                    <div class="keyboard_shortcuts_section">
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Save: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>Ctrl + S </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Undo: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>Ctrl + Z </p>
                            </div>
                        </div>
                    </div>
                    <div class="keyboard_shortcuts_section">
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Full Screen: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>F11 </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box"></div>
                    </div>
                </div>

                <div class="keyboard_shortcuts_merge">
                    <div class="keboard_shortcuts_main_title_merge">
                        <h3>Keyboard Shortcuts For Compare Code:</h3>
                    </div>
                    <div class="keyboard_shortcuts_section_merge">
                        <div class="keboard_shortcuts_box_merge">
                            <div class="keyboard_shortcuts_title_merge">
                                <h3>Merge Changes: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + M </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box_merge">
                            <div class="keyboard_shortcuts_title_merge">
                                <h3>Word Wrap: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + W </p>
                            </div>
                        </div>
                    </div>
                    <div class="keyboard_shortcuts_section_merge">
                        <div class="keboard_shortcuts_box_merge">
                            <div class="keyboard_shortcuts_title_merge">
                                <h3>Exit Compare: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + E </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box_merge">

                        </div>
                    </div>
                </div>
            </div>
        </main>
        <div class="leaf-right-nav">
            <div id="closeMobileToolsNavBtnContainer"><button type="button" id="closeMobileToolsNavBtn" aria-label="close tools menu"
                    onclick="closeRightNavTools('leaf-right-nav')">X</button></div>
            <aside class="filesMobile">
            </aside>
            <aside class="sidenav-right">
                <div id="controls">
                    <button type="button" id="save_button" class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem"
                        onclick="save();">
                        Save Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>
                    <button type="button" id="restore_original"
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                        onclick="restore();">Restore Original</button>
                    <button type="button"
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_compareStop" style="display: none" onclick="loadContent();">Stop Comparing</button>
                    <!-- <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                    id="btn_compare" onclick="compare();">Compare to Original</button> -->
                </div>
            </aside>
            <aside class="sidenav-right-compare">
                <div class="controls-compare">
                    <button type="button" class="file_replace_file_btn">Use Old File</button>
                    <button type="button" class="close_expand_mode_screen" onclick="exitExpandScreen()">Stop Comparing</button>
                </div>
            </aside>
            <div class="file-history">
                <h3>File History</h3>
                <div class="file-history-res"></div>
            </div>
        </div>
    </div>
</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script>
    function openRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '0'
        });
    }

    function checkFieldEntries() {
        const elTextareaTo = document.getElementById("emailToCode");
        const elTextareaCc = document.getElementById("emailCcCode");
        const elTextInput = (elTextareaTo?.value || "") + "\r\n" + (elTextareaCc?.value || "");
        if(elTextInput !== "") {
            const fieldReg = /field\.\d*/g;
            const fieldMatches = elTextInput.match(fieldReg);
            let elNotice = document.getElementById("field_use_notice");
            if (elNotice !== null) {
                if(fieldMatches?.length > 0) {
                    const ids = fieldMatches.map(m => +m.slice(m.indexOf(".") + 1));
                    let includesNonOrgchartEmp = false;
                    for(let i = 0; i < ids.length; i++) {
                        const id = ids[i];
                        if(allowedToCcFormats?.[indicatorFormats[id]] !== 1) {
                            includesNonOrgchartEmp = true;
                            break;
                        }
                    }
                    elNotice.style.display = includesNonOrgchartEmp ? "block" : "none";
                } else {
                    elNotice.style.display = "none";
                }
            }
        }
    }

    function closeRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '-100%'
        });
    }
    var codeEditor;
    // saves current file content changes
    function save() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        const divEmailTo = document.getElementById('divEmailTo');
        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;
        const data = (typeof codeEditor !== 'undefined' && codeEditor.getValue() !== undefined) ? codeEditor
            .getValue() : codeEditor.edit.getValue();
        const subject = (typeof subjectEditor !== 'undefined' && subjectEditor.getValue() !== undefined) ? subjectEditor
            .getValue() : subjectEditor.edit.getValue();
        const isContentChanged = (
            emailToData !== currentEmailToContent ||
            emailCcData !== currentEmailCcContent ||
            data !== currentFileContent ||
            subject !== currentSubjectContent
        );
        const isContentUnchanged = (data === currentFileContent);
        const isNull = emailToData === null || emailCcData === null;



        if (divEmailTo.style.display === 'none') {
            if (isContentUnchanged || isNull) {
                showDialog('Please make a change to the content in order to save.');
            } else {
                saveTemplate();
            }
        } else {
            if (isContentChanged || isNull) {
                saveTemplate();
            } else {
                showDialog('Please make a change to the content in order to save.');
            }
        }

        function saveTemplate() {
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
                    updateUIAfterSave();
                    if (res != null) {
                        alert(res);
                    }

                    saveFileHistory();
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.log('Error occurred during the save operation:', errorThrown);
                }
            });
        }

        function showDialog(message, color) {
            dialog_message.setContent('<h2 style="color:' + (color || 'black') + '">' + message + '</h2>');
            dialog_message.setTitle('Alert!');
            dialog_message.show();
        }

        function updateUIAfterSave() {
            $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
            $('.modifiedTemplate').css('display', 'block');
            if ($('#btn_compareStop').css('display') !== 'none') {
                $('#btn_compare').css('display', 'none');
            }
            var time = new Date().toLocaleTimeString();
            $('#saveStatus').html('<br /> Last saved: ' + time);
            currentFileContent = data;
            currentSubjectContent = subject;
            currentEmailToContent = emailToData;
            currentEmailCcContent = emailCcData;
        }
    }
    // creates a copy of the current file content
    function saveFileHistory() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        let data = '';
        let subject = '';
        // If any changes made to emailTo, emailCc, body or subject
        // then get edits, else get default values
        if (codeEditor.getValue() === undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }
        if (subjectEditor.getValue() === undefined) {
            subject = subjectEditor.edit.getValue();
        } else {
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
            url: '../api/emailTemplateFileHistory/_' + currentFile,
            success: function(res) {
                $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') !== 'none') {
                    $('#btn_compare').css('display', 'none');
                }
                // Show saved time in "Save Changes" button and set current content
                var time = new Date().toLocaleTimeString();
                $('#saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                currentSubjectContent = subject;
                currentEmailToContent = emailToData;
                currentEmailCcContent = emailCcData;
                getFileHistory(currentFile);
            }
        });
    }
    // restores file to default
    function restore() {
        dialog.setTitle('Are you sure?');
        dialog.setContent('This will restore the template to the original version.');
        dialog.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: '../api/emailTemplates/_' + currentFile + '?' + $.param({
                    'subjectFileName': currentSubjectFile,
                    'emailToFileName': currentEmailToFile,
                    'emailCcFileName': currentEmailCcFile,
                    'CSRFToken': '<!--{$CSRFToken}-->'
                }),
                success: function() {
                    saveFileHistory();
                    loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile,
                        currentEmailCcFile);
                }
            });
            dialog.hide();
        });
        dialog.show();
    }
    // request's copies of the current file content
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: `../api/templateFileHistory/_${template}`,
            dataType: 'json',
            success: function(res) {
                if (res.length === 0) {
                    var contentMessage = '<p class="contentMessage">There are no history files.</p>';
                    $('.file-history-res').html(contentMessage);
                    return;
                }

                var fileNames = res.map(function(item) {
                    return item.file_parent_name;
                });

                if (!fileNames.includes(template)) {
                    return;
                }

                let accordion = '<div id="file_history_container">' +
                    '<div class="file_history_titles">' +
                    '<div class="file_history_date">Date:</div>' +
                    '<div class="file_history_author">Author:</div>' +
                    '</div>' +
                    '<div class="file_history_options_container">';
                for (let i = 0; i < res.length; i++) {
                    var fileParentName = res[i].file_parent_name;
                    var fileName = res[i].file_name;
                    var whoChangedFile = res[i].file_modify_by;
                    var fileCreated = res[i].file_created;
                    ignoreUnsavedChanges = false;

                    accordion +=
                        '<div class="file_history_options_wrapper" onclick="compareHistoryFile(\'' +
                        fileName + '\', \'' + fileParentName + '\', true)">' +
                        '<div class="file_history_options_date">' + fileCreated + '</div>' +
                        '<div class="file_history_options_author">' + whoChangedFile + '</div>' +
                        '</div>';
                }
                accordion += '</div>' +
                    '</div>';
                $('.file-history-res').html(accordion);
            },
            error: function(xhr, status, error) {
                console.log('Error getting file history: ' + error);
            },
            cache: false
        });
    }

    var dv;
    // Global variables
    var currentName;
    var currentFile;
    var currentSubjectFile;
    var currentEmailToFile;
    var currentEmailCcFile;
    var currentFileContent;
    var currentSubjectContent;
    var currentEmailToContent;
    var currentEmailCcContent;
    var subjectEditor;
    var dialog_message;

    var ignoreUnsavedChanges = false;
    var ignorePrompt = true;
    let indicatorFormats = {};
    const allowedToCcFormats = {
        "orgchart_employee": 1,
    }

    // compares current file content with history file from getFileHistory()
    function compareHistoryFile(fileName, parentFile, updateURL) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#save_button').css('display', 'none');
        $('#btn_compareStop').css('display', 'none');
        $('#btn_merge').css('display', 'block');
        $('#word-wrap-button').css('display', 'block');
        $('.file_replace_file_btn').css('display', 'block');
        let wordWrapEnabled = false; // default to false

        $('#word-wrap-button').click(function() {
            wordWrapEnabled = !wordWrapEnabled;
            if (wordWrapEnabled) {
                codeEditor.editor().setOption('lineWrapping', true);
                codeEditor.leftOriginal().setOption('lineWrapping', true);
                $(this).removeClass('off').addClass('on').text('Word Wrap: On');
            } else {
                codeEditor.editor().setOption('lineWrapping', false);
                codeEditor.leftOriginal().setOption('lineWrapping', false);
                $(this).removeClass('on').addClass('off').text('Word Wrap: Off');
            }
            $('.CodeMirror-linebackground').css({
                'background-color': '#8ce79b !important'
            });
        });

        $.ajax({
            type: 'GET',
            url: `../api/templateCompareFileHistory/_${fileName}`,
            dataType: 'json',
            cache: false,
            success: function(res) {
                $(".compared-label-content").css("display", "flex");
                let filePath = '';
                let fileParentFile = '';
                let requestCount = res.length; // Keep track of completed requests
                for (let i = 0; i < res.length; i++) {
                    filePath = res[i].file_path;
                    fileParentFile = res[i].file_parent_name;
                    $.ajax({
                        type: 'GET',
                        url: filePath,
                        dataType: 'text',
                        cache: false,
                        success: function(fileContent) {
                            // Assign CodeMirror.MergeView instance to codeEditor
                            codeEditor = CodeMirror.MergeView(document.getElementById(
                                "codeCompare"), {
                                value: currentFileContent.replace(/\r\n/g, "\n"),
                                origLeft: fileContent.replace(/\r\n/g, "\n"),
                                lineNumbers: true,
                                mode: 'htmlmixed',
                                collapseIdentical: true,
                                lineWrapping: false, // initial value
                                autoFormatOnStart: true,
                                autoFormatOnMode: true,
                                leftTitle: "Current File",
                                rightTitle: "Comparison File"
                            });

                            updateEditorSize();
                            $('.CodeMirror-linebackground').css({
                                'background-color': '#8ce79b !important'
                            });

                            // Add a shortcut for exit from the merge screen
                            $(document).on('keydown', function(event) {
                                if (event.ctrlKey && event.key === 'm') {
                                    mergeFile();
                                }
                                if (event.ctrlKey && event.key === 'w') {
                                    toggleWordWrap();
                                }
                            });

                            function mergeFile() {
                                ignoreUnsavedChanges = true;
                                var changedLines = codeEditor.leftOriginal()
                                    .lineCount();
                                var mergedContent = "";
                                for (var i = 0; i < changedLines; i++) {
                                    var mergeLine = codeEditor.leftOriginal().getLine(
                                        i);
                                    if (mergeLine !== null && mergeLine !== undefined) {
                                        mergedContent += mergeLine + "\n";
                                    }
                                }
                                saveMergedChangesToFile(fileParentFile, mergedContent);
                            }
                            $('.file_replace_file_btn').click(function() {
                                ignoreUnsavedChanges = true;
                                let changedLines = codeEditor.leftOriginal()
                                    .lineCount();
                                let mergedContent = "";
                                for (let i = 0; i < changedLines; i++) {
                                    let mergeLine = codeEditor.leftOriginal().getLine(
                                        i);
                                    if (mergeLine !== null && mergeLine !== undefined) {
                                        mergedContent += mergeLine + "\n";
                                    }
                                }
                                saveMergedChangesToFile(fileParentFile, mergedContent);
                            });

                            function toggleWordWrap() {
                                let lineWrapping = codeEditor.editor().getOption('lineWrapping');
                                codeEditor.editor().setOption('lineWrapping', !lineWrapping);
                                codeEditor.leftOriginal().setOption('lineWrapping', !
                                    lineWrapping);
                            }

                            requestCount--; // Decrement the request count
                            if (requestCount === 0) {
                                // All requests have completed
                                editorExpandScreen();
                            }
                        }
                    });
                }
            }
        });

        if (updateURL) {
            let url = new URL(window.location.href);
            url.searchParams.set('fileName', fileName);
            url.searchParams.set('parentFile', parentFile);
            window.history.replaceState(null, null, url.toString());
        }
    }
    // Add a shortcut for exit from the merge screen
    $(document).on('keydown', function(event) {
        if (event.ctrlKey && event.key === 'e') {
            exitExpandScreen();
        }
    });
    // overrites current file content after merge
    function saveMergedChangesToFile(fileParentName, mergedContent) {
        $.ajax({
            type: 'POST',
            url: '../api/templateEmailHistoryMergeFile/_' + fileParentName,
            data: {
                CSRFToken: '<!--{$CSRFToken}-->',
                file: mergedContent
            },
            dataType: 'json',
            cache: false,
            success: function(res) {
                loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile,
                    currentEmailCcFile);
                exitExpandScreen();
            },
            error: function(xhr, status, error) {
                console.log(xhr.responseText);
            }
        });
    }
    // Retreave URL to display comparison of files
    function initializePage() {
        let urlParams = new URLSearchParams(window.location.search);

        let fileName = urlParams.get('fileName');
        let parentFile = urlParams.get('parentFile');

        let templateFile = urlParams.get('file');
        let templateName = urlParams.get('name');
        let templateSubjectFile = urlParams.get('subjectFile');
        let templateEmailToFile = urlParams.get('emailToFile');
        let templateEmailCcFile = urlParams.get('emailCcFile');

        if (fileName !== null && parentFile !== null && templateSubjectFile == 'undefined' && templateName == 'undefined') {
            loadContent(currentName, templateFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (fileName !== null && parentFile !== null && templateSubjectFile !== null) {
            loadContent(templateName, templateFile, templateSubjectFile, templateEmailToFile, templateEmailCcFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (templateSubjectFile == 'undefined') {
            loadContent(currentName, templateFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
        } else if (templateFile !== null) {
            loadContent(templateName, templateFile, templateSubjectFile, templateEmailToFile, templateEmailCcFile);
        } else {
            loadContent(undefined, 'LEAF_main_email_template.tpl', undefined, undefined, undefined);
        }
    }

    // compares the current file to the default file content
    function compare() {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#subjectCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#btn_compareStop').css('display', 'block');
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
    // Expands the current and history file to compare both files
    function editorExpandScreen() {
        $('.page-title-container .file_replace_file_btn').show();
        $('.page-title-container .close_expand_mode_screen').show();
        $('.sidenav-right').hide();
        $('#emailLists, #subject, .email-template-variables, .email-keyboard-shortcuts').hide();
        $('.sidenav-right-compare').show();
        $('#quick_field_search_container').hide();
        $('.page-title-container h2').css({
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Email Template Editor > Compare Code');
        let windowWidth = $(window).width();
        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
            $('.main-content').css({
                'width': '95%',
                'transition': 'all .5s ease',
                'justify-content': 'flex-start'
            });
        } else {
            $('.main-content').css({
                'width': '85%',
                'transition': 'all .5s ease',
                'justify-content': 'flex-start'
            });
        }
        $('.leaf-code-container').css({
            'width': '100% !important'
        });
        $('.usa-table').hide();
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
            'transition': 'all .5s ease'
        });
        $('.keyboard_shortcuts').css('display', 'none');
        $('.keyboard_shortcuts_merge').show();
    }
    // exits the current and history comparison
    function exitExpandScreen() {
        $(".compared-label-content").hide();
        $('#word-wrap-button').hide();
        $('.page-title-container .file_replace_file_btn').hide();
        $('.page-title-container .close_expand_mode_screen').hide();
        $('#save_button_compare').hide();
        $('.sidenav-right-compare').hide();
        $('.sidenav-right').show();
        $('#quick_field_search_container').show();
        $('.page-title-container h2').css({
            'width': '100%',
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Email Template Editor');

        let windowWidth = $(window).width();

        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
            $('.main-content').css({
                'width': '95%',
                'transition': 'all .5s ease',
                'justify-content': 'center'
            });
        } else {
            $('.main-content').css({
                'width': '65%',
                'transition': 'all .5s ease',
                'justify-content': 'center'
            });
        }

        $('#codeContainer').css({
            'display': 'block',
            'height': '95%',
            'width': '90% !important'
        });
        $('.usa-table').show();

        $('.leaf-left-nav').css({
            'position': 'relative',
            'left': '0',
            'transition': 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });

        $('#save_button').show();
        $('.email-template-variables, .email-keyboard-shortcuts, #emailLists, #subject').show();

        $('.keyboard_shortcuts').css('display', 'flex');
        $('.keyboard_shortcuts_merge').hide();

        // Will reset the URL
        let url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());

        loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
    }

    // This function displays a prompt if there are unsaved changes before leaving the page
    function editorCurrentContent() {
        $(window).on('beforeunload', function(e) {
            if (!ignoreUnsavedChanges && !ignorePrompt) { // Check if ignoring unsaved changes and prompt
                let data = '';
                if (codeEditor.getValue === undefined) {
                    data = codeEditor.edit.getValue();
                } else {
                    data = codeEditor.getValue();
                }
                if (currentFileContent !== data) {
                    var confirmationMessage =
                        'You have unsaved changes. Are you sure you want to leave this page?';
                    return confirmationMessage;
                }
            }
        });
    }
    // loads all files and retreave's them
    function loadContent(name, file, subjectFile, emailToFile, emailCcFile) {
        if (file === undefined) {
            name = currentName;
            file = currentFile;
            subjectFile = currentSubjectFile;
            emailToFile = currentEmailToFile;
            emailCcFile = currentEmailCcFile;
        }

        if (ignorePrompt) {
            ignorePrompt = false; // Reset ignorePrompt flag
        } else {
            if (!ignoreUnsavedChanges && hasUnsavedChanges() && !confirm(
                    'You have unsaved changes. Are you sure you want to leave this page?')) {
                return;
            }
        }

        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#subjectCompare').empty();
        $('#btn_compareStop').hide();
        $('#codeContainer').hide();
        $('#controls').css('visibility', 'visible');
        $('.keyboard_shortcuts_merge').hide();
        currentName = name;
        currentFile = file;
        currentSubjectFile = subjectFile;
        currentEmailToFile = emailToFile;
        currentEmailCcFile = emailCcFile;
        $('#emailTemplateHeader').html(currentName);

        initEditor();
        if (typeof subjectFile === 'undefined' || subjectFile === null || subjectFile === '') {
            $('#subject, #emailLists, #emailTo, #emailCc').hide();
            $('#divSubject, #divEmailTo, #divEmailCc').hide().prop('disabled', true);
            subjectEditor.setOption("readOnly", true);
        } else {
            $('#subject, #emailLists, #emailTo, #emailCc').show();
            $('#divSubject, #divEmailTo, #divEmailCc').show().prop('disabled', false);
        }

        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates/_' + file,
            success: function(res) {
                currentEmailToContent = res.emailToFile;
                currentEmailCcContent = res.emailCcFile;
                $('#codeContainer').fadeIn();

                // Assuming you have initialized the codeEditor and subjectEditor objects correctly
                codeEditor.setValue(res.file);
                if (subjectEditor && res.subjectFile !== null) {
                    subjectEditor.setValue(res.subjectFile);
                    currentSubjectContent = subjectEditor.getValue();
                }
                currentFileContent = codeEditor.getValue();

                $("#emailToCode").val(currentEmailToContent);
                $("#emailCcCode").val(currentEmailCcContent);
                checkFieldEntries();

                if (res.modified === 1) {
                    $('.modifiedTemplate').show();

                } else {
                    $('.modifiedTemplate').hide();
                }
                getFileHistory(file);
                addCustomEventInfo(currentFile);
            },
            cache: false
        });
        $('#saveStatus').html('');

        editorCurrentContent()

        // Keyboard shortcuts
        codeEditor.setOption("extraKeys", {
            'Ctrl-Z': function(cm) {
                cm.undo();
            },
            'Ctrl-S': function(cm) {
                save();
            },
            'Ctrl-W': function(cm) {
                cm.setOption('lineWrapping', !cm.getOption('lineWrapping'));
            },
            'F11': function(cm) {
                if (cm.getOption('fullScreen')) {
                    cm.setOption('fullScreen', false);
                    $('.CodeMirror-scroll').css('height', '60vh');
                } else {
                    cm.setOption('fullScreen', true);
                    $('.CodeMirror-scroll').css('height', '100vh');
                }
            }
        });

        function hasUnsavedChanges() {
            let data = '';
            if (codeEditor.getValue === undefined) {
                data = codeEditor.edit.getValue();
            } else {
                data = codeEditor.getValue();
            }
            return currentFileContent !== data;
        }

        // A shortcut for changing the theme
        $(document).on('keydown', function(event) {
            if (event.ctrlKey && event.key === 'b') {
                changeThemeToDracula();
            }
            if (event.ctrlKey && event.key === 'n') {
                revertToOriginalTheme();
            }
        });

        function changeThemeToDracula() {
            codeEditor.setOption('theme', 'lucario');
        }

        function revertToOriginalTheme() {
            codeEditor.setOption('theme', 'default'); // Replace 'default' with your original theme name
        }

        // (name, file, subjectFile, emailToFile, emailCcFile)

        if (file !== null) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            url.searchParams.set('name', name);
            url.searchParams.set('subjectFile', subjectFile);
            url.searchParams.set('emailToFile', emailToFile);
            url.searchParams.set('emailCcFile', emailCcFile);
            window.history.replaceState(null, null, url.toString());
        }

    }

    function updateEditorSize() {
        codeWidth = $('#codeArea').width() - 30;
        $('#codeContainer').css('width', codeWidth + 'px');
        // Refresh CodeMirror
        $('.CodeMirror').each(function(i, el) {
            el.CodeMirror.refresh();
        });
    }

    /**
     * getForms Function
     * Purpose: On loading document, get all available forms on the portal for quick search
     */
    function getForms() {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "GET",
                url: "../api/formStack/categoryList",
                cache: false,
                success: (res) => loadFormSelection(res),
                fail: (err) => reject(err)
            });
        });
    }

    /**
     * loadFormSelection
     * Purpose: On getting forms, load selections into dropdown
     * @param forms
     */
    function loadFormSelection(forms) {
        let sel = document.getElementById('form-select-dropdown');
        // empty the selection for between loads
        sel.innerHTML = `<option value="">Select a Form</option>`;

        // repopulate the dropdown
        forms.forEach(form => {
            let opt = document.createElement('option');
            opt.value = form.categoryID;
            opt.innerHTML = form.categoryName.length > 50 ? form.categoryName.slice(0, 47) + "..." : form.categoryName;
            sel.appendChild(opt);
        });

        if (forms.length === 1) {
            getIndicators(forms[0].categoryID);
        }
    }

    /**
     * getIndicators Function
     * Purpose: On selecting a form via the dropdown generated by getForms(),
     * get all available indicators that exist in the selected form.
     */
    function getIndicators(form = "") {
        $.ajax({
            type: "GET",
            url: "../api/form/indicator/list",
            data: {forms: form},
            cache: false,
            success: (res) => {
                if (form === "") {
                    loadIndicatorSelection([]);
                } else {
                    const filteredIndicators = res.filter(i => +i.isDisabled === 0);
                    loadIndicatorSelection(filteredIndicators);
                }
                res.forEach(indicator => {
                    const indID = indicator.indicatorID
                    const format = (indicator.format || "").split("\n")[0];
                    indicatorFormats[indID] = format.trim().toLowerCase();
                });
                checkFieldEntries();
            },
            error: (err) => reject(err)
        });
    }

    /**
     * loadIndicatorSelection
     * Purpose: On selecting form in the form dropdown, load the indicators
     * for that form in the indicator dropdown.
     * @param indicators
     */
    function loadIndicatorSelection(indicators = []) {
        let div = document.getElementById('indicator-select');
        let sel = document.getElementById("indicator-select-dropdown");
        div.style.visibility = 'visible';
        let opt = null;

        sel.innerHTML = "";
        if(indicators.length === 0) {
            sel.innerHTML = `<option value="">No options available</option>`;
            showIndicator(0, 0);
        } else {
            let elFilter = document.createElement('div');
            indicators.forEach(indicator => {
                elFilter.innerHTML = indicator.name;
                const displayText = elFilter.textContent;
                opt = document.createElement('option');
                opt.value = indicator.indicatorID;
                opt.innerHTML = (displayText.length > 50 ? displayText.slice(0, 47) + "..." : displayText) + ` (#${indicator.indicatorID})`;
                opt.dataset.isSensitive = indicator.is_sensitive;
                sel.appendChild(opt);
            });
            showIndicator(indicators[0].indicatorID, indicators[0].is_sensitive);
        }
    }

    /**
     * Function showIndicator
     * Purpose: On selecting indicator in the indicator dropdown, show the
     * field ID and provide means to copy the syntax into the email template.
     * @param indicator: the ID of the indicator being selected
     * @param isSensitive: If the indicator is sensitive, warn the user.
     */
    function showIndicator(indicator = 0, isSensitive = 0) {
        let warning = document.getElementById('sensitive-warning');
        warning.style.visibility = +isSensitive === 1 && +indicator > 0 ? "visible" : "hidden";

        let sel = document.getElementById('indicator-id-label');
        let id = document.getElementById('indicator-id');

        let fieldValue = "\{\{\$field." + indicator + "\}\}";

        let copyFieldButton = document.getElementById("copy-field-id");
        copyFieldButton.innerHTML = `<i class="fas fa-copy" aria-hidden="true"></i> Copy`;
        copyFieldButton.style.color = "#005ea2";
        copyFieldButton.style.boxShadow = "inset 0 0 0 2px #005ea2";
        copyFieldButton.onclick = () => copyField(copyFieldButton, fieldValue);

        id.textContent = fieldValue;
        sel.style.visibility = +indicator > 0 ? "visible" : "hidden";
        copyFieldButton.style.visibility = +indicator > 0 ? "visible" : "hidden";
    }

    /**
     * Function copyField
     * Purpose: When click the copy button, copy the syntax of the field ID
     * required to the clipboard for use with the email template.
     * @param button: button whose appearance is changing to signify the
     * copy was successful.
     * @param fieldValue: The string being copied to the clipboard.
     */
    function copyField(button, fieldValue) {
        navigator.clipboard.writeText(fieldValue);
        button.innerHTML = `<i class="fas fa-check" aria-hidden="true"></i> Copied`;
        button.style.color = "#00a91c";
        button.style.boxShadow = "inset 0 0 0 2px #00a91c";
    }

    /**
     * initEditor Function
     * Purpose: Initiate the CodeMirror editor functions for the body and subject fields
     */
    function initEditor() {
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
    // Displays  user's history when creating, merge, and so on
    function viewHistory() {
        dialog_message.setContent('');
        dialog_message.setTitle('Access Template History');
        dialog_message.show();
        dialog_message.indicateBusy();
        var windowWidth = $(window).width();

        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
        }
        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistory&type=emailTemplate&id=' + currentFile,
            dataType: 'text',
            success: function(res) {
                dialog_message.setContent(res);
                dialog_message.indicateIdle();
                dialog_message.show();
            },
            error: function() {
                dialog_message.setContent('Loading failed.');
                dialog_message.show();
            },
            cache: false
        });
    }
    /* adds information about which users or groups are notified for custom email events */
    function addCustomEventInfo() {
        if(typeof currentFile === 'string') {
            const bubbleAttrs = `class="bg-yellow-5v" style="border-radius: 12px / 50%; padding: 0.375rem 0.625rem 0.25rem;"`
            try {
                fetch(`../api/workflow/customEvents`)
                .then(res => res.json()
                .then(data => {
                    const events = Array.isArray(data) ? data : [];
                    const sliceEnd = -('_body.tpl'.length);
                    const currentEvent = events.find(ev => ev?.eventID === currentFile.slice(0, sliceEnd)) || null;
                    let elInfo = document.getElementById('emailNotificationInfo');
                    if(currentEvent !== null && currentEvent.eventData !== '' && elInfo !== null) {
                        try {
                            const eventData = JSON.parse(currentEvent?.eventData || '{}');
                            const { NotifyRequestor, NotifyNext, NotifyGroup } = eventData;
                            const reqText = NotifyRequestor === 'true' ? `<div ${bubbleAttrs}>Notifies Requestor</div>` : '';
                            const nextText = NotifyNext === 'true' ? `<div ${bubbleAttrs}>Notifies Next Approver</div>` : '';
                            let arrNotices = [ reqText, nextText ];
                            arrNotices = arrNotices.filter(n => n !== '');

                            if (+NotifyGroup > 0) {
                                try {
                                    fetch('../api/group/list')
                                    .then(res => res.json()
                                    .then(data => {
                                        const groups = data;
                                        const groupName = groups.find(g => +NotifyGroup === g.groupID)?.name || '';
                                        const groupText = +NotifyGroup > 0 && groupName !== '' ? `<div ${bubbleAttrs}>Notifies Group \'${groupName}\'</div>` : '';
                                        if(groupText !== '') {
                                            arrNotices.push(groupText);
                                        }
                                        elInfo.innerHTML = arrNotices.join('');
                                        elInfo.style.display = arrNotices.length > 0 ? 'flex' : 'none';
                                    }).catch(err => console.log(err))
                                    ).catch(err => console.log(err));
                                } catch (err) {
                                    console.log(err);
                                }
                            } else {
                                elInfo.innerHTML = arrNotices.join('');
                                elInfo.style.display = arrNotices.length > 0 ? 'flex' : 'none';
                            }
                        } catch (err) {
                            console.log(err);
                        }

                    } else {
                        elInfo.innerHTML = '';
                        elInfo.style.display = 'none';
                    }
                }).catch(err => console.log(err))
                ).catch(err => console.log(err));

            } catch (err) {
                console.log(err);
            }
        }
    }
    // loads components when the document loads
    $(document).ready(function() {
        getIndicators(); //get indicators to make format table 
        $('.currentUrlLink').hide();
        $('.sidenav-right-compare').hide();
        dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
        initEditor();
        $(window).on('resize', function() {
            updateEditorSize();
        });
        // Get forms for quick search
        getForms().then((res) => console.log(res));
        // Get initial email tempates for page from database
        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates',
            success: function (res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/emailTemplates/custom',
                    dataType: 'json',
                    success: function (result) {
                        let res_array = $.parseJSON(result);
                        let buffer = '<ul class="leaf-ul">';
                        let filesMobile = `<label for="template_file_select">Template Files:</label>
                            <div class="template_select_container"><select id="template_file_select" class="templateFiles">`;

                        if (res_array.status['code'] === 2) {
                            for (let i in res) {
                                let custom = '';

                                if (result.includes(res[i].fileName)) {
                                    custom = '<span class=\'custom_file\' style=\'color:#c00000; font-size: .75em\'>(custom)</span>';
                                }

                                // Construct the option element with data- attributes for filesMobile
                                filesMobile += '<option data-template-data=\'' + JSON.stringify({
                                    displayName: res[i].displayName,
                                    fileName: res[i].fileName,
                                    subjectFileName: res[i].subjectFileName || '',
                                    emailToFileName: res[i].emailToFileName || '',
                                    emailCcFileName: res[i].emailCcFileName || '',
                                }) + '\'>' + res[i].displayName + custom + '</option>';

                                // Construct the li element for buffer
                                buffer += '<li>' + '<div class="template_files"><a href="#" data-template-index="' + i + '">' + res[i].displayName + '</a> ' + custom + ' </div>' + '</li>';
                            }

                            filesMobile += '</select></div>';
                            buffer += '</ul>';
                        } else if (res_array.status['code'] === 4) {
                            buffer += '<li>' + res_array.status['message'] + '</li>';
                            filesMobile += '<select><option>' + res_array.status['message'] + '</option></select>';
                        } else {
                            buffer += '<li>Internal error occurred. If this persists, contact your Primary Admin.</li>';
                            filesMobile += '<div>Internal error occurred. If this persists, contact your Primary Admin.</div>';
                        }

                        $('#fileList').html(buffer);
                        $('.filesMobile').html(filesMobile);

                        // Attach onchange event handler to templateFiles select element
                        $('.template_select_container').on('change', 'select.templateFiles', function () {
                            let selectedOption = $(this).find(':selected');
                            let templateData = selectedOption.data('template-data');

                            if (templateData) {
                                // Call the loadContent function with the required parameters
                                loadContent(templateData.displayName, templateData.fileName, templateData.subjectFileName, templateData.emailToFileName, templateData.emailCcFileName);
                            }
                        });

                        // Attach click event handler to template links in the buffer
                        $('.template_files a').on('click', function (e) {
                            e.preventDefault();
                            let templateIndex = $(this).data('template-index');
                            let template = res[templateIndex];

                            // Call the loadContent function with the required parameters
                            loadContent(template.displayName, template.fileName, template.subjectFileName || '', template.emailToFileName || '', template.emailCcFileName || '');
                        });
                    },
                    error: function (error) {
                        console.log(error);
                    }
                });
            },
            cache: false
        });

        // Load content from those templates to the current main template
        initializePage();
        // Refresh CodeMirror
        $('.CodeMirror').each(function(i, el) {
            el.CodeMirror.refresh();
        });
        $('#xhrDialog').hide();
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr',
            'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    });
</script>