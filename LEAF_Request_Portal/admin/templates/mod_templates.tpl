<link rel=stylesheet href="../../libs/js/codemirror/addon/merge/merge.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.62.2/theme/lucario.min.css">
<script src="../../libs/js/diff-match-patch/diff-match-patch.js"></script>
<script src="../../libs/js/codemirror/addon/merge/merge.js"></script>

<style>
    /* Glyph to improve usability of code compare */
    .leaf-code-container {
        background-color: #ffffff00 !important;
        overflow: initial;
    }

    .CodeMirror-merge-copybuttons-left>.CodeMirror-merge-copy {
        visibility: hidden;
    }

    .CodeMirror-merge-left {
        border: 4px solid #083;
        overflow: auto;
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
        width: 100%;
        font-size: .9rem;
    }

    #fileBrowser {
        width: 80%;
        margin: 0 auto;
        padding: 10px 0;
    }

    #fileBrowser>h3 {
        width: 100%;
        text-align: left;
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
        padding: 25px 15px;
        font-size: 1.2rem;
        background: #1a4480;
        color: #fff;
        text-align: left;
        border-radius: 5px;
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

    .page-title-container h2 {
        width: 100%;
        margin: 15px 0;
        text-align: left;
    }

    .page-title-container .file_replace_file_btn {
        display: none;
        width: 20%;
    }

    .page-title-container .close_expand_mode_screen {
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

    #controls,
    .controls-compare {
        width: 80%;
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


    @media only screen and (max-width:1280px) {

        .file-history-res,
        #controls,
        .controls-compare {
            width: 90%;
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

                    <!--<button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem  modifiedTemplate"
                        id="btn_compare" onclick="compare();">
                        Compare to Original
                    </button> -->

                    <button id="icon_library"
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem"
                        target="_blank">
                        <a href="<!--{$domain_path}-->/libs/dynicons/gallery.php">Icon Library</a>
                    </button>
                    <button
                        class="usa-button usa-button--outline leaf-marginTop-1rem leaf-display-block leaf-btn-med leaf-width-14rem mobileHistory"
                        id="btn_history" onclick="viewHistory()">
                        View History
                    </button>
                </div>
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
                console.log("File history has been saved.");
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
                        loadContent(currentFile);
                    }
            });
            dialog.hide();
        });

        dialog.show();
    }

    var dv;
    // compares the default with the new template
    function compare() {
        $('.CodeMirror').remove();
        $('#codeCompare').empty();
        $('#btn_compare').css('display', 'none');
        $('#btn_compareStop').css('display', 'block');
        $('#save_button_compare').css('display', 'block');


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
                $('.CodeMirror-linebackground').css({
                    'background-color': '#8ce79b !important'
                });
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

    // Retreave URL to display comparison of files
    function initializePage() {
        let urlParams = new URLSearchParams(window.location.search);
        let fileName = urlParams.get('fileName');
        let parentFile = urlParams.get('parentFile');
        let templateFile = urlParams.get('templateFile');

        if (fileName && parentFile) {
            loadContent(parentFile);
            compareHistoryFile(fileName, parentFile, false);
        } else if (templateFile) {
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
    // Compare the current file content with the history file obtained from getFileHistory()
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


        // Word Wrap when viewing the merge editor
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

                            function toggleWordWrap() {
                                var lineWrapping = codeEditor.editor().getOption(
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
        var windowWidth = $(window).width();

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
    // loads components when the document loads
    $(document).ready(function() {
        $('.currentUrlLink').hide();
        $('.sidenav-right-compare').hide();
        dialog = new dialogController('confirm_xhrDialog', 'confirm_xhr', 'confirm_loadIndicator',
            'confirm_button_save', 'confirm_button_cancelchange');

        initEditor();

        $.ajax({
            type: 'GET',
            url: '../api/template/',
            success: function(res) {
                $.ajax({
                    type: 'GET',
                    url: '../api/template/custom',
                    dataType: 'json',
                    success: function(result) {
                        let res_array = $.parseJSON(result);
                        let buffer = '<ul class="leaf-ul">';
                        let filesMobile =
                            '<h3>Template Files:</h3><select class="templateFiles">';

                        if (res_array.status['code'] === 2) {
                            for (let i in res) {
                                if (result.includes(res[i])) {
                                    custom =
                                        '<span class=\'custom_file\' style=\'color: red; font-size: .75em\'>(custom)</span>';
                                } else {
                                    custom = '';
                                }

                                file = res[i].replace('.tpl', '');

                                buffer += '<li onclick="loadContent(\'' + res[i] +
                                    '\');"><div class="template_files"><a href="#">' +
                                    file + '</a> ' + custom + '</div></li>';

                                filesMobile += '<option onclick="loadContent(\'' + res[
                                        i] +
                                    '\');"><div class="template_files"><a href="#">' +
                                    file + '</a> ' + custom + '</div></option>';
                            }
                        } else if (res_array.status['code'] === 4) {
                            buffer += '<li><div class="template_files">' + res_array
                                .status['message'] + '</div></li>';
                            filesMobile += '<select><option>' + res_array
                                .status['message'] + '</option></select>';
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

        initializePage();


        dialog_message = new dialogController('genericDialog', 'genericDialogxhr',
            'genericDialogloadIndicator',
            'genericDialogbutton_save', 'genericDialogbutton_cancelchange');

    });
</script>