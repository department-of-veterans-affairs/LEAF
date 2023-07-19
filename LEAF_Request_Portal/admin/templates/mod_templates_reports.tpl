<link rel=stylesheet href="../../libs/js/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.62.2/theme/lucario.min.css">
<script src="../../libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="../../libs/js/codemirror/addon/merge/merge.js"></script>
<style>
    /* Glyph to improve usability of code compare */
    /* .usa-prose>table,
    .usa-table {
        width: 100%;
        max-width: 700px;
    } */

    .CodeMirror-merge-left {
        border: 4px solid #083;
        overflow: auto;
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

    .CodeMirror-merge-copy {
        display: none !important;
    }

    .CodeMirror,
    .cm-s-default {
        height: auto !important;
        border-radius: 0 0 0 5px;
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

    #reportURL {
        text-align: left;
        background-color: #1a4480;
        padding: 0 0 15px 15px;
        width: 100%;
        border-radius: 0 0 5px 5px;
        color: #fff;
    }

    #reportURL>a {
        color: #fff;
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
        width: 98% !important;
        box-shadow: none;
        padding: 0;
    }

    .CodeMirror-merge,
    .CodeMirror-merge {
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
        flex-direction: row;
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
        width: 80%;
        font-size: .9rem;
    }

    #fileBrowser {
        width: 100%;
        margin: 0 auto;
        padding: 10px 0;
        display: flex;
        flex-flow: column;
    }

    #fileBrowser>h3 {
        width: 100%;
        text-align: left;
    }

    .new-report {
        width: 80%;
        max-width: 250px;
        font-size: 1rem;
        margin: 0 auto;
        background-color: #1a4480;
        border: none;
        color: #fff;
        padding: 10px 0;
        border-radius: 5px;
    }

    .main-content {
        display: flex;
        justify-content: space-evenly;
        align-content: flex-start;
        width: 65%;
        flex: none;
        margin: 0 auto;
        transition: all 1s ease;
    }

    .sticky {
        position: sticky;
        top: 0;
        padding-top: 10px;
        transition: all 1s ease-in-out;
    }

    #filename {
        padding: 15px;
        font-size: 1.2rem;
        background: #1a4480;
        color: #fff;
        text-align: left;
        border-radius: 5px 5px 0 0;
    }

    .leaf-btn-med {
        margin: 10px 0 0 0;
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

    .accordion-container {
        display: block;
        margin-top: 10px;
        width: 100%;
        max-width: 250px;
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
        font-size: .75rem;
    }

    .file_compare_file_btn:hover {
        background-color: #c97c00;
    }

    .template_link {
        font-size: .8rem;
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
        width: 90%;
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
    #open_file_button,
    #deleteButton {
        width: 80%;
        font-weight: 500;
    }

    #save_button {
        background-color: #1a4480;
    }

    .contentMessage {
        width: 100%;
        font-size: .8rem;
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

    .leaf-ul>li {
        width: 100%;
        line-height: 2;
        list-style: disc;
    }

    .leaf-ul>li>a {
        color: #000;
        text-decoration: none;
        font-size: .8rem;
        border-bottom: 2px solid #005ea200;
        transition: all 0.3s ease;
    }

    .leaf-ul>li>a:hover {
        border-bottom: 2px solid #005ea2;
        color: #005EA2;
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
        width: 80%;
        display: block;
        text-decoration: none;
        border-bottom: 2px solid #e4e4e4;
        transition: all 0.3s ease;
        color: #005ea2;
    }

    .template_files>a:hover {
        border-bottom: 2px solid #005ea2;
    }

    .custom_file {
        margin-left: 10px;
    }

    #controls,
    .controls-compare {
        width: 100%;
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

    .CodeMirror-scroll {
        margin-right: 0;
        height: 60vh;
        min-height: 563px;
    }

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
        width: 80%;
        padding: 10px;
        font-size: .8rem;
        border: none;
        border-radius: 5px;
    }

    .mobileToolsNav {
        display: none;
        justify-content: flex-end;
        align-items: center;
        width: 45%;
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

    @media only screen and (max-width:1280px) {
        #controls,
        .controls-compare {
            width: 100%;
        }

        .file-history-res {
            width: 80%;
        }

        .accordion-header {
            font-size: .6rem;
        }

        .leaf-btn-med,
        .controls-compare>button {
            font-size: .75rem;
        }

        .leaf-ul li {
            font-size: .7rem !important;
            line-height: 2;
        }

        .keyboard_shortcuts_section {
            width: 90%;
        }

    }

    @media only screen and (max-width:1024px) {
        #codeContainer{
            width: 100% !important;
        }
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

        .page-title-container > h2 {
            width: 48%;
            font-size: 1.3rem;
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
            width: 95% !important;
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
        <h2>LEAF Programmer</h2>
        <div class="mobileToolsNav">
            <button class="mobileToolsNavBtn" onclick="openRightNavTools('leaf-right-nav')">Template Tools</button>
        </div>
    </div>
    <div class="page-main-content">
        <div class="leaf-left-nav">
            <aside class="sidenav" id="fileBrowser">
                <button class="new-report" onclick="newReport();">New File</button>
                <button
                    class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                    id="btn_history" onclick="viewHistory()">
                    View History
                </button>
                <div id="fileList"></div>
            </aside>
        </div>

        <main id="codeArea" class="main-content">
            <div id="codeContainer" class="leaf-code-container">
                <div id="filename"></div>
                <div id="reportURL"></div>
                <div>
                    <div class="compared-label-content">
                        <div class="CodeMirror-merge-pane-label">(History File)</div>
                        <div class="CodeMirror-merge-pane-label">(Current File)</div>
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
            <aside class="sidenav-right" id="controls">
                <button id="save_button" class="usa-button leaf-btn-med leaf-display-block leaf-width-14rem"
                    onclick="save();">Save Changes<span id="saveStatus"
                        class="leaf-display-block leaf-font0-5rem"></span>
                </button>
                <button id="open_file_button"
                    class="usa-button usa-button--accent-cool leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="
                    runReport();">Open File</button>
                <button id="deleteButton"
                    class="usa-button usa-button--secondary leaf-btn-med leaf-display-block leaf-marginTop-1rem leaf-width-14rem"" onclick="
                    deleteReport();">Delete File
                </button>
                <button
                    class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem mobileHistory"
                    id="btn_history" onclick="viewHistory()">
                    View History
                </button>
                <button
                    class="usa-button usa-button--secondary leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                    id="btn_compareStop" style="display: none" onclick="stop_comparing();">
                    Stop Comparing
                </button>
            </aside>
            <aside class="sidenav-right-compare">
                <div class="controls-compare">
                    <button class="file_replace_file_btn">Merge New File</button>
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
            },
            error: function() {
                alert('An error occurred while saving the file.');
            },
            complete: function() {
                $('#saveIndicator').attr('src', '');
            }
        });
    }
    // creates a copy of the current file content 
    function saveFileHistory() {
        $.ajax({
            type: 'POST',
            data: {
                CSRFToken: '<!--{$CSRFToken}-->',
                file: codeEditor.getValue()
            },
            url: '../api/applet/fileHistory/_' + currentFile,
            success: function(res) {
                console.log("File history has been saved.");
                getFileHistory(currentFile);
            }
        });
    }

    // Retreave URL to display comparison of files
    function initializePage() {
        var urlParams = new URLSearchParams(window.location.search);
        var fileName = urlParams.get('fileName');
        var parentFile = urlParams.get('parentFile');
        let templateFile = urlParams.get('templateFile');

        if (fileName && parentFile) {
            loadContent(parentFile);
            compareHistoryFile(fileName, parentFile, false);
        }else if (templateFile) {
            loadContent(templateFile);
        }  else {
            loadContent('example');
        }
    }
    // Expands the current and history file to compare both files
    function editorExpandScreen() {
        $('.page-title-container > .file_replace_file_btn').show();
        $('.page-title-container > .close_expand_mode_screen').show();
        $('.sidenav-right').hide();
        $('.filesMobile').hide();
        $('.sidenav-right-compare').show();
        $('.page-title-container > h2').css({
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('LEAF Programmer > Compare Code');
        let windowWidth = $(window).width();
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
            width: '100% !important'
        });
        $('.usa-table').hide();
        $('.leaf-left-nav').css({
            position: 'fixed',
            left: '-100%',
            transition: 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });
        $('.keyboard_shortcuts').css('display', 'none');
        $('.keyboard_shortcuts_merge').show();
    }
    // exits the current and history comparison
    function exitExpandScreen() {
        $('.compared-label-content').css('display', 'none');
        $('#word-wrap-button').hide();
        $('.page-title-container > .file_replace_file_btn').hide();
        $('.page-title-container > .close_expand_mode_screen').hide();
        $('#save_button_compare').css('display', 'none');
        $('.sidenav-right-compare').hide();
        $('.sidenav-right').show();
        $('.page-title-container > h2').css({
            width: '100%',
            'text-align': 'left'
        });
        $('.page-title-container>h2').html('LEAF Programmer');

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
            display: 'block',
            height: '95%',
            'width': '90% !important'
        });
        $('.usa-table').show();

        $('.leaf-left-nav').css({
            position: 'relative',
            left: '0',
            transition: 'all .5s ease'
        });
        $('.page-title-container').css({
            'flex-direction': 'row'
        });

        $('.keyboard_shortcuts').css('display', 'flex');
        $('.keyboard_shortcuts_merge').hide();
        $('#save_button').css('display', 'block');


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
        dialog.setContent('Filename: <input type="text" id="newFilename">');

        $('#newFilename').on('keyup', function(e) {
            $(this).val($(this).val().replace(/[^a-z0-9\.\/]/gi, '_'));
        });

        dialog.setSaveHandler(function() {
            var file = $('#newFilename').val();
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
    }
    // deletes the history file report when the original report has been deleted
    function deleteHistoryFileReport(templateFile) {
        $.ajax({
            type: 'DELETE',
            url: '../api/applet/deleteHistoryFileReport/_' + templateFile + '?' +
                $.param({'CSRFToken': '<!--{$CSRFToken}-->'}),
                success: function() {
                    console.log(templateFile + ', was deleted');
                    location.reload();
                }
        });
    }
    // opens the report on a new page
    function runReport() {
        window.open('../report.php?a=' + currentFile);
    }

    function isExcludedFile(file) {
        if (file === 'example' || file.substr(0, 5) === 'LEAF_') {
            return true;
        }
        return false;
    }
    // gloabal variables
    var codeEditor;
    var currentFile = '';
    var unsavedChanges = false;
    var currentFileContent = '';
    var dialog, dialog_confirm;

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
        let accordionContent = $(element).parent().next(".accordion-content");
        let chevron = $(element);

        chevron.toggleClass("chevron-rotate");
        accordionContent.slideToggle();

        let accordions = $(".accordion");
        accordions.each(function() {
            let currentAccordionContent = $(this).find(".accordion-content");
            let currentChevron = $(this).find(".accordion-chevron");

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
    // compares current file content with history file from getFileHistory()
    function compareHistoryFile(fileName, parentFile, updateURL) {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#save_button').css('display', 'none');
        $('#btn_compareStop').css('display', 'none');
        $('#btn_merge').css('display', 'block');
        $('#word-wrap-button').css('display', 'block');
        $('.save_button').css('display', 'none');
        $('.file_replace_file_btn').css('display', 'block');
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
                        }
                    });
                }
                editorExpandScreen();
            }
        });

        if (updateURL) {
            var url = new URL(window.location.href);
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
                url: '../api/applet/mergeFileHistory/saveReportMergeTemplate/_' + fileParentName,
                data: {CSRFToken: '<!--{$CSRFToken}-->',
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
    //loads all files and retreave's them
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
        var reportURL = `${window.location.origin}${window.location.pathname.replace('admin/', '')}report.php?a=${file.replace('.tpl', '')}`;
        $('#reportURL').html(`URL: <a href="${reportURL}" target="_blank">${reportURL}</a>`);
        $('#controls').css('visibility', isExcludedFile(file) ? 'hidden' : 'visible');
        $('#filename').html('' + file.replace('.tpl', ''));
        $.ajax({
            type: 'GET',
            url: `../api/applet/_${file}`,
            success: function(res) {
                currentFileContent = res.file;
                $('#codeContainer').fadeIn();

                // Check if codeEditor is already defined and has a setValue method
                if (codeEditor && typeof codeEditor.setValue === 'function') {
                    codeEditor.setValue(res.file);
                } else {
                    console.error('codeEditor is not properly initialized.');
                }

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

        $(window).on('unload', function() {
            if (unsavedChanges) {}
        });

        codeEditor.on('change', function() {
            unsavedChanges = true;
        });

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

        if (file) {
            var url = new URL(window.location.href);
            url.searchParams.set('templateFile', file);
            window.history.replaceState(null, null, url.toString());
        }
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
                },
                "Ctrl-W": function(cm) {
                    cm.setOption("lineWrapping", !cm.getOption("lineWrapping"));
                }
            }
        });
        updateEditorSize();
    }

    function updateEditorSize() {
        codeWidth = $('#codeArea').width() - 30;
        $('#codeContainer').css('width', codeWidth + 'px');
        $('.CodeMirror, .CodeMirror-merge').css('height', $(window).height() - 160 + 'px');
    }
    // example report templates
    function updateFileList() {
        $.ajax({
            type: 'GET',
            url: '../api/applet',
            success: function(res) {
                let buffer = '<ul class="leaf-ul">';
                let bufferExamples = '<div class="leaf-bold">Examples</div><ul class="leaf-ul">';
                let filesMobile = '<h3>Template Files:</h3><select class="templateFiles">';
                for (let i in res) {
                    let file = res[i].replace('.tpl', '');
                    if (!isExcludedFile(file)) {
                        buffer += '<li onclick="loadContent(\'' + file +
                            '\');"><a href="#' +
                            file + '">' + file + '</a></li>';

                            filesMobile += '<option onclick="loadContent(\'' + file + '\');"><div class="template_files"><a href="#">' + file + '</a></div></option>';
                    } else {
                        bufferExamples += '<li onclick="loadContent(\'' + file +
                            '\');" "><a href="#' +
                            file + '">' + file + '</a></li>';
                    }
                }
                buffer += '</ul>';
                bufferExamples += '</ul>';
                filesMobile += '</select>';
                $('#fileList').html(buffer + bufferExamples);
                $('.filesMobile').html(filesMobile);
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
        var windowWidth = $(window).width();

        if (windowWidth < 1024) {
            $('.leaf-right-nav').css('right', '-100%');
        } else {
            console.log('Please check the width of the window');
        }
        $.ajax({
            type: 'GET',
            url: 'ajaxIndex.php?a=gethistory&type=applet&id=' + currentFile,
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

    // loads components when the document loads
    $(document).ready(function() {
        initEditor();
        $('.currentUrlLink').hide();
        $('.sidenav-right-compare').hide();
        dialog = new dialogController('xhrDialog', 'xhr', 'loadIndicator', 'button_save',
            'button_cancelchange');
        dialog_confirm = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');
        initializePage();
        updateFileList();

        dialog_message = new dialogController('genericDialog', 'genericDialogxhr', 'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');
    });
</script>