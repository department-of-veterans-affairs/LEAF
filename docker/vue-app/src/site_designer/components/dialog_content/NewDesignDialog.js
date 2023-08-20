export default {
    name: 'new-design-dialog',
    data() {
        return {
            designName: '',
            designDescription: ''
        }
    },
    mounted() {
        this.setDialogSaveFunction(this.onSave);
    },
    inject: [
        'closeFormDialog',
        'setDialogSaveFunction',

        'currentView',
        'newDesign'
    ],
    methods:{
        onSave() {
            this.newDesign(this.designName, this.designDescription);
            this.closeFormDialog();
        }
    },
    template:`<div style="min-height: 60px; max-width: 600px;">
        <label for="design_name_input" style="margin: 1rem 0;">Design Name <span style="font-size:80%"> (up to 100 characters)</span>
            <input id="design_name_input" type="text" maxlength="100" v-model="designName" />
        </label>
        <label for="design_description_input">Short Description <span style="font-size:80%"> (up to 255 characters)</span>
            <textarea rows="4" v-model="designDescription" maxlength="255"></textarea>
        </label>
    </div>`
}