export default {
    data() {
        return {
            initialFocusElID: 'formPacket',
            files: null,
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'closeFormDialog',
        'selectNewCategory'
    ],
    mounted() {
        document.getElementById(this.initialFocusElID).focus();
    },
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
                        if(res===true) { //NOTE: false if there were issues, newCatID on success would be better
                            console.log('form import success');
                        } else {
                            console.log(res);
                        }
                        this.closeFormDialog();
                        this.selectNewCategory(null);
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
            <div id="file_control" style="margin-bottom: 1em;">
                <p>Select LEAF Form Packet to import:</p>
                <input id="formPacket" name="formPacket" type="file" @change="attachForm"/>
            </div>`
}