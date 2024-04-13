<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates_reports.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Email Template Editor</h2>
        <button type="button" id="mobileToolsNavBtn" onclick="showRightNav(true)">
            Template Tools
        </button>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav" id="fileBrowser">
                <button type="button" id="btn_history" class="usa-button usa-button--outline" onclick="viewHistory()">
                    View History
                </button>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container email_templates">
                <h2 id="emailTemplateHeader">Default Email Template</h2>
                <div id="emailNotificationInfo"></div>
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
                <label for="code_mirror_subject_editor" id="subject">Subject</label>
                <div id="divSubject">
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label-left"></div>
                        <div class="CodeMirror-merge-pane-label-right">Current Subject</div>
                    </div>
                    <textarea id="subjectCode"></textarea>
                    <div id="subjectCompare"></div>
                </div>
                <label for="code_mirror_template_editor" id="filename" class="email">Body</label>
                <div id="emailBodyCode">
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label-left"></div>
                        <div class="CodeMirror-merge-pane-label-right">Current Body</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
                <div class="email-template-variables">
                    <fieldset>
                        <legend>Template Variables</legend>
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
                <div id="quick_field_search_container">
                    <fieldset>
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
                            <div id="sensitive-warning">*This field is marked as sensitive! The field value will not show
                                in sent emails*</div>
                        </div>
                    </fieldset>
                </div>
                <div class="keyboard_shortcuts">
                    <h3 class="keyboard_shortcuts_main_title">Keyboard Shortcuts within the Code Editor:</h3>
                    <div class="keyboard_shortcuts_section">
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Save:</h3>
                            <p class="keyboard_shortcut">Ctrl + S</p>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Undo:</h3>
                            <p class="keyboard_shortcut">Ctrl + Z</p>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Full Screen:</h3>
                            <p class="keyboard_shortcut">F11</p>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Toggle Darkmode:</h3>
                            <p class="keyboard_shortcut">Ctrl + B</p>
                        </div>
                    </div>
                    <p class="cm_editor_nav_help">Within the code editor, tab enters a tab character.  If using the keyboard to navigate, press escape followed by tab to exit the editor.</p>
                </div>
                <div class="keyboard_shortcuts_merge hide">
                    <h3 class="keyboard_shortcuts_main_title">Keyboard Shortcuts For Compare Code:</h3>
                    <div class="keyboard_shortcuts_section_merge">
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Merge Changes:</h3>
                            <p class="keyboard_shortcut">Ctrl + M</p>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <h3 class="keyboard_shortcuts_title">Exit Compare: </h3>
                            <p class="keyboard_shortcut">Ctrl + E </p>
                        </div>
                    </div>
                    <p class="cm_editor_nav_help">Within the code editor, tab enters a tab character.  If using the keyboard to navigate, press escape followed by tab to exit the editor.</p>
                </div>
            </div>
        </main>
        <div class="leaf-right-nav">
            <button type="button" id="closeMobileToolsNavBtn" aria-label="close tools menu"
                    onclick="showRightNav(false)">X</button>
            <aside class="filesMobile">
            </aside>
            <aside class="sidenav-right">
                <div id="controls">
                    <button type="button" id="save_button" class="usa-button" onclick="save();">
                        Save Changes
                        <span class="saveStatus"></span>
                    </button>

                    <button type="button" id="restore_original"
                        class="usa-button usa-button--secondary" onclick="restore();">
                        Restore Original
                    </button>

                    <button type="button" id="file_replace_file_btn" class="usa-button usa-button--secondary compare_only">
                        Use Old File
                    </button>

                    <button type="button" id="btn_compareStop"
                        class="usa-button usa-button--outline compare_only"
                        onclick="loadContent()">
                        Stop Comparing
                    </button>

                    <button type="button" id="btn_compare"
                        class="usa-button usa-button--outline edit_only" onclick="compare();">
                        Compare with Original
                    </button>

                    <button type="button"
                        class="usa-button usa-button--outline mobileHistory edit_only"
                        id="btn_history_mobile" onclick="viewHistory()">
                        View History
                    </button>
                </div>
            </aside>
            <div class="file-history">
                <h3>File History</h3>
                <div class="file-history-res"></div>
            </div>
        </div>
    </div>
</div>

<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script>
    // Global variables
    var codeEditor;
    var subjectEditor;
    var dialog_message;

    var currentName;
    var currentFile;
    var currentSubjectFile;
    var currentEmailToFile;
    var currentEmailCcFile;

    var currentFileContent;
    var currentSubjectContent;
    var currentEmailToContent;
    var currentEmailCcContent;

    let ignoreUnsavedChanges = false;
    let ignorePrompt = true;
    let indicatorFormats = {};
    const allowedToCcFormats = {
        "orgchart_employee": 1,
    }
    /**
    * Force show or hide the right nav despite screen width
    * @param {bool} showNav
    */
    function showRightNav(showNav = false) {
        let nav = $('.leaf-right-nav');
        if(showNav === true) {
            nav.removeClass('hide')
            setTimeout(() => {
                nav.addClass('show');
                $('#mobileToolsNavBtn').attr({'aria-expanded': true});
            });
        } else {
            nav.removeClass('show');
            setTimeout(() => {
                nav.addClass('hide');
                $('#mobileToolsNavBtn').attr({'aria-expanded': false});
            }, 500);
        }
    }
    /**
    * Return the data value of a given codeEditor instance
    * codeEditor instances are used globally but there can be more than one.
    * @param {object} codeEditor
    */
    function getCodeEditorValue(codeEditor = {}) {
        let data = '';
        if (codeEditor.getValue === undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }
        return data;
    }

    /** 
    * used on load and as a listener on email To CC fields
    * displays a message if non-orgchart employee format indicators are referenced in these areas
    */
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

    /**
    * compare content for expected fields to determine if unsaved changes exist
    */
    function hasContentChanged(emailToData, emailCcData, subjectData, bodyData) {
        const isDefaultTemplate = currentFile === "LEAF_main_email_template.tpl";
        const changesDetected = (
            isDefaultTemplate && bodyData !== currentFileContent ||
            !isDefaultTemplate && (
                emailToData !== currentEmailToContent ||
                emailCcData !== currentEmailCcContent ||
                subjectData !== currentSubjectContent ||
                bodyData !== currentFileContent
            )
        )
        return changesDetected;
    }
    /**
    * saves content changes to email/custom_overide folder and logs changes to history, or
    * displays a message if no changes are detected. updates global current content values at success.
    */
    function save() {
        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;
        const subject = getCodeEditorValue(subjectEditor);
        const data = getCodeEditorValue(codeEditor);

        const hasChanges = hasContentChanged(emailToData, emailCcData, subject, data);
        if (!hasChanges) {
            dialog_message.setContent('<h2>Please make a change to the content in order to save.</h2>');
            dialog_message.setTitle('No changes detected');
            dialog_message.show();

        } else {

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
                    if (res !== null) {
                        alert(res);
                    } else {
                        const time = new Date().toLocaleTimeString();
                        $('.saveStatus').html('<br /> Last saved: ' + time);
                        currentFileContent = data;
                        currentSubjectContent = subject;
                        currentEmailToContent = emailToData;
                        currentEmailCcContent = emailCcData;
                        saveFileHistory();
                        $('#restore_original, #btn_compare').addClass('modifiedTemplate');
                        $(`.template_files a[data-file="${currentFile}"] + span`).addClass('custom_file');
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.log('Error occurred during the save operation:', errorThrown);
                }
            });
        }
    }

    /**
     * saves current content for currentFile and associated fields to templates_history/email_templates
     * and adds records to portal template_history_files.  calls getFileHistory at success
     */
    function saveFileHistory() {
        const data = getCodeEditorValue(codeEditor);
        const subject = getCodeEditorValue(subjectEditor);
        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;

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
                getFileHistory(currentFile);
            },
            error: function(err) {
                console.log(err);
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
                    const numRecords = Array.from(document.querySelectorAll('.file_history_options_container button'))?.length;
                    if(numRecords === 0) {
                        saveFileHistory();
                    }
                    exitExpandScreen();
                }
            });
            dialog.hide();
        });
        dialog.show();
    }
    //get the file contents based on path/name and set up comparison view
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: `../api/templateFileHistory/_${template}`,
            dataType: 'json',
            success: function(res) {
                if (res?.length > 0) {
                    ignoreUnsavedChanges = false;
                    let fileParentName = '';
                    let fileName = '';
                    let whoChangedFile = '';
                    let fileCreated = [];

                    let accordion = '<div id="file_history_container">' +
                        '<div class="file_history_titles">' +
                        '<div class="file_history_date">Date:</div>' +
                        '<div class="file_history_author">Author:</div>' +
                        '</div>' +
                        '<div class="file_history_options_container">';
                    for (let i = 0; i < res.length; i++) {
                        fileParentName = res[i].file_parent_name;
                        fileName = res[i].file_name;
                        whoChangedFile = res[i].file_modify_by;
                        fileCreated = (res[i].file_created || '').split(' ');

                        accordion +=
                            `<button type="button" class="file_history_options_wrapper" onclick="compareHistoryFile('${fileName}','${fileParentName}', true)">
                                <div class="file_history_options_date">
                                    <div>${fileCreated?.[0] || ''}</div>
                                    <div>${fileCreated?.[1] || ''}</div>
                                </div>
                                <div class="file_history_options_author">${whoChangedFile}</div>
                            </button>`;
                    }
                    accordion += '</div></div>';
                    $('.file-history-res').html(accordion);

                } else {
                    $('.file-history-res').html(
                        '<p class="contentMessage">There are no history files.</p>'
                    );
                }
            },
            error: function(xhr, status, error) {
                console.log('Error getting file history: ' + error);
            },
            cache: false
        });
    }

    /*
    * Get the content for a file using names from its snapshot history and enter merge view.
    * @param {string} fileName - full file name
    * @param {string} parentFile - parent/basis file name
    * @param {bool} updateURL - whether to update URL params and add to URL history
    */
    function compareHistoryFile(fileName = '', parentFile = '', updateURL = false) {
        const initialBodyData = getCodeEditorValue(codeEditor);
        $('#bodyarea').off('keydown');
        $('#file_replace_file_btn').off('click');
        $('.CodeMirror').remove();
        $('#codeCompare').empty();

        //subject editor is not currently used in file history comparisons
        $('#subjectCompare').empty();
        $('#subject, #emailLists, #emailTo, #emailCc').hide();
        $('#divSubject, #divEmailTo, #divEmailCc').hide().prop('disabled', true);
        if(typeof subjectEditor?.setOption === 'function') {
            subjectEditor.setOption("readOnly", true);
        }

        $.ajax({
            type: 'GET',
            url: `../templates_history/email_templates/${fileName}`,
            dataType: 'text',
            cache: false,
            success: function(fileContent) {
                $('#emailBodyCode .CodeMirror-merge-pane-label-left').html(`Old Body File ${initialBodyData === fileContent ? '(No Changes)' : ''}`);

                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    mode: 'htmlmixed',
                    lineNumbers: true,
                    indentUnit: 4,
                    value: initialBodyData,
                    origLeft: fileContent.replace(/\r\n/g, "\n"),
                    showDifferences: true,
                    collapseIdentical: true,
                    autoFormatOnStart: true,
                    autoFormatOnMode: true,
                    extraKeys: {
                        "Esc": function(cm) {
                            const disableTab = { "Tab": false, "Shift-Tab": false };
                            cm.addKeyMap(disableTab);
                            setTimeout(() => {
                                cm.removeKeyMap(disableTab);
                            }, 2500);
                        },
                    }
                });
                addCodeMirrorAria('codeCompare', true);

                const mergeFile = () => {
                    const currentBodyData = getCodeEditorValue(codeEditor);
                    const leftBodyData = codeEditor.leftOriginal().getValue();
                    if(currentBodyData === leftBodyData) {
                        alert('There are no changes to save.');
                    } else {
                        ignoreUnsavedChanges = true;
                        saveMergedChangesToFile(parentFile, leftBodyData);
                    }
                }
                const compareModeQuickKeys = (event) => {
                    const key = event.key.toLowerCase();
                    if (event.ctrlKey && ['e','m'].includes(key)) {
                        event.preventDefault();
                        if(key === 'e') {
                            exitExpandScreen();
                        }
                        if(key === 'm') {
                            mergeFile();
                        }
                    }
                }
                editorExpandScreen();
                $('.CodeMirror').each(function(i, el) {
                    el.CodeMirror.refresh();
                });
                $('#bodyarea').on('keydown', compareModeQuickKeys);
                $('#file_replace_file_btn').on('click', mergeFile);
            },
            error: function(err) {
                console.log("file not found", err)
            }
        });

        if (updateURL === true) {
            let url = new URL(window.location.href);
            url.searchParams.set('fileName', fileName);
            url.searchParams.set('parentFile', parentFile);
            window.history.replaceState(null, null, url.toString());
        }
    }
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
                exitExpandScreen();
            },
            error: function(xhr, status, error) {
                console.log(xhr.responseText);
            }
        });
    }
    //Called once at DOM ready. Loads the intial file based on URL and sets beforeunload listener.
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
        //displays a generic prompt if navigating from page with unsaved changes
        $(window).on('beforeunload', function(e) {
            const emailToData = document.getElementById('emailToCode').value;
            const emailCcData = document.getElementById('emailCcCode').value;
            const subject = getCodeEditorValue(subjectEditor);
            const data = getCodeEditorValue(codeEditor);
            const hasChanges = hasContentChanged(emailToData, emailCcData, subject, data);
            if (!ignoreUnsavedChanges && !ignorePrompt && hasChanges) {
                e.preventDefault();
                return true;
            }
        });
    }

    // compares the current file to the default file content
    function compare() {
        const bodyData = getCodeEditorValue(codeEditor);
        const subjectData = getCodeEditorValue(subjectEditor);
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#subjectCompare').empty();

        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates/_' + currentFile + '/standard',
            success: function(standard) {
                const noBodyChanges = bodyData === standard.file; //this could potentially still happen due to manual reverts
                $('#emailBodyCode .CodeMirror-merge-pane-label-left').html(`Original Body ${noBodyChanges === true ? '(No Changes)' : ''}`);
                //set body and subject to their current value, origLeft to standard file values
                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    mode: "htmlmixed",
                    lineNumbers: true,
                    indentUnit: 4,
                    value: bodyData,
                    origLeft: standard.file.replace(/\r\n/g, "\n"),
                    showDifferences: true,
                    collapseIdentical: true,
                    extraKeys: {
                        "Esc": function(cm) {
                            const disableTab = { "Tab": false, "Shift-Tab": false };
                            cm.addKeyMap(disableTab);
                            setTimeout(() => {
                                cm.removeKeyMap(disableTab);
                            }, 2500);
                        },
                    }
                });
                addCodeMirrorAria('codeCompare', true);

                const noSubjectChanges = subjectData === standard.subjectFile || ''; //this could potentially still happen due to manual reverts
                $('#divSubject .CodeMirror-merge-pane-label-left').html(`Original Subject ${noSubjectChanges === true ? '(No Changes)' : ''}`);
                subjectEditor = CodeMirror.MergeView(document.getElementById("subjectCompare"), {
                    mode: "htmlmixed",
                    lineNumbers: true,
                    indentUnit: 4,
                    value: subjectData,
                    origLeft: (standard.subjectFile || '').replace(/\r\n/g, "\n"),
                    showDifferences: true,
                    collapseIdentical: true,
                    extraKeys: {
                        "Esc": function(cm) {
                            const disableTab = { "Tab": false, "Shift-Tab": false };
                            cm.addKeyMap(disableTab);
                            setTimeout(() => {
                                cm.removeKeyMap(disableTab);
                            }, 2500);
                        },
                    }
                });
                addCodeMirrorAria('subjectCompare', true);

                editorExpandScreen(true);
            },
            error: function(err) {
                console.log("error getting standard file", err)
            },
            cache: false
        });
    }
    //enters 2 pane comparison merge view
    function editorExpandScreen(compareOriginal = false) {
        $('.page-title-container > h2').html('Email Template Editor > Compare Code');
        showRightNav(false);
        $('#restore_original, #file_replace_file_btn').removeClass('comparing');
        if(compareOriginal === true) {
            $('#restore_original').addClass('comparing');
        } else {
            $('#file_replace_file_btn').addClass('comparing');
        }
        $('#controls').addClass('comparing');
        $(".compared-label-content").css("display", "flex");

        $('.leaf-left-nav').addClass('hide');
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
        });
        $('#quick_field_search_container').hide();
        $('#emailLists, .email-template-variables').hide();
        $('.keyboard_shortcuts').addClass('hide');
        $('.keyboard_shortcuts_merge').removeClass('hide');
    }
    // exits comparison view and loads the current files
    function exitExpandScreen(load = true) {
        $('#file_replace_file_btn').off('click');
        $('#bodyarea').off('keydown');
        $('.page-title-container > h2').html('Email Template Editor');
        showRightNav(false);
        $('#controls, #restore_original, #file_replace_file_btn').removeClass('comparing');
        $(".compared-label-content").css("display", "none");

        $('.leaf-left-nav').removeClass('hide');
        setTimeout(() => {
            $('.leaf-left-nav').css({
                'position': 'relative',
                'left': '0'
            });
        });
        $('#quick_field_search_container').show();
        $('.email-template-variables, #emailLists').show();

        $('.keyboard_shortcuts').removeClass('hide');
        $('.keyboard_shortcuts_merge').addClass('hide');

        //remove comparison view url params
        let url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());
        if(load === true) {
            loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
        }
    }

    /**
    * Used in editing view to load content and associated history records.
    * Prepares codeEditor. Updates the display area, url, and current content global variables.
    * @param {string} name - description of event being loaded. eg Send Back
    * @param {string} file - body template name. eg LEAF_send_back_body.tpl
    * @param {string} subjectFile - subject template name. eg LEAF_send_back_subject.tpl
    * @param {string} emailToFile - eg LEAF_send_back_emailTo.tpl
    * @param {string} emailCcFile - eg LEAF_send_back_emailCc.tpl
    */
    function loadContent(name, file, subjectFile, emailToFile, emailCcFile) {
        console.log("email loadC\n", name + "\n", file + "\n", subjectFile + "\n", emailToFile + "\n", emailCcFile)
        if (file === undefined) {
            console.log(codeEditor || 'not init')
            name = currentName;
            file = currentFile;
            subjectFile = currentSubjectFile;
            emailToFile = currentEmailToFile;
            emailCcFile = currentEmailCcFile;
            exitExpandScreen(false);
        }

        if (ignorePrompt) { //true on page load
            ignorePrompt = false;
        } else {
            const emailToData = document.getElementById('emailToCode').value;
            const emailCcData = document.getElementById('emailCcCode').value;
            const subject = getCodeEditorValue(subjectEditor);
            const data = getCodeEditorValue(codeEditor);
            const hasChanges = hasContentChanged(emailToData, emailCcData, subject, data);
            if (!ignoreUnsavedChanges && hasChanges &&
                !confirm('You have unsaved changes. Are you sure you want to leave this page?')) {
                return;
            }
        }

        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#subjectCompare').empty();
        $('#codeContainer').hide();

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
        getFileHistory(file);
        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates/_' + file,
            success: function(res) {
                $('#codeContainer').fadeIn();
                // Check if codeEditor is defined, has a setValue method and file property exists
                if (codeEditor && typeof codeEditor.setValue === 'function' && res?.file !== undefined) {
                    codeEditor.setValue(res.file);
                    currentFileContent = codeEditor.getValue();
                    if (subjectEditor && res.subjectFile !== null) { //subject is null for default email template
                        subjectEditor.setValue(res.subjectFile);
                        currentSubjectContent = subjectEditor.getValue();
                    }
                    $('.CodeMirror').each(function(i, el) {
                        el.CodeMirror.refresh();
                    });
                    currentEmailToContent = res.emailToFile;
                    currentEmailCcContent = res.emailCcFile;
                    $("#emailToCode").val(currentEmailToContent);
                    $("#emailCcCode").val(currentEmailCcContent);
                } else {
                    res?.file === undefined ?
                    console.error('file not found'):
                    console.error('codeEditor is not properly initialized.');
                }

                checkFieldEntries();
                if (res.modified === 1) {
                    $('#restore_original, #btn_compare').addClass('modifiedTemplate');
                    $(`.template_files a[data-file="${currentFile}"] + span`).addClass('custom_file');
                } else {
                    $('#restore_original, #btn_compare').removeClass('modifiedTemplate');
                    $(`.template_files a[data-file="${currentFile}"] + span`).removeClass('custom_file');
                }
                addCustomEventInfo(currentFile);
            },
            error: function(err) {
                console.log("error getting file", err)
            },
            async: false,
            cache: false
        });
        $('.saveStatus').html('');

        if(file) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            url.searchParams.set('name', name);
            url.searchParams.set('subjectFile', subjectFile);
            url.searchParams.set('emailToFile', emailToFile);
            url.searchParams.set('emailCcFile', emailCcFile);
            window.history.replaceState(null, null, url.toString());
        }
    }

    /**
     * getForms Function
     * Purpose: On loading document, get all available forms on the portal for quick search
     */
    function getForms() {
        $.ajax({
            type: "GET",
            url: "../api/formStack/categoryList",
            cache: false,
            success: (res) => loadFormSelection(res),
            error: (err) => console.log(err)
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
            data: { forms: form },
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
            error: (err) => console.log(err)
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

    /* adds aria attributes to editor or merge panes for screenreaders */
    function addCodeMirrorAria(mountID = '', mergeView = false) {
        const textareaID = mountID.includes('code') ? 'code_mirror_template_editor' : 'code_mirror_subject_editor';
        if (mergeView === true) {
            $('.CodeMirror-merge-pane textarea').attr({
                'aria-label': 'Template Editor coding area.  Press escape twice followed by tab to navigate out.'
            });
            $(`#${mountID} .CodeMirror-merge-pane-rightmost textarea`).attr({
                'id': textareaID,
                'role': 'textbox',
                'aria-multiline': true,
            });
        } else {
            $(`#${mountID} + .CodeMirror textarea`).attr({
                'id': textareaID,
                'role': 'textbox',
                'aria-multiline': true,
                'aria-label': 'Template Editor coding area.  Press escape twice followed by tab to navigate out.'
            });
        }
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
                    if (cm.getOption("fullScreen")) {
                        cm.setOption("fullScreen", false);
                    } else {
                        const disableTab = { "Tab": false, "Shift-Tab": false };
                        cm.addKeyMap(disableTab);
                        setTimeout(() => {
                            cm.removeKeyMap(disableTab);
                        }, 2500);
                    }
                },
                "Ctrl-S": function(cm) {
                    save();
                },
                "Ctrl-B": function(cm) {
                    const newTheme = cm.options.theme === 'default' ? 'lucario' : 'default';
                    cm.setOption('theme', newTheme);
                }
            }
        });
        addCodeMirrorAria('code');

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
                    if (cm.getOption("fullScreen")) {
                        cm.setOption("fullScreen", false);
                    } else {
                        const disableTab = { "Tab": false, "Shift-Tab": false };
                        cm.addKeyMap(disableTab);
                        setTimeout(() => {
                            cm.removeKeyMap(disableTab);
                        }, 2500);
                    }
                },
                "Ctrl-S": function(cm) {
                    save();
                }
            }
        });
        addCodeMirrorAria('subjectCode');
    }
    // Displays  user's history when creating, merge, and so on
    function viewHistory() {
        dialog_message.setContent('');
        dialog_message.setTitle('Access Template History');
        dialog_message.show();
        dialog_message.indicateBusy();
        showRightNav(false);
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
                            const reqText = NotifyRequestor === 'true' ? `<div class="bg-yellow-5v">Notifies Requestor</div>` : '';
                            const nextText = NotifyNext === 'true' ? `<div class="bg-yellow-5v">Notifies Next Approver</div>` : '';
                            let arrNotices = [ reqText, nextText ];
                            arrNotices = arrNotices.filter(n => n !== '');

                            if (+NotifyGroup > 0) {
                                try {
                                    fetch('../api/group/list')
                                    .then(res => res.json()
                                    .then(data => {
                                        const groups = data;
                                        const groupName = groups.find(g => +NotifyGroup === g.groupID)?.name || '';
                                        const groupText = +NotifyGroup > 0 && groupName !== '' ? `<div class="bg-yellow-5v">Notifies Group \'${groupName}\'</div>` : '';
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
    //loads components when the document loads
    $(document).ready(function() {
        getIndicators(); //get indicators to make format table 
        getForms(); //get forms for quick search and indicator format info

        dialog = new dialogController(
            'confirm_xhrDialog',
            'confirm_xhr',
            'confirm_loadIndicator',
            'confirm_button_save',
            'confirm_button_cancelchange'
        );
        dialog_message = new dialogController(
            'genericDialog',
            'genericDialogxhr',
            'genericDialogloadIndicator',
            'genericDialogbutton_save',
            'genericDialogbutton_cancelchange'
        );

        // Get initial email templates for page from database
        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates',
            success: function (res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/emailTemplates/custom',
                    dataType: 'json',
                    success: function (customTemplates) {
                        let buffer = '<ul class="leaf-ul">';
                        let filesMobile = `<label for="template_file_select">Template Files:</label>
                            <div class="template_select_container"><select id="template_file_select" class="templateFiles">`;

                        if (Array.isArray(customTemplates)) {
                            let customClass = '';
                            for (let i in res) {
                                customClass = customTemplates.includes(res[i].fileName) ? ' class="custom_file"' : '';

                                // Construct the option element with data- attributes for filesMobile
                                filesMobile += '<option data-template-data=\'' + JSON.stringify({
                                    displayName: res[i].displayName,
                                    fileName: res[i].fileName,
                                    subjectFileName: res[i].subjectFileName || '',
                                    emailToFileName: res[i].emailToFileName || '',
                                    emailCcFileName: res[i].emailCcFileName || '',
                                }) + '\'>' + res[i].displayName + (customClass ? ' (custom)' : '') + '</option>';

                                // Construct the li element for buffer
                                buffer += `<li>
                                    <div class="template_files">
                                        <a href="#" data-template-index="${i}" data-file="${res[i].fileName}">${res[i].displayName}</a> <span${customClass}>(custom)</span>
                                    </div>
                                </li>`;
                            }

                            filesMobile += '</select></div>';
                            buffer += '</ul>';
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
    });
</script>