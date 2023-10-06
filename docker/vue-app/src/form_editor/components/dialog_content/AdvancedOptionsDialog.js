export default {
    name: 'advanced-options-dialog',
    data() {
        return {
            initialFocusElID: '#advanced legend',
            left: '{{',
            right: '}}',
            formID: this.focusedFormRecord.categoryID,
            codeEditorHtml: {},
            codeEditorHtmlPrint: {},
            html: this.indicatorRecord[this.currIndicatorID].html === null ? '' : this.indicatorRecord[this.currIndicatorID].html,
            htmlPrint: this.indicatorRecord[this.currIndicatorID].htmlPrint === null ? '' : this.indicatorRecord[this.currIndicatorID].htmlPrint
        }
    },
    inject: [
        'APIroot',
        'libsPath',
        'CSRFToken',
        'setDialogSaveFunction',
        'closeFormDialog',
        'focusedFormRecord',
        'currIndicatorID',
        'indicatorRecord',
        'selectNewCategory',
        'hasDevConsoleAccess',
        'selectedNodeIndicatorID'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted(){
        document.querySelector(this.initialFocusElID)?.focus();
        if(+this.hasDevConsoleAccess === 1) {
            this.setupAdvancedOptions();
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
                    "Esc": (cm) => {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-S": (cm) => {
                        this.saveCodeHTML();
                    }
                }
            });
            this.codeEditorHtmlPrint = CodeMirror.fromTextArea(document.getElementById("htmlPrint"), {
                mode: "htmlmixed",
                lineNumbers: true,
                extraKeys: {
                    "F11": (cm) => {
                        cm.setOption("fullScreen", !cm.getOption("fullScreen"));
                    },
                    "Esc": (cm) => {
                        if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
                    },
                    "Ctrl-S": (cm) => {
                        this.saveCodeHTMLPrint();
                    }
                }
            });
            $('.CodeMirror').css('border', '1px solid black');
        },
        /* save with the modal's html and htmlPrint 'save code' buttons  */
        saveCodeHTML() {
            const htmlValue = this.codeEditorHtml.getValue();
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.currIndicatorID}/html`,
                data: {
                    html: htmlValue,
                    CSRFToken: this.CSRFToken
                },
                success: ()=> {
                    this.html = htmlValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_html').innerHTML = ', Last saved: ' + time;
                    this.selectNewCategory(this.formID);
                },
                error: (err) => console.log(err)
            });
        },
        saveCodeHTMLPrint() {
            const htmlPrintValue = this.codeEditorHtmlPrint.getValue();
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formEditor/${this.currIndicatorID}/htmlPrint`,
                data: {
                    htmlPrint: htmlPrintValue,
                    CSRFToken: this.CSRFToken
                },
                success: ()=> {
                    this.htmlPrint = htmlPrintValue;
                    const time = new Date().toLocaleTimeString();
                    document.getElementById('codeSaveStatus_htmlPrint').innerHTML =', Last saved: ' + time;
                    this.selectNewCategory(this.formID);
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
                        url: `${this.APIroot}formEditor/${this.currIndicatorID}/html`,
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
                        url: `${this.APIroot}formEditor/${this.currIndicatorID}/htmlPrint`,
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
                    this.selectNewCategory(this.formID);
                }
            }).catch(err => console.log('an error has occurred', err));
        }
    },
    template: `<div v-if="parseInt(hasDevConsoleAccess) === 1">
            <fieldset id="advanced" style="min-width: 700px; padding: 0.5em; margin:0"><legend tabindex="0">Template Variables and Controls</legend>
                <table class="table" style="border-collapse: collapse; margin: 0; width: 100%;">
                    <tr>
                        <td><b>{{ left }} iID {{ right }}</b></td>
                        <td>The indicatorID # of the current data field.</td>
                        <td><b>Ctrl-S</b></td>
                        <td>Save the focused section</td>
                    </tr>
                    <tr>
                        <td><b>{{ left }} recordID {{ right }}</b></td>
                        <td>The record ID # of the current request.</td>
                        <td><b>F11</b></td>
                        <td>Toggle Full Screen mode for the focused section</td>
                    </tr>
                    <tr>
                        <td><b>{{ left }} data {{ right }}</b></td>
                        <td>The contents of the current data field as stored in the database.</td>
                        <td><b>Esc</b></td>
                        <td>Escape Full Screen mode</td>
                    </tr>
                </table><br />
                <div style="display:flex; justify-content: space-between; align-items: flex-end;">
                    html (for pages where the user can edit data): 
                    <button type="button" id="btn_codeSave_html" class="btn-general" @click="saveCodeHTML" title="Save Code">
                        <img id="saveIndicator" :src="libsPath + 'dynicons/svg/media-floppy.svg'" style="width:16px" alt="" />
                        &nbsp;Save Code<span id="codeSaveStatus_html"></span>
                    </button>
                </div>
                <textarea id="html">{{html}}</textarea><br />
                <div style="display:flex; justify-content: space-between; align-items: flex-end;">
                    htmlPrint (for pages where the user can only read data): 
                    <button  type="button" id="btn_codeSave_htmlPrint" class="btn-general" @click="saveCodeHTMLPrint" title="Save Code">
                        <img id="saveIndicator" :src="libsPath + 'dynicons/svg/media-floppy.svg'" style="width:16px" alt="" />
                        &nbsp;Save Code<span id="codeSaveStatus_htmlPrint"></span>
                    </button>
                </div>
                <textarea id="htmlPrint">{{htmlPrint}}</textarea>
            </fieldset>
        </div>
        <div v-else style="height:50px; margin: 1em 0;">
            Notice: Please go to <b>Admin Panel → LEAF Programmer</b> to ensure continued access to this area.
        </div>`
}