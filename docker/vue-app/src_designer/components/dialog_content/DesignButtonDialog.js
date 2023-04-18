export default {
    name: 'design-button-dialog',
    data() {
        return {
            buttonTitleTrumbowyg: '',
            buttonDescriptionTrumbowyg: '',
        }
    },
    mounted() {
        this.useTrumbowEditor();
    },
    methods: {
        useTrumbowEditor() {
            $('#menu_title_trumbowyg').trumbowyg({
                resetCss: true,
                btns: ['formatting', 'bold', 'italic', 'underline', '|',
                    'unorderedList', 'orderedList', '|',
                    'link', '|',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('#menu_description_trumbowyg').trumbowyg({
                resetCss: true,
                btns: ['formatting', 'bold', 'italic', 'underline', '|',
                    'unorderedList', 'orderedList', '|',
                    'link', '|',
                    'justifyLeft', 'justifyCenter', 'justifyRight']
            });
            $('.trumbowyg-box').css({
                'min-height': '130px',
                'max-width': '700px',
                'margin': '0.5rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '100px',
                'height': '100px',
                'padding': '1rem'
            });
        },
        updateTitleText() {
            const elTrumbow = document.querySelector('#menu_title_trumbowyg.trumbowyg-editor');
            if(elTrumbow !== undefined && elTrumbow !== null){
                this.buttonTitleTrumbowyg = elTrumbow.innerHTML;
            }
        },
        updateDescriptionText() {
            const elTrumbow = document.querySelector('#menu_description_trumbowyg.trumbowyg-editor');
            if(elTrumbow !== undefined && elTrumbow !== null){
                this.buttonDescriptionTrumbowyg = elTrumbow.innerHTML;
            }
        },
        testing() {
            console.log('testing called')
        },
        onSave() {
            console.log('modal save')
        }
    },
    template: `<div>
        <p>Button Title</p>
        <div id="menu_title_trumbowyg" @input="updateTitleText"></div>
        <p>Button Description</p>
        <div id="menu_description_trumbowyg" @input="updateDescriptionText"></div>
        <p style="margin-top: 1rem;">Button Preview</p>
        <div>
            <div v-html="buttonTitleTrumbowyg"></div>
            <div v-html="buttonDescriptionTrumbowyg"></div>
        </div>
    </div>`
}