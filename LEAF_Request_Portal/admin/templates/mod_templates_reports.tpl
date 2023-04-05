<link rel=stylesheet href="../../libs/js/codemirror/addon/merge/merge.css">
<script src="../../libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="../../libs/js/codemirror/addon/merge/merge.js"></script>
<style>
    /* Glyph to improve usability of code compare */
    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy {
        visibility: hidden;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy::before {
        visibility: visible;
        content: '\25ba\25ba\25ba';
    }

    #reportURL {
        text-align: center;
        background-color: #dcdcdc;
        padding: 10px 0;
    }

    .leaf-center-content {
        display: flex;
        flex-direction: column;
        align-content: space-around;
        align-items: center;
        margin-top: 10px;
        font-family: "PublicSans-Regular";
        max-width: 2000px;
    }

    #codeAreaWrapper {
        display: none;
    }

    #codeContainer {
        width: 95% !important;
    }

    .page-title-container {
        width: 95%;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-evenly;
        align-items: flex-start;
        flex-direction: row;
        height: 10%;
    }

    .page-main-content {
        display: flex;
        width: 100%;
        justify-content: space-evenly;
        align-items: flex-start;
        height: 80%;
        flex-direction: row;
        margin-top: 10px;
    }

    .keyboard_shortcuts {
        display: flex;
        justify-content: center;
    }

    .keyboard_shortcuts>table {
        width: 50%;
    }

    .leaf-left-nav,
    .leaf-right-nav {
        width: 20%;
        margin: 0;
        flex: none;
    }

    .sidenav,
    .sidenav-right {
        max-width: none;
        padding: 0;
    }

    #fileBrowser {
        display: flex;
        justify-items: center;
        flex-direction: column;
        width: 90%;
        margin: 0 auto;
        padding: 10px 0;
    }

    .main-content {
        display: flex;
        justify-content: space-evenly;
        align-content: flex-start;
        width: 60%;
        flex: none;
        margin: 0 auto;
        transition: all 3s ease;
    }

    #filename {
        padding: 10px;
        font-size: 1.2rem;
        background: #252f3e;
        color: #fff;
        text-align: center;
    }

    .file-history {
        width: 100%;
        max-height: 600px;
        overflow: auto;
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        background-color: #e8e4e4;
        margin: 0 auto;
    }

    .view-history {
        width: 90%;
        padding: 10px 0;
        background-color: #005EA2;
        color: #fff;
        border: none;
        border-radius: 5px;
        font-size: 14px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.3s ease;
        margin-top: 5px;
    }

    .view-history:hover {
        background-color: #112e51;
    }

    .accordion-container {
        display: none;
        margin-top: 10px;
        width: 100%;
        font-family: sans-serif;
    }

    .accordion {
        width: 90%;
        border-radius: 5px;
        overflow: hidden;
        margin-bottom: 10px;
        background-color: #eee;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        margin: 10px auto;
    }

    .accordion-header {
        padding: 10px 0;
        background-color: #1a4480;
        color: #fff;
        font-size: 0.75rem;
        font-weight: bold;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .accordion-header:hover {
        background-color: #112e51;
    }

    .accordion-header.accordion-active {
        background-color: #112e51;
    }

    .accordion-content {
        display: none;
        padding: 10px 10px;
        font-size: .8rem;
        line-height: 1.5;
        background-color: #fff;
    }

    .accordion-content>ul {
        padding: 0;
    }

    .accordion-content>ul>li {
        list-style: none;
    }

    .accordion-content>ul>li>p {
        margin: 0;
    }

    .accordion-content>ul>li:nth-child(4) {
        list-style: none;
    }

    .accordion-content>ul>li:nth-child(5) {
        list-style: none;
    }

    .file_compare_file_btn {
        width: 100%;
        padding: 10px 0;
        border: none;
        background-color: #e99002;
        color: #fff;
        font-weight: 700;
        margin-top: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        border-radius: 5px;
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        -ms-border-radius: 5px;
        -o-border-radius: 5px;
    }

    .file_compare_file_btn:hover {
        background-color: #c97c00;
    }

    .file_replace_file_btn {
        width: 100%;
        padding: 10px 0;
        border: none;
        background-color: #43ac6a;
        color: #fff;
        font-weight: 700;
        margin-top: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        border-radius: 5px;
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        -ms-border-radius: 5px;
        -o-border-radius: 5px;
    }

    .file_replace_file_btn:hover {
        background-color: #338451;
    }

    .close_expand_mode_screen {
        width: 100%;
        padding: 10px 0;
        border: none;
        background-color: #ac4343;
        color: #fff;
        font-size: 1rem;
        font-weight: 700;
        margin-top: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        border-radius: 5px;
        -webkit-border-radius: 5px;
        -moz-border-radius: 5px;
        -ms-border-radius: 5px;
        -o-border-radius: 5px;
    }

    .close_expand_mode_screen:hover {
        background-color: #862a2a;
    }

    .page-title-container>h2 {
        width: 100%;
        margin: 10px 0 0 0;
        text-align: center;
    }

    .page-title-container>.file_replace_file_btn {
        display: none;
        width: 15%;
        min-width: 200px;
    }

    .page-title-container>.close_expand_mode_screen {
        display: none;
        width: 10%;
    }

    .word-wrap-button {
        display: inline-block;
        background-color: #ddd;
        border: none;
        color: black;
        padding: 10px;
        text-align: center;
        text-decoration: none;
        font-size: 16px;
        margin: 10px 0 0 0;
        cursor: pointer;
        border-radius: 5px;
    }

    .word-wrap-button.on {
        background-color: #43ac6a;
        color: white;
    }

    .word-wrap-button.off {
        background-color: #ad4343;
        color: white;
    }



    .contentMessage {
        width: 90%;
        font-size: .8rem;
        padding: 10px 0;
        text-align: center;
    }

    .leaf-btn-med {
        width: 90%;
        margin: 5px auto;
    }

    .leaf-ul {
        width: 100%;
        overflow: scroll;
        padding: 0;
        margin: 10px auto;
    }

    #controls {
        width: 90%;
        margin: 0 auto;
        padding: 10px 0;
        display: flex;
        flex-direction: column;
        justify-items: center;
        align-items: center;
    }

    #fileList {
        width: 90%;
        overflow: auto;
        margin: 0 auto;
    }
</style>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>LEAF Programmer</h2>
        <button id="word-wrap-button" class="word-wrap-button off">Word Wrap: Off</button>
        <button class="file_replace_file_btn">Merge to Current File</button>
        <button class="close_expand_mode_screen" onclick="exitExpandScreen()">Exit</button>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav" id="fileBrowser">
                <button class="usa-button leaf-btn-med leaf-width-13rem" onclick="newReport();">New File</button>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">

            <div id="codeContainer" class="leaf-code-container">
                <div id="filename"></div>
                <div id="reportURL"></div>
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
                        <tr>
                            <td>Word Wrap</td>
                            <td>Ctrl + W</td>
                        </tr>
                    </table>
                </div>
            </div>
        </main>

        <div class="leaf-right-nav">
            <aside class="sidenav-right" id="controls">
                <button id="saveButton" class="usa-button leaf-btn-med leaf-display-block leaf-width-14rem"
                    onclick="save();">Save Changes<span id="saveStatus"
                        class="leaf-display-block leaf-font0-5rem"></span>
                </button>
                <button
                    class="usa-button usa-button--accent-cool leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="
                    runReport();">Open Report</button>
                <button id="deleteButton"
                    class="usa-button usa-button--secondary leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="
                    deleteReport();">Delete Report</button>
                <button
                    class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                    id="btn_history" onclick="viewHistory()">
                    View History
                </button>
                <button class="view-history">View File History</button>
                <div class="file-history">
                </div>
            </aside>
        </div>
    </div>

</div>

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->


<script>
    function save() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');

        $.ajax({
                type: 'POST',
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                file: codeEditor.getValue()
            },
            url: '../api/reportTemplates/_' + currentFile,
            success: function(res) {
                $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
                $('.modifiedTemplate').css('display', 'block');
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }
                var time = new Date().toLocaleTimeString();
                $('#saveStatus').html('<br /> Last saved: ' + time);
                if (res != null) {
                    alert(res);
                }
                saveFileHistory();
                location.reload();
            }
        });
    }
    function saveFileHistory() {
        $.ajax({
                type: 'POST',
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                file: codeEditor.getValue()
            },
            url: '../api/reportTemplates/fileHistory/_' + currentFile,
            success: function(res) {
                console.log("It worked");
            }
        });
    }
    function formatFileSize(bytes, threshold = 1024) {
        if (bytes < threshold) {
            return bytes + ' bytes';
        } else if (bytes < threshold * threshold) {
            return (bytes / threshold).toFixed(2) + ' KB';
        } else if (bytes < threshold * threshold * threshold) {
            return (bytes / (threshold * threshold)).toFixed(2) + ' MB';
        } else {
            return (bytes / (threshold * threshold * threshold)).toFixed(2) + ' GB';
        }
    }
    // According code
    $(document).ready(function() {
        $('#word-wrap-button').css('display', 'none');
        // Hide the accordion container and all accordion content on page load
        $(".accordion-container").hide();
        $(".accordion-content").hide();

        // When the View File History button is clicked, toggle the accordion container
        $(".view-history").click(function() {
            $(".accordion-container").slideToggle();
        });
    });
    function displayAccordionContent(element) {
        var accordionContent = $(element).next(".accordion-content");
        $(element).toggleClass("accordion-active");
        accordionContent.slideToggle();
        $(".accordion-header").not(element).removeClass("accordion-active");
        $(".accordion-content").not(accordionContent).slideUp();
    }
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: '../api/reportTemplates/getHistoryFiles/_' + template,
            dataType: 'json',
            success: function(res) {
                if (res.length === 0) {
                    console.log('There are no files in the directory');
                    var contentMessage =
                        '<p class="contentMessage">There are no history files.</p>';
                    $('.file-history').html(contentMessage);
                    return;
                }

                var fileNames = res.map(function(template) {
                    return template.file_parent_name;
                });

                if (fileNames.indexOf(template) === -1) {
                    console.log('Template file not found in directory');
                    return;
                }

                var accordion = '<div class="accordion-container">';
                for (var i = 0; i < res.length; i++) {
                    historyFile = res[i].file_name;
                    var fileId = res[i].file_id;
                    var fileParentName = res[i].file_parent_name;
                    var fileName = res[i].file_name;
                    var filePath = res[i].file_path;
                    var fileSize = res[i].file_size;
                    var whoChangedFile = res[i].file_modify_by;
                    var fileCreated = res[i].file_created;

                    var formattedFileSize = formatFileSize(fileSize);

                    accordion += '<div class="accordion">';
                    accordion +=
                        '<div class="accordion-header" onclick="displayAccordionContent(this)">Date: ' +
                        fileCreated + '</div>';
                    accordion += '<div class="accordion-content">';
                    accordion += '<ul>';
                    accordion += '<li><strong>File Name: </strong><br><p>' + fileParentName + '</p></li>';
                    accordion += '<li><strong>Who Changed File:</strong><br><p>' + whoChangedFile +
                        '</p></li>';
                    accordion += '<li><strong>File Size:</strong><br><p>' + formattedFileSize + '</p></li>';
                    accordion +=
                        '<li><button class="file_compare_file_btn" onclick="compareHistoryFile(\'' +
                        fileName + '\')">Compare Current File</button></li>';
                    accordion += '</ul>';
                    accordion += '</div>';
                    accordion += '</div>';

                }
                accordion += '</div>';

                $('.file-history').html(accordion);
            },
            error: function(xhr, status, error) {
                console.log('Error getting file history: ' + error);
            },
            cache: false
        });
    }
    function compareHistoryFile(fileName) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#save_button').css('display', 'none');
        $('#btn_compareStop').css('display', 'none');
        $('#btn_merge').css('display', 'block');
        $('#word-wrap-button').css('display', 'block');

        var wordWrapEnabled = false; // default to false

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
            url: '../api/reportTemplates/getCompareHistoryHistoryFiles/_' + fileName,
            dataType: 'json',
            cache: false,
            success: function(res) {
                var filePath = '';
                var fileParentFile = '';
                for (var i = 0; i < res.length; i++) {
                    filePath = res[i].file_path;
                    fileParentFile = res[i].file_parent_name;

                    $.ajax({
                        type: 'GET',
                        url: filePath,
                        dataType: 'text',
                        cache: false,
                        success: function(fileContent) {
                            codeEditor = CodeMirror.MergeView(document.getElementById(
                                "codeCompare"), {
                                value: fileContent.replace(/\r\n/g, "\n"),
                                origLeft: currentFileContent.replace(/\r\n/g, "\n"),
                                lineNumbers: true,
                                mode: 'htmlmixed',
                                collapseIdentical: true,
                                lineWrapping: true, // initial value
                                autoFormatOnStart: true,
                                autoFormatOnMode: true
                            });
                            updateEditorSize();

                            $('.CodeMirror-linebackground').css({
                                'background-color': '#8ce79b !important'
                            });

                            $('.file_replace_file_btn').click(function() {
                                var changedLines = codeEditor.editor().lineCount();
                                var mergedContent = "";
                                for (var i = 0; i < changedLines; i++) {
                                    var mergeLine = codeEditor.editor().getLine(i);
                                    if (mergeLine !== null && mergeLine !== undefined) {
                                        mergedContent += mergeLine + "\n";
                                    }
                                }
                                saveMergedChangesToFile(fileParentFile, mergedContent);
                            });
                        }
                    });
                }

                editorExpandScreen();
            }
        });
    }
    function saveMergedChangesToFile(fileParentName, mergedContent) {
        $.ajax({
                type: 'POST',
                url: '../api/reportTemplates/saveReportMergeTemplate/_' + fileParentName,
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                file: mergedContent
            },
            dataType: 'json',
            cache: false,
            success: function(res) {
                loadContent();
                exitExpandScreen();
            },
            error: function(xhr, status, error) {
                console.log(xhr.responseText);
            }
        });
    }
    function editorExpandScreen() {
        $('.page-title-container>.file_replace_file_btn').show();
        $('.page-title-container>.close_expand_mode_screen').show();
        $('.page-title-container>h2').css({
            'width': '50%',
            'text-align': 'left'
        });

        $('.main-content').css({
            'width': '100%',
            'height': '80%',
            'top': 0,
            'left': 0,
            'align-items': 'center',
            'transition': 'all 1s ease'
        });

        $('.leaf-code-container').css({
            'width': '100% !important'
        });

        $('.usa-table').hide();

        $('.leaf-right-nav').css({
            'position': 'fixed',
            'right': '-100%',
            'transition': 'all 3s ease'
        });

        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
            'transition': 'all 3s ease'
        });

        $('.page-title-container').css({
            'flex-direction': 'coloumn'
        });
    }
    function exitExpandScreen() {
        $('#word-wrap-button').hide();
        $('.page-title-container>.file_replace_file_btn').hide();
        $('.page-title-container>.close_expand_mode_screen').hide();
        $('.page-title-container>h2').css({
            'width': '100%',
            'text-align': 'center'
        });
        $('.main-content').css({
            'width': '60%',
            'height': '80%',
            'top': 0,
            'left': 0,
            'align-items': 'center',
            'transition': 'all 1s ease'
        });
        $('#codeContainer').css({
            'height': '95%',
            'width': '90% !important'
        })

        $('.usa-table').show();
        $('.leaf-right-nav').css({
            'position': 'relative',
            'right': '0',
            'transition': 'all 1.5s ease'
        });
        $('.leaf-left-nav').css({
            'position': 'relative',
            'left': '0',
            'transition': 'all 1.5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });
        // $('#codeCompare').hide();

        loadContent(currentFile);
    }
    function newReport() {
        dialog.setTitle('New File');
        dialog.setContent('Filename: <input type="text" id="newFilename"></input>');

        dialog.setSaveHandler(function() {
            var file = $('#newFilename').val().replace(/[^a-z0-9\.\/]/gi, '_');
            if (file.trim() === '') {
                alert('Please enter a valid filename.');
                return;
            }
            $.ajax({
                type: 'POST',
                url: '../api/reportTemplates',
                data: {
                    CSRFToken: '<!--{$CSRFToken}-->',
                    filename: file
                },
                success: function(res) {
                    if (res == 'CreateOK') {
                        updateFileList();
                        loadContent(file);
                    } else {
                        alert(res);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Error creating file: ' + error);
                }
            });
            dialog.hide();
        });

        $('#newFilename').on('keyup change', function(e) {
            $('#newFilename').val($('#newFilename').val().replace(/[^a-z0-9\.\/]/gi, '_'));
        });
        dialog.show();
    }
    function deleteReport() {
        dialog_confirm.setTitle('Are you sure?');
        dialog_confirm.setContent('This will irreversibly delete this report.');

        dialog_confirm.setSaveHandler(function() {
            $.ajax({
                type: 'DELETE',
                url: '../api/reportTemplates/_' + currentFile + '?' +
                    $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                    success: function() {
                        location.reload();
                    }
            });
            deleteHistoryFileReport(currentFile);
            dialog_confirm.hide();
        });
        dialog_confirm.show();
    }
    function deleteHistoryFileReport(templateFile) {
        $.ajax({
            type: 'DELETE',
            url: '../api/reportTemplates/deleteHistoryFileReport/_' + templateFile + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                success: function() {
                    console.log(templateFile + ', was deleted');
                    location.reload();
                }
        });
    }
    function runReport() {
        window.open('../report.php?a=' + currentFile);
    }
    function isExcludedFile(file) {
        if (file == 'example' ||
            file.substr(0, 5) == 'LEAF_'
        ) {
            return true;
        }
        return false;
    }

    var currentFile = '';
    var currentFileContent = '';

    function loadContent(file) {
        if (file == undefined) {
            file = currentFile;
        }

        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compareStop').css('display', 'none');
        $('#save_button').css('display', 'block');

        initEditor();
        currentFile = file;

        var reportURL = `${window.location.origin}${window.location.pathname.replace('admin/', '')}report.php?a=${file.replace('.tpl', '')}`;
        $('#reportURL').html(`URL: <a href="${reportURL}" target="_blank">${reportURL}</a>`);
        $('#controls').css('visibility', isExcludedFile(file) ? 'hidden' : 'visible');

        $('#filename').html('<strong>File Name:</strong> ' + file.replace('.tpl', ''));
        $.ajax({
            type: 'GET',
            url: `../api/reportTemplates/_${file}`,
            success: function(res) {
                currentFileContent = res.file;
                $('#codeContainer').fadeIn();
                codeEditor.setValue(res.file);
                getFileHistory(file);
            },
            cache: false
        });
        $('#saveStatus').html('');
    }
    function updateEditorSize() {
        codeWidth = $('#codeArea').width() - 30;
        $('#codeContainer').css('width', codeWidth + 'px');
        $('.CodeMirror, .CodeMirror-merge').css('height', $(window).height() - 160 + 'px');
    }
    function updateFileList() {
        $.ajax({
            type: 'GET',
            url: '../api/reportTemplates',
            success: function(res) {
                var buffer = '<ul class="leaf-ul">';
                buffer += '<p class="leaf-bold leaf-marginTop-1rem">Files</p>';
                var bufferExamples = '<div class="leaf-bold">Examples</div><ul class="leaf-ul">';
                for (var i in res) {
                    file = res[i].replace('.tpl', '');
                    if (!isExcludedFile(file)) {
                        buffer += '<li onclick="loadContent(\'' + file +
                            '\');" style="display: block; width: 12rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><a href="#' +
                            file + '">' + file + '</a></li>';
                    } else {
                        bufferExamples += '<li onclick="loadContent(\'' + file +
                            '\');" style="display: block; width: 12rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><a href="#' +
                            file + '">' + file + '</a></li>';
                    }
                }
                buffer += '</ul>';
                bufferExamples += '</ul>';
                $('#fileList').html(buffer + bufferExamples);
            },
            cache: false
        });
    }
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
                "Ctrl-W": function(cm) {
                    cm.setOption("lineWrapping", !cm.getOption("lineWrapping"));
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
            url: 'ajaxIndex.php?a=gethistory&type=templateReports&id=' + currentFile,
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

    var codeEditor = null;
    var dialog, dialog_confirm;
    $(function() {
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save',
            'button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
        codeWidth = $(document).width() - 420;
        $('#codeContainer').css('width', codeWidth + 'px');

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
        $(window).on('resize', function() {
            updateEditorSize();
        });

        updateFileList();
        loadContent('example');

        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    });
</script>