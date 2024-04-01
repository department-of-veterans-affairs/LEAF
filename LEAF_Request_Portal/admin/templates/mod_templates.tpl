<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates_reports.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Template Editor</h2>
        <button type="button" id="mobileToolsNavBtn" onclick="showRightNav(true)" aria-expanded="false">Template Tools</button>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav" id="fileBrowser">
                <button type="button" class="usa-button usa-button--outline" id="btn_history" onclick="viewHistory()">
                    View History
                </button>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <div id="filename"></div>
                <div>
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label-left">(Old File)</div>
                        <div class="CodeMirror-merge-pane-label-right">(Current File)</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
                <div class="keyboard_shortcuts">
                    <h3 class="keboard_shortcuts_main_title">Keyboard Shortcuts within the Code Editor:</h3>
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
                    <h3 class="keboard_shortcuts_main_title">Keyboard Shortcuts For Compare Code:</h3>
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
        <div class="leaf-right-nav">
            <button type="button" id="closeMobileToolsNavBtn" aria-label="close" onclick="showRightNav(false)">X</button>
            <aside class="filesMobile"></aside>
            <aside class="sidenav-right">
                <div id="controls">
                    <button type="button" id="save_button" class="usa-button" onclick="save();">
                        Save Changes
                        <span class="saveStatus"></span>
                    </button>

                    <button type="button" id="restore_original"
                        class="usa-button usa-button--secondary edit_only" onclick="restore();">
                        Restore Original
                    </button>

                    <button type="button" id="file_replace_file_btn" class="usa-button usa-button--secondary compare_only">
                        Use Old File
                    </button>

                    <button type="button" id="btn_compareStop"
                        class="usa-button usa-button--outline compare_only"
                        onclick="exitExpandScreen()">
                        Stop Comparing
                    </button>
                    <button type="button" id="btn_compare"
                        class="usa-button usa-button--outline edit_only" onclick="compare();">
                        Compare with Original
                    </button>

                    <a href="<!--{$domain_path}-->/app/libs/dynicons/gallery.php" id="icon_library"
                        class="usa-button usa-button--outline edit_only" target="_blank">
                        Icon Library
                    </a>
                    
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
    /* used to show or hide the right nav despite screen width */
    function showRightNav(showNav = false) {
        let nav = $('.leaf-right-nav');
        showNav ? nav.addClass('show') : nav.removeClass('show');
    }

    // saves current file content changes
    function save() {
        let data = '';
        if (codeEditor.getValue === undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }

        // Check if the content has changed
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
            url: '../api/template/_' + currentFile,
            success: function(res) {
                const time = new Date().toLocaleTimeString();
                $('.saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                if (res !== null) {
                    alert(res);
                }
                saveFileHistory();
                $('#restore_original, #btn_compare').addClass('modifiedTemplate');
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
            url: '../api/templateFileHistory/_' + currentFile,
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
                url: '../api/template/_' + currentFile + '?' +
                    $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                success: function() {
                    saveFileHistory();
                    loadContent(currentFile);
                },
                error: function(err) {
                    console.log(err);
                }
            });
            dialog.hide();
        });

        dialog.show();
    }

    // compares the default with the current template
    function compare() {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();

        $.ajax({
            type: 'GET',
            url: '../api/template/_' + currentFile + '/standard',
            success: function(standard) {
                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    screenReaderLabel: "Editor coding area.  Press escape then tab to navigate out.",
                    mode: "htmlmixed",
                    lineNumbers: true,
                    indentUnit: 4,
                    value: currentFileContent.replace(/\r\n/g, "\n"),
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
                editorExpandScreen();
            },
            error: function(err) {
                console.log(err)
            },
            cache: false
        });
    }

    // Expands the current and history file to compare both files
    function editorExpandScreen() {
        $('.page-title-container > h2').html('Template Editor > Compare Code');
        showRightNav(false);
        $('#controls').addClass('comparing');
        $(".compared-label-content").css("display", "flex");

        $('.leaf-left-nav').addClass('hide');
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
        });
        $('.keyboard_shortcuts').addClass('hide');
        $('.keyboard_shortcuts_merge').removeClass('hide');
    }
    // exits comparison view
    function exitExpandScreen() {
        //remove compare view listeners
        $(document).off('keydown');
        $('#file_replace_file_btn').off('click');

        $('.page-title-container > h2').html('Template Editor');
        showRightNav(false);
        $('#controls').removeClass('comparing');
        $(".compared-label-content").css("display", "none");

        $('.leaf-left-nav').removeClass('hide');
        setTimeout(() => { //timeout needed to preserve transition effect
            $('.leaf-left-nav').css({
                'position': 'relative',
                'left': '0'
            });
        });
        $('.keyboard_shortcuts').removeClass('hide');
        $('.keyboard_shortcuts_merge').addClass('hide');

        // Will reset the URL
        let url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());

        loadContent(currentFile);
    }
    /*
    get records about history for a template and
    create table with buttons that can load them
    */
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: '../api/templateFileHistory/_' + template,
            dataType: 'json',
            success: function(res) {
                if(res?.length > 0) {
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

    //Called once at DOM ready. load file based on URL info (home if none).  Set some listeners.
    function initializePage() {
        let urlParams = new URLSearchParams(window.location.search);
        let fileName = urlParams.get('fileName');
        let parentFile = urlParams.get('parentFile');
        let templateFile = urlParams.get('file');

        if (fileName && parentFile !== null) {
            loadContent(parentFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (templateFile !== null) {
            loadContent(templateFile);
        } else {
            loadContent('view_homepage.tpl');
        }
    }

    var codeEditor = null;
    var currentFile = '';
    var unsavedChanges = false;
    var currentFileContent = "";
    var ignoreUnsavedChanges = false;
    var ignorePrompt = true;

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
    //get the file contents based on path/name and set up comparison view
    function compareHistoryFile(fileName, parentFile, updateURL) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        const templateFilePath = `../templates_history/template_editor/${fileName}`;

        $.ajax({
            type: 'GET',
            url: templateFilePath,
            dataType: 'text',
            cache: false,
            success: function(fileContent) {
                codeEditor = CodeMirror.MergeView(document.getElementById("codeCompare"), {
                    screenReaderLabel: "Editor coding area.  Press escape then tab to navigate out.",
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
                $(document).on('keydown', compareModeQuickKeys);
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

    // overwrites current file content after merge
    function saveMergedChangesToFile(fileParentName, mergedContent) {
        $.ajax({
            type: 'POST',
            url: '../api/templateHistoryMergeFile/_' + fileParentName,
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
    // Load the content of a file
    function loadContent(file) {
        if (file === undefined) {
            console.error('No file specified. File cannot be loaded.');
            $('#codeContainer').html('Error: No file specified. File cannot be loaded.');
            return;
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

        initEditor();
        currentFile = file;
        $('#codeContainer').css('display', 'none');
        $('#filename').html(file.replace('.tpl', ''));

        getFileHistory(file);
        $.ajax({
            type: 'GET',
            url: '../api/template/_' + file,
            success: function(res) {
                $('#codeContainer').fadeIn();
                // Check if codeEditor is already defined and has a setValue method
                if (codeEditor && typeof codeEditor.setValue === 'function') {
                    codeEditor.setValue(res.file);
                    currentFileContent = codeEditor.getValue();
                } else {
                    console.error('codeEditor is not properly initialized.');
                }

                if (res.modified === 1) {
                    $('#restore_original, #btn_compare').addClass('modifiedTemplate');
                } else {
                    $('#restore_original, #btn_compare').removeClass('modifiedTemplate');
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

        function hasUnsavedChanges() {
            let data = '';
            if (codeEditor.getValue === undefined) {
                data = codeEditor.edit.getValue();
            } else {
                data = codeEditor.getValue();
            }
            return currentFileContent !== data;
        }

        if (file !== null) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            window.history.replaceState(null, null, url.toString());
        }
    }

    //instantiate CodeMirror code editor on the DOM element with the 'code' id
    function initEditor() {
        codeEditor = CodeMirror.fromTextArea(document.getElementById("code"), {
            screenReaderLabel: "Template Editor coding area.  Press escape then tab to navigate out.",
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
            url: 'ajaxIndex.php?a=gethistory&type=template&id=' + currentFile,
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


    //loads components when the document loads
    $(document).ready(function() {
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

        /* get files for file selection list and information about existing customizations */
        $.ajax({
            type: 'GET',
            url: '../api/template/',
            success: function(res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/template/custom',
                    dataType: 'json',
                    success: function (customTemplates) {
                        let template_excluded = 'import_from_webHR.tpl';
                        let buffer = '<ul class="leaf-ul">';
                        let filesMobile = '<label for="template_file_select">Template Files:</label><select id="template_file_select">';
                        
                        if (Array.isArray(customTemplates)) {
                            for (let i in res) {
                                if (res[i] === template_excluded) {
                                    // Will skip the excluded template, until further notice.
                                    continue;
                                }

                                let custom = '';
                                if (customTemplates.includes(res[i])) {
                                    custom = '<span class=\'custom_file\'>(custom)</span>';
                                }
                                let file = res[i].replace('.tpl', '');

                                buffer += '<li><div class="template_files"><a href="#" data-file="' + res[i] + '">' + file + '</a> ' + custom + '</div></li>';

                                filesMobile += '<option value="' + res[i] + '">' + file + ' ' + custom + '</option>';
                            }
                        } else {
                            buffer += '<li>Internal error occurred, if this persists contact your Primary Admin.</li>';
                        }

                        buffer += '</ul>';
                        filesMobile += '</select></div>';
                        $('#fileList').html(buffer);
                        $('.filesMobile').html(filesMobile);

                        // Attach click event handler to template links in the buffer
                        $('#fileList a').on('click', function (e) {
                            e.preventDefault();
                            let selectedFile = $(this).data('file');
                            loadContent(selectedFile);
                            window.scrollTo(0,0);
                        });

                        // Attach onchange event handler to templateFiles select element
                        $('#template_file_select').on('change', function() {
                            let selectedFile = event.currentTarget.value
                            loadContent(selectedFile);
                        });
                    },
                    error: function (error) {
                        console.log(error);
                    }
                });
            },
            error: function(err){
                console.log(err)
            },
            cache: false
        });
        
        initializePage();
    });
</script>