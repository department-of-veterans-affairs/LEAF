<link rel=stylesheet href="/libs/js/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.62.2/theme/lucario.min.css">
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

    .template_files {
        width: 100%;
        display: flex;
        justify-content: flex-start;
        align-items: center;
        flex-direction: row;
        font-size: .8rem !important;
        line-height: 2;
        list-style: circle;
    }

    .template_files>a {
        /* width: 80%; */
        display: block;
        text-decoration: none;
        border-bottom: 2px solid #e4e4e400;
        transition: all 0.3s ease;
        color: #242424;
    }

    .template_files>a:hover {
        border-bottom: 2px solid #005ea2;
        color: #005EA2;
    }

    .custom_file {
        margin-left: 10px;
    }

    fieldset {
        background-color: #fff;
        border-radius: 5px;
    }

    .email-template-variables>fieldset {
        width: 100%;
        display: flex;
        justify-content: center;
        background-color: #fff;
        border-radius: 5px;
    }

    #quick_field_search_container {
        border-radius: 5px;
    }

    #divEmailCc {
        margin-bottom: 20px;
    }

    .email-template-variables>fieldset>table {
        width: 100%;
    }

    .email-keyboard-shortcuts>table {
        width: 100%;
        /* max-width: 700px; */
    }

    .leaf-code-container {
        background-color: #ffffff00 !important;
        overflow: initial;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy {
        visibility: hidden;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy::before {
        visibility: visible;
        content: '\25ba\25ba\25ba';
    }

    .CodeMirror-merge-left {
        border: 4px solid #083;
        overflow: auto;
    }

    .CodeMirror-merge-copy {
        display: none !important;
    }

    .CodeMirror,
    .cm-s-default {
        height: auto !important;
        border-radius: 0 0 5px 5px;
        border: 2px solid #000;
    }

    .CodeMirror pre {
        padding: 3px 15px;
    }

    .CodeMirror-lines {
        padding: 18px 0;
    }

    .CodeMirror-linenumber {
        text-align: center;
    }

    .CodeMirror-gutters {
        background-color: #e8e8e8;
    }

    #subjectCompare .CodeMirror-merge,
    .CodeMirror-merge .CodeMirror {}

    #emailTemplateHeader {
        padding: 25px 15px;
        font-size: 1.2rem;
        background: #1a4480;
        color: #fff;
        text-align: left;
        border-radius: 5px;
        margin: 0 0 10px 0;
    }

    #emailLists fieldset legend {
        font-size: 1.2em;
    }

    legend {
        background-color: #fff;
        padding: 10px 15px !important;
        border-radius: 5px 5px 0 0;
        margin-bottom: 10px;
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
        padding: 0;
    }

    .CodeMirror-merge,
    .CodeMirror-merge .CodeMirror {
        height: 60vh !important;
    }

    .CodeMirror-merge-2pane .CodeMirror-merge-pane {
        height: 100%;
    }

    .page-title-container {
        width: 98%;
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

    /*Keyboard Shortcuts*/
    .keyboard_shortcuts,
    .keyboard_shortcuts_merge {
        width: 100%;
        display: flex;
        flex-direction: column;
        justify-content: space-evenly;
        background-color: #fff;
        margin-top: 10px;
        padding: 20px;
        border-radius: 5px;
    }

    .keyboard_shortcuts,
    .keyboard_shortcuts_merge {
        width: 100%;
        display: flex;
        flex-direction: column;
        justify-content: space-evenly;
        background-color: #fff;
        margin-top: 10px;
        padding: 20px;
        border-radius: 5px;
    }

    .keyboard_shortcuts_section,
    .keyboard_shortcuts_section_merge {
        width: 70%;
        display: flex;
        justify-content: space-evenly;
        align-items: center;
        padding: 8px 0;
    }

    .keboard_shortcuts_box,
    .keboard_shortcuts_box_merge {
        width: 100%;
        display: flex;
        justify-content: space-evenly;
        align-items: center;
    }

    .keboard_shortcuts_box:last-child,
    .keboard_shortcuts_box_merge:last-child {
        padding-left: 50px;
    }

    .keyboard_shortcuts_title,
    .keyboard_shortcut,
    .keyboard_shortcuts_title_merge,
    .keyboard_shortcut_merge {
        width: 50%;
        text-align: left;
    }

    .keyboard_shortcuts_title>h3,
    .keyboard_shortcuts_title_merge>h3 {
        font-weight: 500;
        text-transform: uppercase;
        font-size: .7rem;
        margin: 0;
    }

    .keyboard_shortcut>p,
    .keyboard_shortcut_merge>p {
        background-color: #e6e6e6;
        border-radius: 5px;
        padding: 8px;
        text-align: center;
        font-size: .7rem;
        margin: 0;
    }

    .keboard_shortcuts_main_title,
    .keboard_shortcuts_main_title_merge {
        width: 100%;
        margin-bottom: 10px;
    }

    .leaf-left-nav,
    .leaf-right-nav {
        width: 15%;
        max-width: 400px;
        margin: 0;
        flex: auto;
        transition: all ease-in-out .5s;
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
        width: 80%;
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
        width: 65%;
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

    #filename,
    #subject {
        padding: 10px 15px !important;
        font-size: 1.2rem;
        color: #000;
        text-align: left;
        border-radius: 5px 5px 0 0;
        background-color: #fff;
        font-size: 1.3rem !important;
        margin-top: 10px;
    }

    .leaf-btn-med {
        margin-top: 10px;
    }

    .file-history {
        width: 100%;
        max-height: 675px;
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
        width: 80%;
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

    .file_replace_file_btn {
        width: 100%;
        padding: 10px 0;
        border: none;
        background-color: #B50909;
        color: #fff;
        font-weight: 700;
        margin-top: 10px;
        cursor: pointer;
        transition: all 0.3s ease;
        border-radius: 5px;
    }

    .file_replace_file_btn:hover {
        background-color: #960707;
    }

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

    .close_expand_mode_screen {
        background-color: #1a4480;
        font-size: 1rem;
    }

    .close_expand_mode_screen:hover {
        background-color: #143461;
    }

    .page-title-container>h2 {
        width: 100%;
        margin: 15px 0;
        text-align: left;
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

    #save_button,
    #btn_history,
    #restore_original,
    #icon_library {
        width: 100%;
        font-weight: 500;
    }

    #save_button {
        background-color: #1a4480;
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
        font-weight: 500;
    }


    .leaf-ul {
        width: 100%;
        min-height: 300px;
        max-width: 250px;
        padding: 0 0 0 12px;
        margin: 10px auto;
        overflow: auto;
    }

    .leaf-ul li {
        width: 100%;
        line-height: 2;
        list-style: disc;
    }


    .leaf-ul>li>a {
        width: 80%;
        display: block;
        text-decoration: none;
        border-bottom: 2px solid #e4e4e400;
        transition: all 0.3s ease;
        font-size: .8rem !important;
        color: #242424;
    }

    .leaf-ul>li>a:hover {
        border-bottom: 2px solid #005ea2;
        color: #005EA2;
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
        background-color: #fff;
        border-radius: 5px;
        margin: 15px 0;
        padding: 5px 0;
    }

    /* .CodeMirror-scroll {
        margin-right: 0;
        height: 60vh;
        min-height: 563px;
    } */

    .CodeMirror-merge-pane-label {
        width: 50%;
        text-align: center;
        font-weight: bold;
        padding: 10px 0;
    }

    .CodeMirror-merge-pane-label:nth-child(1) {
        color: #083;
    }

    /*File History Contents*/

    #file_history_container {
        width: 100%;
        max-height: 675px;
        background-color: #fff;
        margin: 10px 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: flex-start;
    }

    .file_history_titles {
        width: 100%;
        display: flex;
        flex-direction: row;
        justify-content: center;
        align-items: flex-start;
        background-color: #1A4480;
        color: #fff;
        padding: 10px 0;
        /* box-shadow: 0px 3px 3px -1px #01000061; */
        border-radius: 5px 5px 0 0;
        -webkit-border-radius: 5px 5px 0 0;
        -moz-border-radius: 5px 5px 0 0;
        -ms-border-radius: 5px 5px 0 0;
        -o-border-radius: 5px 5px 0 0;
    }

    .file_history_date,
    .file_history_author {
        width: 48%;
        text-align: center;
        font-size: .8rem;
    }

    .file_history_options_container {
        width: 100%;
        height: 100%;
        max-height: 500px;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        align-items: center;
        border: 2px solid #112D55;
        border-top: #ffffff00;
        overflow: auto;
        border-radius: 0 0 5px 5px;
    }

    .file_history_options_wrapper {
        width: 100%;
        display: flex;
        flex-direction: row;
        justify-content: center;
        align-items: center;
        border-bottom: 2px solid #112D55;
        border-top: #ffffff00;
        cursor: pointer;
        transition: all ease-in-out .3s;
        -webkit-transition: all ease-in-out .3s;
        -moz-transition: all ease-in-out .3s;
        -ms-transition: all ease-in-out .3s;
        -o-transition: all ease-in-out .3s;
    }

    .file_history_options_wrapper:hover {
        border-bottom: 2px solid #112D55;
        background-color: #112D55;
        color: #fff;
    }

    .file_history_options_wrapper:first-child {
        border-top: #9f9f9f00;
    }

    .file_history_options_wrapper:last-child {
        border-bottom: #ffffff00;
    }

    .file_history_options_date,
    .file_history_options_author {
        width: 50%;
        font-size: .7rem;
        text-align: center;
        padding: 10px 0;
        overflow: auto;
        font-weight: 500;
        text-transform: capitalize;
    }

    .file_history_options_date {
        border-right: 2px solid #112D55;
    }

    .filesMobile {
        width: 100%;
        display: none;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        background-color: #fff;
        padding: 10px 0;
        margin: 0 0 10px 0;
    }

    .templateFiles {
        width: 85%;
        padding: 10px;
        font-size: .8rem;
        border: none;
        border-radius: 5px;
    }

    .mobileToolsNav {
        display: none;
        justify-content: flex-end;
        align-items: center;
        width: 50%;
    }

    .mobileToolsNavBtn {
        background-color: none;
        border: 2px solid #1A4480;
        padding: 5px;
        border-radius: 5px;

    }

    #closeMobileToolsNavBtn {
        display: none;
        background-color: #0000;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        transition: all ease-in-out .5s;
    }

    #closeMobileToolsNavBtn:hover {
        color: #B50909;
    }

    #closeMobileToolsNavBtnContainer {
        width: 90%;
        display: flex;
        justify-content: flex-end;
        align-items: center;
    }

    .mobileHistory {
        display: none;
    }

    #quick_field_search_container {
        margin-top: 0;
    }

    #quick_field_search {
        width: 100%;
    }

    #form-select-dropdown,
    #indicator-select-dropdown,
    #indicator-id {
        border: none;
        margin-top: 10px;
        padding: 10px;
        border-radius: 5px;
    }

    #indicator-id {
        padding: 0;
    }

    #form-select,
    #indicator-select,
    #indicator-id-label {
        width: 100%;
        display: flex;
        flex-wrap: wrap;
        flex-direction: column;
        justify-content: flex-start;
        align-items: flex-start;
        margin-bottom: 20px;
    }

    #form-select>span,
    #indicator-select>span,
    #indicator-id-label>span {
        font-weight: 600;
    }

    #indicator-id-label {
        margin: 0;
    }

    #indicator-select,
    #indicator-id-label,
    #copy-field-id {
        visibility: hidden;
    }

    #sensitive-warning {
        color: red;
        visibility: hidden;
    }

    #copy-field-id {
        margin: 15px 0 0 0;
    }

    @media only screen and (max-width: 1280px) {

        .file-history-res,
        #controls,
        .controls-compare {
            width: 90%;
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

        .keyboard_shortcuts_section {
            width: 90%;
        }
    }



    @media only screen and (max-width:1024px) {
        .mobileHistory {
            display: block;
        }

        #closeMobileToolsNavBtn {
            display: block;
        }

        .page-title-container {
            width: 90%;
            flex-wrap: nowrap;
            align-items: center;
        }

        .mobileToolsNav {
            display: flex;
        }

        .leaf-left-nav {
            display: none;
        }

        .filesMobile {
            display: flex;
        }

        .main-content {
            width: 95%;
        }

        .CodeMirror-code {
            font-size: .7rem;
        }

        .leaf-right-nav {
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            padding: 20px 0;
            position: fixed;
            right: -100%;
            width: 300px;
            background-color: #fff;
            height: 100%;
            z-index: 999;
            top: 0;
            box-shadow: 0 0 15px 5px #00000040;
            align-items: center;
        }

        .sidenav,
        .sidenav-right {
            width: 100%;
        }

        .sidenav-right-compare {
            width: 95%;
        }

        #nav {
            z-index: 998;
        }

        .keyboard_shortcuts_section {
            width: 100%;
        }
    }
</style>

<div class="leaf-center-content">
    <div class="page-title-container">
        <h2>Email Template Editor</h2>
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
                <div id="divSubject">
                    <textarea id="subjectCode"></textarea>
                    <div id="subjectCompare"></div>
                </div>
                <div id="filename" style="padding: 8px; font-size: 140%; font-weight: bold">Body</div>
                <div id="divCode">
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label">(History Files)</div>
                        <div class="CodeMirror-merge-pane-label">(Current File)</div>
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
                            <tr>
                                <td><b>{{$field.&lt;fieldID&gt;}}</fieldID>
                                </td>
                                <td>The value of the field by ID. <span style="color: red;">Sensitive data fields may
                                        not be included in email templates.</span></td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <fieldset id="quick_field_search_container">
                    <legend>Quick Field Search</legend>
                    <div id="quick_field_search">
                        <div id="form-select">
                            <span>Select Form:</span>
                            <select id="form-select-dropdown" onchange="getIndicators(this.value)"></select>
                        </div>
                        <div id="indicator-select">
                            <span>Select Question:</span>
                            <select id="indicator-select-dropdown"
                                onchange="showIndicator(this.value, this.options[this.selectedIndex].dataset.isSensitive)"></select>
                        </div>
                        <div id="indicator-id-label">
                            <span>Your field ID is: </span><span id="indicator-id"
                                style="font-weight: 700; margin-right: 1rem;"></span>
                            <button id="copy-field-id" style="width: auto; display: inline-block;"
                                class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med"><i
                                    class="fas fa-copy"></i> Copy</button>
                        </div>
                        <span id="sensitive-warning">*This field is marked as sensitive! The field value will not show
                            in sent emails*</span>
                    </div>
                </fieldset>

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
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Word Wrap: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>Ctrl + W </p>
                            </div>
                        </div>
                    </div>
                    <div class="keyboard_shortcuts_section">
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Dark Mode: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>Ctrl + B </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box">
                            <div class="keyboard_shortcuts_title">
                                <h3>Default Mode: </h3>
                            </div>
                            <div class="keyboard_shortcut">
                                <p>Ctrl + N</p>
                            </div>
                        </div>
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
                                <h3>Word Wrap: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + W </p>
                            </div>
                        </div>
                    </div>
                    <div class="keyboard_shortcuts_section_merge">
                        <div class="keboard_shortcuts_box_merge">
                            <div class="keyboard_shortcuts_title_merge">
                                <h3>Exit Compare: </h3>
                            </div>
                            <div class="keyboard_shortcut_merge">
                                <p>Ctrl + E </p>
                            </div>
                        </div>
                        <div class="keboard_shortcuts_box_merge">

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
                <div id="controls">
                    <button id="save_button" class="usa-button leaf-display-block leaf-btn-med leaf-width-14rem"
                        onclick="save();">
                        Save Changes<span id="saveStatus"
                            class="leaf-display-block leaf-font-normal leaf-font0-5rem"></span>
                    </button>
                    <button id="restore_original"
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
    function openRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '0'
        });
    }

    function closeRightNavTools(option) {
        let nav = $('.' + option + '');
        nav.css({
            'right': '-100%'
        });
    }
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
        const data = (typeof codeEditor !== 'undefined' && codeEditor.getValue() !== undefined) ? codeEditor
            .getValue() : codeEditor.edit.getValue();
        const subject = (typeof subjectEditor !== 'undefined' && subjectEditor.getValue() !== undefined) ? subjectEditor
            .getValue() : subjectEditor.edit.getValue();
        const isContentChanged = (
            emailToData !== currentEmailToContent ||
            emailCcData !== currentEmailCcContent ||
            data !== currentFileContent ||
            subject !== currentSubjectContent
        );
        const isContentUnchanged = (data === currentFileContent);
        const isNull = emailToData === null || emailCcData === null;

        // console.log('divEmailTo: ' + divEmailTo);
        console.log('emailToData: ' + emailToData);
        console.log('emailCcData: ' + emailCcData);
        console.log('data: ' + data);
        console.log('subject: ' + subject);
        console.log('isContentChanged: ' + isContentChanged);
        console.log('isContentUnchanged: ' + isContentUnchanged);
        console.log('isNull: ' + isNull);


        if (divEmailTo.style.display === 'none') {
            console.log('divEmailTo is display none');
            if (isContentUnchanged || isNull) {
                showDialog('Please make a change to the content in order to save.');
            } else {
                saveTemplate();
            }
        } else {
            console.log('divEmailTo is display block');
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
                    updateUIAfterSave();
                    if (res != null) {
                        alert(res);
                    }

                    saveFileHistory();
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
            if ($('#btn_compareStop').css('display') !== 'none') {
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

                let accordion = '<div id="file_history_container">' +
                    '<div class="file_history_titles">' +
                    '<div class="file_history_date">Date:</div>' +
                    '<div class="file_history_author">Author:</div>' +
                    '</div>' +
                    '<div class="file_history_options_container">';
                for (let i = 0; i < res.length; i++) {
                    var fileId = res[i].file_id;
                    var fileParentName = res[i].file_parent_name;
                    var fileName = res[i].file_name;
                    var filePath = res[i].file_path;
                    var fileSize = res[i].file_size;
                    var whoChangedFile = res[i].file_modify_by;
                    var fileCreated = res[i].file_created;
                    var formattedFileSize = formatFileSize(fileSize);
                    ignoreUnsavedChanges = false;

                    accordion +=
                        '<div class="file_history_options_wrapper" onclick="compareHistoryFile(\'' +
                        fileName + '\', \'' + fileParentName + '\', true)">' +
                        '<div class="file_history_options_date">' + fileCreated + '</div>' +
                        '<div class="file_history_options_author">' + whoChangedFile + '</div>' +
                        '</div>';
                }
                accordion += '</div>' +
                    '</div>';
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
        $('.file_replace_file_btn').css('display', 'block');
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
                                codeEditor.leftOriginal().setOption('lineWrapping', !
                                    lineWrapping);
                            }

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
    // Add a shortcut for exit from the merge screen
    $(document).on('keydown', function(event) {
        if (event.ctrlKey && event.key === 'e') {
            exitExpandScreen();
        }
    });
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
    // Retreave URL to display comparison of files
    function initializePage() {
        const urlParams = new URLSearchParams(window.location.search);
        const fileName = urlParams.get('fileName');
        const parentFile = urlParams.get('parentFile');
        const templateFile = urlParams.get('templateFile');

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
        $('#quick_field_search_container').hide();
        $('.page-title-container h2').css({
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Email Template Editor > Compare Code');
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
            'flex-direction': 'column'
        });
        $('.keyboard_shortcuts').css('display', 'none');
        $('.keyboard_shortcuts_merge').show();
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
        $('#quick_field_search_container').show();
        $('.page-title-container h2').css({
            'width': '100%',
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('Email Template Editor');

        let windowWidth = $(window).width();

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

        $('.keyboard_shortcuts').css('display', 'flex');
        $('.keyboard_shortcuts_merge').hide();

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
        $('.keyboard_shortcuts_merge').hide();
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

        editorCurrentContent()

        // Keyboard shortcuts
        codeEditor.setOption("extraKeys", {
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

        if (file != '') {
            let url = new URL(window.location.href);
            url.searchParams.set('templateFile', file);
            window.history.replaceState(null, null, url.toString());
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

    /**
     * getForms Function
     * Purpose: On loading document, get all available forms on the portal for quick search
     */
    function getForms() {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "GET",
                url: "../api/formStack/categoryList",
                cache: false,
                success: (res) => loadFormSelection(res),
                fail: (err) => reject(err)
            });
        });
    }

    /**
     * loadFormSelection
     * Purpose: On getting forms, load selections into dropdown
     * @param forms
     */
    function loadFormSelection(forms) {
        let sel = document.getElementById('form-select-dropdown');
        let opt = null;

        // empty the selection for between loads
        sel.innerHTML = "";

        // repopulate the dropdown
        forms.forEach(form => {
            opt = document.createElement('option');
            opt.value = form.categoryID;
            opt.innerHTML = form.categoryName.length > 50 ? form.categoryName.slice(0, 47) + "..." : form
                .categoryName;
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
    function getIndicators(form) {
        if (this.value === "" || typeof form === 'undefined' || typeof form === 'null') {
            return;
        }

        return new Promise((resolve, reject) => {
            $.ajax({
                type: "GET",
                url: "../api/form/indicator/list",
                data: {forms: form},
                cache: false,
                success: (res) => loadIndicatorSelection(res),
                fail: (err) => reject(err)
            });
        });
    }

    /**
     * loadIndicatorSelection
     * Purpose: On selecting form in the form dropdown, load the indicators 
     * for that form in the indicator dropdown.
     * @param indicators
     */
    function loadIndicatorSelection(indicators) {
        let div = document.getElementById('indicator-select');
        let sel = document.getElementById("indicator-select-dropdown");
        div.style.visibility = 'visible';
        let opt = null;

        sel.innerHTML = "";

        indicators.forEach(indicator => {
            opt = document.createElement('option');
            opt.value = indicator.indicatorID;
            opt.innerHTML = indicator.name.length > 50 ? indicator.name.slice(0, 47) + "..." : indicator.name;
            opt.dataset.isSensitive = indicator.is_sensitive;
            sel.appendChild(opt);
        });

        if (indicators.length === 1) {
            showIndicator(indicators[0].indicatorID, indicators[0].isSensitive);
        }
    }

    /**
     * Function showIndicator
     * Purpose: On selecting indicator in the indicator dropdown, show the 
     * field ID and provide means to copy the syntax into the email template.
     * @param indicator: the ID of the indicator being selected
     * @param isSensitive: If the indicator is sensitive, warn the user.
     */
    function showIndicator(indicator, isSensitive) {
        let warning = document.getElementById('sensitive-warning');
        warning.style.visibility = isSensitive == 1 ? "visible" : "hidden";

        let sel = document.getElementById('indicator-id-label');
        let id = document.getElementById('indicator-id');

        let fieldValue = "\{\{\$field." + indicator + "\}\}";

        let copyFieldButton = document.getElementById("copy-field-id");
        copyFieldButton.innerHTML = `<i class="fas fa-copy" aria-hidden="true"></i> Copy`;
        copyFieldButton.style.color = "#005ea2";
        copyFieldButton.style.boxShadow = "inset 0 0 0 2px #005ea2";
        copyFieldButton.onclick = () => copyField(copyFieldButton, fieldValue);

        id.textContent = fieldValue;
        sel.style.visibility = "visible";
        copyFieldButton.style.visibility = "visible";
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
    // Displays  user's history when creating, merge, and so on
    function viewHistory() {
        dialog_message.setContent('');
        dialog_message.setTitle('Access Template History');
        dialog_message.show();
        dialog_message.indicateBusy();
        var windowWidth = $(window).width();

        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
        } else {
            console.log('Please check the width of the window');
        }
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
        // Get forms for quick search
        getForms().then((res) => console.log(res));
        // Get initial email tempates for page from database
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
                        let filesMobile =
                            '<h3>Template Files:</h3><select class="templateFiles">';

                        if (res_array.status['code'] === 2) {
                            for (let i in res) {
                                if (result.includes(res[i].fileName)) {
                                    custom =
                                        '<span class=\'custom_file\' style=\'color: red; font-size: .75em\'>(custom)</span>';
                                } else {
                                    custom = '';
                                }
                                filesMobile += '<option onclick="loadContent(\'' + res[
                                        i].displayName +
                                    '\');"><div class="template_files"><a href="#">' +
                                    res[i].displayName + '</a> ' + custom +
                                    '</div></option>';


                                buffer += '<li onclick="loadContent(\'' + res[i].displayName + '\', ' + '\'' + res[i].fileName + '\'';
                                if (res[i].subjectFileName != '') {
                                    buffer += ', \'' + res[i].subjectFileName + '\', ' +
                                        '\'' + res[i].emailToFileName + '\', ' +
                                        '\'' + res[i].emailCcFileName + '\'';
                                } else {
                                    buffer += ', undefined, undefined, undefined';
                                }

                                buffer += ');"><div class="template_files"><a href="#">' + res[i].displayName +
                                    '</a> ' + custom + ' </div></li>';

                            }
                        } else if (res_array.status['code'] === 4) {
                            buffer += '<li>' + res_array.status['message'] + '</li>';
                            filesMobile += '<select><option>' + res_array.status[
                                'message'] + '</option></select>';
                        } else {
                            buffer +=
                                '<li>Internal error occured, if this persists contact your Primary Admin.</li>';
                        }

                        buffer += '</ul>';
                        filesMobile += '</select>';
                        $('#fileList').html(buffer);
                        $('.filesMobile').html(filesMobile);
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