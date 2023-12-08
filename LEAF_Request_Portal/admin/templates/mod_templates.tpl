<link rel=stylesheet href="<!--{$app_js_path}-->/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="<!--{$app_js_path}-->/codemirror/theme/lucario.css">
<link rel="stylesheet" href="./css/mod_templates.css">
<script src="<!--{$app_js_path}-->/diff-match-patch/diff-match-patch.js"></script>
<script src="<!--{$app_js_path}-->/codemirror/addon/merge/merge.js"></script>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Template Editor</h2>
        <div class="mobileToolsNav">
            <button class="mobileToolsNavBtn" onclick="openRightNavTools('leaf-right-nav')">Template Tools</button>
        </div>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav">
                <div id="fileBrowser">

                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_history" onclick="viewHistory()">
                        View History
                    </button>
                    <div id="fileList"></div>
                </div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <div id="filename"></div>
                <div>
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label-left"></div>
                        <div class="CodeMirror-merge-pane-label-right"></div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
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
            <div id="closeMobileToolsNavBtnContainer"><button id="closeMobileToolsNavBtn"
                    onclick="closeRightNavTools('leaf-right-nav')">X</button></div>
            <aside class="filesMobile">
            </aside>
            <aside class="sidenav-right">
                <div id="controls" style="visibility: hidden">

                    <button id="save_button" class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem"
                        onclick="save();">
                        Save Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>

                    <button id="restore_original"
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem  modifiedTemplate"
                        onclick="restore();">
                        Restore Original
                    </button>

                    <button
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_compareStop" style="display: none" onclick="stop_comparing();">
                        Stop Comparing
                    </button>

                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem  modifiedTemplate"
                        id="btn_compare" onclick="compare();">
                        Compare to Original
                    </button>


                    <a id="icon_library"
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        href="<!--{$domain_path}-->/libs/dynicons/gallery.php" target="_blank">Icon Library</a>

                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem mobileHistory"
                        id="btn_history" onclick="viewHistory()">
                        View History
                    </button>
                </div>
            </aside>
            <aside class="sidenav-right-compare">
                <div class="controls-compare">
                    <button id="save_button" class="usa-button leaf-btn-med leaf-width-14rem"
                        onclick="saveInCompared();">
                        Save Current Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>
                    <button class="restore_original_compare" onclick="restore()">Save </button>
                    <button class="file_replace_file_btn">Use Old File</button>
                    <button class="close_expand_mode_screen" onclick="exitExpandScreen()">Stop Comparing</button>
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
    // Function displays the compared titles
    function comparedTitle(currentFile, otherFile) {
        $(".compared-label-content").css("display", "flex");
        document.querySelector(".CodeMirror-merge-pane-label-right").innerHTML = currentFile;
        document.querySelector(".CodeMirror-merge-pane-label-left").innerHTML = otherFile;
    }
    // This is a mobile nav slider open
    function openRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '0'
        });
    }
    // This is a mobile nav slider close
    function closeRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '-100%'
        });
    }
    // saves current file content changes
    function save() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        var data = '';
        if (codeEditor.getValue == undefined) {
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
                $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }

                var time = new Date().toLocaleTimeString();
                $('#saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                if (res != null) {
                    alert(res);
                }
                saveFileHistory();
            }
        });
    }
    // saves current file content while being in the compared section
    function saveInCompared() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        var data = '';
        if (codeEditor.getValue == undefined) {
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
                $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }

                var time = new Date().toLocaleTimeString();
                $('#saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                if (res != null) {
                    alert(res);
                }
                saveFileHistory();
                exitExpandScreen();
            }
        });
    }
    // This saves the new updates done to the current file while in the copared section
    function save_compare() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        var data = '';
        if (codeEditor.getValue() == undefined) {
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
                $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }

                var time = new Date().toLocaleTimeString();
                $('#saveStatusCompared').html('<br /> Last saved: ' + time);
                setTimeout(function() {
                    $('#saveStatusCompared').fadeOut(1000, function() {
                        $(this).html('').fadeIn();
                    });
                }, 3000);
                currentFileContent = data;
                if (res != null) {
                    alert(res);
                }
                saveFileHistory();
            }
        });
    }
    // creates a copy of the current file content
    function saveFileHistory() {
        var data = '';
        if (codeEditor.getValue == undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }
        $.ajax({
                type: 'POST',
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                file: data
            },
            url: '../api/templateFileHistory/_' + currentFile,
            success: function(res) {
                getFileHistory(currentFile);
            }
        })
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
                        exitExpandScreen()
                    }
            });
            dialog.hide();
        });

        dialog.show();
    }

    var dv;
    //compares the default with the new template
    function compare() {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('.restore_original_compare').css('display', 'block');
        $('.file-history').hide();
        $('.controls-compare>#save_button').css('display', 'none');
        comparedTitle("(Current File)", "(Original File)");

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
                updateEditorSize();
                editorExpandScreen();
                $('.file_replace_file_btn').hide();
            },
            cache: false
        });
    }
    // stops comparing the default with the new template
    function stop_comparing() {
        loadContent(currentFile);
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
        var windowWidth = $(window).width();
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
        $('.page-title-container').css({
            'flex-direction': 'coloumn'
        });
        $('.keyboard_shortcuts').css('display', 'none');
        $('.keyboard_shortcuts_merge').show();
    }
    // exits the current and history comparison
    function exitExpandScreen() {
        $(".compared-label-content").css("display", "none");
        $('#word-wrap-button').hide();
        $('.page-title-container>.file_replace_file_btn').hide();
        $('.page-title-container>.close_expand_mode_screen').hide();
        $('#save_button_compare').css('display', 'none');
        $('.sidenav-right-compare').hide();
        $('.sidenav-right').show();
        $('.file-history').show();
        $('#restore_original').css('display', 'block');
        $('.page-title-container>h2').css({
            'width': '100%',
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Template Editor');

        var windowWidth = $(window).width();

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
                if (res.length === 0) {
                    console.log('There are no files in the directory');
                    var contentMessage = '<p class="contentMessage">There are no history files.</p>';
                    $('.file-history-res').html(contentMessage);
                    return;
                }

                var fileNames = res.map(function(template) {
                    return template.file_parent_name;
                });

                if (fileNames.indexOf(template) === -1) {
                    console.log('Template file not found in directory');
                    return;
                }

                var accordion = '<div id="file_history_container">' +
                    '<div class="file_history_titles">' +
                    '<div class="file_history_date">Date:</div>' +
                    '<div class="file_history_author">Author:</div>' +
                    '</div>' +
                    '<div class="file_history_options_container">';

                for (var i = 0; i < res.length; i++) {
                    var fileParentName = res[i].file_parent_name;
                    var fileName = res[i].file_name;
                    var whoChangedFile = res[i].file_modify_by;
                    var fileCreated = res[i].file_created;
                    ignoreUnsavedChanges = false;

                    accordion +=
                        '<div class="file_history_options_wrapper" data-file="' + fileName +
                        '" onclick="compareHistoryFile(\'' +
                        fileName + '\', \'' + fileParentName + '\', true)">' +
                        '<div class="file_history_options_date">' + fileCreated + '</div>' +
                        '<div class="file_history_options_author">' + whoChangedFile + '</div>' +
                        '</div>';
                }

                accordion += '</div>' +
                    '</div>';

                $('.file-history-res').html(accordion);

                // Add event listener to handle the click on options
                $('.file_history_options_wrapper').on('click', function() {
                    // Remove the 'active' class from all options
                    $('.file_history_options_wrapper').removeClass('active');
                    // Add the 'active' class to the clicked option
                    $(this).addClass('active');
                });

                // Adds active to the file list
                let urlParams = new URLSearchParams(window.location.search);
                let historyFile = urlParams.get('fileName');

                if (historyFile !== null) {
                    let selectedTemplateLink = document.querySelector(
                        '.file_history_options_wrapper[data-file="' +
                        historyFile + '"]');

                    if (selectedTemplateLink !== null) {
                        selectedTemplateLink.classList.add('active');
                    } else {
                        console.log(
                            "No matching element found for templateFile:", historyFile);
                    }
                }
            },
            error: function(xhr, status, error) {
                console.log('Error getting file history: ' + error);
            },
            cache: false
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
        $('.restore_original_compare').css('display', 'none');
        $('.file_replace_file_btn').css('display', 'block');
        $('.controls-compare>#save_button').css('display', 'block');
        var wordWrapEnabled = false; // default to false

        comparedTitle("(Current File)", "(Old File)");

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
                                lineWrapping: false,
                                autoFormatOnStart: true,
                                autoFormatOnMode: true,
                                connect: "chunk", // Change to "chunk" for chunk-based connections
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
                                let changedLines = codeEditor.leftOriginal().lineCount();
                                let mergedContent = "";
                                for (let i = 0; i < changedLines; i++) {
                                    let mergeLine = codeEditor.leftOriginal().getLine(i);
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
                                let lineWrapping = codeEditor.editor().getOption(
                                    'lineWrapping');
                                codeEditor.editor().setOption('lineWrapping', !lineWrapping);
                                codeEditor.leftOriginal().setOption('lineWrapping', !
                                    lineWrapping);
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
    // Add a shortcut for exit from the merge screen
    $(document).on('keydown', function(event) {
        if (event.ctrlKey && event.key === 'e') {
            exitExpandScreen();
        }
    });
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
    function updateEditorSize() {
        codeWidth = $('#codeArea').width() - 66;
        $('#codeContainer').css('width', codeWidth + 'px');
        $('.CodeMirror, .CodeMirror-merge').css('height', $(window).height() - 160 + 'px');
    }
    // initiates  the loadContent()
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
        updateEditorSize();
    }
    // Displays  user's history when creating, merge, and so on
    function viewHistory() {
        dialog_message.setContent('');
        dialog_message.setTitle('Access Template History');
        dialog_message.show();
        dialog_message.indicateBusy();
        let windowWidth = $(window).width();

        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
        } else {
            console.log('Please check the width of the window');
        }
        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistory&type=template&id=' + currentFile,
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
    // Retreave URL to display comparison of files
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
        $('#saveStatus').html('');

        editorCurrentContent();

        // Shortcuts for undo, save, and full screen functionality
        codeEditor.setOption('extraKeys', {
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

        if (file !== null) {
            let url = new URL(window.location.href);
            url.searchParams.set('file', file);
            window.history.replaceState(null, null, url.toString());
        }
    }
    // loads components when the document loads
    $(document).ready(function() {
        $('.currentUrlLink').hide();
        $('.sidenav-right-compare').hide();
        dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');

        initEditor();
        initializePage();

        $.ajax({
            type: 'GET',
            url: '../api/template/',
            success: function(res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/template/custom',
                    dataType: 'json',
                    success: function(result) {
                        let template_excluded = 'import_from_webHR.tpl';
                        let res_array = $.parseJSON(result);
                        let buffer = '<ul class="leaf-ul">';
                        let filesMobile =
                            '<h3>Template Files:</h3><div class="template_select_container"><select class="templateFiles">';

                        if (res_array.status['code'] === 2) {
                            for (let i in res) {
                                if (res[i] === template_excluded) {
                                    // Will skip the excluded template, until further notice.
                                    continue;
                                }

                                if (result.includes(res[i])) {
                                    custom =
                                        '<span class=\'custom_file\' style=\'color: red; font-size: .75em\'>(custom)</span>';
                                } else {
                                    custom = '';
                                }

                                let file = res[i].replace('.tpl', '');

                                buffer +=
                                    '<li><div class="template_files">' +
                                    '<a href="#" data-file="' + res[i] +
                                    '" class="template-link">' +
                                    file + custom + '</a></div></li>';

                                filesMobile += '<option value="' + res[i] + '">' +
                                    file + ' ' + custom + '</option>';
                            }
                        } else if (res_array.status['code'] === 4) {
                            buffer += '<li><div class="template_files">' + res_array
                                .status['message'] + '</div></li>';
                            filesMobile += '<select><option>' + res_array.status[
                                'message'] + '</option></select>';
                        } else {
                            buffer +=
                                '<li>Internal error occurred, if this persists contact your Primary Admin.</li>';
                        }

                        buffer += '</ul>';
                        filesMobile += '</select></div>';
                        $('#fileList').html(buffer);
                        $('.filesMobile').html(filesMobile);

                        // Attach click event handler to template links in the buffer
                        $('#fileList a.template-link').on('click', function(e) {
                            e.preventDefault();
                            // Remove the 'active' class from all template links
                            $('#fileList a.template-link').removeClass(
                                'active');
                            // Add the 'active' class to the clicked template link
                            $(this).addClass('active');

                            let selectedFile = $(this).data('file');
                            loadContent(selectedFile);
                        });

                        // Attach onchange event handler to templateFiles select element
                        $('.template_select_container').on('change',
                            'select.templateFiles',
                            function() {
                                let selectedFile = $(this).val();
                                loadContent(selectedFile);
                            });

                        // Adds active to the file list
                        let urlParams = new URLSearchParams(window.location.search);
                        let templateFile = urlParams.get('file');

                        if (templateFile !== null) {
                            let selectedTemplateLink = document.querySelector(
                                '#fileList a.template-link[data-file="' +
                                templateFile + '"]');

                            if (selectedTemplateLink !== null) {
                                selectedTemplateLink.classList.add('active');
                            } else {
                                console.log(
                                    "No matching element found for templateFile:",
                                    templateFile);
                            }
                        }
                    },
                    error: function(error) {
                        console.log(error);
                    }
                });
            },
            cache: false
        });

        // initializePage();


        dialog_message = new dialogController('genericDialog', 'genericDialogxhr',
            'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');

    });
</script>