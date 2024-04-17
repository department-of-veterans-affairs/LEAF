export default {
    name: 'import-form-dialog',
    data() {
        return {
            initialFocusElID: 'formPacket',
            files: null,
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
                        if(+res !== 1) {
                            alert(res);
                        }
                        this.closeFormDialog();
                        this.$emit('import-form');
                        //TODO: update return val to ID of imported form - might be more ideal to route to FE view
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
                <input id="formPacket" name="formPacket" type="file" @change="attachForm"/>
            </div>`
}