export default {
    name: 'import-form-dialog',
    data() {
        return {
            initialFocusElID: 'formPacket',
            files: null,
            userMessage: '',
            inputStyles: {
                padding: "1.25rem 0.5rem",
                border: "1px solid #cadff0",
                borderRadius: "2px",
                backgroundColor: "#f2f2f8",
            }
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'setDialogSaveFunction',
        'closeFormDialog'
    ],
    created() {
        this.setDialogSaveFunction(this.onSave);
    },
    mounted() {
        document.getElementById(this.initialFocusElID).focus();
    },
    emits: ['import-form'],
    methods: {
        onSave() {
            if (this.files !== null) {
                this.userMessage = "Form is being imported ...";
                let pkg = new FormData();
                pkg.append('formPacket', this.files[0]);
                pkg.append('CSRFToken', this.CSRFToken);
                
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}formStack/import`,
                    processData: false,
                    contentType: false,
                    cache: false,
                    data: pkg,
                    success: (res) => {
                        const formReg = /^form_[0-9a-f]{5}$/i;
                        if(formReg.test(res) !== true) {
                            alert(res);
                        }
                        this.closeFormDialog();
                        this.$emit('import-form', res);
                    },
                    error: err => console.log('form import error', err),
                })

            } else {
                console.log('no attachment');
            }
        },
        attachForm(e = {}) {
            const files = e.target?.files || e.dataTransfer?.files;
            if(files?.length > 0) {
                this.files = files;
            }
        }
    },
    template: `
            <div id="file_control" style="margin: 1em 0; min-height: 50px;">
                <label for="formPacket">Select LEAF Form Packet to import:</label>
                <input id="formPacket" name="formPacket" type="file" @change="attachForm" :style=inputStyles />
                <div v-if="userMessage" style="padding: 0.5rem 0"><b>{{ userMessage }}</b></div>
            </div>`
}