export default {
    inject: [
		'dialogTitle', 
		'dialogFormContent',
		'closeFormDialog'
	],
    template: `
        <div id="genericDialog2" style="border: 1px solid red">
            <div v-html="dialogTitle"></div>
            <div><slot name="dialog-content-slot"></slot></div>
            <div>
                <div id="genericDialogbutton_cancelchange2"></div>
                <div id="genericDialogbutton_save2"></div>
            </div>
        </div>`
};