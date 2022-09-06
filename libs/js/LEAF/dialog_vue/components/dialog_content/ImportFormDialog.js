export default {
    data() {
        return {
            isImportingForm: false,
            files: '',
        }
    },
    inject: [
        'APIroot',
        'CSRFToken',
        'closeFormDialog'
    ],
    methods: {
        onSave() {
            console.log('files bf ajax call', this.files);
            
            $.ajax({
                type: 'POST',
                url: `${this.APIroot}formStack/import`,
                data: {
                    formPacket: this.files,
                    CSRFToken: this.CSRFToken
                },
                success: (res) => {
                    console.log(res);
                    if(res===true){
                        console.log('form import success');
                    } //TODO: close dialog
                },
                error: err => console.log('form import error', err),
                processData: false,
                contentType: false
            })
        },
        attachForm(e) {
            console.log(e.target.value)
            const files = e.target.files || e.dataTransfer.files;
            if(files.length > 0) {
                this.files = files;
            }
        },
        removeFile() {
            this.files = '';
        }
    },
    template: `<div class="leaf-center-content">
            <div v-show="!isImportingForm" id="file_control" style="margin-bottom: 1em;">
                <p>Select LEAF Form Packet to import:</p>
                <input id="formPacket" name="formPacket" type="file" @change="attachForm"/>
            </div>
            <div v-show="isImportingForm" id="file_status" style="visibility: hidden; display: none; background-color: #fffcae; padding: 4px">
                <img src="../images/indicator.gif" alt="loading..." />
                Importing form...
            </div>
        </div>`
}