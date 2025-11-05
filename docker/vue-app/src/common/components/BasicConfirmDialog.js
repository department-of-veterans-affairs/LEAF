export default {
    name: 'basic-confirm-dialog',
    inject: [
        'dialogData',
    ],
    data() {
        return {
            confirmMessage: this.dialogData,
        }
    },
    template: `<div id="basic_confirm_dialog" v-html="confirmMessage"></div>`
}