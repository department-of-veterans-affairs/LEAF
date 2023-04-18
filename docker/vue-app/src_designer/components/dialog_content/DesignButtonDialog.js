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
                'min-height': '75px',
                'height': 'auto',
                'max-width': '700px',
                'margin': '0.5rem 0'
            });
            $('.trumbowyg-editor, .trumbowyg-texteditor').css({
                'min-height': '50px',
                'height': 'auto',
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
        <div id="menu_title_trumbowyg_label">Button Title</div>
        <div id="menu_title_trumbowyg" aria-labelledby="menu_title_trumbowyg_label"
            @input="updateTitleText"></div>
        <div id="menu_description_trumbowyg_label">Button Description</div>
        <div id="menu_description_trumbowyg" aria-labelledby="menu_description_trumbowyg_label"
            @input="updateDescriptionText"></div>
        <p style="margin-top: 1rem;">Button Preview</p>
        <div>
            <div v-html="buttonTitleTrumbowyg"></div>
            <div v-html="buttonDescriptionTrumbowyg"></div>
        </div>
    </div>`
}