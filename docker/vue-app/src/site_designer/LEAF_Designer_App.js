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
            allDesignData: null,
            designSettings: null,
            customizableViews: ['homepage'], //each is a router view  'testpage'
            currentDesignID: null,
            currentDesignName: null,

            appIsGettingData: true,
            appIsUpdating: false,
            isEditingMode: true,
            iconList: [],

            /* basic modal properties */
            dialogTitle: "",
            dialogFormContent: "",
            dialogButtonText: {confirm: 'Save', cancel: 'Cancel'},
            formSaveFunction: '',
            showFormDialog: false
        }
    },
    provide() {
        return {
            iconList: computed(() => this.iconList),
            appIsGettingData: computed(() => this.appIsGettingData),
            appIsUpdating: computed(() => this.appIsUpdating),
            isEditingMode: computed(() => this.isEditingMode),
            currentViewEnabledDesignID: computed(() => this.currentViewEnabledDesignID),
            currentView: computed(() => this.currentView),
            currentViewDesigns: computed(() => this.currentViewDesigns),
            currentDesignID: computed(() => this.currentDesignID),
            selectedDesign: computed(() => this.selectedDesign),

            //static
            CSRFToken: this.CSRFToken,
            APIroot: this.APIroot,
            rootPath: this.rootPath,
            libsPath: this.libsPath,
            orgchartPath: this.orgchartPath,
            userID: this.userID,
            truncateText: this.truncateText,
            publishTemplate: this.publishTemplate,
            newDesign: this.newDesign,
            deleteDesign: this.deleteDesign,
            postDesignContent: this.postDesignContent,
            generateID: this.generateID,
            openDesignCardDialog: this.openDesignCardDialog,
            openHistoryDialog: this.openHistoryDialog,

            /** dialog  */
            closeFormDialog: this.closeFormDialog,
            setDialogTitleHTML: this.setDialogTitleHTML,
            setDialogButtonText: this.setDialogButtonText,
            setDialogContent: this.setDialogContent,
            setDialogSaveFunction: this.setDialogSaveFunction,
            showFormDialog: computed(() => this.showFormDialog),
            dialogTitle: computed(() => this.dialogTitle),
            dialogFormContent: computed(() => this.dialogFormContent),
            dialogButtonText: computed(() => this.dialogButtonText),
            formSaveFunction: computed(() => this.formSaveFunction)
        }
    },
    created() {
        this.getIconList();
        this.getDesignData();
    },
    computed: {
        currentView() {
            return this.$route.name;
        },
        currentViewDesigns() {
            let viewDesigns = (this.allDesignData || []).filter(d => d.templateName === this.currentView);
            return viewDesigns.sort((a,b) => a.designID - b.designID);
        },
        selectedDesign() {
            return (this.currentViewDesigns|| []).find(d => +d.designID === +this.currentDesignID) || null;
        },
        selectedMenuValid() {
            const contentJSON = this.selectedDesign?.designContent || '{}';
            const data = JSON.parse(contentJSON);
            const cards = data?.menu?.menuCards || [];
            const enabledCards = cards.filter(c => +c.enabled === 1 && c.link !== '')
            return enabledCards.length > 0;
        },
        enabled() {
            return this.currentDesignID !== 0 && parseInt(this.designSettings?.[`${this.currentView}_enabled`] || 0) === this.currentDesignID;
        },
        currentViewEnabledDesignID() {
            return this.designSettings === null ? null : +this.designSettings[`${this.currentView}_enabled`];
        }
    },
    methods: {
        truncateText(str = '', maxlength = 40, overflow = '...') {
            return str.length <= maxlength ? str : str.slice(0, maxlength) + overflow;
        },
        setView(event) {
            this.$router.push({ name: event.target.value });
        },
        showLastUpdate(elementID = '') {
            const lastUpdated = new Date().toLocaleString();
            const el = document.getElementById(elementID);
            if(el !== null) {
                el.innerText = `last modified: ${lastUpdated}`;
                el.style.display = 'flex';
                el.style.border = '2px solid #20a0f0';
                setTimeout(() => {
                    el.style.border = '2px solid transparent';
                }, 750);
            }
        },
        generateID(arrList = [], keyName = 'id') {
            let result = '';
            do {
                const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
                for (let i = 0; i < 5; i++ ) {
                   result += characters.charAt(Math.floor(Math.random() * characters.length));
                }
            } while (this.idExistsInList(arrList, keyName, result));
            return result;
        },
        idExistsInList(arrItems = [], keyName = 'id', ID = '') {
            return arrItems.some(i => i?.[keyName] === ID);
        },
        setEditMode(isEditMode = true) {
            this.isEditingMode = isEditMode;
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
        /**
         * @param {string} inputJSON
         * @param {string} section of page being updated
         */
        async postDesignContent(inputJSON = '{}', section = '') {
            this.appIsUpdating = true;
            try {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('inputJSON', inputJSON);
                formData.append('templateName', this.currentView);

                const designID = this.currentDesignID;
                const response = await fetch(`${this.APIroot}design/${designID}/content`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                if(+data?.status?.code === 2) {
                    this.allDesignData.find(rec => +rec.designID === +designID).designContent = inputJSON;

                    switch(section) {
                        case 'menuCardList':
                        case 'menuDirection':
                            this.showLastUpdate('custom_menu_last_update');
                            break;
                        case 'searchHeaders':
                            this.showLastUpdate('custom_search_last_update');
                        default:
                            this.showLastUpdate(`custom_${section}_last_update`);
                        break;
                    }

                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        /**
         * @param {boolean} confirmed
         */
        async publishTemplate(confirmed = false) {
            const templateName = this.currentView;
            if(this.customizableViews.includes(templateName) && this.currentDesignID > 0) {
                if (confirmed === true) {
                    this.appIsUpdating = true;
                    try {
                        const newID = this.currentDesignID === this.currentViewEnabledDesignID ?
                            0 : this.currentDesignID;
                        const curID = this.currentViewEnabledDesignID || 0;

                        let formData = new FormData();
                        formData.append('CSRFToken', this.CSRFToken);
                        formData.append('designID', newID);
                        formData.append('currentEnabledID', curID);
                        formData.append('templateName', templateName);

                        const response = await fetch(`${this.APIroot}design/publish`, {
                            method: 'POST',
                            body: formData
                        });
                        const data = await response.json();
                        if(+data?.status?.code === 2) {
                            this.designSettings[`${templateName}_enabled`] = newID;
                        } else {
                            console.log('unexpected response returned:', data);
                        }

                    } catch (error) {
                        console.log(error);
                    } finally {
                        this.appIsUpdating = false;
                    }

                } else {
                    this.openConfirmPublishDialog();
                }

            } else {
                console.log('this page cannot be published');
            }
        },
        async getDesignData() {
            this.appIsGettingData = true;
            try {
                const settingResponse = await fetch(`${this.APIroot}system/settings`);
                const settings = await settingResponse.json();
                this.designSettings = {};
                this.customizableViews.forEach(t => {
                    this.designSettings[`${t}_enabled`] = +settings[`${t}_enabled`] || 0;
                })

                const designResponse = await fetch(`${this.APIroot}design/designList`);
                this.allDesignData = await designResponse.json();

            } catch (error) {
                console.error(`error getting settings: ${error.message}`);
            } finally {
                this.appIsGettingData = false;
            }
        },
        async updateDesignName() {
            this.appIsUpdating = true;
            const designID = this.currentDesignID;
            const name = this.currentDesignName;

            try {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('designName', name);

                const response = await fetch(`${this.APIroot}design/${designID}/name`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();

                if(+data?.status?.code === 2 && Number.isInteger(data?.data)) {
                    this.allDesignData.find(rec => +rec.designID === +designID).designName = this.currentDesignName;

                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        async newDesign(designName = '') {
            this.appIsUpdating = true;
            try {
                let formData = new FormData();
                formData.append('CSRFToken', this.CSRFToken);
                formData.append('templateName', this.currentView);
                formData.append('designName', designName);

                const response = await fetch(`${this.APIroot}design/new`, {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                if(+data?.status?.code === 2 && Number.isInteger(data?.data)) {
                    this.allDesignData.push({
                        designID: data.data,
                        templateName: this.currentView,
                        designName: designName,
                        designContent: '{}'
                    });
                    this.currentDesignID = data.data;
                    this.isEditingMode = true;
                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        async deleteDesign(id = 0, templateName = '') {
            this.appIsUpdating = true;
            try {
                const response = await fetch(`${this.APIroot}design/delete/${id}/_${templateName}?CSRFToken=${this.CSRFToken}`, {
                    method: 'DELETE',
                });
                const data = await response.json();
                if(+data?.status?.code === 2) {
                    this.currentDesignID = 0;
                    this.allDesignData = this.allDesignData.filter(d => +d.designID !== +id);
                    this.isEditingMode = true;
                } else {
                    console.log('unexpected response returned:', data);
                }

            } catch (error) {
                console.log(error);
            } finally {
                this.appIsUpdating = false;
            }
        },
        openNewDesignDialog() {
            this.setDialogTitleHTML(`<h2>Creating a new item for the ${this.currentView}</h2>`);
            this.setDialogContent('new-design-dialog');
            this.showFormDialog = true;
        },
        openDeleteDesignDialog() {
            this.setDialogTitleHTML(`<h2>Please Confirm</h2>`);
            this.dialogButtonText = { confirm: 'Delete', cancel: 'Cancel'};
            this.setDialogContent('confirm-delete-dialog');
            this.showFormDialog = true;
        },
        openConfirmPublishDialog() {
            this.setDialogTitleHTML('<h2>Please Confirm</h2>');
            this.dialogButtonText = { confirm: 'Confirm', cancel: 'Cancel'};
            this.setDialogContent('confirm-publish-dialog');
            this.showFormDialog = true;
        },
        openDesignCardDialog() {
            this.setDialogTitleHTML('<h2>Menu Editor</h2>');
            this.setDialogContent('design-card-dialog');
            this.showFormDialog = true;
        },
        openHistoryDialog() {
            this.setDialogTitleHTML(`<h2>Showing ${this.currentView} History</h2>`);
            this.setDialogContent('history-dialog');
            this.showFormDialog = true;
        },

        /** basic modal methods.  Use a component name to set the dialog's content.
        /** Components must be registered to the component containing the dialog */
        closeFormDialog() {
            this.showFormDialog = false;
            this.dialogTitle = '';
            this.dialogFormContent = '';
            this.dialogButtonText = {confirm: 'Save', cancel: 'Cancel'};
            this.formSaveFunction = '';
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
        //if the view is changed, or on initial data retrieval, set the designID to the one published for the view or 0 if there isn't one
        currentView(newVal, oldVal) {
            if(this.customizableViews.includes(newVal)) {
                this.currentDesignID = this.currentViewEnabledDesignID || 0;
            }
        },
        designSettings(newVal, oldVal) {
            if(oldVal === null) {
                this.currentDesignID = this.currentViewEnabledDesignID || 0;
            }
        },
        selectedDesign(newVal, oldVal) {
            this.currentDesignName = this.selectedDesign === null ? null : this.selectedDesign.designName;
        },
        currentDesignName(newVal, oldVal) {
            if(newVal !== null && newVal !== this.selectedDesign?.designName) {
                this.updateDesignName();
            }
        }
    }
}