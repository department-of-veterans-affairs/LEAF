export default {
    name: 'advanced-options-dialog',
    data() {
        return {
            requiredDataProperties: ['indicatorID','html','htmlPrint'],
            initialFocusElID: '#advanced legend',
            left: '{{',
            right: '}}',
            codeEditorHtml: {},
            codeEditorHtmlPrint: {},
            html: this.dialogData?.html || '',
            htmlPrint: this.dialogData?.htmlPrint || ''
        }
    },
    inject: [
        'APIroot',
        'libsPath',
        'CSRFToken',
        'setDialogSaveFunction',
        'dialogData',
        'checkRequiredData',
        'closeFormDialog',
        'focusedFormRecord',
        'getFormByCategoryID',
        'hasDevConsoleAccess'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
        this.checkRequiredData(this.requiredDataProperties);
    },
    mounted(){
        document.querySelector(this.initialFocusElID)?.focus();
        if(this.hasDevConsoleAccess) {
            this.setupAdvancedOptions();
        }
    },
    computed: {
        indicatorID() {
            return this.dialogData?.indicatorID;
        },
        formID() {
            return this.focusedFormRecord.categoryID;
        }
    },
    methods: {
        /**
         * html and htmlPrint fields use CodeMirror
         */
        setupAdvancedOptions() {
            this.codeEditorHtml = CodeMirror.fromTextArea(document.getElementById("html"), {
                mode: "htmlmixed",
                lineNumbers: true,
                extraKeys: {
                    "F11": (cm) => {
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
                    "Ctrl-S": (cm) => {
                        this.saveCodeHTML();
                    }
                }
            });
            this.addCodeMirrorAria('html','codemirror_html_label');
            this.codeEditorHtmlPrint = CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
                mode: "htmlmixed",
                lineNumbers: true,
                extraKeys: {
                    "F11": (cm) => {
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
                    "Ctrl-S": (cm) => {
                        this.saveCodeHTMLPrint();
                    }
                }
            });
            this.addCodeMirrorAria('htmlPrint','codemirror_htmlPrint_label');
            $('.CodeMirror').css('border', '1px solid black');
        },
        /* adds aria attributes to editor for screenreaders */
        addCodeMirrorAria(mountID = '', labelID = '') {
            let elTextarea = document.querySelector(`#${mountID} + .CodeMirror textarea`);
            if(elTextarea !== null) {
                elTextarea.setAttribute('id', labelID);
                elTextarea.setAttribute('role', 'textbox');
                elTextarea.setAttribute('aria-multiline', true);
                elTextarea.setAttribute('aria-label', 'Coding area.  Press escape twice followed by tab to navigate out.');
            }
        },
        /* save with the modal's html and htmlPrint 'save code' buttons  */
        saveCodeHTML() {
            const htmlValue = this.codeEditorHtml.getValue();
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.indicatorID}/html`,
                data: {
                    html: htmlValue,
                    CSRFToken: this.CSRFToken
                },
                success: ()=> {
                    this.html = htmlValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_html').innerHTML = ', Last saved: ' + time;
                    this.getFormByCategoryID(this.formID);
                },
                error: (err) => console.log(err)
            });
        },
        saveCodeHTMLPrint() {
            const htmlPrintValue = this.codeEditorHtmlPrint.getValue();
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.indicatorID}/htmlPrint`,
                data: {
                    htmlPrint: htmlPrintValue,
                    CSRFToken: this.CSRFToken
                },
                success: ()=> {
                    this.htmlPrint = htmlPrintValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_htmlPrint').innerHTML =', Last saved: ' + time;
                    this.getFormByCategoryID(this.formID);
                },
                error: (err) => console.log(err)
            });
        },
        /* called with the 'save' button of base modal */
        onSave() {
            let advancedOptionsUpdates = [];
            const htmlChanged = this.html !== this.codeEditorHtml.getValue();
            const htmlPrintChanged = this.htmlPrint !== this.codeEditorHtmlPrint.getValue();

            if(htmlChanged) {
                advancedOptionsUpdates.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${this.indicatorID}/html`,
                        data: {
                            html: this.codeEditorHtml.getValue(),
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {},
                        error: err => console.log('ind html post err', err)
                    })
                );                    
            }
            if(htmlPrintChanged) {
                advancedOptionsUpdates.push(
                    $.ajax({
                        type: 'POST',
                        url: `${this.APIroot}formEditor/${this.indicatorID}/htmlPrint`,
                        data: {
                            htmlPrint: this.codeEditorHtmlPrint.getValue(),
                            CSRFToken: this.CSRFToken
                        },
                        success: () => {},
                        error: err => console.log('ind htmlPrint post err', err)
                    })
                );                    
            }

            Promise.all(advancedOptionsUpdates).then((res)=> {
                this.closeFormDialog();
                if (res.length > 0) {
                    this.getFormByCategoryID(this.formID);
                }
            }).catch(err => console.log('an error has occurred', err));
        }
    },
    template: `<div v-if="hasDevConsoleAccess" id="advanced_options_dialog_content">
            <fieldset id="advanced"><legend tabindex="0">Template Variables and Controls</legend>
                <table class="table">
                    <tbody>
                        <tr>
                            <td><b style="white-space: nowrap;">{{ left }} iID {{ right }}</b></td>
                            <td>The indicatorID # of the current data field.</td>
                            <td><b>Ctrl-S</b></td>
                            <td>Save the focused section</td>
                        </tr>
                        <tr>
                            <td><b style="white-space: nowrap;">{{ left }} recordID {{ right }}</b></td>
                            <td>The record ID # of the current request.</td>
                            <td><b>F11</b></td>
                            <td>Toggle Full Screen mode for the focused section</td>
                        </tr>
                        <tr>
                            <td><b style="white-space: nowrap;">{{ left }} data {{ right }}</b></td>
                            <td>The contents of the current data field as stored in the database.</td>
                            <td><b>Esc</b></td>
                            <td>Escape Full Screen mode</td>
                        </tr>
                    </tbody>
                </table>
                <div style="font-size:14px;">
                    Within the code editor, tab enters a tab character. If using the keyboard to navigate, press escape followed by tab to exit the editor.
                </div><br />
                <div class="save_code">
                    <label for="codemirror_html_label">html (for pages where the user can edit data):</label>
                    <button type="button" id="btn_codeSave_html" class="btn-general" @click="saveCodeHTML" aria-label="save html code">
                        <img id="saveIndicator" :src="libsPath + 'dynicons/svg/media-floppy.svg'" alt="" />
                        &nbsp;Save Code<span id="codeSaveStatus_html"></span>
                    </button>
                </div>
                <textarea id="html">{{html}}</textarea><br />
                <div class="save_code">
                    <label for="codemirror_htmlPrint_label">htmlPrint (for pages where the user can only read data):</label>
                    <button  type="button" id="btn_codeSave_htmlPrint" class="btn-general" @click="saveCodeHTMLPrint" aria-label="save html-print code">
                        <img id="saveIndicator" :src="libsPath + 'dynicons/svg/media-floppy.svg'" alt="" />
                        &nbsp;Save Code<span id="codeSaveStatus_htmlPrint"></span>
                    </button>
                </div>
                <textarea id="htmlPrint">{{htmlPrint}}</textarea>
            </fieldset>
        </div>
        <div v-else id="advanced_options_dialog_content">
            <b>Notice:</b><br/>
            <p>Please go to <a href="../report.php?a=LEAF_start_leaf_dev_console_request" target="_blank">LEAF Programmer</a>
            to ensure continued access to this area.</p>
        </div>`
}