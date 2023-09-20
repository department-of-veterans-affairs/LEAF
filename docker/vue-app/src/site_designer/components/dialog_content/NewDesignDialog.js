export default {
    name: 'new-design-dialog',
    data() {
        return {
            designName: this.$props.dialogProps.isCopy === true ?
                this.$props.dialogProps.designName : '',
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
    props: {
        dialogProps: {
            type: Object,
            required: true
        },
    },
    methods:{
        onSave() {
            this.newDesign(this.designName, this.$props.dialogProps.isCopy);
            this.closeFormDialog();
        }
    },
    template:`<div style="min-height: 60px; max-width: 600px;">
        <label for="design_name_input" style="margin: 1rem 0;">Title <span style="font-size:80%"> (up to 50 characters)</span>
            <input id="design_name_input" type="text" maxlength="50" v-model="designName" />
        </label>
    </div>`
}