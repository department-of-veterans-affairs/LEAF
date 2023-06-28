<link rel=stylesheet href="/libs/js/codemirror/addon/merge/merge.css">
<script src="/libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="/libs/js/codemirror/addon/merge/merge.js"></script>
<style>
    /* Glyph to improve usability of code compare */

    .email-template-variables,
    .email-keyboard-shortcuts {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
    }

    .email-template-variables>fieldset {
        width: 100%;
        /* max-width: 700px; */
        display: flex;
        justify-content: center;
    }

    .email-template-variables>fieldset>table {
        width: 100%;
    }

    .email-keyboard-shortcuts>table {
        width: 100%;
        /* max-width: 700px; */
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy {
        visibility: hidden;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy::before {
        visibility: visible;
        content: '\25ba\25ba\25ba';
    }

    .CodeMirror-merge-copy {
        display: none !important;
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
        justify-content: space-around;
        align-items: center;
        margin-top: 10px;
        font-family: "PublicSans-Regular";
        max-width: 2000px;
    }

    #codeAreaWrapper {
        display: none;
    }

    #codeContainer {
        width: 98% !important;
        box-shadow: none;
    }

    .CodeMirror-merge,
    .CodeMirror-merge {
        height: 60vh !important;
    }

    .page-title-container {
        width: 95%;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-evenly;
        align-items: flex-start;
        height: 10%;
    }

    .page-main-content {
        display: flex;
        width: 98%;
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
        width: 15%;
        max-width: 300px;
        margin: 0;
        flex: 0 auto;
    }

    .sidenav,
    .sidenav-right {
        max-width: none;
        padding: 0;
        box-shadow: none;
    }

    .sidenav-right-compare {
        background-color: #fff;
        border-radius: 5px;
    }

    .controls-compare>button {
        width: 100%;
        font-size: 0.9rem;
    }

    #fileBrowser {
        width: 90%;
        margin: 0 auto;
        padding: 10px 0;
    }

    #fileBrowser>h3 {
        text-align: left;
    }

    .main-content {
        display: flex;
        justify-content: space-evenly;
        align-content: flex-start;
        width: 70%;
        flex: none;
        margin: 0 auto;
        transition: all 0.5s ease;
    }

    .sticky {
        position: sticky;
        top: 0;
        padding-top: 10px;
        transition: all 1s ease-in-out;
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
        margin-top: 10px;
    }

    .file-history {
        width: 100%;
        max-height: 600px;
        overflow: auto;
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        background-color: #fff;
        margin: 10px auto;
        padding: 20px 0;
        border-radius: 5px;
    }

    .view-history {
        width: 90%;
        max-width: 250px;
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

    .file-history-res {
        width: 85%;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }


    .accordion-container {
        margin-top: 10px;
        width: 100%;
        max-width: 250px;
    }

    .accordion {
        width: 93%;
        border-radius: 5px;
        overflow: hidden;
        margin-bottom: 10px;
        background-color: #fff;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        margin: 5px auto;
    }

    .accordion-header {
        display: flex;
        justify-content: flex-start;
        align-items: center;
        background-color: #1a4480;
        color: #fff;
        font-size: 0.7rem;
        font-weight: bold;
        text-align: left;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    .accordion-header:hover {
        background-color: #112e51;
    }

    .accordion-header.accordion-active {
        background-color: #112e51;
    }

    .accordion-date {
        width: 80%;
        border-right: 1px solid #fff;
        padding: 8px;
    }

    .accordion-date,
    .accordion-content a {
        color: #fff;
        text-decoration: none;
        font-weight: normal;
    }

    .accordion-chevron {
        width: 20%;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 8px 0;
        transition: transform 0.3s ease;
    }

    .chevron-rotate {
        transform: rotate(90deg);
    }

    .accordion-content {
        display: none;
        padding: 10px;
        font-size: 0.65rem;
        line-height: 1.5;
        background-color: #fff;
    }

    .accordion-content>ul {
        padding: 0;
        margin: 0;
    }

    .accordion-content ul li {
        list-style: none;
        margin: 5px 0;
        border-bottom: 2px solid #e4e4e4;
        padding: 5px 0;
    }

    .accordion-content ul li:last-child {
        border: none;
    }

    .accordion-content ul li strong {
        text-transform: uppercase;
    }

    .accordion-content ul li p {
        margin: 0;
        font-size: 0.65rem;
        overflow: auto;
    }

    .file_compare_file_btn,
    .file_replace_file_btn,
    .close_expand_mode_screen {
        width: 100%;
        padding: 10px 0;
        border: none;
        color: #fff;
        font-weight: 700;
        margin-top: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        border-radius: 5px;
    }

    .file_compare_file_btn,
    .file_replace_file_btn {
        background-color: #e99002;
    }

    .file_compare_file_btn:hover,
    .file_replace_file_btn:hover {
        background-color: #c97c00;
    }

    .close_expand_mode_screen {
        background-color: #ac4343;
        font-size: 1rem;
    }

    .close_expand_mode_screen:hover {
        background-color: #862a2a;
    }

    .copyIcon {
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 0.6rem;
        font-weight: bold;
        text-transform: uppercase;
        cursor: pointer;
        padding: 5px 10px;
        margin-top: 5px;
        border: none;
        transition: 0.5s ease;
        border-radius: 5px;
    }

    .copyIcon:hover {
        background-color: #45a245;
        color: #fff;
    }

    .copyIcon span {
        font-size: 1rem;
        padding-left: 5px;
    }

    .template_link {
        font-size: 0.8rem;
        border: 1px solid #eee;
        width: 100%;
        padding: 5px;
        border-radius: 5px;
        box-sizing: border-box;
        overflow: auto;
        background-color: #ccc;
    }

    .page-title-container>h2 {
        width: 100%;
        margin: 10px 0 0 0;
        text-align: center;
    }

    .page-title-container>.file_replace_file_btn {
        display: none;
        width: 20%;
    }

    .page-title-container>.close_expand_mode_screen {
        display: none;
        width: 10%;
        min-width: 200px;
    }

    #save_button_compare {
        display: none;
        margin: 10px 0;
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
        width: 100%;
        font-size: 0.8rem;
        padding: 10px 0;
        text-align: center;
    }

    .usa-button {
        width: 100%;
        max-width: 250px;
        margin: 5px auto;
    }


    .leaf-ul {
        width: 100%;
        min-height: 300px;
        overflow: auto;
        padding: 0;
        margin: 10px auto;
    }

    .leaf-ul li {
        width: 100%;
        display: flex;
        justify-content: flex-start;
        align-items: center;
        flex-direction: row;
        font-size: 0.75rem !important;
        line-height: 2;
        list-style: none;
    }

    .leaf-ul>li::before {
        content: "";
        display: inline-block;
        width: 16px;
        height: 16px;
        margin-right: 5px;
        background-image: url("data:image/svg+xml;charset=utf-8,<svg xmlns='http://www.w3.org/2000/svg' width='50' height='50' fill='%23000000' viewBox='0 0 20 20'><path fill-rule='evenodd' d='M6.854 6.146a.5.5 0 010 .708L3.707 10l3.147 3.146a.5.5 0 01-.708.708l-3.5-3.5a.5.5 0 010-.708l3.5-3.5a.5.5 0 01.708 0zm6.292 0a.5.5 0 000 .708L16.293 10l-3.147 3.146a.5.5 0 00.708.708l3.5-3.5a.5.5 0 000-.708l-3.5-3.5a.5.5 0 00-.708 0zm-.999-3.124a.5.5 0 01.33.625l-4 13a.5.5 0 11-.955-.294l4-13a.5.5 0 01.625-.33z' clip-rule='evenodd'/></svg>");
        background-repeat: no-repeat;
        background-size: contain;
    }

    .leaf-ul>li>a {
        width: 80%;
        display: block;
        text-decoration: none;
        border-bottom: 2px solid #e4e4e4;
        transition: all 0.3s ease;
        color: #005ea2;
    }

    .leaf-ul>li>a:hover {
        border-bottom: 2px solid #005ea2;
    }

    #controls,
    .controls-compare {
        display: none;
        width: 80%;
        margin: 0 auto;
        padding: 10px 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    .compared-label-content {
        width: 100%;
        display: none;
        justify-content: space-evenly;
        align-items: center;
    }

    .CodeMirror-scroll {
        margin-right: 0;
        height: 60vh;
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

    .chevron-rotate {
        animation: chevron-rotate 0.5s forwards;
    }

    @keyframes chevron-rotate {
        100% {
            transform: rotate(90deg);
        }
    }

    .gg-chevron-right {
        box-sizing: border-box;
        position: relative;
        display: block;
        transform: scale(var(--ggs, 1));
        width: 22px;
        height: 22px;
        border: 2px solid transparent;
        border-radius: 100px;
    }

    .gg-chevron-right::after {
        content: "";
        display: block;
        box-sizing: border-box;
        position: absolute;
        width: 10px;
        height: 10px;
        border-bottom: 2px solid;
        border-right: 2px solid;
        transform: rotate(-45deg);
        right: 6px;
        top: 4px;
    }

    @media only screen and (max-width: 1280px) {

        .file-history-res,
        #controls,
        .controls-compare {
            width: 100%;
        }

        .accordion-container {
            width: 90%;
        }

        .accordion {
            width: 100%;
        }

        .accordion-header {
            font-size: 0.6rem;
        }

        .leaf-btn-med,
        .controls-compare>button {
            width: 90%;
            font-size: 0.75rem;
        }

        .leaf-ul li {
            font-size: 0.7rem !important;
            line-height: 2;
        }

        .usa-table {
            font-size: 0.8rem;
        }
    }
</style>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Email Template Editor</h2>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav">
                <div id="fileBrowser">
                    <h3>Email Templates</h3>
                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_history" onclick="viewHistory()">View History</button>
                </div>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <h2 id="emailTemplateHeader">Default Email Template</h2>
                <div id="emailLists">
                    <fieldset>
                        <legend>Email To and CC</legend>
                        <br />
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
                        </table>
                    </fieldset>
                </div>
                <div class="email-keyboard-shortcuts">
                    <table class="table">
                        <tr>
                            <td colspan="2">Keyboard Shortcuts within coding area</td>
                        </tr>
                        <tr>
                            <td>Save</td>
                            <td>Ctrl + S</td>
                        </tr>
                        <tr>
                            <td>Undo</td>
                            <td>Ctrl-Z</td>
                        </tr>
                        <tr>
                            <td>Word Wrap</td>
                            <td>Ctrl-W</td>
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
                <div id="controls">
                    <button class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem" onclick="save();">
                        Save Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>
                    <button
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                        onclick="restore();">Restore Original</button>
                    <button
                        class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        id="btn_compareStop" style="display: none" onclick="loadContent();">Stop Comparing</button>
                    <!-- <button class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem modifiedTemplate"
                    id="btn_compare" onclick="compare();">Compare to Original</button> -->
                </div>
            </aside>
            <aside class="sidenav-right-compare">
                <div class="controls-compare">
                    <button class="file_replace_file_btn">Merge</button>
                    <button id="word-wrap-button" class="word-wrap-button off">Word Wrap: Off</button>
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

<!--{include file="site_elements/generic_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_confirm_xhrDialog.tpl"}-->
<!--{include file="site_elements/generic_dialog.tpl"}-->

<script>
    var codeEditor;
    // browser listens when scrolling to scroll components
    window.addEventListener('scroll', function() {
        let mainEditorContent = document.querySelector('.main-content');
        let rightSideNav = document.querySelector('.leaf-right-nav');
        let code = mainEditorContent.getBoundingClientRect();
        let buttonsNav = rightSideNav.getBoundingClientRect();

        if (code.top <= 0 || buttonsNav.top <= 0) {
            mainEditorContent.classList.add('sticky');
            rightSideNav.classList.add('sticky');
        } else {
            mainEditorContent.classList.remove('sticky');
            rightSideNav.classList.remove('sticky');
        }
    });
    // saves current file content changes
    function save() {
        $('#saveIndicator').attr('src', '../images/indicator.gif');
        const divEmailTo = document.getElementById('divEmailTo');
        const emailToData = document.getElementById('emailToCode').value;
        const emailCcData = document.getElementById('emailCcCode').value;
        const data = (codeEditor.getValue() == undefined) ? codeEditor.edit.getValue() : codeEditor.getValue();
        const subject = (subjectEditor.getValue() == undefined) ? subjectEditor.edit.getValue() : subjectEditor
            .getValue();
        const isContentChanged = (
            emailToData !== currentEmailToContent ||
            emailCcData !== currentEmailCcContent ||
            data !== currentFileContent ||
            subject !== currentSubjectContent
        ) ? true : false;
        const isContentUnchanged = (data === currentFileContent || subject === currentSubjectContent) ? true : false;
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
                console.log("File history has been saved.");
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
    // accordion content inside getFileHistory()
    function displayAccordionContent(element) {
        var accordionContent = $(element).parent().next(".accordion-content");
        var chevron = $(element);

        chevron.toggleClass("chevron-rotate");
        accordionContent.slideToggle();

        var accordions = $(".accordion");
        accordions.each(function() {
            var currentAccordionContent = $(this).find(".accordion-content");
            var currentChevron = $(this).find(".accordion-chevron");

            if (
                !currentAccordionContent.is(accordionContent) &&
                !currentChevron.is(chevron)
            ) {
                currentAccordionContent.slideUp();
                currentChevron.removeClass("chevron-rotate");
            }
        });
    }
    // request's copies of the current file content in an accordion layout
    function getFileHistory(template) {
        $.ajax({
            type: 'GET',
            url: `../api/templateFileHistory/_${template}`,
            dataType: 'json',
            success: function(res) {
                if (res.length === 0) {
                    console.log('There are no files in the directory');
                    var contentMessage = '<p class="contentMessage">There are no history files.</p>';
                    $('.file-history-res').html(contentMessage);
                    return;
                }

                var fileNames = res.map(function(item) {
                    return item.file_parent_name;
                });

                if (!fileNames.includes(template)) {
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
                    ignoreUnsavedChanges = false;

                    accordion += '<div class="accordion">' +
                        '<div class="accordion-header">' +
                        '<a href="#" id="scanFolderLink" class="accordion-date" onclick="compareHistoryFile(\'' +
                        fileName + '\', \'' + fileParentName + '\', true)">' +
                        '<span><strong style="color:#37beff;">DATE:</strong><br>' + fileCreated +
                        '</span>' +
                        '</a>' +
                        '<span class="accordion-chevron" onclick="displayAccordionContent(this)"><i class="gg-chevron-right"></i></span>' +
                        '</div>' +
                        '<div class="accordion-content">' +
                        '<ul>' +
                        '<li><strong>File Name: </strong><p>' + fileName + '</p></li>' +
                        '<li><p>' + whoChangedFile + '</p></li>' +
                        '<li><p>' + formattedFileSize + '</p></li>' +
                        '<li><strong>Share File URL: </strong>' +
                        '<div class="textContainer">' +
                        '<button class="copyIcon" onclick="getUrlLink(\'' + fileName + '\', \'' +
                        fileParentName + '\', true)">Copy Link <span>&#10063;</span></button>' +
                        '</div>' +
                        '</li>' +
                        '</ul>' +
                        '</div>' +
                        '</div>';
                }
                accordion += '</div>';
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

    // compares current file content with history file from getFileHistory()
    function compareHistoryFile(fileName, parentFile, updateURL) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#save_button').css('display', 'none');
        $('#btn_compareStop').css('display', 'none');
        $('#btn_merge').css('display', 'block');
        $('#word-wrap-button').css('display', 'block');
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
                console.log(res);
                loadContent(currentName, currentFile, currentSubjectFile, currentEmailToFile,
                    currentEmailCcFile);
                exitExpandScreen();
            },
            error: function(xhr, status, error) {
                console.log(xhr.responseText);
            }
        });
    }
    // Copy URL when clicking the copy button
    function getUrlLink(fileName, fileParentName, updateURL) {
        let currentURL = new URL(window.location.href);
        currentURL.searchParams.set('fileName', fileName);
        currentURL.searchParams.set('parentFile', fileParentName);

        let textField = document.createElement('textarea');
        textField.value = currentURL.href;
        document.body.appendChild(textField);
        textField.select();
        document.execCommand('copy');
        textField.remove();
        console.log('URL copied: ' + currentURL.href);
    }
    // Retreave URL to display comparison of files
    function initializePage() {
        const urlParams = new URLSearchParams(window.location.search);
        const fileName = urlParams.get('fileName');
        const parentFile = urlParams.get('parentFile');

        if (fileName && parentFile) {
            loadContent(currentName, parentFile, currentSubjectFile, currentEmailToFile, currentEmailCcFile);
            compareHistoryFile(fileName, parentFile, false);
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
        $('.page-title-container h2').css({
            'width': '35%',
            'text-align': 'left'
        });
        $('.main-content').css({
            'width': '85%',
            'transition': 'all .5s ease',
            'justify-content': 'flex-start'
        });
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
            'flex-direction': 'column'
        });
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
        $('.page-title-container h2').css({
            'width': '100%',
            'text-align': 'center'
        });
        $('.main-content').css({
            'width': '70%',
            'transition': 'all .5s ease',
            'justify-content': 'center'
        });
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

        // Will reset the URL
        var url = new URL(window.location.href);
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
                currentFileContent = res.file;
                currentSubjectContent = res.subjectFile;
                currentEmailToContent = res.emailToFile;
                currentEmailCcContent = res.emailCcFile;
                $('#codeContainer').fadeIn();

                // Assuming you have initialized the codeEditor and subjectEditor objects correctly
                codeEditor.setValue(currentFileContent);
                if (subjectEditor && currentSubjectContent !== null) {
                    subjectEditor.setValue(currentSubjectContent);
                }

                $("#emailToCode").val(currentEmailToContent);
                $("#emailCcCode").val(currentEmailCcContent);

                if (res.modified === 1) {
                    $('.modifiedTemplate').show();
                    
                } else {
                    $('.modifiedTemplate').hide();
                }
                getFileHistory(file);
            },
            cache: false
        });
        $('#saveStatus').html('');

        // Keyboard shortcuts
        codeEditor.setOption("extraKeys", {
            "Ctrl-S": function() {
                // Save action
                save();
            },
            "Ctrl-Z": function() {
                // Undo action
                codeEditor.undo();
            },
            "Ctrl-W": function() {
                // Word wrap action
                codeEditor.setOption("lineWrapping", !codeEditor.getOption("lineWrapping"));
            },
            "F11": function() {
                // Fullscreen action
                toggleFullscreen();
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

    }

    function updateEditorSize() {
        codeWidth = $('#codeArea').width() - 30;
        $('#codeContainer').css('width', codeWidth + 'px');
        // Refresh CodeMirror
        $('.CodeMirror').each(function(i, el) {
            el.CodeMirror.refresh();
        });
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
    // loads components when the document loads
    $(document).ready(function() {
        $('.currentUrlLink').hide();
        $('.sidenav-right-compare').hide();
        dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
        initEditor();
        $(window).on('resize', function() {
            updateEditorSize();
        });
        // Get initial email templates for the page from the database
        $.ajax({
            type: 'GET',
            url: '../api/emailTemplates',
            success: function(res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/emailTemplates/custom',
                    dataType: 'json',
                    success: function(result) {
                        let res_array = $.parseJSON(result);
                        let buffer = '<ul class="leaf-ul">';

                        if (res_array.status['code'] === 2) {
                            for (let i in res) {
                                if (result.includes(res[i].fileName)) {
                                    custom =
                                        '<span class=\'custom_file\' style=\'color: red; font-size: .75em\'>(custom)</span>';
                                } else {
                                    custom = '';
                                }

                                buffer += '<li onclick="loadContent(\'' + res[i]
                                    .displayName + '\', ' +
                                    '\'' + res[i].fileName + '\'';
                                if (res[i].subjectFileName != '') {
                                    buffer += ', \'' + res[i].subjectFileName + '\', ' +
                                        '\'' + res[i].emailToFileName + '\', ' +
                                        '\'' + res[i].emailCcFileName + '\'';
                                } else {
                                    buffer += ', undefined, undefined, undefined';
                                }

                                buffer += ');"><a href="#">' + res[i].displayName +
                                    '</a> ' + custom + ' </li>';
                            }
                        } else if (res_array.status['code'] === 4) {
                            buffer += '<li>' + res_array.status['message'] + '</li>';
                        } else {
                            buffer +=
                                '<li>Internal error occured, if this persists contact your Primary Admin.</li>';
                        }

                        buffer += '</ul>';
                        $('#fileList').html(buffer);
                    },
                    error: function(error) {
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