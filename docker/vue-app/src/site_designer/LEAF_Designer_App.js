import { computed } from 'vue';

import './LEAF_Designer.scss';

export default {
    data() {
        return {
            CSRFToken: CSRFToken,
            APIroot: APIroot,
            rootPath: '../',
            libsPath: libsPath,
            orgchartPath: orgchartPath,
            userID: userID,
            designData: null,
            customizableTemplates: ['homepage'],
            views: ['homepage', 'testview'], //NOTE: anticipate more templates, keeping for testing
            custom_page_select: 'homepage',
            appIsGettingData: true,
            appIsPublishing: false,
            isEditingMode: true,
            iconList: [],

            /* basic modal properties */
            dialogTitle: "",
            dialogFormContent: "",
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            formSaveFunction: '',
            showFormDialog: false,
        }
    },
    provide() {
        return {
            iconList: computed(() => this.iconList),
            appIsGettingData: computed(() => this.appIsGettingData),
            appIsPublishing: computed(() => this.appIsPublishing),
            isEditingMode: computed(() => this.isEditingMode),
            designData: computed(() => this.designData),

            //static
            CSRFToken: this.CSRFToken,
            APIroot: this.APIroot,
            rootPath: this.rootPath,
            libsPath: this.libsPath,
            orgchartPath: this.orgchartPath,
            userID: this.userID,
            setCustom_page_select: this.setCustom_page_select,
            toggleEnableTemplate: this.toggleEnableTemplate,
            updateLocalDesignData: this.updateLocalDesignData,
            /** dialog  */
            openDialog: this.openDialog,
            closeFormDialog: this.closeFormDialog,
            setDialogTitleHTML: this.setDialogTitleHTML,
            setDialogButtonText: this.setDialogButtonText,
            setDialogContent: this.setDialogContent,
            setDialogSaveFunction: this.setDialogSaveFunction,
            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            formSaveFunction: computed(() => this.formSaveFunction),
        }
    },
    created() {
        this.getIconList();
        this.getDesignData();
    },
    methods: {
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
        },
        setCustom_page_select(view = 'homepage') {
            this.custom_page_select = view;
        },
        async getIconList() {
            try {
                const response = await fetch(`${this.APIroot}iconPicker/list`);
                const data = await response.json();
                this.iconList = data || [];
            } catch (error) {
                console.error(`error getting icons: ${error.message}`);
            }
        },
        async toggleEnableTemplate(templateName = '') {
            if(this.customizableTemplates.includes(templateName)) {
                /*NOTE: 'enabled' will be updated to be its own design table field for each design section.
                site settings table will keep an overall 'nocode enabled' 1/0 setting indicating whether any designs are enabled */
                const enabled = this.designData[`${templateName}_enabled`];
                const flag = enabled === undefined || parseInt(enabled) === 0 ? 1 : 0;
                this.appIsPublishing = true;

                try {
                    let formData = new FormData();
                    formData.append('CSRFToken', CSRFToken);
                    formData.append('enabled', flag);
                    const response = await fetch(`${this.APIroot}site/settings/enable_${templateName}`, {
                        method: 'POST',
                        body: formData
                    });
                    const data = await response.json();
                    if(+data?.code === 1) {
                        this.designData[`${templateName}_enabled`] = flag;
                    } else {
                        console.log('unexpected response returned:', data)
                    }

                } catch (error) {
                    console.log(error);
                } finally {
                    this.appIsPublishing = false;
                }
            }
        },
        async getDesignData() {
            this.appIsGettingData = true;
            try {
                //NOTE: currently in settings table, so this is getting all settings
                const response = await fetch(`${this.APIroot}system/settings`);
                const data = await response.json();
                this.designData = data;
            } catch (error) {
                console.error(`error getting settings: ${error.message}`);
            } finally {
                this.appIsGettingData = false;
            }
        },
        /**
         * 
         * @param {string} section template name being updated
         * @param {string} json the new json value after successful post
         */
        updateLocalDesignData(section = '', json = '{}') {
            this.designData[`${section}_design_json`] = json;
        },

        /** basic modal methods.  Use a component name to set the dialog's content.
        /** Components must be registered to the component containing the dialog */
        openDialog() {
            this.showFormDialog = true;
        },
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
        },
        setDialogTitleHTML(titleHTML = '') {
            this.dialogTitle = titleHTML;
        },
        setDialogButtonText({ confirm = '', cancel = '' } = {}) {
            this.dialogButtonText = { confirm, cancel };
        },
        setDialogContent(component = '') {
            this.dialogFormContent = component;
        },
        setDialogSaveFunction(func = '') {
            if (typeof func === 'function') {
                this.formSaveFunction = func;
            }
        },
    },
    watch: {
        custom_page_select(newVal, oldVal) {
            if(this.views.includes(newVal)) {
                this.$router.push({name: this.custom_page_select});
            }
        }
    }
}