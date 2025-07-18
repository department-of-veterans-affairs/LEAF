<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates_reports.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>LEAF Programmer</h2>
        <button type="button" id="mobileToolsNavBtn" onclick="showRightNav(true)">
            Template Tools
        </button>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav" id="fileBrowser">
                <button type="button" class="new-report usa-button" onclick="newReport();">
                    New File
                </button>
                <button type="button" id="btn_history" class="usa-button usa-button--outline" onclick="viewHistory()">
                    View History
                </button>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <label for="code_mirror_template_editor" id="filename"></label>
                <div id="reportURL"></div>
                <div>
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label-left"></div>
                        <div class="CodeMirror-merge-pane-label-right">Current File</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
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

        <div class="reports leaf-right-nav">
            <button type="button" id="closeMobileToolsNavBtn" aria-label="close" onclick="showRightNav(false)">X</button>
            <aside class="filesMobile"></aside>
            <aside class="sidenav-right">
                <div id="controls">
                    <button type="button" id="save_button" class="usa-button" onclick="save();">
                        Save Changes
                        <span class="saveStatus"></span>
                    </button>

                    <button type="button" id="open_file_button"
                        class="usa-button usa-button--accent-cool edit_only" onclick="runReport();">
                        Open File
                    </button>
                    <button type="button" id="mobile_new_report_btn"
                        class="usa-button new-report edit_only" onclick="newReport();">
                        New File
                    </button>
                    <button type="button" id="deleteButton"
                        class="usa-button usa-button--secondary edit_only" onclick="deleteReport()">
                        Delete File
                    </button>
                    <button type="button" id="btn_history_mobile"
                        class="usa-button usa-button--outline edit_only" onclick="viewHistory()">
                        View History
                    </button>

                    <button type="button" id="file_replace_file_btn" class="usa-button usa-button--secondary compare_only">
                        Use Old File
                    </button>
                    <button type="button" id="btn_compareStop"
                        class="usa-button usa-button--outline compare_only" onclick="loadContent(null)">
                        Stop Comparing
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


<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->


<script>
    //global variables
    let codeEditor;
    let currentFile = "";
    let currentFileContent = "";
    let dialog, dialog_confirm;

    let ignoreUnsavedChanges = false;
    let ignorePrompt = true;

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
    * Saves codeEditor content to templates/reports if there are changes.
    * Displays last save time, updates currentFileContent value, and calls saveFileHistory at success.
    */
    function save() {
        let elSaveBtn = document.getElementById('save_button');
        const data = getCodeEditorValue(codeEditor);
        if (data === currentFileContent) {
            alert('There are no changes to save.');
        } else {
            elSaveBtn.setAttribute("disabled", "disabled");
            //if no history exists yet, snapshot the original first
            const numRecords = Array.from(document.querySelectorAll('.file_history_options_container button')).length;
            if(numRecords === 0) {
                $.ajax({
                    type: 'POST',
                    data: {
                        CSRFToken: '<!--{$CSRFToken}-->',
                        file: currentFileContent
                    },
                    url: '../api/applet/fileHistory/_' + currentFile,
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
                    file: data
                },
                url: '../api/applet/_' + currentFile,
                success: function(res) {
                    if (res !== null) {
                        alert(res);
                    } else {
                        const time = new Date().toLocaleTimeString();
                        $('.saveStatus').html('<br /> Last saved: ' + time);
                        currentFileContent = data;
                        saveFileHistory();
                    }
                    elSaveBtn.removeAttribute("disabled");
                },
                error: function(err) {
                    alert('An error occurred while saving the file.', err);
                    elSaveBtn.removeAttribute("disabled");
                }
            });
        }
    }

    /**
    * Saves current codeEditor content to templates_history/leaf_programmer and
    * adds a record to portal template_history_files.  Calls getFileHistory at success
    */
    function saveFileHistory() {
        const data = getCodeEditorValue(codeEditor);
        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: '<!--{$CSRFToken}-->',
                file: data
            },
            url: '../api/applet/fileHistory/_' + currentFile,
            success: function(res) {
                getFileHistory(currentFile);
            },
            error: function(err) {
                console.log(err);
            }
        });
    }

    //Called once at DOM ready. Loads the intial file based on URL and sets beforeunload listener.
    function initializePage() {
        let urlParams = new URLSearchParams(window.location.search);
        let fileName = urlParams.get('fileName');
        let parentFile = urlParams.get('parentFile');
        let templateFile = urlParams.get('file');

        if (fileName && parentFile != undefined) {
            loadContent(templateFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (templateFile != undefined) {
            loadContent(templateFile);
        } else {
            loadContent('example');
        }
        //displays a generic prompt if navigating from page with unsaved changes
        $(window).on('beforeunload', function(e) {
            if (!ignoreUnsavedChanges && !ignorePrompt) {
                if (currentFile === 'example' || /^LEAF_/.test(currentFile)) {
                    return;
                }

                if (currentFileContent !== getCodeEditorValue(codeEditor)) {
                    e.preventDefault();
                    return true;
                }
            }
        });
    }
    //enters 2 pane comparison merge view
    function editorExpandScreen() {
        $('.page-title-container > h2').html('LEAF Programmer > Compare Code');
        showRightNav(false);
        $('#controls, #file_replace_file_btn').addClass('comparing');
        $(".compared-label-content").css("display", "flex");

        $('.leaf-left-nav').addClass('hide');
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
        });
        $('.keyboard_shortcuts').addClass('hide');
        $('.keyboard_shortcuts_merge').removeClass('hide');
    }
    //exits comparison merge view. If load is true, synchronously loads the current file
    function exitExpandScreen(load = true) {
        $('#codeCompare').empty();
        $('#file_replace_file_btn').off('click');
        $('#bodyarea').off('keydown');
        $('.page-title-container > h2').html('LEAF Programmer');
        showRightNav(false);
        $('#controls, #file_replace_file_btn').removeClass('comparing');
        $(".compared-label-content").css("display", "none");

        $('.leaf-left-nav').removeClass('hide');
        setTimeout(() => {
            $('.leaf-left-nav').css({
                'position': 'relative',
                'left': '0'
            });
        });
        $('.keyboard_shortcuts').removeClass('hide');
        $('.keyboard_shortcuts_merge').addClass('hide');

        //remove comparison view url params
        let url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());

        if(load === true) {
            loadContent(currentFile);
        }
    }
    // creates a new report
    function newReport() {
        dialog.setTitle('New File');
        dialog.setContent('<label for="newFilename">Filename: </label><input type="text" id="newFilename">');

        $('#newFilename').on('keyup', function(e) {
            $(this).val($(this).val().replace(/[^a-z0-9\.\/]/gi, '_'));
        });

        dialog.setSaveHandler(function() {
            let file = $('#newFilename').val();
            $.ajax({
                type: 'POST',
                url: '../api/applet',
                data: {
                    CSRFToken: '<!--{$CSRFToken}-->',
                    filename: file
                },
                success: function(res) {
                    if (res === 'CreateOK') {
                        updateFileList();
                        loadContent(file);
                    } else {
                        alert(res);
                    }
                }
            });
            dialog.hide();
        });

        dialog.show();
    }
    // deletes the report
    function deleteReport() {
        dialog_confirm.setTitle('Are you sure?');
        dialog_confirm.setContent('This will irreversibly delete this report.');

        dialog_confirm.setSaveHandler(function() {
            ignoreUnsavedChanges = true;
            $.ajax({
                type: 'DELETE',
                url: '../api/applet/_' + currentFile + '?' +
                    $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                    success: function() {
                        location.reload();
                    }
            });
            deleteHistoryFileReport(currentFile);
            dialog_confirm.hide();
        });

        dialog_confirm.show();
        // Will reset the URL
        const url = new URL(window.location.href);
        url.searchParams.delete('file');
        window.history.replaceState(null, null, url.toString());
    }
    // deletes the history file report when the original report has been deleted
    function deleteHistoryFileReport(templateFile) {
        $.ajax({
            type: 'DELETE',
            url: '../api/applet/deleteHistoryFileReport/_' + templateFile + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                success: function() {
                    location.reload();
                }
        });
    }
    // opens the report on a new page
    function runReport() {
        window.open('../report.php?a=' + currentFile);
    }

    function isExcludedFile(file) {
        return file === 'example' || file.substr(0, 5) === 'LEAF_';
    }

    /*
    * Gets an array of all records that have the given file as their basis (file parent name).
    * Creates a table that displays snapshot history, which can be used to load specific files.
    * @param {string} template - base file name of a template, minus .tpl extension
    */
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: '../api/templateFileHistory/_' + template,
            dataType: 'json',
            success: function(res) {
                if (res?.length > 0) {
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
            cache: false,
        });
    }

    /*
    * Get the content for a file using names from its snapshot history and enter merge view.
    * @param {string} fileName - specific full file name with timestamp prefix
    * @param {string} parentFile - basis file name, without .tpl (seems same as currentFile)
    * @param {bool} updateURL - whether to update URL params and add to URL history
    */
    function compareHistoryFile(fileName = '', parentFile = '', updateURL = false) {
        const currentData = getCodeEditorValue(codeEditor);
        $('#bodyarea').off('keydown');
        $('#file_replace_file_btn').off('click');
        $('.CodeMirror').remove();
        $('#codeCompare').empty();

        $.ajax({
            type: 'GET',
            url: `../templates_history/leaf_programmer/${fileName}`,
            dataType: 'text',
            cache: false,
            success: function(fileContent) {
                $('.CodeMirror-merge-pane-label-left').html(`Old File ${currentData === fileContent ? '(No Changes)' : ''}`);

                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    mode: 'htmlmixed',
                    lineNumbers: true,
                    indentUnit: 4,
                    value: currentData,
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
                    const currentData = getCodeEditorValue(codeEditor);
                    const leftData = codeEditor.leftOriginal().getValue();
                    if(currentData === leftData) {
                        alert('There are no changes to save.');
                    } else {
                        ignoreUnsavedChanges = true;
                        saveMergedChangesToFile(parentFile, leftData);
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
    * Set content for report file based on merge view left pane content to templates/reports.
    * @param {string} fileParentName - name of the base file, without .tpl (for reports this is added in Applet.php)
    * @param {string} mergedContent - content to save
    */
    function saveMergedChangesToFile(fileParentName, mergedContent) {
        $.ajax({
            type: 'POST',
            url: '../api/applet/mergeFileHistory/saveReportMergeTemplate/_' + fileParentName,
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

    /**
    * Used in editing view to synchronously load file content and (async) associated history records.
    * If file is explicity null (stop comparing), init with edit side marge view value.
    * Otherwise, prompts prior to loading if there are unsaved changes.  Prepares codeEditor.
    * Updates display area, url, and globals currentFile, currentFileContent, ignoreUnsavedChanges.
    * @param {string} file - name of the template being loaded (eg LEAF_Inbox).  Does not include .tpl
    */
    function loadContent(file) {
        if (!file) {
            if(file === null && currentFile && codeEditor) { //from compare view
                const mergeViewValue = getCodeEditorValue(codeEditor);
                exitExpandScreen(false);
                initEditor();
                codeEditor.setValue(mergeViewValue);
                $('.CodeMirror').each(function(i, el) {
                    el.CodeMirror.refresh();
                });
            } else {
                $('#codeContainer').html('Error: No file specified. File cannot be loaded.');
            }
            return
        }

        if (ignorePrompt) { //true only on page load
            ignorePrompt = false;
        } else {
            const isLeafFile = currentFile === 'example' || /^LEAF_/.test(currentFile);
            if (!isLeafFile && !ignoreUnsavedChanges &&
                currentFileContent !== getCodeEditorValue(codeEditor) &&
                !confirm('You have unsaved changes. Are you sure you want to leave this page?')) {
                return;
            }
        }
        $('.saveStatus').html('');
        $('.CodeMirror').remove();

        initEditor();
        currentFile = file;
        $('#codeContainer').css('display', 'none');
        $('#filename').html(file.replace('.tpl', ''));
        let reportURL = `${window.location.origin}${window.location.pathname.replace('admin/', '')}report.php?a=${file.replace('.tpl', '')}`;
        $('#reportURL').html(`URL: <a href="${reportURL}" target="_blank">${reportURL}</a>`);
        isExcludedFile(file) ? $('.reports.leaf-right-nav').removeClass('custom') : $('.reports.leaf-right-nav').addClass('custom');

        getFileHistory(file);
        $.ajax({
            type: 'GET',
            url: `../api/applet/_${file}`,
            success: function(res) {
                $('#codeContainer').fadeIn();
                // Check if codeEditor is defined, has a setValue method and file property exists
                if (codeEditor && typeof codeEditor.setValue === 'function' && res?.file !== undefined) {
                    codeEditor.setValue(res.file);
                    currentFileContent = codeEditor.getValue();
                    $('.CodeMirror').each(function(i, el) {
                        el.CodeMirror.refresh();
                    });
                    ignoreUnsavedChanges = false;
                } else {
                    res?.file === undefined ?
                    console.error('file not found'):
                    console.error('codeEditor is not properly initialized.');
                }
            },
            error: function(xhr, status, error) {
                console.log('Error loading file: ' + error);
            },
            async: false,
            cache: false
        });

        if (file) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            window.history.replaceState(null, null, url.toString());
        }
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
    //instantiate CodeMirror code editor on the DOM element with the 'code' id
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
                    if(!isExcludedFile(currentFile)) {
                        save();
                    }
                },
                "Ctrl-B": function(cm) {
                    const newTheme = cm.options.theme === 'default' ? 'lucario' : 'default';
                    cm.setOption('theme', newTheme);
                }
            }
        });
        addCodeMirrorAria('code');
    }

    // example report templates
    function updateFileList() {

        $.ajax({
            type: 'GET',
            url: '../api/applet',
            success: function (res) {
                let buffer = '<ul class="leaf-ul reports">';
                let bufferExamples = '<div class="templates_header">Examples</div><ul class="leaf-ul">';
                let filesMobile = '<label for="template_file_select">Template Files:</label><select id="template_file_select">';
                
                for (let i in res) {
                    let file = res[i].replace('.tpl', '');
                    
                    if (!isExcludedFile(file)) {
                        buffer += '<li><a href="#" role="button" data-file="' + file + '">' + file + '</a></li>';
                        filesMobile += '<option value="' + file + '">' + file + '</option>';
                    } else {
                        bufferExamples += '<li><a href="#" role="button" data-file="' + file + '">' + file + '</a></li>';
                    }
                }

                buffer += '</ul>';
                bufferExamples += '</ul>';
                filesMobile += '</select>';
                
                $('#fileList').html(buffer + bufferExamples);
                $('.filesMobile').html(filesMobile);

                // Attach click event handler to template links in the buffer
                $('#fileList a').on('click', function(e) {
                    e.preventDefault();
                    let selectedFile = String($(this).data('file'));
                    loadContent(selectedFile);
                    window.scrollTo(0,0);
                });

                $('#template_file_select').on('change', function () {
                    let selectedFile = event.currentTarget.value
                    loadContent(selectedFile);
                });
            },
            cache: false
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
            url: 'ajaxIndex.php?a=gethistory&type=applet&id=' + currentFile,
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

    // loads components when the document loads
    $(document).ready(function() {
        dialog = new dialogController(
            'xhrDialog',
            'xhr',
            'loadIndicator',
            'button_save',
            'button_cancelchange'
        );
        dialog_confirm = new dialogController(
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

        initializePage();
        updateFileList();
    });
</script>