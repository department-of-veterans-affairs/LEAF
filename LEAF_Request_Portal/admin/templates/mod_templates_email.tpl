<link rel=stylesheet href="/libs/js/codemirror/addon/merge/merge.css">
<script src="/libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="/libs/js/codemirror/addon/merge/merge.js"></script>
<style>
    /* Glyph to improve usability of code compare */
    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy {
        visibility: hidden;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy::before {
        visibility: visible;
        content: '\25ba\25ba\25ba';
    }

    .CodeMirror,
    .cm-s-default {
        height: auto !important;
    }

    #subjectCompare .CodeMirror-merge,
    .CodeMirror-merge .CodeMirror {}

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

    #fileList {
        width: 90%;
        margin: 0 auto;
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
        width: 90%;
        margin: 0 auto;
        padding: 10px 0;
    }

    #fileBrowser>h3 {
        margin: 0;
    }

    .main-content {
        display: flex;
        justify-content: space-evenly;
        align-content: flex-start;
        width: 60%;
        flex: none;
        margin: 0 auto;
        transition: all .5s ease;
    }

    #filename {
        padding: 10px;
        margin-bottom: 10px;
        font-size: 1.2rem;
        background: #252f3e;
        color: #fff;
        text-align: center;
    }

    .leaf-btn-med {
        margin: 10px 0 0 0;
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
        margin-top: 10px;
    }

    .view-history:hover {
        background-color: #112e51;
    }

    .accordion-container {
        display: block;
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
        display: flex;
        justify-content: center;
        align-items: center;
        flex-flow: row;
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

    .accordion-date {
        border-right: 1px solid #fff;
        padding: 0 10px;
    }

    .accordion-name {
        padding: 0 10px;
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
        width: 20%;
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

    .usa-button {
        width: 90%;
        max-width: 200px;
        margin: 5px auto;
    }

    .leaf-ul {
        width: 100%;
        min-height: 300px;
        overflow: auto;
        padding: 0 10px;
        margin: 10px auto;
    }

    .leaf-ul li {
        font-size: .8rem !important;
        line-height: 2;
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

    .compared-label-content {
        width: 100%;
        display: none;
        justify-content: space-evenly;
        align-items: center;

    }

    .CodeMirror-merge-pane-label {
        width: 45%;
        text-align: center;
        font-weight: bold;
        padding: 10px 0;
    }

    .CodeMirror-merge-pane-label:nth-child(1) {
        color: #9f0000;
    }

    .CodeMirror-merge-pane-label:nth-child(2) {
        color: #083;
    }
</style>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Email Template Editor</h2>
        <button id="word-wrap-button" class="word-wrap-button off">Word Wrap: Off</button>
        <button class="file_replace_file_btn">Merge to Current File</button>
        <button class="close_expand_mode_screen" onclick="exitExpandScreen()">Exit</button>

    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav">
                <div id="fileBrowser">
                    <h3>Email Templates</h3>
                </div>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">

                <h2 id="emailTemplateHeader">Default Email Template</h2>
                <div id="emailLists">
                    <fieldset>
                        <legend>Email To and CC</legend><br />
                        <p>
                            Enter email addresses, one per line. Users will be
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
                <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold">Body</div>
                <div id="divCode" style="border: 1px solid black">
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label">(File being compared)</div>
                        <div class="CodeMirror-merge-pane-label">(Current file)</div>
                    </div>
                    <textarea id="code"></textarea>
                    <div id="codeCompare"></div>
                </div>
                <div>
                    <fieldset>
                        <legend>Template Variables</legend><br />
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
                        Save Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>

                    <button
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                        onclick="restore();">
                        Restore Original
                    </button>

                    <button
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_compareStop" style="display: none" onclick="loadContent();">
                        Stop Comparing
                    </button>

                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                        id="btn_compare" onclick="compare();">
                        Compare to Original
                    </button>

                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_history" onclick="viewHistory()">
                        View History
                    </button>
                    <button class="view-history">View File History</button>
                </div>
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
    /**
     * Function: save
     * Purpose: Save all fields to template files
     */
    function save() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        const divEmailTo = document.getElementById('divEmailTo');
        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;
        const data = (codeEditor.getValue() == undefined) ? codeEditor.edit.getValue() : codeEditor.getValue();
        const subject = (subjectEditor.getValue() == undefined) ? subjectEditor.edit.getValue() : subjectEditor.getValue();
        const isContentChanged = (
            emailToData !== currentEmailToContent ||
            emailCcData !== currentEmailCcContent ||
            data !== currentFileContent ||
            subject !== currentSubjectContent
        ) ? true : false;
        const isContentUnchanged = (data === currentFileContent || subject === currentSubjectContent) ? true : false;



        if (divEmailTo.style.display === 'none') {
            if (isContentUnchanged) {
                showDialog('Please make a change to the content in order to save.');
            } else {
                saveTemplate();
            }
        } else {
            if (isContentChanged) {
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
                    console.log('New template has been saved');
                    saveFileHistory();
                    updateUIAfterSave();
                    if (res != null) {
                        alert(res);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.log('Error occurred during the save operation:', errorThrown);
                }
            });
            console.log('Your Template has been saved.');
        }

        function showDialog(message, color) {
            dialog_message.setContent('<h2 style="color:' + (color || 'black') + '">' + message + '</h2>');
            dialog_message.setTitle('Alert!');
            dialog_message.show();
        }

        function updateUIAfterSave() {
            $('#saveIndicator').attr('src', '../dynicons/?img=media-floppy.svg&w=32');
            $('.modifiedTemplate').css('display', 'block');
            if ($('#btn_compareStop').css('display') != 'none') {
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

    // Done
    function saveFileHistory() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        let data = '';
        let subject = '';
        // If any changes made to emailTo, emailCc, body or subject
        // then get edits, else get default values
        if (codeEditor.getValue == undefined) {
            data = codeEditor.edit.getValue();
        } else {
            data = codeEditor.getValue();
        }
        if (subjectEditor.getValue == undefined) {
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
                if ($('#btn_compareStop').css('display') != 'none') {
                    $('#btn_compare').css('display', 'none');
                }
                // Show saved time in "Save Changes" button and set current content
                var time = new Date().toLocaleTimeString();
                $('#saveStatus').html('<br /> Last saved: ' + time);
                currentFileContent = data;
                currentSubjectContent = subject;
                currentEmailToContent = emailToData;
                currentEmailCcContent = emailCcData;
                console.log("File history has been saved.");
                getFileHistory(currentFile);
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
                    loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile,
                        currentEmailCcFile);
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

    function formatFileSize(bytes, threshold = 1024) {
        const units = ['bytes', 'KB', 'MB', 'GB'];
        let i = 0;

        while (bytes >= threshold && i < units.length - 1) {
            bytes /= threshold;
            i++;
        }

        return bytes.toFixed(2) + ' ' + units[i];
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
            url: '../api/templateFileHistory/_' + template,
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
                        '<div class="accordion-header" onclick="displayAccordionContent(this)"><span class="accordion-date"><strong style="color:#37beff;">DATE:</strong><br>' +
                        fileCreated +
                        '</span><span class="accordion-name"><strong style="color:#37beff;">USER:</strong><br>' +
                        whoChangedFile +
                        '</span></div>';
                    accordion += '<div class="accordion-content">';
                    accordion += '<ul>';
                    accordion
                        += '<li><strong>File Name: </strong><br><p>' + fileParentName + '</p></li>';
                    accordion
                        += '<li><strong>Who Changed File:</strong><br><p>' + whoChangedFile + '</p></li>';
                    accordion
                        += '<li><strong>File Size:</strong><br><p>' + formattedFileSize + '</p></li>';
                    accordion
                        += '<li><button class="file_compare_file_btn" onclick="compareHistoryFile(\'' +
                        fileName + ' \')">Compare Current File</button></li>';
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
        $('#emailLists').hide();
        $('#subject').hide();
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
                                lineWrapping: true, // initial value
                                autoFormatOnStart: true,
                                autoFormatOnMode: true,
                                leftTitle: "Current File",
                                rightTitle: "Comparison File"
                            });
                            updateEditorSize();
                            $('.CodeMirror-linebackground').css({
                                'background-color': '#8ce79b !important'
                            });
                            $('.file_replace_file_btn').click(function() {
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
                url: '../api/templateEmailHistoryMergeFile/_' + fileParentName,
                data: {CSRFToken: '<!--{$CSRFToken}-->',
                file: mergedContent
            },
            dataType: 'json',
            cache: false,
            success: function(res) {
                console.log(res);
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
            'width': '35%',
            'text-align': 'left'
        });
        $('.main-content').css({
            'width': '100%',
            'height': '80%',
            'top': 0,
            'left': 0,
            'align-items': 'center',
            'transition': 'all .5s ease'
        });
        $('.leaf-code-container').css({
            'width': '100% !important'
        });
        $('.usa-table').hide();
        $('.leaf-right-nav').css({
            'position': 'fixed',
            'right': '-100%',
            'transition': 'all .5s ease'
        });
        $('.leaf-left-nav').css({
            'position': 'fixed',
            'left': '-100%',
            'transition': 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'coloumn'
        });
        // exitExpandScreen()
    }

    function exitExpandScreen() {
        $(".compared-label-content").css("display", "none");
        $('#word-wrap-button').hide();
        $('.page-title-container>.file_replace_file_btn').hide();
        $('.page-title-container>.close_expand_mode_screen').hide();
        $('#emailLists').show();
        $('#subject').show();
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
            'transition': 'all .5s ease'
        });
        $('#codeContainer').css({
            'height': '95%',
            'width': '90% !important'
        })
        $('.usa-table').show();
        $('.leaf-right-nav').css({
            'position': 'relative',
            'right': '0',
            'transition': 'all .5s ease'
        });
        $('.leaf-left-nav').css({
            'position': 'relative',
            'left': '0',
            'transition': 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });
        loadContent();
    }
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
        if (file == undefined) {
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
        if (typeof(subjectFile) == 'undefined' || subjectFile == 'null' || subjectFile == '') {
            $('#subject, #emailLists, #emailTo, #emailCc').hide();
            $('#divSubject, #divEmailTo, #divEmailCc').hide().attr('disabled', 'disabled');
            subjectEditor.setOption("readOnly", true);
        } else {
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
                if (res.modified == 1) {
                    $('.modifiedTemplate').css('display', 'block');
                } else {
                    $('.modifiedTemplate').css('display', 'none');
                }
                getFileHistory(file);
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
        $('.CodeMirror').each(function(i, el) {
            el.CodeMirror.refresh();
        });
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
        dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
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
                for (var i in res) {
                    buffer += '<li onclick="loadContent(\'' + res[i].displayName + '\', ' +
                        '\'' + res[i].fileName + '\'';
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
        $('#xhrDialog').css('display', 'none');
        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    });
</script>