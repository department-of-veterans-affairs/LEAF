export default {
    data() {
        return {
            initialFocusElID: 'TODO:',
            left: '{{',
            right: '}}',
            formID: this.currSubformID || this.currCategoryID,
            codeEditorHtml: {},
            codeEditorHtmlPrint: {},
            html: this.ajaxIndicatorByID[this.currIndicatorID].html === null ? '' : this.ajaxIndicatorByID[this.currIndicatorID].html,
            htmlPrint: this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint === null ? '' : this.ajaxIndicatorByID[this.currIndicatorID].htmlPrint
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'closeFormDialog',
        'currCategoryID',
        'currSubformID',
        'currIndicatorID',
        'ajaxIndicatorByID',
        'selectNewCategory',
        'hasDevConsoleAccess',
        'selectedNodeIndicatorID'
    ],
    mounted(){
        console.log('Advanced Options mounted', this.currIndicatorID, this.formID);
        if(parseInt(this.hasDevConsoleAccess)===1) {
            this.setupAdvancedOptions();
        }
    },
    methods: {
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
        /* via save code buttons in the modal */
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
                    document.getElementById('codeSaveStatus_html').innerHTML = '<br /> Last saved: ' + time;
                    this.selectNewCategory(this.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);
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
                    document.getElementById('codeSaveStatus_htmlPrint').innerHTML ='<br /> Last saved: ' + time;
                    this.selectNewCategory(this.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);
                },
                error: (err) => console.log(err)
            });
        },
        /* on save button of base modal */
        onSave(){
            console.log('clicked advanced options save');
            let advancedOptionsUpdates = [];
            const htmlChanged = this.html !== this.codeEditorHtml.getValue();
            const htmlPrintChanged = this.htmlPrint !== this.codeEditorHtmlPrint.getValue();
            console.log('dHTML, dHTMLP', htmlChanged,htmlPrintChanged);

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
                console.log('promise all:', advancedOptionsUpdates, res);
                this.closeFormDialog();
                if (res.length > 0) {
                    this.selectNewCategory(this.formID, this.currSubformID !== null, this.selectedNodeIndicatorID);
                }
            });
        }
    },
    template: `<div v-if="parseInt(hasDevConsoleAccess)===1">
            <fieldset id="advanced" style="min-width: 700px; padding: 0.5em; margin:0"><legend>Template Variables and Controls</legend>
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
                <div style="display:flex; justify-content: space-between;">
                    html (for pages where the user can edit data): 
                    <button id="btn_codeSave_html" @click="saveCodeHTML" class="buttonNorm" title="Save Code">
                        <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                        Save Code<span id="codeSaveStatus_html"></span>
                    </button>
                </div>
                <textarea id="html">{{html}}</textarea><br />  <!-- NOTE: can't seem to v-model these areas html and htmlPrint properties updated after save -->
                <div style="display:flex; justify-content: space-between;">
                    htmlPrint (for pages where the user can only read data): 
                    <button id="btn_codeSave_htmlPrint" @click="saveCodeHTMLPrint" class="buttonNorm" title="Save Code">
                        <img id="saveIndicator" src="../../libs/dynicons/?img=media-floppy.svg&w=16" alt="Save" />
                        Save Code<span id="codeSaveStatus_htmlPrint"></span>
                    </button>
                </div>
                <textarea id="htmlPrint">{{htmlPrint}}</textarea>
            </fieldset>
        </div>
        <div v-else style="height:50px; margin: 1em 0;">
            Notice: Please go to <b>Admin Panel → LEAF Programmer</b> to ensure continued access to this area.
        </div>`
}