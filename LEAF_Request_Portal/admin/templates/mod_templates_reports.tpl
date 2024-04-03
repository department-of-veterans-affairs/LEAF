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
                        <div class="CodeMirror-merge-pane-label-left">(Old File)</div>
                        <div class="CodeMirror-merge-pane-label-right">(Current File)</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
                <div class="keyboard_shortcuts">
                    <h3 class="keyboard_shortcuts_main_title">Keyboard Shortcuts within the Code Editor:</h3>
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

                <div class="keyboard_shortcuts_merge hide">
                    <h3 class="keyboard_shortcuts_main_title">Keyboard Shortcuts For Compare Code:</h3>
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
                                <h3>Exit Compare: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + E </p>
                            </div>
                        </div>

                    </div>
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
                        class="usa-button usa-button--outline compare_only" onclick="exitExpandScreen()">
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
    function showRightNav(showNav = false) {
        let nav = $('.leaf-right-nav');
        showNav ? nav.addClass('show') : nav.removeClass('show');
    }

    // saves current file content changes
    function save() {
        let data = '';
        if (typeof codeEditor.edit !== 'undefined' && typeof codeEditor.edit.getValue === 'function') {
            data = codeEditor.edit.getValue();
        } else if (typeof codeEditor.getValue === 'function') {
            data = codeEditor.getValue();
        }

        if (data === currentFileContent) {
            alert('There are no changes to save.');
            return;
        }

        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: '<!--{$CSRFToken}-->',
                file: data
            },
            url: '../api/applet/_' + currentFile,
            success: function(res) {
                const time = new Date().toLocaleTimeString();
                $('.saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                if (res != null) {
                    alert(res);
                }
                saveFileHistory();
            },
            error: function() {
                alert('An error occurred while saving the file.');
            }
        });
    }
    // creates a copy of the current file content
    function saveFileHistory() {
        let data = '';
        if (codeEditor.getValue === undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }
        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: '<!--{$CSRFToken}-->',
                file: data
            },
            url: '../api/applet/fileHistory/_' + currentFile,
            success: function(res) {
                getFileHistory(currentFile);
            }
        });
    }

    // Retreave URL to display comparison of files
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
    }
    // Expands the current and history file to compare both files
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
    // exits the current and history comparison
    function exitExpandScreen() {
        $('.page-title-container > h2').html('Template Editor');
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

        // Will reset the URL
        const url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());

        loadContent(currentFile);
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
    // gloabal variables
    var codeEditor;
    var currentFile = '';
    var unsavedChanges = false;
    var currentFileContent = '';
    var dialog, dialog_confirm;

    var ignoreUnsavedChanges = false;
    var ignorePrompt = true;

    // request's copies of the current file content in an accordion layout
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: '../api/templateFileHistory/_' + template,
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
            cache: false,
        });
    }
    // compares current file content with history file from getFileHistory()
    function compareHistoryFile(fileName, parentFile, updateURL) {
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
                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    mode: 'htmlmixed',
                    lineNumbers: true,
                    indentUnit: 4,
                    value: currentFileContent.replace(/\r\n/g, "\n"),
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
                addCodeMirrorAria('codeCompare');

                const mergeFile = () => {
                    ignoreUnsavedChanges = true;
                    let changedLines = codeEditor.leftOriginal().lineCount();
                    let mergedContent = "";
                    for (let i = 0; i < changedLines; i++) {
                        let mergeLine = codeEditor.leftOriginal().getLine(i);
                        if (mergeLine !== null && mergeLine !== undefined) {
                            mergedContent += mergeLine + "\n";
                        }
                    }
                    saveMergedChangesToFile(parentFile, mergedContent);
                    $('#file_replace_file_btn').off('click');
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
                        $('#bodyarea').off('keydown');
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

        if (updateURL !== null) {
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
    // This function displays a prompt if there are unsaved changes before leaving the page
    function editorCurrentContent() {
        $(window).on('beforeunload', function(e) {
            if (!ignoreUnsavedChanges && !ignorePrompt) { // Check if ignoring unsaved changes and prompt
                // Bypass the prompt if the file name contains "LEAF_"
                if (currentFile && currentFile.includes('LEAF_')) {
                    return;
                }

                let data = '';
                if (codeEditor.getValue === undefined) {
                    data = codeEditor.edit.getValue();
                } else {
                    data = codeEditor.getValue();
                }
                if (currentFileContent !== data) {
                    e.preventDefault();
                    return 'You have unsaved changes. Are you sure you want to leave this page?';
                }
            }
        });
    }
    //loads all files and retreave's them
    function loadContent(file) {
        if (file === undefined) {
            console.error('No file specified. File cannot be loaded.');
            $('#codeContainer').html('Error: No file specified. File cannot be loaded.');
            return;
        }

        // Check if the file name contains "LEAF_"
        const isLeafFile = file.includes('LEAF_');

        if (ignorePrompt) {
            ignorePrompt = false; // Reset ignorePrompt flag
        } else {
            // If the file is not a "LEAF_" file, and there are unsaved changes, show the prompt
            if (!isLeafFile && !ignoreUnsavedChanges && hasUnsavedChanges() && !confirm('You have unsaved changes. Are you sure you want to leave this page?')) {
                return;
            }
        }

        $('.CodeMirror').remove();
        $('#codeCompare').empty();

        currentFile = file;
        initEditor();
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
                // Check if codeEditor is already defined and has a setValue method
                if (codeEditor && typeof codeEditor.setValue === 'function') {
                    codeEditor.setValue(res.file);
                    currentFileContent = codeEditor.getValue();
                    $('.CodeMirror').each(function(i, el) {
                        el.CodeMirror.refresh();
                    });
                } else {
                    console.error('codeEditor is not properly initialized.');
                }
            },
            error: function(xhr, status, error) {
                console.log('Error loading file: ' + error);
            },
            async: false,
            cache: false
        });
        $('.saveStatus').html('');

        editorCurrentContent();

        codeEditor.on('change', function() {
            unsavedChanges = true;
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

        if (!isLeafFile && file !== undefined) {
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
                'aria-label': 'Template Editor coding area.  Press escape followed by tab to navigate out.'
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
                'aria-label': 'Template Editor coding area.  Press escape followed by tab to navigate out.'
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
                let bufferExamples = '<div class="leaf-bold">Examples</div><ul class="leaf-ul">';
                let filesMobile = '<label for="template_file_select">Template Files:</label><select id="template_file_select">';
                
                for (let i in res) {
                    let file = res[i].replace('.tpl', '');
                    
                    if (!isExcludedFile(file)) {
                        buffer += '<li><a href="#" data-file="' + file + '">' + file + '</a></li>';
                        filesMobile += '<option value="' + file + '"><div class="template_files">' + file + '</div></option>';
                    } else {
                        bufferExamples += '<li><a href="#" data-file="' + file + '">' + file + '</a></li>';
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
                    let selectedFile = $(this).data('file');
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