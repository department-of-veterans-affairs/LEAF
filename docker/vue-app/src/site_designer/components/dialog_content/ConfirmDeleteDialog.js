export default {
    name: 'confirm-delete-dialog',
    mounted() {
        document.getElementById('button_save').style.backgroundColor = '#AA0000';
        document.getElementById('button_save').style.border = '2px solid #000000';
        this.setDialogSaveFunction(this.onSave);
    },
    inject: [
        'closeFormDialog',
        'setDialogSaveFunction',

        'selectedDesign',
        'currentView',
        'deleteDesign'
    ],
    methods:{
        onSave() {
            this.deleteDesign(this.selectedDesign.designID, this.currentView);
            this.closeFormDialog();
        }
    },
    template:`<div style="min-height: 60px; max-width: 500px;">
        <div role="img" aria="" style="display: flex; justify-content: center; margin-bottom: 0.5rem;">⚠️</div>
        <div>Please confirm deletion of {{selectedDesign.designName}}(#{{selectedDesign.designID}})</div>  
    </div>`
}