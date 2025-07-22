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

        <div id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container email_templates">
                <h2 id="emailTemplateHeader">Notify Next Approver</h2>
                <div id="emailNotificationInfo"></div>
                <div id="emailLists">
                    <fieldset>
                        <legend>Email To and CC</legend>
                        <p>
                            Enter email addresses, one per line. Users will be
                            emailed each time this template is used in any workflow.&nbsp;
                            <div id="field_use_notice" style="display: none;">
                            Please note that only orgchart employee formats are supported in this section.
                            </div>
                            <div id="to_cc_smarty_vars_notice" style="display:none">
                                Potential Variable errors in To/Cc: <span id="to_cc_field_errors"></span><br>
                                <span style="color:#000;">Example: {{$variable}}</span>
                            </div>
                        </p>
                        <label for="emailToCode" id="emailTo" class="emailToCc">Email To:</label>
                        <div id="divEmailTo">
                            <textarea id="emailToCode" style="width:95%;resize:vertical" rows="4" onchange="checkFieldEntries()"></textarea>
                        </div>
                        <label for="emailCcCode" id="emailCc" class="emailToCc">Email CC:</label>
                        <div id="divEmailCc">
                            <textarea id="emailCcCode" style="width:95%;resize:vertical" rows="4" onchange="checkFieldEntries()"></textarea>
                        </div>
                    </fieldset>
                </div>
                <div id="subject_smarty_vars_notice" style="display:none;">
                    Potential Variable errors in Subject: <span id="subject_field_errors"></span><br>
                    <span style="color:#000;">Example: {{$variable}}</span>
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
                <div id="body_smarty_vars_notice" style="display:none;">
                    Potential Variable errors in Body: <span id="body_field_errors"></span><br>
                    <span style="color:#000;">Example: {{$variable}}</span>
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
                <div>
                    <textarea id="editor_trumbowyg" aria-hidden="true" style="display:none;"></textarea>
                    <div id="editor_trumbowyg_saving"><h3>Saving...</h3></div>
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
                                <td>The full title of the request<br /><span style="color:#c00000;">If need to know is on: The type of form</span></td>
                            </tr>
                            <tr>
                                <td><b>{{$fullTitle_insecure}}</b></td>
                                <td>The full title of the request<br /><span style="color:#c00000;">By using this variable, I certify that record titles related to these emails are not designed to contain PHI/PII.</span></td>
                            </tr>
                            <tr>
                                <td><b>{{$truncatedTitle}}</b></td>
                                <td>The request title, truncated to 45 characters in length<br /><span style="color:#c00000;">If need to know is on: The type of form</span></td>
                            </tr>
                            <tr>
                                <td><b>{{$truncatedTitle_insecure}}</b></td>
                                <td>The request title, truncated to 45 characters in length<br /><span style="color:#c00000;">By using this variable, I certify that record titles related to these emails are not designed to contain PHI/PII.</span></td>
                            </tr>
                            <tr>
                                <td><b>{{$formType}}</b></td>
                                <td>The type of form</td>
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
                                <td>The value of the field by ID<br /><span style="color:#c00000;">Sensitive data fields will not work in email templates.</span></td>
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
        </div>
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
                        onclick="loadContent(null, null)">
                        Stop Comparing
                    </button>

                    <button type="button" id="btn_compare"
                        class="usa-button usa-button--outline edit_only" onclick="compare();">
                        Compare with Original
                    </button>

                    <button type="button" id="btn_useTrumbowyg"
                        class="usa-button usa-button--outline edit_only show_button"
                        onclick="useTrumbowygEmailEditor()">Use Preview Editor
                    </button>
                    <button type="button" id="btn_useCodeMirror"
                        class="usa-button usa-button--outline edit_only"
                        onclick="useCodeEmailEditor()">Use Code Editor
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
    //global variables
    let codeEditor;
    let subjectEditor;
    let dialog_message;

    let currentLabel;
    let currentFile;
    let currentSubjectFile;
    let currentEmailToFile;
    let currentEmailCcFile;

    let currentFileContent;
    let currentTrumbowygFileContent;
    let currentSubjectContent;
    let currentEmailToContent;
    let currentEmailCcContent;

    let ignoreUnsavedChanges = false;
    let ignorePrompt = true;
    let indicatorFormats = {};
    const allowedToCcFormats = {
        "orgchart_employee": 1,
    }

    $(function(){
        $('#emailToCode').on("keyup", function(e) {
            this.value = this.value.replace(/[,;:\s]/g, '\n');
            this.value = this.value.replace(/(.)\n?\n/g, '$1\n');
        });

        $('#emailCcCode').on("keyup", function(e) {
            this.value = this.value.replace(/[,;:\s]/g, '\n');
            this.value = this.value.replace(/(.)\n?\n/g, '$1\n');
        });
    });

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
    function checkFieldEntries(cm = null, orgEmployeeOnly = true) {
        const smartyVarReg = /\{.*?\}?\}/g;
        let smartyErrors = [];
        let varMatches = [];

        if (orgEmployeeOnly === true) {
            //to and cc textareas only support orgchart employee format
            const elTextareaTo = document.getElementById("emailToCode");
            const elTextareaCc = document.getElementById("emailCcCode");
            const elTextInput = (elTextareaTo?.value || "") + "\r\n" + (elTextareaCc?.value || "");

            let elFormatNotice = document.getElementById("field_use_notice");
            let elVariableNotice = document.getElementById("to_cc_smarty_vars_notice");
            let elErrors = document.getElementById('to_cc_field_errors');
            varMatches = elTextInput.match(smartyVarReg) ?? [];

            let includesNonOrgchartEmp = false;
            for(let i = 0; i < varMatches.length; i++) {
                const m = varMatches[i];
                if(typeof m === 'string' && m.includes('field.')) {
                    const id = m.match(/\d{1,}/g)?.[0];
                    if (!/^\{\{\$\S/.test(m) || !m.endsWith('}}')) {
                        smartyErrors.push(m);
                    }
                    if(allowedToCcFormats?.[indicatorFormats?.[id]] !== 1) {
                        includesNonOrgchartEmp = true;
                        break;
                    }
                } else {
                    includesNonOrgchartEmp = true;
                    break;
                }
            }
            if(elFormatNotice !== null) {
                elFormatNotice.style.display = includesNonOrgchartEmp === true ? 'block' : 'none';
            }

            if (elVariableNotice !== null && elErrors !== null) {
                if (smartyErrors.length > 0) {
                    elVariableNotice.style.display = 'block';
                    elErrors.textContent = smartyErrors.join(',');
                } else {
                    elVariableNotice.style.display = 'none';
                    elErrors.textContent = '';
                }
            }


        } else {
            let elVariableNotice = null
            let elErrors = null
            let content = '';

            if(cm !== null) { //subject or code editor mode body
                content = getCodeEditorValue(cm);
                const textareaID = (cm.getTextArea()?.id ?? '').toLowerCase();
                if(textareaID === 'subjectcode') {
                    elVariableNotice = document.getElementById("subject_smarty_vars_notice");
                    elErrors = document.getElementById('subject_field_errors');
                } else {
                    elVariableNotice = document.getElementById("body_smarty_vars_notice");
                    elErrors = document.getElementById('body_field_errors');
                }

            } else {
                content = document.querySelector('#emailBodyCode + div textarea.trumbowyg-textarea')?.value ?? '';
                elVariableNotice = document.getElementById("body_smarty_vars_notice");
                elErrors = document.getElementById('body_field_errors');
            }

            varMatches = content.match(smartyVarReg) ?? [];
            varMatches.forEach(m => {
                if (!/^\{\{\$\S/.test(m) || !m.endsWith('}}')) {
                    smartyErrors.push(m);
                }
            });

            if (elVariableNotice !== null && elErrors !== null) {
                if (smartyErrors.length > 0) {
                    elVariableNotice.style.display = 'block';
                    elErrors.textContent = smartyErrors.join(', ');
                } else {
                    elVariableNotice.style.display = 'none';
                    elErrors.textContent = '';
                }
            }
        }
    }

    /**
    * compare content for expected fields to determine if unsaved changes exist
    */
    function hasContentChanged(emailToData, emailCcData, subjectData, bodyData, trumbowValue = null) {
        let currentBody = currentFileContent;
        if(trumbowValue !== null) {
            bodyData = trumbowValue;
            currentBody = currentTrumbowygFileContent;
        }
        return (
            emailToData !== currentEmailToContent ||
            emailCcData !== currentEmailCcContent ||
            subjectData !== currentSubjectContent ||
            bodyData !== currentBody
        );
    }

    /**
    * Saves codeEditor, subjectEditor, emailTo and emailCc content to templates/email/custom_override if there are changes.
    * Displays last save time, updates current*Content values, and calls saveFileHistory at success.
    */
    function save() {
        let elSaveBtn = document.getElementById('save_button');
        const trumbowValue = document.querySelector(
            '#emailBodyCode + div textarea.trumbowyg-textarea'
        )?.value || null;

        if(trumbowValue !== null) {
            useCodeEmailEditor();
            $('#editor_trumbowyg_saving').show();
            toggleEditorElements(true);
        }

        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;
        const subject = getCodeEditorValue(subjectEditor);
        const data = getCodeEditorValue(codeEditor);

        const hasAnyChanges = hasContentChanged(emailToData, emailCcData, subject, data, trumbowValue);
        if (!hasAnyChanges) {
            alert('There are no changes to save.');
            if(trumbowValue !== null) {
                useTrumbowygEmailEditor();
                $('#editor_trumbowyg_saving').hide();
            }
        } else {
            elSaveBtn.setAttribute("disabled", "disabled");
            //if no history exists yet, snapshot the original first
            const numRecords = Array.from(document.querySelectorAll('.file_history_options_container button')).length;
            if(numRecords === 0) {
                $.ajax({
                    type: 'POST',
                    data: {
                        CSRFToken: '<!--{$CSRFToken}-->',
                        file: currentFileContent,
                        subjectFile: currentSubjectContent,
                        subjectFileName: currentSubjectFile,
                        emailToFile: currentEmailToContent,
                        emailToFileName: currentEmailToFile,
                        emailCcFile: currentEmailCcContent,
                        emailCcFileName: currentEmailCcFile
                    },
                    url: '../api/emailTemplateFileHistory/_' + currentFile,
                    success: function(res) {},
                    error: function(err) {
                        console.log(err);
                    },
                });
            }

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
                        //switch to Trumbowyg if it had been used
                        if(trumbowValue !== null) {
                            $('#editor_trumbowyg_saving').hide();
                            useTrumbowygEmailEditor();
                            currentTrumbowygFileContent = trumbowValue;
                        //use (body) data to sync current value regardless.
                        } else {
                            currentTrumbowygFileContent = data;
                        }
                    }
                    elSaveBtn.removeAttribute("disabled");
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    if(trumbowValue !== null) {
                        $('#editor_trumbowyg_saving').hide();
                        useTrumbowygEmailEditor();
                    }
                    elSaveBtn.removeAttribute("disabled");
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
                    let fileParentName = '';
                    let fileName = '';
                    let whoChangedFile = '';
                    let fileCreated = '';

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
                        let createDate = new Date(parseInt(res[i].filemtime) * 1000);
                        fileCreated = createDate.toLocaleDateString() + '<br />' + createDate.toLocaleTimeString();

                        accordion +=
                            `<button type="button" class="file_history_options_wrapper" onclick="compareHistoryFile('${fileName}','${fileParentName}', true)">
                                <div class="file_history_options_date">
                                    <div>${fileCreated}</div>
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
        useCodeEmailEditor();
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

    /*
    * Set content for an email template body based on merge view left pane content to templates/email/custom_override.
    * @param {string} fileParentName - name of the base body file, including .tpl
    * @param {string} mergedContent - content to save
    */
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
            loadContent(currentLabel, templateFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (fileName !== null && parentFile !== null && templateSubjectFile !== null) {
            loadContent(templateName, templateFile, templateSubjectFile, templateEmailToFile, templateEmailCcFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (templateSubjectFile == 'undefined') {
            loadContent(currentLabel, templateFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
        } else if (templateFile !== null) {
            loadContent(templateName, templateFile, templateSubjectFile, templateEmailToFile, templateEmailCcFile);
        } else {
            loadContent(
                'Notify Next Approver',
                'LEAF_notify_next_body.tpl',
                'LEAF_notify_next_subject.tpl',
                'LEAF_notify_next_emailTo.tpl',
                'LEAF_notify_next_emailCc.tpl'
            );
        }
        //displays a generic prompt if navigating from page with unsaved changes
        $(window).on('beforeunload', function(e) {
            const emailToData = document.getElementById('emailToCode').value;
            const emailCcData = document.getElementById('emailCcCode').value;
            const subject = getCodeEditorValue(subjectEditor);
            const data = getCodeEditorValue(codeEditor);
            const trumbowValue = document.querySelector('#emailBodyCode + div textarea.trumbowyg-textarea')?.value || null;

            const hasChanges = hasContentChanged(emailToData, emailCcData, subject, data, trumbowValue);
            if (!ignoreUnsavedChanges && !ignorePrompt && hasChanges) {
                e.preventDefault();
                return true;
            }
        });
    }

    // compares the current file to the default file content
    function compare() {
        useCodeEmailEditor(false);
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
    //exits comparison merge view. If load is true, synchronously loads the current file
    function exitExpandScreen(load = true) {
        $('#codeCompare').empty();
        $('#subjectCompare').empty();
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
        if(currentSubjectFile) {
            $('.email-template-variables, #emailLists').show();
        }

        $('.keyboard_shortcuts').removeClass('hide');
        $('.keyboard_shortcuts_merge').addClass('hide');

        //remove comparison view url params
        let url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());
        if(load === true) {
            loadContent(currentLabel, currentFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
        }
    }

    /**
    * Used in editing view to load content and associated history records.
    * Prepares codeEditor. Updates the display area, url, and current content global variables.
    * @param {string} label - label of template being loaded. eg Send Back
    * @param {string} file - body template name. eg LEAF_send_back_body.tpl
    * @param {string} subjectFile - subject template name. eg LEAF_send_back_subject.tpl
    * @param {string} emailToFile - eg LEAF_send_back_emailTo.tpl
    * @param {string} emailCcFile - eg LEAF_send_back_emailCc.tpl
    */
    function loadContent(label, file, subjectFile, emailToFile, emailCcFile) {
        //current T editor val if it exists
        const trumbowValue = document.querySelector(
            '#emailBodyCode + div textarea.trumbowyg-textarea'
        )?.value || null;

        useCodeEmailEditor();

        if (!file) {
            if(file === null && currentFile && codeEditor) { //from compare view
                const mergeViewBodyValue = getCodeEditorValue(codeEditor);
                const mergeViewSubjectValue = getCodeEditorValue(subjectEditor);
                exitExpandScreen(false);
                initEditor();
                codeEditor.setValue(mergeViewBodyValue);
                if(currentSubjectFile) {
                    subjectEditor.setValue(mergeViewSubjectValue);
                    $('#subject, #emailLists, #emailTo, #emailCc').show();
                    $('#divSubject, #divEmailTo, #divEmailCc').show().prop('disabled', false);
                }
                $('.CodeMirror').each(function(i, el) {
                    el.CodeMirror.refresh();
                });
            } else {
                $('#codeContainer').html('Error: No file specified. File cannot be loaded.');
            }
            return;
        }

        if (ignorePrompt === true) { //true only on page load
            ignorePrompt = false;
        } else {
            const emailToData = document.getElementById('emailToCode').value;
            const emailCcData = document.getElementById('emailCcCode').value;
            const subject = getCodeEditorValue(subjectEditor);
            const data = getCodeEditorValue(codeEditor);

            const hasChanges = hasContentChanged(emailToData, emailCcData, subject, data, trumbowValue);
            if (!ignoreUnsavedChanges && hasChanges &&
                !confirm('You have unsaved changes. Are you sure you want to leave this page?')) {
                if(trumbowValue !== null) {
                    useTrumbowygEmailEditor();
                }
                return;
            }
        }
        $('.saveStatus').html('');
        $('.CodeMirror').remove();

        initEditor();
        currentLabel = label;
        currentFile = file;
        currentSubjectFile = subjectFile;
        currentEmailToFile = emailToFile;
        currentEmailCcFile = emailCcFile;
        $('#codeContainer').css('display', 'none');
        $('#emailTemplateHeader').html(currentLabel);
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
                if (codeEditor && typeof codeEditor.setValue === 'function' && res?.file !== undefined && res?.file !== false) {
                    codeEditor.setValue(res.file);
                    currentFileContent = codeEditor.getValue();
                    if (subjectEditor && res.subjectFile !== null) { //subject is null for default email template
                        subjectEditor.setValue(res.subjectFile);
                        currentSubjectContent = subjectEditor.getValue();
                    }
                    $('.CodeMirror').each(function(i, el) {
                        el.CodeMirror.refresh();
                    });
                    ignoreUnsavedChanges = false;
                    currentEmailToContent = res.emailToFile;
                    currentEmailCcContent = res.emailCcFile;
                    $("#emailToCode").val(currentEmailToContent);
                    $("#emailCcCode").val(currentEmailCcContent);

                    useTrumbowygEmailEditor();
                    //update current content from new T editor set up after file load
                    const elTrumbow = document.querySelector('#emailBodyCode + div textarea.trumbowyg-textarea');
                    if(elTrumbow !== null) {
                        currentTrumbowygFileContent = elTrumbow.value;
                    }

                } else {
                    res?.file === undefined || res?.file === false ?
                        console.error('file not found') :
                        console.error('codeEditor is not properly initialized.');
                }

                checkFieldEntries();
                if (res?.modified === 1) {
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

        if(file) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            url.searchParams.set('name', label);
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
        codeEditor.on('blur', (cm) => checkFieldEntries(cm, false));
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
        subjectEditor.on('blur', (cm) => checkFieldEntries(cm, false));
        addCodeMirrorAria('subjectCode');

        setTimeout(() => {
            checkFieldEntries(codeEditor, false);
            checkFieldEntries(subjectEditor, false);
        });
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
                .then(res => res.json())
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
                                    .then(res => res.json())
                                    .then(data => {
                                        const groups = data;
                                        const groupName = groups.find(g => +NotifyGroup === g.groupID)?.name || '';
                                        const groupText = +NotifyGroup > 0 && groupName !== '' ? `<div class="bg-yellow-5v">Notifies Group \'${groupName}\'</div>` : '';
                                        if(groupText !== '') {
                                            arrNotices.push(groupText);
                                        }
                                        elInfo.innerHTML = arrNotices.join('');
                                        elInfo.style.display = arrNotices.length > 0 ? 'flex' : 'none';
                                    }).catch(err => console.log(err));
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
                }).catch(err => console.log(err));

            } catch (err) {
                console.log(err);
            }
        }
    }

    function registerVariablesPlugin() {
        const defaultOptions = {
            source: [
                'recordID',
                'fullTitle',
                'fullTitle_insecure',
                'truncatedTitle',
                'truncatedTitle_insecure',
                'formType',
                'lastStatus',
                'comment',
                'service',
                'siteRoot',
                'field.#',
            ],
            formatVariable: formatVariable,
        };

        $.extend(
            true, $.trumbowyg,
            {
                langs: {
                    en: { addVariables: 'Variables' }
                },
                plugins: {
                    addVariables: {
                        init: function(trumbowyg) {
                            trumbowyg.o.plugins.addVariables = $.extend(
                                true, {},
                                defaultOptions,
                                trumbowyg.o.plugins.addVariables || {}
                            );

                            const ddDef = {
                                dropdown: makeDropdown(trumbowyg.o.plugins.addVariables.source, trumbowyg),
                                title: 'Add variables',
                                text: 'Variables',
                                hasIcon: false
                            }
                            trumbowyg.addBtnDef('addVariables', ddDef);
                        }
                    }
                }
            }
        );

        function formatVariable(srcItem) {
            return '\{\{$' + srcItem + '}} ';
        }

        function makeDropdown(sourceArray, trumbowyg) {
            let dd = [];
            sourceArray.forEach((ele, idx) => {
                const d = {
                    fn: function() {
                        trumbowyg.execCmd(
                            "insertHTML",
                            trumbowyg.o.plugins.addVariables.formatVariable(ele)
                        );
                        return true;
                    },
                    text: ele,
                    hasIcon: false,
                };

                trumbowyg.addBtnDef(ele, d);
                dd.push(ele);
            });
            return dd;
        }
    }

    //jQuery plugins for WYSWYG.
    function useTrumbowygEmailEditor() {
        toggleEditorElements(true);
        const data = getCodeEditorValue(codeEditor);
        $('#editor_trumbowyg').val(data);
        $('#editor_trumbowyg').trumbowyg({
            btnsDef: {
                save: {
                    fn: function() {
                        const saveEl = document.getElementById('save_button');
                        if(saveEl !== null) {
                            saveEl.dispatchEvent(new Event('click'));
                        }
                    },
                    key: 'S', //config setting implies Ctrl+
                    text: 'Save',
                    hasIcon: false,
                }
            },
            btns: [
                'formatting', 'bold', 'italic', 'underline', '|',
                'unorderedList', 'orderedList', '|',
                'link', '|',
                'foreColor', 'backColor', '|',
                'justifyLeft', 'justifyCenter', 'justifyRight',
                'addVariables',
                'save'
            ],
        }).on('tbwblur', () => checkFieldEntries(null, false));
        $('.trumbowyg-box').css({
            'min-height': '130px',
            'margin': '0.5rem 0'
        });
        $('.trumbowyg-editor, .trumbowyg-texteditor').css({
            'min-height': '360px',
            'height': '360px',
            'padding': '1rem',
            'resize': 'vertical',
        });
        let trumbowygBtns = Array.from(document.querySelectorAll('.trumbowyg-box button'));

        /** handle keyboard events.  trumbow uses mousedown so dispatch that event for enter or spacebar */
        const handleTrumbowEvents = (event) => {
            const btn = event.currentTarget;
            const isDropdown = btn.classList.contains('trumbowyg-open-dropdown');
            const isActive = btn.classList.contains('trumbowyg-active');

            if(event?.which === 13 || event?.which === 32) {
                btn.dispatchEvent(new Event('mousedown'));
                event.preventDefault();
                if(isDropdown) {
                    btn.setAttribute('aria-expanded', !isActive);
                }
            }
            if(event?.which === 9) { //fix menu tabbing and tabbing order
                const controllerBtn = document.querySelector(`button[aria-controls="${btn.parentNode.id}"]`);

                const btnWrapperSelector = isDropdown ?
                    `id_${this.trumbowygTitleClassMap[btn.title]}` : `${btn.parentNode.id}`;

                if (btnWrapperSelector !== "") {
                    const firstSubmenuBtn = document.querySelector(`#${btnWrapperSelector} button`);
                    const lastSubmenuBtn = document.querySelector(`#${btnWrapperSelector} button:last-child`);
                    //if tabbing forward, mv to the first button in the submenu.  prev default to stop another tab
                    if(event.shiftKey === false && isDropdown && isActive && firstSubmenuBtn !== null) {
                        firstSubmenuBtn.focus();
                        event.preventDefault();
                    }
                    //end of submenu tab to next controller button and close the first one
                    if(event.shiftKey === false && btn === lastSubmenuBtn) {
                        const nextController = controllerBtn?.parentNode?.nextSibling || null;
                        if(nextController !== null) {
                            const nextBtn = nextController.querySelector('button');
                            if(nextBtn !== null) {
                                nextBtn.focus();
                                event.preventDefault();
                                controllerBtn.dispatchEvent(new Event('mousedown'));
                                controllerBtn.setAttribute('aria-expanded', false);
                            }
                        }
                    }
                    //if tabbing backwards out of a submenu, mv to the controller.
                    if(event.shiftKey === true && btn === firstSubmenuBtn && controllerBtn !== null) {
                        controllerBtn.focus();
                        event.preventDefault();
                    }
                }
            }
            if (event.type === 'click' && isDropdown) { //only updating it to whatever trumbow set it to
                btn.setAttribute('aria-expanded', isActive);
            }
        }
        //make buttons more accessible.  add navigable index and aria-controls.
        trumbowygBtns.forEach(btn => {
            btn.setAttribute('tabindex', '0');
            ['keydown', 'click'].forEach(ev => btn.addEventListener(ev, handleTrumbowEvents));
            if(btn.classList.contains('trumbowyg-open-dropdown')) {
                btn.setAttribute('aria-expanded', false);
                const controlClass = this.trumbowygTitleClassMap?.[btn.title] || null;
                if(controlClass !== null) {
                    btn.setAttribute('aria-controls', 'id_' + controlClass);
                    const elSubmenu = document.querySelector('.' + controlClass);
                    if(elSubmenu !== null) {
                        elSubmenu.setAttribute('id', 'id_' + controlClass);
                    }
                }
            }
        });
        checkFieldEntries(null, false);
        document.getElementById('btn_useCodeMirror').focus();
    }

    function useCodeEmailEditor(refreshCodeMirror = true) {
        //if element associated with Trumbowyg exists, update codemirror element before proceeding.
        const elTrumbow = document.querySelector('#emailBodyCode + div textarea.trumbowyg-textarea');
        if(elTrumbow !== null) {
            codeEditor.setValue(elTrumbow.value);
            toggleEditorElements(false);
            $('#editor_trumbowyg').trumbowyg('destroy');
            $('#editor_trumbowyg').hide();
            if(refreshCodeMirror === true) {
                $('.CodeMirror').each(function(i, el) {
                    el.CodeMirror.refresh();
                });
            }
        }
    }

    //show or hide elements associated with Trumbowyg(true) and CodeMirror for email body editing
    function toggleEditorElements(showTrumbow = true) {
        let btnUseTrumbow = document.getElementById('btn_useTrumbowyg');
        let btnUseCodeMirror = document.getElementById('btn_useCodeMirror');
        if(btnUseTrumbow !== null && btnUseCodeMirror !== null) {
            if (showTrumbow === true) {
                $('#emailBodyCode').hide();
                btnUseCodeMirror.classList.add('show_button');
                btnUseTrumbow.classList.remove('show_button');
            } else {
                $('#emailBodyCode').show();
                btnUseCodeMirror.classList.remove('show_button');
                btnUseTrumbow.classList.add('show_button');
            }
        }
    }


    //loads components when the document loads
    $(document).ready(function() {
        registerVariablesPlugin();

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

        // Get array of email templates records from portal.email_templates table
        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates',
            success: function (emailTemplateRecords) {
                const sortedTemplates = emailTemplateRecords.toSorted((a, b) => {
                    const labelA = a.displayName.toLowerCase();
                    const labelB = b.displayName.toLowerCase();
                    return labelA < labelB ? -1 : labelA > labelB ? 1 : 0;
                });
                let standardTemplates = [];
                let userTemplates = [];
                let recordFilenameTable = {};
                sortedTemplates.forEach(rec => {
                    recordFilenameTable[rec.fileName] = { ...rec };
                    if(rec.fileName.startsWith("LEAF_")) {
                        standardTemplates.push(rec);
                    } else {
                        userTemplates.push(rec);
                    }
                });

                $.ajax({
                    type: 'GET',
                    url: '../api/emailTemplates/custom',
                    dataType: 'json',
                    success: function (customTemplates) { //array of file names in templates/email/custom_override
                        let customClass = '';
                        let selectedAttr = '';

                        let buffer = '';
                        let filesMobile = `<label for="template_file_select">Template Files:</label>
                            <div class="template_select_container"><select id="template_file_select" class="templateFiles">`;

                        if (Array.isArray(customTemplates)) {
                            if (userTemplates.length > 0) {
                                buffer += '<div class="templates_header">Custom Events</div><ul class="leaf-ul">';

                                filesMobile += '<optgroup label="Custom Events">';

                                userTemplates.forEach(t => {
                                    customClass = customTemplates.includes(t.fileName) ? ' class="custom_file"' : '';
                                    selectedAttr = t.fileName === currentFile ? ' selected' : '';

                                    // Construct the li element for non-mobile buffer
                                    buffer += `<li>
                                        <div class="template_files">
                                            <a href="#" role="button" data-file="${t.fileName}">${t.displayName}</a> <span${customClass}>(custom)</span>
                                        </div>
                                    </li>`;

                                    // Construct the option element for filesMobile
                                    filesMobile += `<option value="${t.fileName}">${t.displayName + (customClass ? ' (custom)' : '')}</option>`;
                                });

                                buffer += '</ul><hr>';
                                filesMobile += '</optgroup>';
                            }

                            buffer += '<div class="templates_header">Standard Events</div><ul class="leaf-ul">';
                            filesMobile += `<optgroup label="Standard Events">`;

                            standardTemplates.forEach(t => {
                                customClass = customTemplates.includes(t.fileName) ? ' class="custom_file"' : '';
                                selectedAttr = t.fileName === currentFile ? ' selected' : '';

                                // Construct the li element for non-mobile buffer
                                buffer += `<li>
                                    <div class="template_files">
                                        <a href="#" role="button" data-file="${t.fileName}">${t.displayName}</a> <span${customClass}>(custom)</span>
                                    </div>
                                </li>`;

                                // Construct the option element for filesMobile
                                filesMobile += `<option value="${t.fileName}"${selectedAttr}>
                                    ${t.displayName + (customClass ? ' (custom)' : '')}</option>`;
                            });

                            buffer += '</ul>';
                            filesMobile += '</optgroup></select></div>';

                        } else {
                            buffer += '<li>Internal error occurred. If this persists, contact your Primary Admin.</li>';
                            filesMobile += '<div>Internal error occurred. If this persists, contact your Primary Admin.</div>';
                        }

                        $('#fileList').html(buffer);
                        $('.filesMobile').html(filesMobile);

                        // Attach onchange event handler to templateFiles select element (mobile nav)
                        $('.template_select_container').on('change', function (event) {
                            let fName = event.target?.value;
                            let template = recordFilenameTable[fName] ?? null;
                            if (template !== null) {
                                loadContent(
                                    template.displayName,
                                    template.fileName,
                                    template.subjectFileName,
                                    template.emailToFileName,
                                    template.emailCcFileName
                                );
                            }
                        });

                        // Attach click event handler to template links in the buffer
                        $('.template_files a').on('click', function (e) {
                            e.preventDefault();
                            let fName = $(this).data('file');
                            let template = recordFilenameTable[fName] ?? null;
                            if (template !== null) {
                                loadContent(
                                    template.displayName,
                                    template.fileName,
                                    template.subjectFileName || '',
                                    template.emailToFileName || '',
                                    template.emailCcFileName || ''
                                );
                            }
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