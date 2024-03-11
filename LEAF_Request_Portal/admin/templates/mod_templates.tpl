<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates_reports.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Template Editor</h2>
        <button type="button" id="mobileToolsNavBtn" onclick="applyRightNavShowClass(true)">Template Tools</button>
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

                <div class="keyboard_shortcuts_merge">
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
            <button type="button" id="closeMobileToolsNavBtn" aria-label="close" onclick="applyRightNavShowClass(false)">X</button>
            <aside class="filesMobile"></aside>
            <aside class="sidenav-right">
                <div id="controls" style="visibility: hidden">

                    <button type="button" id="save_button" class="usa-button" onclick="save();">
                        Save Changes
                        <span class="saveStatus"></span>
                    </button>

                    <button type="button" id="restore_original"
                        class="usa-button usa-button--secondary modifiedTemplate" onclick="restore();">
                        Restore Original
                    </button>

                    <button type="button" id="btn_compareStop"
                        class="usa-button usa-button--secondary"
                        style="display: none" onclick="stop_comparing();">
                        Stop Comparing
                    </button>

                    <button type="button" id="btn_compare"
                        class="usa-button usa-button--outline modifiedTemplate" onclick="compare();">
                        Compare with Original
                    </button>

                    <a href="<!--{$domain_path}-->/app/libs/dynicons/gallery.php" id="icon_library"
                        class="usa-button usa-button--outline" target="_blank">
                        Icon Library
                    </a>
                    
                    <button type="button"
                        class="usa-button usa-button--outline mobileHistory"
                        id="btn_history_mobile" onclick="viewHistory()">
                        View History
                    </button>
                </div>
            </aside>
            <aside class="sidenav-right-compare">
                <div class="controls-compare">
                    <button type="button" id="save_button" class="usa-button" onclick="save();">
                        Save Changes
                        <span class="saveStatus"></span>
                    </button>
                    <button type="button" class="file_replace_file_btn usa-button usa-button--secondary">
                        Use Old File
                    </button>
                    <button type="button" class="close_expand_mode_screen usa-button usa-button--outline"
                        onclick="exitExpandScreen()">
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

<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->


<script>
    function applyRightNavShowClass(showNav = false) {
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
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }

                const time = new Date().toLocaleTimeString();
                $('.saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                if (res !== null) {
                    alert(res);
                }
                saveFileHistory();
            }
        });
    }

    // creates a copy of the current file content
    function saveFileHistory() {
        let data = '';
        if (codeEditor.getValue == undefined) {
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
        exitExpandScreen();
    }

    var dv;
    // compares the default with the new template
    function compare() {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#btn_compareStop').css('display', 'block');
        $('#save_button_compare').css('display', 'block');
        $('.file-history').hide();


        $.ajax({
            type: 'GET',
            url: '../api/template/_' + currentFile + '/standard',
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
                editorExpandScreen();
                $('.file_replace_file_btn').hide();
            },
            error: function(err) {
                console.log(err)
            },
            cache: false
        });
    }
    // stops comparing the default with the new template
    function stop_comparing() {
        loadContent(currentFile);
    }
    // format size of file inside getFileHistory()
    function formatFileSize(bytes, threshold = 1024) {
        const units = ['bytes', 'KB', 'MB', 'GB'];
        let i = 0;

        while (bytes >= threshold && i < units.length - 1) {
            bytes /= threshold;
            i++;
        }

        return bytes.toFixed(2) + ' ' + units[i];
    }
    // Expands the current and history file to compare both files
    function editorExpandScreen() {
        $('.page-title-container>.file_replace_file_btn').show();
        $('.page-title-container>.close_expand_mode_screen').show();
        $('.sidenav-right').hide();
        $('.sidenav-right-compare').show();
        $('.page-title-container>h2').css({
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Template Editor > Compare Code');
        applyRightNavShowClass(false);
        $('.usa-table').hide();
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%'
        });
        $('.keyboard_shortcuts').css('display', 'none');
        $('.keyboard_shortcuts_merge').show();
    }
    // exits the current and history comparison
    function exitExpandScreen() {
        $(".compared-label-content").css("display", "none");
        $('.page-title-container>.file_replace_file_btn').hide();
        $('.page-title-container>.close_expand_mode_screen').hide();
        $('#save_button_compare').css('display', 'none');
        $('.sidenav-right-compare').hide();
        $('.sidenav-right').show();
        $('.file-history').show();
        $('.page-title-container > h2').css({
            'width': '100%',
            'text-align': 'left'
        });
        $('.page-title-container > h2').html('Template Editor');
        applyRightNavShowClass(false);
        $('#codeContainer').css({
            'display': 'block'
        })
        $('.usa-table').show();

        $('.leaf-left-nav').css({
            'position': 'relative',
            'left': '0',
            'transition': 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });
        $('.keyboard_shortcuts').css('display', 'flex');

        $('#save_button').css('display', 'block');
        $('.keyboard_shortcuts_merge').hide();

        // Will reset the URL
        var url = new URL(window.location.href);
        url.searchParams.delete('fileName');
        url.searchParams.delete('parentFile');
        window.history.replaceState(null, null, url.toString());

        loadContent(currentFile);
    }
    // request's copies of the current file content in an accordion layout
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
                        fileCreated = res[i].file_created;
                        accordion +=
                            '<div class="file_history_options_wrapper" onclick="compareHistoryFile(\'' +
                            fileName + '\', \'' + fileParentName + '\', true)">' +
                            '<div class="file_history_options_date">' + fileCreated + '</div>' +
                            '<div class="file_history_options_author">' + whoChangedFile + '</div>' +
                            '</div>';
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
        // A shortcut for changing the theme
        $(document).on('keydown', function(event) {
            if (event.ctrlKey && event.key === 'b' && typeof codeEditor.setOption === 'function') {
                const newTheme = codeEditor.options.theme === 'default' ? 'lucario' : 'default';
                codeEditor.setOption('theme', newTheme);
            }
        });
        // Add a shortcut for exit from the merge screen
        $(document).on('keydown', function(event) {
            console.log($('.close_expand_mode_screen'))
            if (event.ctrlKey && event.key === 'e') {
                exitExpandScreen();
            }
        });
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
    // Compare the current file content with the history file obtained from getFileHistory()
    function compareHistoryFile(fileName, parentFile, updateURL) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#save_button').css('display', 'none');
        $('#btn_compareStop').css('display', 'none');
        $('#btn_merge').css('display', 'block');
        $('.file_replace_file_btn').css('display', 'block');

        $.ajax({
            type: 'GET',
            url: '../api/templateCompareFileHistory/_' + fileName,
            dataType: 'json',
            cache: false,
            success: function(res) {
                $(".compared-label-content").css("display", "flex");
                var filePath = '';
                var fileParentFile = '';
                for (var i = 0; i < res.length; i++) {
                    filePath = res[i].file_path;
                    fileParentFile = res[i].file_parent_name;
                    // Get the file dir
                    $.ajax({
                        type: 'GET',
                        url: filePath,
                        dataType: 'text',
                        cache: false,
                        success: function(fileContent) {
                            codeEditor = CodeMirror.MergeView(document.getElementById(
                                "codeCompare"), {
                                value: currentFileContent.replace(/\r\n/g, "\n"),
                                origLeft: fileContent.replace(/\r\n/g, "\n"),
                                lineNumbers: true,
                                mode: 'htmlmixed',
                                collapseIdentical: true,
                                lineWrapping: false, // initial value
                                autoFormatOnStart: true,
                                autoFormatOnMode: true
                            });

                            // Add a shortcut for exit from the merge screen
                            $(document).on('keydown', function(event) {
                                if (event.ctrlKey && event.key === 'm') {
                                    mergeFile();
                                }
                                if (event.ctrlKey && event.key === 'n') {
                                    toggleWordWrap();
                                }
                            });

                            function mergeFile() {
                                ignoreUnsavedChanges = true;
                                let changedLines = codeEditor.leftOriginal().lineCount();
                                let mergedContent = "";
                                for (let i = 0; i < changedLines; i++) {
                                    let mergeLine = codeEditor.leftOriginal().getLine(
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
                                codeEditor.leftOriginal().setOption('lineWrapping', !lineWrapping);
                            }
                        }
                    });
                }
                editorExpandScreen();
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
        $('#btn_compareStop').css('display', 'none');
        $('.keyboard_shortcuts_merge').hide();

        initEditor();
        currentFile = file;
        $('#codeContainer').css('display', 'none');
        $('#controls').css('visibility', 'visible');
        $('#filename').html(file.replace('.tpl', ''));

        $.ajax({
            type: 'GET',
            url: '../api/template/_' + file,
            success: function(res) {
                $('#codeContainer').fadeIn();

                // Check if codeEditor is already defined and has a setValue method
                if (codeEditor && typeof codeEditor.setValue === 'function') {
                    codeEditor.setValue(res.file);
                } else {
                    console.error('codeEditor is not properly initialized.');
                }
                currentFileContent = codeEditor.getValue();

                if (res.modified === 1) {
                    $('.modifiedTemplate').css('display', 'block');
                } else {
                    $('.modifiedTemplate').css('display', 'none');
                }
                getFileHistory(file);
            },
            error: function(xhr, status, error) {
                console.log('Error loading file: ' + error);
            },
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
                },
                'Ctrl-Z': function(cm) {
                    cm.undo();
                },
            }
        });
    }
    // Displays  user's history when creating, merge, and so on
    function viewHistory() {
        dialog_message.setContent('');
        dialog_message.setTitle('Access Template History');
        dialog_message.show();
        dialog_message.indicateBusy();
        applyRightNavShowClass(false);
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
        $('.sidenav-right-compare').hide();

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