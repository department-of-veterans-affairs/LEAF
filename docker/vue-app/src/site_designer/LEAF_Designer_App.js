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
            designData: {},
            customizableTemplates: ['homepage'],
            views: ['homepage', 'testview'], //NOTE: anticipate more templates, keeping for testing
            custom_page_select: 'homepage',
            appIsGettingData: true,
            appIsPublishing: false,
            isEditingMode: true,

            iconList: [],
            tagsToRemove: ['script', 'img', 'a', 'link', 'br'],

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
            getDesignData: this.getDesignData,
            tagsToRemove: this.tagsToRemove,
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
    },
    methods: {
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
        },
        setCustom_page_select(view = 'homepage') {
            this.custom_page_select = view;
        },
        getIconList() {
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}iconPicker/list`,
                success: (res) => this.iconList = res || [],
                error: (err) => console.log(err)
            });
        },
        toggleEnableTemplate(templateName = '') {
            if(this.customizableTemplates.includes(templateName)) {
                const enabled = this.designData[`${templateName}_enabled`];
                const flag = enabled === undefined || parseInt(enabled) === 0 ? 1 : 0;
                this.appIsPublishing = true;
                $.ajax({
                    type: 'POST',
                    url: `${this.APIroot}site/settings/enable_${templateName}`,
                    data: {
                        CSRFToken: this.CSRFToken,
                        enabled: flag
                    },
                    success: (res) => {
                        if(+res?.code !== 1) {
                            console.log('unexpected response returned:', res)
                        } else {
                            this.designData[`${templateName}_enabled`] = flag;
                        }
                        this.appIsPublishing = false;
                    },
                    error: (err) => console.log(err)
                });
            }
        },
        getDesignData() {
            this.appIsGettingData = true;
            $.ajax({
                type: 'GET',
                url: `${this.APIroot}system/settings`,
                success: (res) => {
                    this.designData = res;
                    this.appIsGettingData = false;
                },
                error: (err) => {
                    console.log(err);
                }
            });
        },
        updateLocalDesignData(templateName = '', json = '{}') {
            this.designData[`${templateName}_design_json`] = json;
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